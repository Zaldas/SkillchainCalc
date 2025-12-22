-- Addon: SkillchainCalc
-- Description: Calculates all possible skillchain combinations using skills.lua data.

addon.name      = 'SkillchainCalc';
addon.author    = 'Zalyx';
addon.version   = '2.2';
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
        entriesPerColumn = 30,
        entriesHeight = 20,
    },
    default = {
        scLevel = 1,
        both = false,
        includeSubjob = false,
        useCharLevel = false
    },
};

local cache = {
    token1 = nil,
    token2 = nil,
    scLevel = 1,
    both = false,
    scElement = nil,
    stepMode = false,
    charLevel = nil,
    settings = sccSettings;
};

local function applyDefaultsToCache()
    local def = (cache.settings and cache.settings.default) or (sccSettings and sccSettings.default) or {};
    cache.scLevel = def.scLevel or 1;
    cache.both  = def.both  or false;
    cache.includeSubjob = def.includeSubjob or false;
end

local function resetCacheFull()
    cache.token1    = nil;
    cache.token2    = nil;
    cache.scElement = nil;
    cache.stepMode  = false;
    applyDefaultsToCache();
end

local function renderResults(skillchains)
    local resultsTable = SkillchainCore.BuildSkillchainTable(skillchains);
    local sortedResults, orderedResults = SkillchainCore.SortSkillchainTable(resultsTable, debugMode);

    SkillchainRenderer.render(sortedResults, orderedResults, cache.settings, cache.both, minResultsAfterHeader);
end

-- Event handler for addon loading
ashita.events.register('load', 'load_cb', function()
    cache.settings = settings.load(sccSettings);
    applyDefaultsToCache();
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

    local filteredCombinations = SkillchainCore.FilterSkillchainsByLevel(combinations, cache.scLevel);

    if cache.scElement then
        filteredCombinations = SkillchainCore.FilterSkillchainsByElement(filteredCombinations, cache.scElement);
    end

    if (#filteredCombinations > 0) then
        SkillchainRenderer.clear();
        renderResults(filteredCombinations);
    else
        local suffix = label and (' ' .. label) or '';
        print(('[SkillchainCalc] No%s skillchain combinations found for filter level %d.'):format(suffix, cache.scLevel));
        SkillchainRenderer.clear();
    end
end

local function parseSkillchains(isStep)
    if isStep then
        if (not cache.token1) then
            return;
        end

        local wsList = SkillchainCore.ResolveTokenToSkills(cache.token1, nil, cache.charLevel);
        if (not wsList) then
            print('[SkillchainCalc] Invalid weapon/job token for step mode: ' .. tostring(cache.token1));
            SkillchainRenderer.clear();
            return;
        end

        local combinations = SkillchainCore.CalculateStepSkillchains(wsList);
        cache.both = false;

        displaySkillchainResults(combinations, 'step');
        return;
    end

    if (not cache.token1 or not cache.token2) then
        return;
    end

    local skills1 = SkillchainCore.ResolveTokenToSkills(cache.token1, nil, cache.charLevel);
    local skills2 = SkillchainCore.ResolveTokenToSkills(cache.token2, nil, cache.charLevel);

    if (not skills1 or not skills2) then
        print('[SkillchainCalc] Invalid weapon/job token(s): ' ..
            tostring(cache.token1) .. ', ' .. tostring(cache.token2));
        SkillchainRenderer.clear();
        return;
    end

    local combinations = SkillchainCore.CalculateSkillchains(skills1, skills2, cache.both);

    displaySkillchainResults(combinations);
end

-- Draw IMGUI Input Window
ashita.events.register('d3d_present', 'scc_present_cb', function()
    if (SkillchainGUI ~= nil and SkillchainGUI.IsVisible()) then
        local req = SkillchainGUI.DrawWindow(cache);
        if req ~= nil then
            if req.anchorChanged then
                SkillchainRenderer.updateAnchor(cache.settings);
                settings.save();
                if SkillchainRenderer.isVisible() then
                    parseSkillchains(cache.stepMode);
                end
            end

            if req.updateDefaults then
                applyDefaultsToCache();
                settings.save();
                if SkillchainRenderer.isVisible() then
                    parseSkillchains(cache.stepMode);
                end
            end

            if req.clear then
                SkillchainRenderer.clear();
                resetCacheFull();
                return;
            end

            if req.token1 ~= nil then
                cache.token1 = req.token1;
                cache.token2 = req.token2;

                applyDefaultsToCache();
                if req.scLevel ~= nil then
                    cache.scLevel = req.scLevel;
                end
                if req.both ~= nil then
                    cache.both = req.both;
                end

                cache.scElement = req.scElement and req.scElement:lower() or nil;
                cache.charLevel = req.charLevel;

                parseSkillchains(cache.stepMode);
            end
        end
    else
        SkillchainRenderer.clear();
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
        end

        if (validCommand) then
            settings.save();
            if (SkillchainRenderer.isVisible()) then
                parseSkillchains(cache.stepMode);
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
            local poolInfo = SkillchainRenderer.getPoolInfo();
            print(' GDI Pool Size: ' .. poolInfo.poolSize .. ' (last used: ' .. poolInfo.lastUsedCount .. ')');
            return;
        elseif (args[2] == 'help') then
            print('Usage: /scc <token1> <token2> [level] [sc:<element>] [both] [lvl:#]');
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
            print('Usage: /scc setx #             -- set x anchor');
            print('Usage: /scc sety #             -- set y anchor');
            print('Usage: /scc setsclevel #       -- set default skillchain level filter');
            print('Usage: /scc setcharlevel true  -- enable/disable custom character level');
            print('Usage: /scc setboth true       -- set default both flag');
            print('Usage: /scc setsubjob true     -- set default subjob filter');
            print('Usage: /scc status             -- show current defaults');
            print('Usage: /scc                -- open gui interface');
            return;
        end
    end

    if (#args < 3) then
        if (#args == 1) then
            if SkillchainGUI ~= nil then
                SkillchainGUI.SetVisible(true);
            end
        end
        print('/scc help -- for usage help, or /scc to open GUI');
        return;
    end

    -- Parse optional arguments
    local scLevel   = nil;
    local both      = nil;
    local scElement = nil;
    local charLevel = nil;

    for i = 4, #args do
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
            print('[SkillchainCalc] Invalid argument: ' .. param);
            print('/scc help -- for usage help');
            return;
        end
    end

    if args[2] == args[3] then
        both = nil;
    end

    local isStep = false;

    -- Helper function to strip duplicate subjobs from tokens like "nin/nin:mm" -> "nin:mm"
    local function stripDuplicateSubjob(token)
        if not token or type(token) ~= 'string' then
            return token;
        end
        -- Match pattern: job/job or job/job:weapons
        local mainJob, subJob, weapons = token:match('^([^/:]+)/([^/:]+):?(.*)$');
        if mainJob and subJob and mainJob:lower() == subJob:lower() then
            -- Same job, strip the subjob part
            return weapons and weapons ~= '' and (mainJob .. ':' .. weapons) or mainJob;
        end
        return token;
    end

    cache.token1 = stripDuplicateSubjob(isStep and args[3] or args[2]);
    cache.token2 = stripDuplicateSubjob(isStep and nil or args[3]);

    applyDefaultsToCache();
    if scLevel ~= nil then
        cache.scLevel = scLevel;
    end
    if both ~= nil then
        cache.both = both;
    end

    cache.scElement = scElement and scElement:lower() or nil;
    cache.stepMode = isStep;
    cache.charLevel = charLevel;

    parseSkillchains(isStep);

    if (not isStep) and SkillchainGUI ~= nil then
        SkillchainGUI.OpenFromCli(cache);
    end
end);

-- Event handler for addon unloading
ashita.events.register('unload', 'unload_cb', function()
    SkillchainRenderer.destroy();
end);