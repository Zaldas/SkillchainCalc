-- Addon: SkillchainCalc
-- Description: Calculates all possible skillchain combinations using skills.lua data.

addon.name      = 'SkillchainCalc';
addon.author    = 'Zalyx';
addon.version   = '2.4';
addon.desc      = 'Skillchain combination calculator';
addon.link      = 'https://github.com/Zaldas/SkillchainCalc';

require('common');
require('imgui_compat');

local SkillchainCore     = require('SkillchainCore');
local SkillchainRenderer = require('SkillchainRenderer');
local SkillchainGUI      = require('SkillchainGui');
local gdi                = require('gdifonts.include');
local settings           = require('settings');

local debugMode = false; -- Debug mode flag

-- Soft cap configuration: minimum results to show after a header before allowing column split
-- This prevents columns with just a header and 1-4 results
local minResultsAfterHeader = 8;

local sccSettings = T{
    font = {
        font_family = 'Arial',
        font_height = 16,
        font_color = 0xFFAFAFAF,
        outline_color = 0xFF000000,
        outline_width = 1,
    },
    title_font = {
        font_family = 'Times New Roman',
        font_height = 28,
        font_color = 0xFFC1A100,
        outline_color = 0xFF48494B,
        outline_width = 1,
    },
    bg = {
        corner_rounding = 5,
        fill_color = 0xBF000000,
        outline_color = 0xFFFFFFFF,
        gradient_style = gdi.Gradient.TopToBottom,
        gradient_color = 0x59010640,
        z_order = -1,
    },
    anchor = {
        x = 200,
        y = 100,
    },
    layout = {
        columnWidth = 315,
        entriesPerColumn = 30,      -- Soft cap: try to split at this point
        softOverflow = 8,           -- Allow up to 8 extra entries before hard cap
        entriesHeight = 20,
    },
    default = {
        scLevel = 1,
        both = false,
        includeSubjob = false,
        useCharLevel = false,
        enableFavWs = false
    },
};

-- CACHE: Stores the last skillchain calculation that was performed.
-- This represents "what results are currently displayed on screen".
-- Used for CLI mode and keeping results open when GUI closes.
local cache = {
    -- Job tokens and weaponskill filters for the displayed results
    jobs = {
        token1 = nil,  -- e.g., "nin/war:katana,dagger"
        token2 = nil,  -- e.g., "sam:gkt"
        favWs1 = nil,  -- Favorite WS name for filtering (or nil)
        favWs2 = nil,  -- Favorite WS name for filtering (or nil)
    },

    -- Filter settings that were applied to displayed results
    filters = {
        scLevel = 1,           -- Skillchain level filter (1-3)
        both = false,          -- Calculate both directions
        scElement = nil,       -- Element filter (e.g., "ice")
        includeSubjob = false, -- Whether subjob filtering was enabled
        charLevel = nil,       -- Character level for skill caps (or nil for max)
    },

    -- Step mode configuration (property → WS calculations)
    step = {
        enabled = false,
        filter = nil,      -- tier number (1-4) or property name
        filterType = nil,  -- "tier" or "property"
    },

    -- Application settings and state
    settings = sccSettings,
    keepResultsOpen = false,  -- When true, results stay open even if GUI closes
};

local function applyDefaultsToCache()
    local def = cache.settings.default or sccSettings.default or {};
    cache.filters.scLevel = def.scLevel or 1;
    cache.filters.both = def.both or false;
    cache.filters.includeSubjob = def.includeSubjob or false;
end

local function resetCacheFull()
    cache.jobs.token1 = nil;
    cache.jobs.token2 = nil;
    cache.jobs.favWs1 = nil;
    cache.jobs.favWs2 = nil;
    cache.filters.scElement = nil;
    cache.step.enabled = false;
    cache.step.filter = nil;
    cache.step.filterType = nil;
    cache.keepResultsOpen = false;
    applyDefaultsToCache();
end

local function renderResults(skillchains)
    local resultsTable = SkillchainCore.BuildSkillchainTable(skillchains);
    local sortedResults, orderedResults = SkillchainCore.SortSkillchainTable(resultsTable, debugMode);

    SkillchainRenderer.render(sortedResults, orderedResults, cache.settings, cache.filters.both, minResultsAfterHeader);
end

-- Event handler for addon loading
ashita.events.register('load', 'load_cb', function()
    cache.settings = settings.load(sccSettings);
    applyDefaultsToCache();
    SkillchainGUI.SetCache(cache);
    SkillchainRenderer.initialize(gdi, cache.settings);

    settings.register('settings', 'settings_update', function(s)
        if (s ~= nil) then
            SkillchainRenderer.destroy();
            cache.settings = s;
            applyDefaultsToCache();
            SkillchainRenderer.initialize(gdi, cache.settings);
        end
    end)
end);

local function displaySkillchainResults(combinations, label)
    if not combinations then
        SkillchainRenderer.clear();
        return;
    end

    -- Apply all filters in a single pass
    local filteredCombinations = SkillchainCore.FilterSkillchains(combinations, {
        scLevel = cache.filters.scLevel,
        scElement = cache.filters.scElement,
        favWs1 = cache.jobs.favWs1,
        favWs2 = cache.jobs.favWs2
    });

    if (#filteredCombinations > 0) then
        SkillchainRenderer.clear();
        renderResults(filteredCombinations);
    else
        local suffix = label and (' ' .. label) or '';
        print(('[SkillchainCalc] No%s skillchain combinations found for filter level %d.'):format(suffix, cache.filters.scLevel));
        SkillchainRenderer.clear();
    end
end

local function parseSkillchains(isStep)
    if isStep then
        if (not cache.jobs.token1) then
            return;
        end

        local wsList = SkillchainCore.ResolveTokenToSkills(cache.jobs.token1, nil, cache.filters.charLevel);
        if (not wsList) then
            print('[SkillchainCalc] Invalid weapon/job token for step mode: ' .. tostring(cache.jobs.token1));
            SkillchainRenderer.clear();
            return;
        end

        local combinations = SkillchainCore.CalculateStepSkillchains(wsList, cache.step.filter, cache.step.filterType);

        -- Check if filtering resulted in no combinations (possibly invalid property name)
        if cache.step.filterType == 'property' and #combinations == 0 then
            print('[SkillchainCalc] Error: Invalid property name "' .. tostring(cache.step.filter) .. '".');
            print('[SkillchainCalc] Valid properties: Compression, Detonation, Distortion, Fragmentation,');
            print('[SkillchainCalc]   Fusion, Gravitation, Impaction, Induration, Liquefaction,');
            print('[SkillchainCalc]   Reverberation, Scission, Transfixion, Light, Darkness');
            SkillchainRenderer.clear();
            return;
        end

        cache.filters.both = false;

        displaySkillchainResults(combinations, 'step');
        return;
    end

    if (not cache.jobs.token1 or not cache.jobs.token2) then
        return;
    end

    local skills1 = SkillchainCore.ResolveTokenToSkills(cache.jobs.token1, nil, cache.filters.charLevel);
    local skills2 = SkillchainCore.ResolveTokenToSkills(cache.jobs.token2, nil, cache.filters.charLevel);

    if (not skills1 or not skills2) then
        print('[SkillchainCalc] Invalid weapon/job token(s): ' ..
            tostring(cache.jobs.token1) .. ', ' .. tostring(cache.jobs.token2));
        SkillchainRenderer.clear();
        return;
    end

    local combinations = SkillchainCore.CalculateSkillchains(skills1, skills2, cache.filters.both);

    displaySkillchainResults(combinations);
end

-- Draw IMGUI Input Window
ashita.events.register('d3d_present', 'scc_present_cb', function()
    if (SkillchainGUI ~= nil and SkillchainGUI.IsVisible()) then
        local req = SkillchainGUI.DrawWindow();
        if req ~= nil then
            if req.anchorChanged then
                SkillchainRenderer.updateAnchor(cache.settings);
                settings.save();
                -- No need to re-parse skillchains - anchor is visual only
            end

            if req.updateDefaults then
                applyDefaultsToCache();
                settings.save();
                -- Only re-parse if results are currently visible and defaults affect calculation
                -- (scLevel, both, includeSubjob, charLevel, enableFavWs)
                if SkillchainRenderer.isVisible() then
                    parseSkillchains(cache.step.enabled);
                end
            end

            if req.clear then
                SkillchainRenderer.clear();
                resetCacheFull();
                return;
            end

            if req.token1 ~= nil then
                cache.jobs.token1 = req.token1;
                cache.jobs.token2 = req.token2;

                applyDefaultsToCache();
                if req.scLevel ~= nil then
                    cache.filters.scLevel = req.scLevel;
                end
                if req.both ~= nil then
                    cache.filters.both = req.both;
                end

                cache.filters.scElement = req.scElement and req.scElement:lower() or nil;
                cache.filters.charLevel = req.charLevel;
                cache.jobs.favWs1 = req.favWs1;
                cache.jobs.favWs2 = req.favWs2;

                -- GUI-initiated requests are always normal mode (tied to GUI)
                cache.step.enabled = false;
                cache.keepResultsOpen = false;

                parseSkillchains(false);
            end
        end
    else
        -- Only clear renderer if results are not set to stay open
        if not cache.keepResultsOpen then
            SkillchainRenderer.clear();
        end
    end
end);

-- Event handler for commands
ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= '/scc') then
        return;
    end

    e.blocked = true;

    -- Settings-style commands
    local validCommand = false;
    if #args > 2 then
        if (args[2]:any('setx', 'sety')) then
            local value = tonumber(args[3]);
            if value and value >= 0 then
                if (args[2] == 'setx') then
                    cache.settings.anchor.x = value;
                else
                    cache.settings.anchor.y = value;
                end
                SkillchainRenderer.updateAnchor(cache.settings);
                print('New Anchor: x = ' .. cache.settings.anchor.x .. ', y = ' .. cache.settings.anchor.y);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setx or sety. Must be a non-negative number.');
            end
        elseif (args[2] == 'setsclevel') then
            if (args[3]:any('1', '2', '3')) then
                local l = tonumber(args[3]);
                cache.settings.default.scLevel = l;
                applyDefaultsToCache();
                print('[SkillchainCalc] Set default skillchain level: ' .. args[3]);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setsclevel. Must be a 1, 2, or 3.');
            end
        elseif (args[2] == 'setcharlevel') then
            if (args[3]:any('true', 'false')) then
                local b = args[3] == 'true';
                cache.settings.default.useCharLevel = b;
                applyDefaultsToCache();
                print('[SkillchainCalc] Set custom character level filter = ' .. args[3]);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setcharlevel. Must be true or false.');
            end
        elseif (args[2] == 'setboth') then
            if (args[3]:any('true', 'false')) then
                local b = args[3] == 'true';
                cache.settings.default.both = b;
                applyDefaultsToCache();
                print('[SkillchainCalc] Set parameter \'both\' = ' .. args[3]);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setboth. Must be true or false.');
            end
        elseif (args[2] == 'setsubjob') then
            if (args[3]:any('true', 'false')) then
                local s = args[3] == 'true';
                cache.settings.default.includeSubjob = s;
                print('[SkillchainCalc] Set subjob filter default = ' .. args[3]);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setsubjob. Must be true or false.');
            end
        elseif (args[2] == 'setfavws') then
            if (args[3]:any('true', 'false')) then
                local p = args[3] == 'true';
                cache.settings.default.enableFavWs = p;
                print('[SkillchainCalc] Set favorite WS filter default = ' .. args[3]);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setfavws. Must be true or false.');
            end
        end

        if (validCommand) then
            settings.save();
            if (SkillchainRenderer.isVisible()) then
                parseSkillchains(cache.step.enabled);
            end
            return;
        end
    end

    -- 1-arg utility commands
    if (#args == 2) then
        if (args[2] == 'clear') then
            SkillchainRenderer.clear();
            resetCacheFull();

            if (SkillchainGUI ~= nil) then
                SkillchainGUI.SetVisible(false);
            end

            return;
        elseif (args[2] == 'debug') then
            debugMode = not debugMode;
            print('[SkillchainCalc] Debug mode ' .. (debugMode and 'enabled' or 'disabled') .. '.');
            return;
        elseif (args[2] == 'status') then
            print('Status of Default Filter:');
            print(' Skillchain Level: Skillchains Level ' .. cache.settings.default.scLevel .. ' or higher.')
            print(' Calculate Both Direction: ' .. tostring(cache.settings.default.both));
            print(' Include Subjob Filter: ' .. tostring(cache.settings.default.includeSubjob or false));
            print(' Use Character Level: ' .. tostring(cache.settings.default.useCharLevel or false));
            print(' Enable Favorite WS: ' .. tostring(cache.settings.default.enableFavWs or false));
            local poolInfo = SkillchainRenderer.getPoolInfo();
            print(' GDI Pool Size: ' .. poolInfo.poolSize .. ' (last used: ' .. poolInfo.lastUsedCount .. ')');
            return;
        elseif (args[2] == 'help') then
            print('Usage: /scc <token1> <token2> [level] [sc:<element>] [both] [lvl:#]');
            print('Usage: /scc step <token> [level] [sc:<element>] [lvl:#]');
            print(' Tokens can be weapon types, jobs, job:weapon, or job/subjob filters:');
            print('  Weapon Types: h2h, dagger, sword, gs, axe, ga, scythe, polearm,');
            print('                katana, gkt, club, staff, archery, mm, smn');
            print('  Jobs: WAR, MNK, WHM, BLM, RDM, THF, PLD, DRK, BST, BRD, RNG');
            print('        SAM, NIN, DRG, SMN, BLU, COR, DNC, SCH');
            print('  Job+Weapon: thf:sword   (THF, sword WS only)');
            print('              war:ga,polearm (WAR, GA and Polearm WS only)');
            print('  Job+Subjob: nin/war     (NIN main, WAR subjob)');
            print('              nin/war:dagger (NIN/WAR, dagger WS only)');
            print(' [level] optional integer 1-3 that filters skillchain level;');
            print('  e.g. 2 only shows level 2 and 3 skillchains. 1 or empty = all.');
            print(' [sc:<element>] optional filter by SC burst element, e.g. sc:ice, sc:fire');
            print('  e.g. sc:ice shows chains like Darkness / Distortion / Induration.');
            print(' [both] optional keyword to calculate skillchains in both directions.');
            print((' [lvl:#] or [level:#] optional character level 1-%d for skill-based filtering.'):format(SkillchainCore.MAX_LEVEL));
            print('  e.g. lvl:50 or level:50');
            -- print(' Step Mode: Calculate what properties can close with a job/weapon\'s WS.');
            -- print('  e.g. /scc step nin      -- show Property > NIN WS combinations');
            -- print('  e.g. /scc step katana   -- show Property > Katana WS combinations');
            -- print('  e.g. /scc step nin/war:dagger lvl:50 -- NIN/WAR dagger at level 50');
            -- print('  e.g. /scc step lvl:50 sc:ice nin/whm:club -- keywords in any order');
            print('Usage: /scc setx #             -- set x anchor');
            print('Usage: /scc sety #             -- set y anchor');
            print('Usage: /scc setsclevel #       -- set default skillchain level filter');
            print('Usage: /scc setcharlevel true  -- enable/disable custom character level');
            print('Usage: /scc setboth true       -- set default both flag');
            print('Usage: /scc setsubjob true     -- set default subjob filter');
            print('Usage: /scc setfavws true      -- set default favorite WS filter');
            print('Usage: /scc status             -- show current defaults');
            print('Usage: /scc                -- open gui interface');
            return;
        end
    end

    -- Detect step mode early and parse step filter
    local isStep = false;
    local stepFilter = nil;  -- Can be a tier number (1-4) or property name (e.g., "distortion")
    local stepFilterType = nil;  -- "tier" or "property"

    if (#args >= 2 and args[2]:lower():sub(1, 4) == 'step') then
        isStep = true;
        local stepArg = args[2]:lower();

        -- Check if step has a filter: "step:2" or "step:distortion"
        if stepArg:find(':') then
            local colonPos = stepArg:find(':');
            local filterValue = stepArg:sub(colonPos + 1);

            -- Try to parse as a tier number (1-4)
            local tierNum = tonumber(filterValue);
            if tierNum and tierNum >= 1 and tierNum <= 4 then
                stepFilter = tierNum;
                stepFilterType = 'tier';
            else
                -- Treat as property name (e.g., "distortion", "fusion")
                -- Validate it's a valid property name (case-insensitive)
                stepFilter = filterValue;
                stepFilterType = 'property';
            end
        end
    end

    -- Step mode requires at least one token after "step" keyword
    -- Normal mode requires two tokens
    local minArgs = isStep and 3 or 3;
    if (#args < minArgs) then
        if (#args == 1) then
            if SkillchainGUI ~= nil then
                SkillchainGUI.SetVisible(true);
            end
        end
        print('/scc help -- for usage help, or /scc to open GUI');
        return;
    end

    -- Helper to normalize tokens: strip duplicate subjobs and validate format
    -- The core parser already handles this, but we normalize for cleaner cache storage
    local function normalizeToken(token)
        if not token or type(token) ~= 'string' then
            return token;
        end

        -- Parse and rebuild using core logic for consistency
        local jobId, allowedWeapons, subJobId = SkillchainCore.GetJobAndWeaponsFromToken(token);
        if jobId then
            return SkillchainCore.BuildTokenFromSelection(jobId, allowedWeapons, subJobId);
        end

        -- Not a job token, might be a weapon type - return as-is
        return token;
    end

    -- Parse all arguments and separate tokens from keywords
    local scLevel   = nil;
    local both      = nil;
    local scElement = nil;
    local charLevel = nil;
    local foundTokens = {};

    -- Determine where to start parsing based on mode
    local startIdx = isStep and 3 or 2;

    for i = startIdx, #args do
        local param = args[i];
        local lower = param:lower();

        if param:any('1', '2', '3') then
            scLevel = tonumber(param);
        elseif lower == 'both' then
            both = true;
        elseif lower:sub(1, 3) == 'sc:' then
            scElement = lower:sub(4);
        elseif lower:sub(1, 4) == 'lvl:' or lower:sub(1, 6) == 'level:' then
            -- Extract level value after the colon
            local colonPos = lower:find(':');
            local lvlVal = tonumber(lower:sub(colonPos + 1));
            if lvlVal and lvlVal >= 1 and lvlVal <= SkillchainCore.MAX_LEVEL then
                charLevel = lvlVal;
            else
                print(('[SkillchainCalc] Invalid level value. Must be between 1 and %d.'):format(SkillchainCore.MAX_LEVEL));
                return;
            end
        else
            -- Not a keyword, treat as a token
            table.insert(foundTokens, normalizeToken(param));
        end
    end

    -- Validate token count based on mode
    local token1, token2;
    if isStep then
        if #foundTokens == 0 then
            print('[SkillchainCalc] Error: Step mode requires a job/weapon token.');
            print('[SkillchainCalc] Usage: /scc step <job/weapon> [options]');
            return;
        elseif #foundTokens > 1 then
            print('[SkillchainCalc] Error: Step mode only accepts one job/weapon token.');
            print('[SkillchainCalc] You cannot mix step calculation with job>job calculation.');
            return;
        end
        token1 = foundTokens[1];
        token2 = nil;
    else
        if #foundTokens < 2 then
            print('[SkillchainCalc] Error: Normal mode requires two tokens.');
            print('/scc help -- for usage help');
            return;
        elseif #foundTokens > 2 then
            print('[SkillchainCalc] Error: Too many tokens provided.');
            print('/scc help -- for usage help');
            return;
        end

        -- Validate: if user tried to use "step" as a token
        if foundTokens[1]:lower() == 'step' or foundTokens[2]:lower() == 'step' then
            print('[SkillchainCalc] Error: The "step" keyword must be the first token.');
            print('[SkillchainCalc] Usage: /scc step <job/weapon> [options]');
            return;
        end

        token1 = foundTokens[1];
        token2 = foundTokens[2];

        if token1 == token2 then
            both = nil;
        end
    end

    cache.jobs.token1 = token1;
    cache.jobs.token2 = token2;

    applyDefaultsToCache();
    if scLevel ~= nil then
        cache.filters.scLevel = scLevel;
    end
    if both ~= nil then
        cache.filters.both = both;
    end

    cache.filters.scElement = scElement and scElement:lower() or nil;
    cache.filters.charLevel = charLevel;
    -- step filters
    cache.step.enabled = isStep;
    cache.step.filter = stepFilter;
    cache.step.filterType = stepFilterType;
    
    -- In step mode, keep results open without GUI
    -- In normal mode, results are tied to GUI (unless we add a future option)
    cache.keepResultsOpen = isStep;

    parseSkillchains(isStep);

    if (not isStep) and SkillchainGUI ~= nil then
        SkillchainGUI.OpenFromCli();
    end
end);

-- Event handler for addon unloading
ashita.events.register('unload', 'unload_cb', function()
    SkillchainRenderer.destroy();
end);