-- Addon: SkillchainCalc
-- Description: Calculates all possible skillchain combinations using skills.lua data.

addon.name      = 'SkillchainCalc';
addon.author    = 'Zalyx';
addon.version   = '1.0';
addon.desc      = 'Skillchain combination calculator';
addon.link      = '';

require('common');
local skills = require('skills');
local gdi = require('gdifonts.include');
--local settings = require('settings');

local debugMode = false; -- Debug mode flag
local displaySettings = {
    font = {
        font_family = 'Arial',
        font_height = 16,
        font_color = 0xFFD3D3D3,
        outline_color = 0xFF000000,
        outline_width = 1,
    },
    title_font = {
        font_family = 'Times New Roman',
        font_height = 24,
        font_color = 0xFF739BD0,
        outline_color = 0xFF000000,
        outline_width = 2,
    },
    bg = {
        width = 350,
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
    }
};

local gdiObjects = {
    title = nil,
    background = nil,
    skillchainTexts = {},
};

-- Helper function to find the level of a skillchain
local function findChainLevel(chainName)
    local chainInfo = skills.ChainInfo[chainName];
    return chainInfo and chainInfo.level or 0;
end

-- Initialize GDI objects for displaying skillchains
local function initGDIObjects()
    gdiObjects.title = gdi:create_object(displaySettings.title_font);
    gdiObjects.title:set_text('Skillchains');
    gdiObjects.title:set_position_x(displaySettings.anchor.x + 5);
    gdiObjects.title:set_position_y(displaySettings.anchor.y);

    gdiObjects.background = gdi:create_rect(displaySettings.bg);
    gdiObjects.background:set_position_x(displaySettings.anchor.x);
    gdiObjects.background:set_position_y(displaySettings.anchor.y);

    for i = 1, 100 do -- Increased limit to accommodate more lines
        local text = gdi:create_object(displaySettings.font);
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
    gdiObjects.title:set_position_x(displaySettings.anchor.x + 5);
    gdiObjects.title:set_position_y(displaySettings.anchor.y);

    gdiObjects.background:set_position_x(displaySettings.anchor.x);
    gdiObjects.background:set_position_y(displaySettings.anchor.y);

    for _, text in ipairs(gdiObjects.skillchainTexts) do
        text:set_position_x(displaySettings.anchor.x);
        text:set_position_y(displaySettings.anchor.y);
    end
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
        local result = combo.chain;
        resultsTable[result] = resultsTable[result] or {};

        local opener = combo.skill1;
        resultsTable[result][opener] = resultsTable[result][opener] or {};
        table.insert(resultsTable[result][opener], combo.skill2);
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
        return a.level > b.level;
    end);

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
                local closerLevelA = findSkillLevel(a);
                local closerLevelB = findSkillLevel(b);
                if debugMode then print(('[Debug] Comparing closer %s (Level %d) with closer %s (Level %d)'):format(a, closerLevelA, b, closerLevelB)); end
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

    local resultsTable = buildSkillchainTable(skillchains);
    local sortedResults, orderedResults = sortSkillchainTable(resultsTable);
    local y_offset = 40;
    local textIndex = 1; -- Track text object index
    local totalHeight = 60; -- Start with a base height for the title and spacing

    for _, result in ipairs(orderedResults) do
        local openers = sortedResults[result];
        -- Display skillchain result header
        local header = gdiObjects.skillchainTexts[textIndex];
        if not header then break; end
        local chainInfo = skills.ChainInfo[result];
        local burstElements = chainInfo and chainInfo.burst or {};
        local elementsText = table.concat(burstElements, ', ');
        header:set_text(('%s [%s]'):format(result, elementsText));

        header:set_position_x(displaySettings.anchor.x + 10);
        header:set_position_y(displaySettings.anchor.y + y_offset);
        header:set_visible(true);
        textIndex = textIndex + 1;
        y_offset = y_offset + 20;
        totalHeight = totalHeight + 20;

        -- Display each opener and each closer on a separate line
        for _, openerData in ipairs(openers) do
            for _, closer in ipairs(openerData.closers) do
                local comboText = gdiObjects.skillchainTexts[textIndex];
                if not comboText then break; end
                comboText:set_text(('  %s > %s'):format(openerData.opener, closer));
                comboText:set_position_x(displaySettings.anchor.x + 20);
                comboText:set_position_y(displaySettings.anchor.y + y_offset);
                comboText:set_visible(true);
                textIndex = textIndex + 1;
                y_offset = y_offset + 20;
                totalHeight = totalHeight + 20;
            end
        end
    end

    -- Adjust background height to fit the text
    gdiObjects.background:set_height(totalHeight);
end

-- Event handler for addon loading
ashita.events.register('load', 'load_cb', function()
    --print('[SkillchainCalc] Addon loaded.');
    --settings.load(displaySettings);
    initGDIObjects();
    clearGDI();

    --[[
    settings.register('settings', 'settings_update', function(s)
        if (s ~= nil) then
            displaySettings = s;
        end
    end)
    ]]
end);

-- Calculates all possible skillchains between two sets of skills
local function calculateSkillchains(skills1, skills2)
    local results = {};

    for _, skill1 in pairs(skills1) do
        for _, skill2 in pairs(skills2) do
            for _, chain1 in pairs(skill1.skillchain or {}) do
                for _, chain2 in pairs(skill2.skillchain or {}) do
                    local chainInfo = skills.ChainInfo[chain1];
                    if chainInfo and chainInfo[chain2] then
                        table.insert(results, {
                            skill1 = skill1.en,
                            skill2 = skill2.en,
                            chain = chainInfo[chain2].skillchain
                        });
                    end
                end
            end
        end
    end

    return results;
end

local function CalculateSkllchains(wt1, wt2, l)
end

-- Event handler for commands
ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= '/scc') then
        return;
    end

    -- Block the command to prevent further processing
    e.blocked = true;

    --[[
    if (#args > 2 and args[2]:any('setx', 'sety')) then
        local value = tonumber(args[3]);
        if value and value >= 0 then
            print(args[2] .. ': ' .. tostring(args[3]));

            if args[2]:any('setx') then
                displaySettings.anchor.x = value;
            end

            if args[2]:any('sety') then
                displaySettings.anchor.y = value;
            end

            -- Update the GDI objects to reflect the new position
            moveGDIAnchor();
            settings.save();
        else
            print('[SkillchainCalc] Invalid value for setx or sety. Must be a non-negative number.');
        end
        return;
    end
    ]]

    if (#args == 2 and args[2] == 'clear') then
        clearGDI();
        return;
    end

    if (#args == 2 and args[2] == 'debug') then
        debugMode = not debugMode;
        print('[SkillchainCalc] Debug mode ' .. (debugMode and 'enabled' or 'disabled') .. '.');
        return;
    end

    if (#args == 2 and args[2] == 'help') then
        print('[SkillchainCalc] Usage: /scc <weaponType1> <weaponType2> [level]');
        print('[SkillchainCalc] Valid weaponTypes: h2h, dagger, sword, gs, axe, ga, scythe, polearm, katana, gkt, club, staff, archery, mm, smn');
        return;
    end

    -- Ensure we have the necessary arguments
    if (#args < 3) then
        print('[SkillchainCalc] Usage: /scc <weaponType1> <weaponType2> [level]');
        return;
    end

    local weaponType1 = args[2];
    local weaponType2 = args[3];
    local filterLevel = tonumber(args[4]) or 1; -- Default to level 1 if no level is provided

    -- Validate weapon types
    local weapon1Skills = skills[weaponType1];
    local weapon2Skills = skills[weaponType2];

    if not weapon1Skills or not weapon2Skills then
        print('[SkillchainCalc] Invalid weapon types provided.');
        return;
    end

    -- Calculate combinations
    local combinations = calculateSkillchains(weapon1Skills, weapon2Skills);

    -- Filter combinations by level or higher
    local filteredCombinations = filterSkillchainsByLevel(combinations, filterLevel);

    -- Display results
    if (#filteredCombinations > 0) then
        updateGDI(filteredCombinations);
    else
        print('[SkillchainCalc] No skillchain combinations found for filter level ' .. filterLevel .. '.');
        clearGDI();
    end
end);

-- Event handler for addon unloading
ashita.events.register('unload', 'unload_cb', function()
    print('[SkillchainCalc] Addon unloaded.');
    destroyGDIObjects();
end);
