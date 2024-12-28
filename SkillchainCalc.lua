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
        outline_width = 1,
    },
    anchor = {
        x = 200,
        y = 200,
    }
};

local gdiObjects = {
    title = nil,
    background = nil,
    skillchainTexts = {},
    visible = false,
};

-- Initialize GDI objects for displaying skillchains
local function initGDIObjects()
    gdiObjects.title = gdi:create_object(displaySettings.font);
    gdiObjects.title:set_text('[SkillchainCalc] Combinations');
    gdiObjects.title:set_position_x(displaySettings.anchor.x + 10);
    gdiObjects.title:set_position_y(displaySettings.anchor.y + 10);

    gdiObjects.background = gdi:create_rect(displaySettings.bg);
    gdiObjects.background:set_position_x(displaySettings.anchor.x);
    gdiObjects.background:set_position_y(displaySettings.anchor.y);

    for i = 1, 20 do
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

-- Update GDI display with skillchains
local function updateGDI(skillchains)
    gdiObjects.background:set_visible(true);
    gdiObjects.title:set_visible(true);

    local y_offset = 40;
    for i, combo in ipairs(skillchains) do
        if i > #gdiObjects.skillchainTexts then break; end
        local text = gdiObjects.skillchainTexts[i];
        text:set_text(('  %s > %s = %s'):format(combo.skill1 or "Unknown", combo.skill2 or "Unknown", combo.chain or "Unknown"));
        text:set_position_x(displaySettings.anchor.x + 10);
        text:set_position_y(displaySettings.anchor.y + y_offset);
        text:set_visible(true);
        y_offset = y_offset + 20;
    end
end

-- Clear GDI display
local function clearGDI()
    gdiObjects.background:set_visible(false);
    gdiObjects.title:set_visible(false);
    for _, text in ipairs(gdiObjects.skillchainTexts) do
        text:set_visible(false);
    end
end

-- Event handler for addon loading
ashita.events.register('load', 'load_cb', function()
    print('[SkillchainCalc] Addon loaded. Use /scc <weaponType1> <weaponType2> to calculate skillchains.');
    initGDIObjects();
end);

-- Event handler for commands
ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= '/scc') then
        return;
    end

    -- Block the command to prevent further processing
    e.blocked = true;

    if (#args == 2 and args[2] == 'display') then
        gdiObjects.visible = not gdiObjects.visible;
        if not gdiObjects.visible then
            clearGDI();
        end
        return;
    end

    -- Ensure we have the necessary arguments
    if (#args < 3) then
        print('[SkillchainCalc] Usage: /scc <weaponType1> <weaponType2>');
        return;
    end

    local weaponType1 = args[2];
    local weaponType2 = args[3];

    -- Validate weapon types
    local weapon1Skills = skills[weaponType1];
    local weapon2Skills = skills[weaponType2];

    if not weapon1Skills or not weapon2Skills then
        print('[SkillchainCalc] Invalid weapon types provided.');
        return;
    end

    -- Calculate combinations
    local combinations = calculateSkillchains(weapon1Skills, weapon2Skills);

    -- Display results
    if (#combinations > 0) then
        print('[SkillchainCalc] Skillchain combinations:');
        for _, combo in ipairs(combinations) do
            print(('  %s > %s = %s'):format(combo.skill1 or "Unknown", combo.skill2 or "Unknown", combo.chain or "Unknown"));
        end
        if gdiObjects.visible then
            updateGDI(combinations);
        end
    else
        print('[SkillchainCalc] No skillchain combinations found.');
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
