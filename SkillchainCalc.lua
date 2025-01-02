-- Addon: SkillchainCalc
-- Description: Calculates all possible skillchain combinations using skills.lua data.

addon.name      = 'SkillchainCalc';
addon.author    = 'Zalyx';
addon.version   = '1.11';
addon.desc      = 'Skillchain combination calculator';
addon.link      = 'https://github.com/Zaldas/skillchaincalc';

require('common');
local skills = require('skills');
local gdi = require('gdifonts.include');
local settings = require('settings');

local debugMode = false; -- Debug mode flag
local displaySettings = T{
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
        width = 300,
        height = 600,
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
        columnWidth = 300,
        entriesPerColumn = 30,
    }
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
    settings = displaySettings;
};

-- Helper function to find the level of a skillchain
local function findChainLevel(chainName)
    local chainInfo = skills.ChainInfo[chainName];
    return chainInfo and chainInfo.level or 0;
end

-- Initialize GDI objects for displaying skillchains
local function initGDIObjects()
    gdiObjects.title = gdi:create_object(cache.settings.title_font);
    gdiObjects.title:set_text('Skillchains');
    gdiObjects.title:set_position_x(cache.settings.anchor.x + 5);
    gdiObjects.title:set_position_y(cache.settings.anchor.y);

    gdiObjects.background = gdi:create_rect(cache.settings.bg);
    gdiObjects.background:set_position_x(cache.settings.anchor.x);
    gdiObjects.background:set_position_y(cache.settings.anchor.y);

    for i = 1, 100 do -- Increased limit to accommodate more lines
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

-- Filter skillchains by level or higher
local function filterSkillchainsByLevel(combinations, filterLevel)
    local filteredResults = {};
    for _, combo in ipairs(combinations) do
        local chainLevel = findChainLevel(combo.chain);
        if chainLevel >= filterLevel then
            table.insert(filteredResults, combo);
        end
    end
    return filteredResults;
end

-- Build results into a table
local function buildSkillchainTable(skillchains)
    local resultsTable = {};

    for _, combo in ipairs(skillchains) do
        local opener = combo.skill1;
        local closer = combo.skill2;
        local chainLevel = findChainLevel(combo.chain);

        -- Check if the opener/closer pair already exists
        local existingEntry = nil;
        for chain, openers in pairs(resultsTable) do
            if openers[opener] then
                for _, entry in ipairs(openers[opener]) do
                    if entry.closer == closer then
                        existingEntry = { chain = chain, entry = entry };
                        break;
                    end
                end
            end
            if existingEntry then break; end
        end

        if existingEntry then
            local existingLevel = findChainLevel(existingEntry.chain);
            if chainLevel > existingLevel then
                -- Remove the lower-level chain entry
                local openers = resultsTable[existingEntry.chain];
                for i, entry in ipairs(openers[opener]) do
                    if entry.closer == closer then
                        table.remove(openers[opener], i);
                        break;
                    end
                end
                if #openers[opener] == 0 then
                    openers[opener] = nil;
                end
                if not next(openers) then
                    resultsTable[existingEntry.chain] = nil;
                end
            else
                -- Skip adding this chain since a higher-level one exists
                goto continue;
            end
        end

        -- Add the new chain
        resultsTable[combo.chain] = resultsTable[combo.chain] or {};
        resultsTable[combo.chain][opener] = resultsTable[combo.chain][opener] or {};
        table.insert(resultsTable[combo.chain][opener], { closer = closer });

        ::continue::
    end

    return resultsTable;
end

-- Helper function to find the level of a weapon skill
local function findSkillLevel(skillName)
    for weaponType, weaponSkills in pairs(skills) do
        if type(weaponSkills) == 'table' then
            for _, skill in pairs(weaponSkills) do
                if skill.en == skillName then
                    return skill.tier or 0;
                end
            end
        end
    end
    return 0; -- Default to 0 if not found
end

-- Sort results table by skillchain level and opening weapon skill
local function sortSkillchainTable(resultsTable)
    local sortedResults = {};
    local orderedResults = {};

    if debugMode then print('[Debug] Starting level-based sorting'); end
    -- Sort by skillchain level using skills.ChainInfo
    local chainLevels = {};
    for chainName, _ in pairs(resultsTable) do
        table.insert(chainLevels, {
            chain = chainName,
            level = findChainLevel(chainName)
        });
    end

    table.sort(chainLevels, function(a, b)
        return skills.GetDisplayIndex(a.chain) < skills.GetDisplayIndex(b.chain)
    end)

    for _, chainData in ipairs(chainLevels) do
        local chainName = chainData.chain;
        sortedResults[chainName] = resultsTable[chainName];
        table.insert(orderedResults, chainName);
    end

    -- Sort opening weapon skills within each skillchain level by their weapon skill level
    for result, openers in pairs(sortedResults) do
        local sortedOpeners = {};
        if debugMode then print(('[Debug] Sorting openers for chain %s'):format(result)); end
        for opener, closers in pairs(openers) do
            local openerLevel = findSkillLevel(opener);
            if debugMode then print(('[Debug] Found opener %s with level %d'):format(opener, openerLevel)); end

            -- Sort closers by weapon skill level
            table.sort(closers, function(a, b)
                local closerLevelA = findSkillLevel(a.closer);
                local closerLevelB = findSkillLevel(b.closer);
                if debugMode then print(('[Debug] Comparing closer %s (Level %d) with closer %s (Level %d)'):format(a.closer, closerLevelA, b.closer, closerLevelB)); end
                return closerLevelA > closerLevelB;
            end);

            table.insert(sortedOpeners, {
                opener = opener,
                closers = closers,
                level = openerLevel
            });
        end

        table.sort(sortedOpeners, function(a, b)
            if debugMode then print(('[Debug] Comparing opener %s (Level %d) with opener %s (Level %d)'):format(a.opener, a.level, b.opener, b.level)); end
            return a.level > b.level;
        end);

        sortedResults[result] = sortedOpeners;
    end

    if debugMode then print('[Debug] Sorting completed'); end
    return sortedResults, orderedResults;
end

-- Update GDI display with skillchains
local function updateGDI(skillchains)
    clearGDI(); -- Clear previous objects

    gdiObjects.background:set_visible(true);
    gdiObjects.title:set_visible(true);

    local layout = cache.settings.layout;
    local resultsTable = buildSkillchainTable(skillchains);
    local sortedResults, orderedResults = sortSkillchainTable(resultsTable);
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

    -- Ensure maxColumnHeight accounts for the last column
    maxColumnHeight = math.max(maxColumnHeight, y_offset);

    -- Adjust background dimensions
    gdiObjects.background:set_height(maxColumnHeight + 5); -- Add padding to the height
    gdiObjects.background:set_width(columnOffset + layout.columnWidth); -- Adjust width based on total columns
end

-- Event handler for addon loading
ashita.events.register('load', 'load_cb', function()
    --print('[SkillchainCalc] Addon loaded.');
    cache.settings = settings.load(displaySettings);
    initGDIObjects();
    clearGDI();

    settings.register('settings', 'settings_update', function(s)
        if (s ~= nil) then
            cache.settings = s;
            initGDIObjects();
            clearGDI();
        end
    end)
end);

-- Calculates all possible skillchains between two sets of skills
local function parseSkillchain(skill1, skill2, results, parsedPairs, suppress)
    local pairKey = skill1.en .. ">" .. skill2.en
    suppress = suppress or false -- Default to false if not provided

    -- Iterate over skillchains of skill1 and skill2
    for _, chain1 in ipairs(skill1.skillchain or {}) do
        for _, chain2 in ipairs(skill2.skillchain or {}) do
            local chainInfo = skills.ChainInfo[chain1]

            if chainInfo and chainInfo[chain2] and not parsedPairs[pairKey] then
                -- Suppress insertion if the resulting chain is Light or Darkness
                if suppress and (chainInfo[chain2].skillchain == "Light" or chainInfo[chain2].skillchain == "Darkness") then
                    return -- Skip this entry
                end

                -- Insert into results if suppression is not active or chain is valid
                parsedPairs[pairKey] = true
                table.insert(results, {
                    skill1 = skill1.en,
                    skill2 = skill2.en,
                    chain = chainInfo[chain2].skillchain,
                })
                break -- Exit the inner loop once a match is found
            end
        end
    end
end

local function calculateSkillchains(skills1, skills2, both)
    local results = {}
    local parsedPairs = {}

    -- Normal calculation (skills1 -> skills2)
    for _, skill1 in pairs(skills1) do
        for _, skill2 in pairs(skills2) do
            parseSkillchain(skill1, skill2, results, parsedPairs)
        end
    end

    -- If `both` is specified, add reversed calculation (skills2 -> skills1)
    if cache.both then
        for _, skill2 in pairs(skills2) do
            for _, skill1 in pairs(skills1) do
                parseSkillchain(skill2, skill1, results, parsedPairs, true) -- Suppresses Light/Darkness as they are reversable
            end
        end
    end

    return results
end

local function ParseSkillchains()
    if not cache.wt1 or not cache.wt2 then
        return;
    end

    -- Validate weapon types
    local weapon1Skills = skills[cache.wt1];
    local weapon2Skills = skills[cache.wt2];

    if not weapon1Skills or not weapon2Skills then
        print('[SkillchainCalc] Invalid weapon types provided.');
        return;
    end

    -- Calculate combinations
    local combinations = calculateSkillchains(weapon1Skills, weapon2Skills);

    -- Filter combinations by level or higher
    local filteredCombinations = filterSkillchainsByLevel(combinations, cache.level);

    -- Display results
    if (#filteredCombinations > 0) then
        updateGDI(filteredCombinations);
    else
        print('[SkillchainCalc] No skillchain combinations found for filter level ' .. cache.level .. '.');
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

    if (#args > 2 and args[2]:any('setx', 'sety')) then
        local value = tonumber(args[3]);
        if value and value >= 0 then
            if args[2]:any('setx') then
                cache.settings.anchor.x = value;
            end

            if args[2]:any('sety') then
                cache.settings.anchor.y = value;
            end

            -- Update the GDI objects to reflect the new position
            settings.save();
            moveGDIAnchor();
            ParseSkillchains();

            print('New Anchor: x = ' .. cache.settings.anchor.x .. ', y = ' .. cache.settings.anchor.y);
        else
            print('[SkillchainCalc] Invalid value for setx or sety. Must be a non-negative number.');
        end
        return;
    end

    if (#args == 2 and args[2] == 'clear') then
        clearGDI();
        cache.wt1 = nil;
        cache.wt2 = nil;
        cache.level = 1;
        return;
    end

    if (#args == 2 and args[2] == 'debug') then
        debugMode = not debugMode;
        print('[SkillchainCalc] Debug mode ' .. (debugMode and 'enabled' or 'disabled') .. '.');
        return;
    end

    if (#args == 2 and args[2] == 'help') then
        print('Usage: /scc <weaponType1> <weaponType2> [#] [both]');
        print(' WeaponTypes: h2h, dagger, sword, gs, axe, ga, scythe, polearm');
        print('              katana, gkt, club, staff, archery, mm, smn');
        print(' [#] is optional integer value that filters skillchain tier')
        print('  i.e. 2 only shows tier 2 and 3 skillchains. 1 or empty is default all.')
        print(' [both] keyword is optional parameter to calculate skillchain in both directions.');
        print('  e.g. /scc gs gkt both');
        print('Usage: /scc setx # -- set x anchor');
        print('Usage: /scc sety # -- set y anchor');
        print('Usage: /scc clear -- clear out window');
        print('Usage: /scc debug -- enable debugging');
        return;
    end

    -- Ensure we have the necessary arguments
    if (#args < 3) then
        print('/scc help -- for usage help');
        return;
    end

    -- Parse optional arguments
    local level = 1;
    local both = false;
    for i = 4, #args do
        if tonumber(args[i]) then
            level = tonumber(args[i]);
        elseif args[i] == 'both' then
            both = true;
        else
            print('[SkillchainCalc] Invalid argument: ' .. args[i])
            print('/scc help -- for usage help');
            return;
        end
    end

    -- Optimization: If the weapon types are the same, set 'both' to false
    if args[2] == args[3] then
        both = false;
    end

    cache.wt1 = args[2];
    cache.wt2 = args[3];
    cache.level = level;
    cache.both = both;

    ParseSkillchains();
end);

-- Event handler for addon unloading
ashita.events.register('unload', 'unload_cb', function()
    --print('[SkillchainCalc] Addon unloaded.');
    --settings.save();
    destroyGDIObjects();
end);
