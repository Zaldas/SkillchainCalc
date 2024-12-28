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

local displaySettings = {
    font = {
        font_family = 'Arial',
        font_height = 16,
        font_color = 0xFFFFFFFF,
        outline_color = 0xFF000000,
        outline_width = 1,
    },
    bg = {
        width = 400,
        height = 300,
        corner_rounding = 5,
        fill_color = 0xBF000000,
        outline_color = 0xFFFFFFFF,
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

-- Tier priorities
local tierPriority = {
    t3 = {'Light', 'Darkness'},
    t2 = {'Distortion', 'Fragmentation', 'Fusion', 'Gravitation'},
    t1 = {'Compression', 'Liquefaction', 'Induration', 'Reverberation', 'Transfixion', 'Scission', 'Detonation', 'Impaction'}
};

-- Initialize GDI objects for displaying skillchains
local function initGDIObjects()
    gdiObjects.title = gdi:create_object(displaySettings.font);
    gdiObjects.title:set_text('Skillchain Combinations');
    gdiObjects.title:set_position_x(displaySettings.anchor.x + 10);
    gdiObjects.title:set_position_y(displaySettings.anchor.y + 10);

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

-- Filter skillchains by tier or higher
local function filterSkillchainsByTier(combinations, filter)
    local filteredResults = {};
    local tiersToInclude = {};

    if filter == 't3' then
        tiersToInclude = {'t3'};
    elseif filter == 't2' then
        tiersToInclude = {'t3', 't2'};
    elseif filter == 't1' then
        tiersToInclude = {'t3', 't2', 't1'};
    end

    local includedChains = {};
    for _, tier in ipairs(tiersToInclude) do
        for _, chainName in ipairs(tierPriority[tier]) do
            includedChains[chainName] = true;
        end
    end

    local highestTierCombos = {};

    for _, combo in ipairs(combinations) do
        if includedChains[combo.chain] then
            local key = ('%s>%s'):format(combo.skill1, combo.skill2);
            if not highestTierCombos[key] then
                highestTierCombos[key] = combo;
            end
        end
    end

    for _, combo in pairs(highestTierCombos) do
        table.insert(filteredResults, combo);
    end

    return filteredResults;
end

-- Group skillchains by the skillchain result and opening weapon skill
local function groupSkillchainsByResultAndOpener(skillchains)
    local groupedResults = {};

    for _, combo in ipairs(skillchains) do
        local result = combo.chain;
        groupedResults[result] = groupedResults[result] or {};

        local opener = combo.skill1;
        groupedResults[result][opener] = groupedResults[result][opener] or {};
        table.insert(groupedResults[result][opener], combo);
    end

    return groupedResults;
end

-- Update GDI display with skillchains
local function updateGDI(skillchains)
    clearGDI(); -- Clear previous objects

    gdiObjects.background:set_visible(true);
    gdiObjects.title:set_visible(true);

    local groupedResults = groupSkillchainsByResultAndOpener(skillchains);
    local y_offset = 40;
    local textIndex = 1; -- Track text object index
    local totalHeight = 60; -- Start with a base height for the title and spacing

    for result, group in pairs(groupedResults) do
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

        -- Display each opener under the result
        for opener, combos in pairs(group) do
            for _, combo in ipairs(combos) do
                local comboText = gdiObjects.skillchainTexts[textIndex];
                if not comboText then break; end
                comboText:set_text(('  %s > %s'):format(opener, combo.skill2));
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
    print('[SkillchainCalc] Addon loaded. Use /scc <weaponType1> <weaponType2> [tier] to calculate skillchains.');
    initGDIObjects();
    clearGDI();
end);

-- Event handler for commands
ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= '/scc') then
        return;
    end

    -- Block the command to prevent further processing
    e.blocked = true;

    if (#args == 2 and args[2] == 'clear') then
        clearGDI();
        return;
    end

    -- Ensure we have the necessary arguments
    if (#args < 3) then
        print('[SkillchainCalc] Usage: /scc <weaponType1> <weaponType2> [tier]');
        return;
    end

    local weaponType1 = args[2];
    local weaponType2 = args[3];
    local filter = args[4] or 't1'; -- Default to t1 if no filter is provided

    -- Validate weapon types
    local weapon1Skills = skills[weaponType1];
    local weapon2Skills = skills[weaponType2];

    if not weapon1Skills or not weapon2Skills then
        print('[SkillchainCalc] Invalid weapon types provided.');
        return;
    end

    -- Calculate combinations
    local combinations = calculateSkillchains(weapon1Skills, weapon2Skills);

    -- Filter combinations by tier or higher
    local filteredCombinations = filterSkillchainsByTier(combinations, filter);

    -- Display results
    if (#filteredCombinations > 0) then
        updateGDI(filteredCombinations);
    else
        print('[SkillchainCalc] No skillchain combinations found for filter ' .. filter .. '.');
        clearGDI();
    end
end);

-- Calculates all possible skillchains between two sets of skills
function calculateSkillchains(skills1, skills2)
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

-- Event handler for addon unloading
ashita.events.register('unload', 'unload_cb', function()
    print('[SkillchainCalc] Addon unloaded.');
    destroyGDIObjects();
end);
