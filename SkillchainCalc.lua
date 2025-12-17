-- Addon: SkillchainCalc
-- Description: Calculates all possible skillchain combinations using skills.lua data.

addon.name      = 'SkillchainCalc';
addon.author    = 'Zalyx';
addon.version   = '2.01';
addon.desc      = 'Skillchain combination calculator';
addon.link      = 'https://github.com/Zaldas/SkillchainCalc';

require('common');
require('imgui_compat');

local skills         = require('skills');
local SkillchainCore = require('SkillchainCore');
local gdi            = require('gdifonts.include');
local settings       = require('settings');
local SkillchainGUI  = require('skillchaingui');

local debugMode = false; -- Debug mode flag
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
        level = 1,
        both = false
    },
};

local gdiObjects = {
    title = nil,
    background = nil,
    textPool = {},          -- Active text objects
    poolSize = 0,           -- Current pool size
    maxPoolSize = 150,      -- Hard cap
    minPoolSize = 20,       -- Minimum to keep alive
    lastUsedCount = 0,      -- Track last frame usage
};

local cache = {
    token1 = nil,
    token2 = nil,
    level = 1,
    both = false,
    scElement = nil,
    stepMode = false,
    settings = sccSettings;
};

local function applyDefaultsToCache()
    local def = (cache.settings and cache.settings.default) or (sccSettings and sccSettings.default) or {};
    cache.level = def.level or 1;
    cache.both  = def.both  or false;
end

local function resetCacheFull()
    cache.token1    = nil;
    cache.token2    = nil;
    cache.scElement = nil;
    cache.stepMode  = false;
    applyDefaultsToCache();
end

local isVisible = false;

local function initGDIObjects()
    gdiObjects.title = gdi:create_object(cache.settings.title_font);
    gdiObjects.title:set_text('Skillchains');
    gdiObjects.title:set_position_x(cache.settings.anchor.x + 5);
    gdiObjects.title:set_position_y(cache.settings.anchor.y);

    gdiObjects.background = gdi:create_rect(cache.settings.bg);
    gdiObjects.background:set_position_x(cache.settings.anchor.x);
    gdiObjects.background:set_position_y(cache.settings.anchor.y);

    -- Start with minimum pool size
    for i = 1, gdiObjects.minPoolSize do
        local text = gdi:create_object(cache.settings.font);
        text:set_visible(false);
        table.insert(gdiObjects.textPool, text);
    end
    gdiObjects.poolSize = gdiObjects.minPoolSize;
end

local function destroyGDIObjects()
    if gdiObjects.title then
        gdi:destroy_object(gdiObjects.title);
        gdiObjects.title = nil;
    end
    
    if gdiObjects.background then
        gdi:destroy_object(gdiObjects.background);
        gdiObjects.background = nil;
    end
    
    for _, text in ipairs(gdiObjects.textPool) do
        gdi:destroy_object(text);
    end
    gdiObjects.textPool = {};
    gdiObjects.poolSize = 0;
    gdiObjects.lastUsedCount = 0;
end

local function clearGDI()
    isVisible = false;
    gdiObjects.background:set_visible(false);
    gdiObjects.title:set_visible(false);
    
    -- Only hide objects that were previously used
    for i = 1, gdiObjects.lastUsedCount do
        gdiObjects.textPool[i]:set_visible(false);
    end
    gdiObjects.lastUsedCount = 0;
end

-- Move GDI Anchor
local function moveGDIAnchor()
    gdiObjects.title:set_position_x(cache.settings.anchor.x + 5);
    gdiObjects.title:set_position_y(cache.settings.anchor.y);

    gdiObjects.background:set_position_x(cache.settings.anchor.x);
    gdiObjects.background:set_position_y(cache.settings.anchor.y);
end

local function ensurePoolSize(requiredSize)
    if requiredSize > gdiObjects.maxPoolSize then
        requiredSize = gdiObjects.maxPoolSize;
    end
    
    -- Grow pool if needed
    while gdiObjects.poolSize < requiredSize do
        local text = gdi:create_object(cache.settings.font);
        text:set_visible(false);
        table.insert(gdiObjects.textPool, text);
        gdiObjects.poolSize = gdiObjects.poolSize + 1;
    end
end

local function shrinkPool()
    -- Shrink pool if it's much larger than needed (keep buffer)
    local targetSize = math.max(gdiObjects.minPoolSize, gdiObjects.lastUsedCount + 20);
    
    while gdiObjects.poolSize > targetSize do
        local text = table.remove(gdiObjects.textPool);
        if text then
            gdi:destroy_object(text);
            gdiObjects.poolSize = gdiObjects.poolSize - 1;
        else
            break;
        end
    end
end

local function updateGDI(skillchains)
    isVisible = true;

    gdiObjects.background:set_visible(true);
    gdiObjects.title:set_visible(true);

    local layout = cache.settings.layout;
    local resultsTable = SkillchainCore.buildSkillchainTable(skillchains);
    local sortedResults, orderedResults = SkillchainCore.sortSkillchainTable(resultsTable, debugMode);
    
    local y_offset = 40;
    local textIndex = 1;
    local columnOffset = 0;
    local entriesInColumn = 0;
    local maxColumnHeight = 0;
    
    -- Count required objects first
    local requiredObjects = 0;
    for _, result in ipairs(orderedResults) do
        local openers = sortedResults[result];
        requiredObjects = requiredObjects + 1; -- Header
        for _, openerData in ipairs(openers) do
            requiredObjects = requiredObjects + #openerData.closers;
        end
    end
    
    -- Ensure pool has enough objects
    ensurePoolSize(requiredObjects);
    
    -- Track if we hit the limit
    local hitLimit = false;
    
    -- Render results
    for _, result in ipairs(orderedResults) do
        if textIndex > gdiObjects.poolSize then
            hitLimit = true;
            break;
        end
        
        local openers = sortedResults[result];

        -- Move to next column if needed
        if entriesInColumn + 1 > layout.entriesPerColumn then
            maxColumnHeight = math.max(maxColumnHeight, y_offset);
            columnOffset = columnOffset + layout.columnWidth;
            y_offset = 40;
            entriesInColumn = 0;
        end

        -- Display skillchain result header
        local header = gdiObjects.textPool[textIndex];
        local chainInfo = skills.ChainInfo[result];
        local burstElements = chainInfo and chainInfo.burst or {};
        local elementsText = table.concat(burstElements, ', ');
        local color = skills.GetPropertyColor(result);
        
        header:set_text(string.format('%s [%s]', result, elementsText));
        header:set_font_color(color);
        header:set_position_x(cache.settings.anchor.x + 10 + columnOffset);
        header:set_position_y(cache.settings.anchor.y + y_offset);
        header:set_visible(true);
        
        textIndex = textIndex + 1;
        y_offset = y_offset + layout.entriesHeight;
        entriesInColumn = entriesInColumn + 1;

        -- Display each opener and closer
        for _, openerData in ipairs(openers) do
            for _, closerData in ipairs(openerData.closers) do
                if textIndex > gdiObjects.poolSize then
                    hitLimit = true;
                    break;
                end
                
                local comboText = gdiObjects.textPool[textIndex];

                -- Check for level 3 skillchains (Light or Darkness)
                local isReversible = (result == 'Light' or result == 'Darkness');
                local arrow = (isReversible and cache.both) and '↔' or '→';
                
                comboText:set_text(string.format('  %s %s %s', openerData.opener, arrow, closerData.closer));
                comboText:set_font_color(cache.settings.font.font_color);
                comboText:set_position_x(cache.settings.anchor.x + 20 + columnOffset);
                comboText:set_position_y(cache.settings.anchor.y + y_offset);
                comboText:set_visible(true);
                
                textIndex = textIndex + 1;
                y_offset = y_offset + layout.entriesHeight;
                entriesInColumn = entriesInColumn + 1;
            end
            
            if hitLimit then break; end
        end
        
        if hitLimit then break; end
    end

    -- Track how many objects we actually used
    gdiObjects.lastUsedCount = textIndex - 1;
    
    -- Show truncation notice if we hit the limit
    if hitLimit and gdiObjects.poolSize > 0 then
        local notice = gdiObjects.textPool[gdiObjects.poolSize];
        notice:set_text('⚠ Results trimmed. Add filters such as job:weapon or limit number of weapons in job or level=2.');
        notice:set_font_color(0xFFFF5555);
        notice:set_position_x(cache.settings.anchor.x + 5);
        notice:set_position_y(cache.settings.anchor.y - 20);
        notice:set_visible(true);
    end

    -- Update max column height
    maxColumnHeight = math.max(maxColumnHeight, y_offset);

    -- Adjust background dimensions
    gdiObjects.background:set_height(maxColumnHeight + 5);
    gdiObjects.background:set_width(columnOffset + layout.columnWidth);
    
    -- Shrink pool if oversized (do this after a delay to avoid thrashing)
    if gdiObjects.poolSize > gdiObjects.lastUsedCount + 50 then
        shrinkPool();
    end
end

-- ============================================================================
-- Event handler for addon loading
-- ============================================================================
ashita.events.register('load', 'load_cb', function()
    cache.settings = settings.load(sccSettings);
    applyDefaultsToCache();
    initGDIObjects();
    clearGDI();

    settings.register('settings', 'settings_update', function(s)
        if (s ~= nil) then
            destroyGDIObjects();
            cache.settings = s;
            applyDefaultsToCache();
            initGDIObjects();
            clearGDI();
        end
    end)
end);

local function displaySkillchainResults(combinations, label)
    if not combinations then
        clearGDI();
        return;
    end

    local filteredCombinations = SkillchainCore.filterSkillchainsByLevel(combinations, cache.level);

    if cache.scElement then
        filteredCombinations = SkillchainCore.filterSkillchainsByElement(filteredCombinations, cache.scElement);
    end

    if (#filteredCombinations > 0) then
        clearGDI();
        updateGDI(filteredCombinations);
    else
        local suffix = label and (' ' .. label) or '';
        print(('[SkillchainCalc] No%s skillchain combinations found for filter level %d.'):format(suffix, cache.level));
        clearGDI();
    end
end

local function ParseSkillchains(isStep)
    if isStep then
        if (not cache.token1) then
            return;
        end

        local wsList = SkillchainCore.resolveTokenToSkills(cache.token1);
        if (not wsList) then
            print('[SkillchainCalc] Invalid weapon/job token for step mode: ' .. tostring(cache.token1));
            clearGDI();
            return;
        end

        local combinations = SkillchainCore.calculateStepSkillchains(wsList);
        cache.both = false;

        displaySkillchainResults(combinations, 'step');
        return;
    end

    if (not cache.token1 or not cache.token2) then
        return;
    end

    local skills1 = SkillchainCore.resolveTokenToSkills(cache.token1);
    local skills2 = SkillchainCore.resolveTokenToSkills(cache.token2);

    if (not skills1 or not skills2) then
        print('[SkillchainCalc] Invalid weapon/job token(s): ' ..
            tostring(cache.token1) .. ', ' .. tostring(cache.token2));
        clearGDI();
        return;
    end

    local combinations = SkillchainCore.calculateSkillchains(skills1, skills2, cache.both);

    displaySkillchainResults(combinations);
end

-- Draw IMGUI Input Window
ashita.events.register('d3d_present', 'scc_present_cb', function()
    if (SkillchainGUI ~= nil and SkillchainGUI.IsVisible()) then
        local req = SkillchainGUI.DrawWindow(cache);
        if req ~= nil then
            if req.anchorChanged then
                moveGDIAnchor();
                settings.save();
                if isVisible then
                    ParseSkillchains(cache.stepMode);
                end
            end

            if req.updateDefaults then
                applyDefaultsToCache();
                settings.save();
                if isVisible then
                    ParseSkillchains(cache.stepMode);
                end
            end

            if req.clear then
                clearGDI();
                resetCacheFull();
                return;
            end

            if req.token1 ~= nil then
                cache.token1 = req.token1;
                cache.token2 = req.token2;

                applyDefaultsToCache();
                if req.level ~= nil then
                    cache.level = req.level;
                end
                if req.both ~= nil then
                    cache.both = req.both;
                end

                cache.scElement = req.scElement and req.scElement:lower() or nil;

                ParseSkillchains(cache.stepMode);
            end
        end
    else
        clearGDI();
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
                moveGDIAnchor();
                print('New Anchor: x = ' .. cache.settings.anchor.x .. ', y = ' .. cache.settings.anchor.y);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setx or sety. Must be a non-negative number.');
            end
        elseif (args[2] == 'setlevel') then
            if (args[3]:any('1', '2', '3')) then
                local l = tonumber(args[3]);
                cache.settings.default.level = l;
                applyDefaultsToCache();
                print('[SkillchainCalc] Set default level: ' .. args[3]);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setlevel. Must be a 1, 2, or 3.');
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
        end

        if (validCommand) then
            settings.save();
            if (isVisible) then
                ParseSkillchains(cache.stepMode);
            end
            return;
        end
    end

    -- 1-arg utility commands
    if (#args == 2) then
        if (args[2] == 'clear') then
            clearGDI();
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
            print(' Skillchain Level: Skillchains Level ' .. cache.settings.default.level .. ' or higher.')
            print(' Calculate Both Direction: ' .. tostring(cache.settings.default.both));
            print(' GDI Pool Size: ' .. gdiObjects.poolSize .. ' (last used: ' .. gdiObjects.lastUsedCount .. ')');
            return;
        elseif (args[2] == 'help') then
            print('Usage: /scc <token1> <token2> [level] [sc:<element>] [both]');
            print(' Tokens can be weapon types, jobs, or job:weapon filters:');
            print('  Weapon Types: h2h, dagger, sword, gs, axe, ga, scythe, polearm,');
            print('                katana, gkt, club, staff, archery, mm, smn');
            print('  Jobs: WAR, MNK, WHM, BLM, RDM, THF, PLD, DRK, BST, BRD, RNG');
            print('        SAM, NIN, DRG, SMN, BLU, COR, DNC, SCH');
            print('  Job+Weapon: thf:sword   (THF, sword WS only)');
            print('               war:ga,polearm (WAR, GA and Polearm WS only)');
            print(' [level] optional integer 1-3 that filters skillchain level;');
            print('  e.g. 2 only shows level 2 and 3 skillchains. 1 or empty = all.');
            print(' [sc:<element>] optional filter by SC burst element, e.g. sc:ice, sc:fire');
            print('  e.g. sc:ice shows chains like Darkness / Distortion / Induration.');
            print(' [both] optional keyword to calculate skillchains in both directions.');
            print('Usage: /scc setx #       -- set x anchor');
            print('Usage: /scc sety #       -- set y anchor');
            print('Usage: /scc setlevel #   -- set default level filter');
            print('Usage: /scc setboth true -- set default both flag');
            print('Usage: /scc status       -- show current defaults');
            print('Usage: /scc              -- open gui interface');
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
    local level     = nil;
    local both      = nil;
    local scElement = nil;

    for i = 4, #args do
        local param = args[i];
        local lower = param:lower();

        if param:any('1', '2', '3') then
            level = tonumber(param);
        elseif lower == 'both' then
            both = true;
        elseif lower:sub(1, 3) == 'sc:' then
            scElement = lower:sub(4);
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

    cache.token1 = isStep and args[3] or args[2];
    cache.token2 = isStep and nil or args[3];

    applyDefaultsToCache();
    if level ~= nil then
        cache.level = level;
    end
    if both ~= nil then
        cache.both = both;
    end

    cache.scElement = scElement and scElement:lower() or nil;
    cache.stepMode = isStep;

    ParseSkillchains(isStep);

    if (not isStep) and SkillchainGUI ~= nil then
        SkillchainGUI.OpenFromCli(cache);
    end
end);

-- Event handler for addon unloading
ashita.events.register('unload', 'unload_cb', function()
    destroyGDIObjects();
end);