-- Addon: SkillchainCalc
-- Description: Calculates all possible skillchain combinations using skills.lua data.

addon.name      = 'SkillchainCalc';
addon.author    = 'Zalyx';
addon.version   = '1.16';
addon.desc      = 'Skillchain combination calculator';
addon.link      = 'https://github.com/Zaldas/SkillchainCalc';

require('common');
local skills = require('skills');
local SkillchainCore = require('SkillchainCore');
local jobs = require('jobs');
local gdi = require('gdifonts.include');
local settings = require('settings');

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
    },
    default = {
        level = 1,
        both = false
    },
};

local gdiObjects = {
    title = nil,
    background = nil,
    skillchainTexts = {},
};

local cache = {
    wt1 = nil,
    wt2 = nil,
    level = 1,
    both = false,
    scElement = nil,
    settings = sccSettings;
};

local isVisible = false;

-- Initialize GDI objects for displaying skillchains
local function initGDIObjects()
    gdiObjects.title = gdi:create_object(cache.settings.title_font);
    gdiObjects.title:set_text('Skillchains');
    gdiObjects.title:set_position_x(cache.settings.anchor.x + 5);
    gdiObjects.title:set_position_y(cache.settings.anchor.y);

    gdiObjects.background = gdi:create_rect(cache.settings.bg);
    gdiObjects.background:set_position_x(cache.settings.anchor.x);
    gdiObjects.background:set_position_y(cache.settings.anchor.y);

    for i = 1, 150 do -- Increased limit to accommodate more lines
        local text = gdi:create_object(cache.settings.font);
        text:set_visible(false);
        table.insert(gdiObjects.skillchainTexts, text);
    end
end

-- Destroy GDI objects
local function destroyGDIObjects()
    gdi:destroy_object(gdiObjects.title);
    gdi:destroy_object(gdiObjects.background);
    for _, text in ipairs(gdiObjects.skillchainTexts) do
        gdi:destroy_object(text);
    end
    gdiObjects.skillchainTexts = {};
end

-- Clear GDI text objects
local function clearGDI()
    isVisible = false;
    gdiObjects.background:set_visible(false);
    gdiObjects.title:set_visible(false);
    for _, text in ipairs(gdiObjects.skillchainTexts) do
        text:set_visible(false);
    end
end

-- Move GDI Anchor
local function moveGDIAnchor()
    gdiObjects.title:set_position_x(cache.settings.anchor.x + 5);
    gdiObjects.title:set_position_y(cache.settings.anchor.y);

    gdiObjects.background:set_position_x(cache.settings.anchor.x);
    gdiObjects.background:set_position_y(cache.settings.anchor.y);
end

-- Update GDI display with skillchains
local function updateGDI(skillchains)
    clearGDI(); -- Clear previous objects

    isVisible = true;

    gdiObjects.background:set_visible(true);
    gdiObjects.title:set_visible(true);

    local layout = cache.settings.layout;
    local resultsTable = SkillchainCore.buildSkillchainTable(skillchains);
    local sortedResults, orderedResults = SkillchainCore.sortSkillchainTable(resultsTable, debugMode);
    local y_offset = 40; -- Starting y-offset
    local textIndex = 1; -- Track text object index
    local columnOffset = 0; -- Track horizontal offset for new columns
    local entriesInColumn = 0; -- Track lines in the current column
    local maxColumnHeight = 0; -- Track the tallest column height

    for _, result in ipairs(orderedResults) do
        local openers = sortedResults[result];

        -- Move to the next column if the first line of this header would exceed the limit
        if entriesInColumn + 1 > layout.entriesPerColumn then
            maxColumnHeight = math.max(maxColumnHeight, y_offset); -- Update max height for the current column
            columnOffset = columnOffset + layout.columnWidth; -- Shift to the next column
            y_offset = 40; -- Reset y-offset for the new column
            entriesInColumn = 0; -- Reset entry count for the new column
        end

        -- Display skillchain result header
        local header = gdiObjects.skillchainTexts[textIndex];
        if not header then break; end
        local chainInfo = skills.ChainInfo[result];
        local burstElements = chainInfo and chainInfo.burst or {};
        local elementsText = table.concat(burstElements, ', ');
        local color = skills.GetPropertyColor(result);
        header:set_text(('%s [%s]'):format(result, elementsText));
        header:set_font_color(color);
        header:set_position_x(cache.settings.anchor.x + 10 + columnOffset);
        header:set_position_y(cache.settings.anchor.y + y_offset);
        header:set_visible(true);
        textIndex = textIndex + 1;
        y_offset = y_offset + 20;
        entriesInColumn = entriesInColumn + 1;

        -- Display each opener and closer
        for _, openerData in ipairs(openers) do
            for _, closerData in ipairs(openerData.closers) do
                local comboText = gdiObjects.skillchainTexts[textIndex];
                if not comboText then break; end

                -- Check for level 3 skillchains (Light or Darkness)
                local isReversible = (result == 'Light' or result == 'Darkness');
                if isReversible and cache.both then
                    comboText:set_text(('  %s ↔ %s'):format(openerData.opener, closerData.closer));
                else
                    comboText:set_text(('  %s → %s'):format(openerData.opener, closerData.closer));
                end

                comboText:set_font_color(cache.settings.font.font_color);
                comboText:set_position_x(cache.settings.anchor.x + 20 + columnOffset);
                comboText:set_position_y(cache.settings.anchor.y + y_offset);
                comboText:set_visible(true);
                textIndex = textIndex + 1;
                y_offset = y_offset + 20;
                entriesInColumn = entriesInColumn + 1;
            end
        end
    end

    -- If results exceeded available text objects, show a truncation notice.
    local textLimit = #gdiObjects.skillchainTexts;
    if textIndex > textLimit then
        local notice = gdiObjects.skillchainTexts[textLimit];
        notice:set_text('⚠ Results trimmed. Add filters such as job:weapon or limit number of weapons in job or level=2.');
        notice:set_font_color(0xFFFF5555); -- light red highlight
        notice:set_position_x(cache.settings.anchor.x + 5);
        notice:set_position_y(cache.settings.anchor.y - 20);
        notice:set_visible(true);
    end

    -- Ensure maxColumnHeight accounts for the last column
    maxColumnHeight = math.max(maxColumnHeight, y_offset);

    -- Adjust background dimensions
    gdiObjects.background:set_height(maxColumnHeight + 5); -- Add padding to the height
    gdiObjects.background:set_width(columnOffset + layout.columnWidth); -- Adjust width based on total columns
end

-- Event handler for addon loading
ashita.events.register('load', 'load_cb', function()
    --print('[SkillchainCalc] Addon loaded.');
    cache.settings = settings.load(sccSettings);
    initGDIObjects();
    clearGDI();

    settings.register('settings', 'settings_update', function(s)
        if (s ~= nil) then
            destroyGDIObjects();
            cache.settings = s;
            initGDIObjects();
            clearGDI();
        end
    end)
end);

local function ParseSkillchains()
    if (not cache.wt1 or not cache.wt2) then
        return;
    end

    -- Resolve tokens (weapon types OR jobs)
    local skills1 = SkillchainCore.resolveTokenToSkills(cache.wt1);
    local skills2 = SkillchainCore.resolveTokenToSkills(cache.wt2);

    if (not skills1 or not skills2) then
        print('[SkillchainCalc] Invalid weapon/job token(s): ' ..
            tostring(cache.wt1) .. ', ' .. tostring(cache.wt2));
        clearGDI();
        return;
    end

    --[[ debugging
    print('Skills1:');
    for _, skill1 in pairs(skills1) do
        print(skill1.en .. ' ');
    end
    print('Skills2:');
    for _, skill2 in pairs(skills2) do
        print(skill2.en .. ' ');
    end
    ]]--

    -- Calculate combinations (respect /scc both)
    local combinations = SkillchainCore.calculateSkillchains(skills1, skills2, cache.both);

    -- Filter combinations by requested skillchain level (1/2/3)
    local filteredCombinations = SkillchainCore.filterSkillchainsByLevel(combinations, cache.level);

    -- Filter by element property if sc:<element> provided
    if cache.scElement then
        filteredCombinations = SkillchainCore.filterSkillchainsByElement(filteredCombinations, cache.scElement);
    end

    -- Display results
    if (#filteredCombinations > 0) then
        updateGDI(filteredCombinations);
    else
        print(('[SkillchainCalc] No skillchain combinations found for filter level %d.'):format(cache.level));
        clearGDI();
    end
end

-- Event handler for commands
ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= '/scc') then
        return;
    end

    -- Block the command to prevent further processing
    e.blocked = true;

    local validCommand = false;
    if #args > 2 then
        if (args[2]:any('setx', 'sety')) then
            local value = tonumber(args[3]);
            if value and value >= 0 then
                if (args[2] == 'setx') then
                    cache.settings.anchor.x = value;
                else --if args[2] == 'sety' then
                    cache.settings.anchor.y = value;
                end
                -- Update the GDI objects to reflect the new position
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
                cache.level = l;
                print('[SkillchainCalc] Set default level: ' .. args[3]);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setlevel. Must be a 1, 2, or 3.');
            end
        elseif (args[2] == 'setboth') then
            if (args[3]:any('true', 'false')) then
                local b = args[3] == 'true';
                cache.settings.default.both = b;
                cache.both = b;
                print('[SkillchainCalc] Set parameter \'both\' = ' .. args[3]);
                validCommand = true;
            else
                print('[SkillchainCalc] Invalid value for setboth. Must be true or false.');
            end
        end

        if (validCommand) then
            settings.save();
            if (isVisible) then
                ParseSkillchains();
            end
            return;
        end
    end

    if (#args == 2) then
        if (args[2] == 'clear') then
            clearGDI();
            cache.wt1      = nil;
            cache.wt2      = nil;
            cache.level    = cache.settings.default.level or 1;
            cache.both     = cache.settings.default.both or false;
            cache.scElement = nil;
            return;
        elseif (args[2] == 'debug') then
            debugMode = not debugMode;
            print('[SkillchainCalc] Debug mode ' .. (debugMode and 'enabled' or 'disabled') .. '.');
            return;
        elseif (args[2] == 'status') then
            print('Status of Default Filter:');
            print(' Skillchain Level: Skillchains Level ' .. cache.settings.default.level .. ' or higher.')
            print(' Calculate Both Direction: ' .. tostring(cache.settings.default.both));
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
            print(' [level] optional integer 1–3 that filters skillchain level;');
            print('  e.g. 2 only shows level 2 and 3 skillchains. 1 or empty = all.');
            print(' [sc:<element>] optional filter by SC burst element, e.g. sc:ice, sc:fire');
            print('  e.g. sc:ice shows chains like Darkness / Distortion / Induration.');
            print(' [both] optional keyword to calculate chains in both directions.');
            print('Usage: /scc setx #       -- set x anchor');
            print('Usage: /scc sety #       -- set y anchor');
            print('Usage: /scc setlevel #   -- set default level filter');
            print('Usage: /scc setboth true -- set default both flag');
            print('Usage: /scc status       -- show current defaults');
            return;
        end
    end

    -- Ensure we have the necessary arguments
    if (#args < 3) then
        print('/scc help -- for usage help');
        return;
    end

    -- Parse optional arguments
    local level     = nil;
    local both      = nil;
    local scElement = nil;

    for i = 4, #args do
        if args[i]:any('1', '2', '3') then
            level = tonumber(args[i]);
        elseif args[i] == 'both' then
            both = true;
        elseif lower:sub(1, 3) == 'sc:' then
            scElement = lower:sub(4)   -- always stored as lowercase
        else
            print('[SkillchainCalc] Invalid argument: ' .. args[i])
            print('/scc help -- for usage help');
            return;
        end
    end

    -- Optimization: If the weapon types are the same, set 'both' to nil
    if args[2] == args[3] then
        both = nil;
    end

    cache.wt1 = args[2];
    cache.wt2 = args[3];
    cache.level = level or cache.settings.default.level;
    cache.both = both or cache.settings.default.both;
    cache.scElement = scElement and scElement:lower() or nil;

    ParseSkillchains();
end);

-- Event handler for addon unloading
ashita.events.register('unload', 'unload_cb', function()
    --print('[SkillchainCalc] Addon unloaded.');
    destroyGDIObjects();
end);
