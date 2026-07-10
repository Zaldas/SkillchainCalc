-- Addon: SkillchainCalc
-- Description: Calculates all possible skillchain combinations using skills.lua data.

addon.name      = 'SkillchainCalc';
addon.author    = 'Zaldas';
addon.version   = '2.10.3';
addon.desc      = 'Skillchain combination calculator';
addon.link      = 'https://github.com/Zaldas/SkillchainCalc';

require('common');
local chat               = require('chat');

local function msg(text) print(chat.header(addon.name):append(chat.message(text))); end
local function err(text) print(chat.header(addon.name):append(chat.error(text))); end

local jobs               = require('Jobs');
local SkillchainCore     = require('SkillchainCore');
local SkillchainRenderer = require('SkillchainRenderer');
local SkillchainGUI      = require('SkillchainGui');
local SkillchainParty    = require('SkillchainParty');
local Autotranslate      = require('Autotranslate');
local gdi                = require('gdifonts.include');
local settings           = require('settings');

local debugMode = false; -- Debug mode flag

-- Each block below grew with a different feature and is owned by a different
-- window; the naming isn't fully consistent across them (e.g. `default.enableFavWs`
-- vs `partyFilters.showFavWs` for the same concept on each window's side), but
-- keys are not renamed for consistency -- that would break existing users'
-- settings.json for no functional gain. Owner reference:
--   font/title_font/bg/layout -- GDI results window rendering (shared)
--   anchor                    -- results window position (shared)
--   guiPosition               -- input window position (shared, mutually exclusive windows)
--   default                   -- Calculator tab defaults/filters
--   partyFilters              -- Party tab REMA/Fav WS toggles
--   localPlayer               -- Party tab "Local Player" REMA weapon ownership
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
    guiPosition = {
        x = 100,
        y = 100,
    },
    layout = {
        columnWidth = 315,
        entriesPerColumn = 30,      -- Soft cap: try to split at this point
        softOverflow = 8,           -- Allow up to 8 extra entries before hard cap
        entriesHeight = 20,
        minResultsAfterHeader = 8,  -- Min results after a header before allowing column split
    },
    default = {
        scLevel = 1,
        both = false,
        includeSubjob = false,
        useCharLevel = false,
        enableFavWs = false,
        showRema = false
    },
    partyFilters = {
        showRema      = false,
        showFavWs     = false,
        scFilterIndex = 1,  -- index into partyScFilters (1 = 'All'); last Skillchain filter used
    },
    localPlayer = {
        remaWeapons = {},
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
        showRema = false,      -- Whether to include REMA weapon skills (² suffix)
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
    cache.filters.showRema = def.showRema or false;
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

-- Window mutual-exclusion policy: only one of the two input windows is ever
-- open at a time. These three helpers are the single place that enforces it,
-- instead of each command-handler branch hand-rolling its own
-- SetVisible/clear/resetCacheFull combination.
local function closeAllWindows()
    if SkillchainGUI ~= nil then SkillchainGUI.SetVisible(false); end
    SkillchainParty.SetVisible(false);
    SkillchainRenderer.Clear();
    resetCacheFull();
end

local function showCalculator()
    SkillchainParty.SetVisible(false);
    if SkillchainGUI ~= nil then SkillchainGUI.SetVisible(true); end
end

local function showParty()
    if SkillchainGUI ~= nil then SkillchainGUI.SetVisible(false); end
    SkillchainParty.SetVisible(true);
end

local function renderResults(skillchains)
    local resultsTable = SkillchainCore.BuildSkillchainTable(skillchains);
    local sortedResults, orderedResults = SkillchainCore.SortSkillchainTable(resultsTable, debugMode);

    SkillchainRenderer.Render(sortedResults, orderedResults, cache.settings, cache.filters.both);
end

-- Event handler for addon loading
ashita.events.register('load', 'load_cb', function()
    cache.settings = settings.load(sccSettings);
    applyDefaultsToCache();
    SkillchainGUI.SetCache(cache);
    SkillchainParty.SetCache(cache);
    SkillchainRenderer.Initialize(gdi, cache.settings);

    settings.register('settings', 'settings_update', function(s)
        if (s ~= nil) then
            SkillchainRenderer.Destroy();
            cache.settings = s;
            applyDefaultsToCache();
            SkillchainRenderer.Initialize(gdi, cache.settings);
        end
    end)
end);

local function displaySkillchainResults(combinations, label)
    if not combinations then
        SkillchainRenderer.Clear();
        return;
    end

    -- Apply all filters in a single pass
    local filteredCombinations = SkillchainCore.FilterSkillchains(combinations, {
        scLevel = cache.filters.scLevel,
        scElement = cache.filters.scElement,
        favWs1 = cache.jobs.favWs1,
        favWs2 = cache.jobs.favWs2,
        showRema = cache.filters.showRema,
        charLevel = cache.filters.charLevel,
        both = cache.filters.both,
    });

    if (#filteredCombinations > 0) then
        SkillchainRenderer.Clear();
        renderResults(filteredCombinations);
    else
        local suffix = label and (' ' .. label) or '';
        msg(('No%s skillchain combinations found for filter level %d.'):format(suffix, cache.filters.scLevel));
        SkillchainRenderer.Clear();
    end
end

local function parseSkillchains(isStep)
    if isStep then
        if (not cache.jobs.token1) then
            return;
        end

        local wsList = SkillchainCore.ResolveTokenToSkills(cache.jobs.token1, nil, cache.filters.charLevel);
        if (not wsList) then
            err('Invalid weapon/job token for step mode: ' .. tostring(cache.jobs.token1));
            SkillchainRenderer.Clear();
            return;
        end

        local combinations = SkillchainCore.CalculateStepSkillchains(wsList, cache.step.filter, cache.step.filterType);

        -- Check if filtering resulted in no combinations (possibly invalid property name)
        if cache.step.filterType == 'property' and #combinations == 0 then
            err('Invalid property name "' .. tostring(cache.step.filter) .. '".');
            msg('Valid properties: Compression, Detonation, Distortion, Fragmentation, Fusion, Gravitation, Impaction, Induration, Liquefaction, Reverberation, Scission, Transfixion, Light, Darkness');
            SkillchainRenderer.Clear();
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
        err(('Invalid weapon/job token(s): %s, %s'):format(tostring(cache.jobs.token1), tostring(cache.jobs.token2)));
        SkillchainRenderer.Clear();
        return;
    end

    local combinations = SkillchainCore.CalculateSkillchains(skills1, skills2, cache.filters.both);

    displaySkillchainResults(combinations);
end

local function parsePartySkillchains(members, partyFilters)
    local chains = partyFilters and partyFilters.chains or nil;

    local partyResults = SkillchainCore.CalculatePartySkillchains(members);

    -- Filter by chain family set (nil = Any, pass all)
    local filtered = {};
    for _, entry in ipairs(partyResults) do
        if not chains or chains[entry.chain] then
            table.insert(filtered, entry);
        end
    end

    if #filtered == 0 then
        msg('No party skillchain combinations found for the selected filter.');
        SkillchainRenderer.Clear();
        return;
    end

    local sortedResults, orderedResults = SkillchainCore.BuildPartySkillchainTable(filtered);
    SkillchainRenderer.Clear();
    SkillchainRenderer.Render(sortedResults, orderedResults, cache.settings, true);
end

-- Mouse event handler for drag functionality and combo clicks
ashita.events.register('mouse', 'mouse_cb', function(e)
    local result = SkillchainRenderer.HandleMouse(e, cache.settings);
    -- Check if a combo was clicked
    if result and result.opener and result.closer and result.chainName then
        local message;
        if result.openerNames then
            message = Autotranslate.FormatPartyCombo(result.opener, result.openerNames, result.closer, result.closerNames, result.chainName);
        else
            message = Autotranslate.FormatCombo(result.opener, result.closer, result.chainName);
        end
        AshitaCore:GetChatManager():QueueCommand(1, message);
    end
end);

-- Draw IMGUI Input Windows
ashita.events.register('d3d_present', 'scc_present_cb', function()
    -- Party window (standalone, default /scc)
    local partyReq = SkillchainParty.DrawWindow();
    if partyReq then
        if partyReq.anchorChanged then
            SkillchainRenderer.UpdateAnchor(cache.settings);
            settings.save();
        end
        if partyReq.settingsChanged then
            settings.save();
        end
        if partyReq.partyPositionChanged then
            settings.save();
        end
        if partyReq.mode == 'party' then
            if partyReq.warnings and #partyReq.warnings > 0 then
                msg('[Party] Warning: party data may be outdated:');
                for _, w in ipairs(partyReq.warnings) do
                    msg('  ' .. w);
                end
            end
            cache.step.enabled = false;
            cache.keepResultsOpen = false;
            parsePartySkillchains(partyReq.members, partyReq.partyFilters);
        end
    end

    if (SkillchainGUI ~= nil and SkillchainGUI.IsVisible()) then
        local req = SkillchainGUI.DrawWindow();
        if req ~= nil then
            if req.anchorChanged then
                SkillchainRenderer.UpdateAnchor(cache.settings);
                settings.save();
                -- No need to re-parse skillchains - anchor is visual only
            end

            if req.guiPositionChanged then
                settings.save();
            end

            if req.updateDefaults then
                applyDefaultsToCache();
                settings.save();
                -- Only re-parse if results are currently visible and defaults affect calculation
                -- (scLevel, both, includeSubjob, charLevel, enableFavWs)
                if SkillchainRenderer.IsVisible() then
                    parseSkillchains(cache.step.enabled);
                end
            end

            if req.clear then
                SkillchainRenderer.Clear();
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
                cache.filters.showRema = req.showRema or false;

                -- GUI-initiated requests are always normal mode (tied to GUI)
                cache.step.enabled = false;
                cache.keepResultsOpen = false;

                parseSkillchains(false);
            end
        end
    elseif not SkillchainParty.IsVisible() then
        -- Only clear renderer if results are not set to stay open
        -- (Party window manages its own results; don't clear while it's visible)
        -- isVisible() guard avoids a needless clear() every idle frame once
        -- results are already hidden -- clear() is idempotent but not free.
        if not cache.keepResultsOpen and SkillchainRenderer.IsVisible() then
            SkillchainRenderer.Clear();
        end
    end
end);

-- Normalize a CLI token by round-tripping through the core parser.
-- Strips redundant subjobs and canonicalizes weapon ordering.
local function normalizeToken(token)
    if not token or type(token) ~= 'string' then
        return token;
    end
    local jobId, allowedWeapons, subJobId = SkillchainCore.GetJobAndWeaponsFromToken(token);
    if jobId then
        return SkillchainCore.BuildTokenFromSelection(jobId, allowedWeapons, subJobId);
    end
    return token;
end

-- Handles the 1-arg utility commands (calc/party/debug/help). Returns true if
-- the command was recognized and handled (caller should return immediately).
local function handleUtilityCommand(args)
    if #args ~= 2 then
        return false;
    end

    if (args[2] == 'calc') then
        if SkillchainGUI ~= nil then
            if SkillchainGUI.IsVisible() then
                closeAllWindows();
            else
                showCalculator();
                msg('/scc calc - Generic skillchain calculator');
                msg('/scc (or /scc party) - Party skillchain calculator for your current party');
            end
        end
        return true;
    elseif (args[2] == 'party') then
        if SkillchainParty.IsVisible() then
            closeAllWindows();
        else
            showParty();
            msg('/scc (or /scc party) - Party skillchain calculator for your current party');
            msg('/scc calc - Generic skillchain calculator');
        end
        return true;
    elseif (args[2] == 'debug') then
        debugMode = not debugMode;
        msg(('Debug mode %s.'):format(debugMode and 'enabled' or 'disabled'));
        return true;
    elseif (args[2] == 'help') then
        msg('Commands:');
        msg('  /scc (or /scc party) - Toggle party skillchain calculator');
        msg('  /scc calc - Toggle generic skillchain calculator');
        msg('  /scc debug - Toggle debug mode');
        return true;
    end

    return false;
end

-- Detects step mode from args[2] ("step", "step:2", "step:distortion") and
-- parses its optional filter. Returns isStep, stepFilter (tier number or
-- property name), stepFilterType ("tier" or "property").
local function detectStepMode(args)
    if not (#args >= 2 and args[2]:lower():sub(1, 4) == 'step') then
        return false, nil, nil;
    end

    local stepArg = args[2]:lower();
    local stepFilter = nil;
    local stepFilterType = nil;

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
            stepFilter = filterValue;
            stepFilterType = 'property';
        end
    end

    return true, stepFilter, stepFilterType;
end

-- Parses scLevel/both/scElement/charLevel keywords and remaining job/weapon
-- tokens starting at startIdx. Returns false (after printing an error) if a
-- keyword value is invalid; otherwise true plus the parsed values.
local function parseCommandArgs(args, startIdx)
    local scLevel, both, scElement, charLevel = nil, nil, nil, nil;
    local foundTokens = {};

    for i = startIdx, #args do
        local param = args[i];
        local lower = param:lower();

        local paramNum = tonumber(param);
        if paramNum == 1 or paramNum == 2 or paramNum == 3 then
            scLevel = paramNum;
        elseif lower == 'both' then
            both = true;
        elseif lower:sub(1, 3) == 'sc:' then
            scElement = lower:sub(4);
        elseif lower:sub(1, 4) == 'lvl:' or lower:sub(1, 6) == 'level:' then
            -- Extract level value after the colon
            local colonPos = lower:find(':');
            local lvlVal = tonumber(lower:sub(colonPos + 1));
            if lvlVal and lvlVal >= 1 and lvlVal <= jobs.MAX_LEVEL then
                charLevel = lvlVal;
            else
                err(('Invalid level value. Must be between 1 and %d.'):format(jobs.MAX_LEVEL));
                return false;
            end
        else
            -- Not a keyword, treat as a token
            table.insert(foundTokens, normalizeToken(param));
        end
    end

    return true, scLevel, both, scElement, charLevel, foundTokens;
end

-- Validates the parsed token count against step/normal mode and resolves
-- token1/token2 (nil token2 in step mode). Returns false (after printing an
-- error) if validation fails; otherwise true, token1, token2, both (both is
-- forced nil when token1 == token2, matching normal-mode dedup rules).
local function resolveTokens(isStep, foundTokens, both)
    if isStep then
        if #foundTokens == 0 then
            err('Step mode requires a job/weapon token.');
            msg('Usage: /scc step <job/weapon> [options]');
            return false;
        elseif #foundTokens > 1 then
            err('Step mode only accepts one job/weapon token.');
            msg('You cannot mix step calculation with job>job calculation.');
            return false;
        end
        return true, foundTokens[1], nil, both;
    end

    if #foundTokens < 2 then
        err('Normal mode requires two tokens.');
        msg('/scc help -- for usage help');
        return false;
    elseif #foundTokens > 2 then
        err('Too many tokens provided.');
        msg('/scc help -- for usage help');
        return false;
    end

    -- Validate: if user tried to use "step" as a token
    if foundTokens[1]:lower() == 'step' or foundTokens[2]:lower() == 'step' then
        err('The "step" keyword must be the first token.');
        msg('Usage: /scc step <job/weapon> [options]');
        return false;
    end

    local token1, token2 = foundTokens[1], foundTokens[2];
    if token1 == token2 then
        both = nil;
    end

    return true, token1, token2, both;
end

-- Event handler for commands
ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= '/scc') then
        return;
    end

    e.blocked = true;

    if handleUtilityCommand(args) then
        return;
    end

    -- Detect step mode early and parse step filter
    local isStep, stepFilter, stepFilterType = detectStepMode(args);

    local minArgs = 3; -- both step (/scc step <token>) and normal (/scc <t1> <t2>) need at least 3 args
    if (#args < minArgs) then
        if (#args == 1) then
            local anyOpen = SkillchainParty.IsVisible() or (SkillchainGUI ~= nil and SkillchainGUI.IsVisible());
            if anyOpen then
                closeAllWindows();
            else
                showParty();
                msg('/scc (or /scc party) - Party skillchain calculator for your current party');
                msg('/scc calc - Generic skillchain calculator');
            end
        end
        return;
    end

    -- Determine where to start parsing based on mode
    local startIdx = isStep and 3 or 2;

    local parseOk, scLevel, both, scElement, charLevel, foundTokens = parseCommandArgs(args, startIdx);
    if not parseOk then
        return;
    end

    local tokensOk, token1, token2;
    tokensOk, token1, token2, both = resolveTokens(isStep, foundTokens, both);
    if not tokensOk then
        return;
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
    ashita.events.unregister('load', 'load_cb');
    ashita.events.unregister('mouse', 'mouse_cb');
    ashita.events.unregister('d3d_present', 'scc_present_cb');
    ashita.events.unregister('command', 'command_cb');
    ashita.events.unregister('unload', 'unload_cb');

    -- Disable drag on shutdown
    SkillchainRenderer.SetEnableDrag(false);
    SkillchainRenderer.Destroy();
end);