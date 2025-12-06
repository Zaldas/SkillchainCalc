-- skillchaingui.lua
-- ImGui input window for SkillchainCalc (GDI shows results).

require('common');
local imgui    = require('imgui');
local jobsData = require('jobs');

local SkillchainGUI = {};
local showWindow    = { false };

-- canonical weapon order
local weaponOrder = {
    'h2h','dagger','sword','gs','axe','ga','scythe',
    'polearm','katana','gkt','club','staff','archery','mm',
};

-- shared width for each job column
local JOB_COLUMN_WIDTH = 160;

-- job tokens (CLI side)
local jobTokens = {
    'war','mnk','whm','blm','rdm','thf','pld','drk','bst',
    'brd','rng','sam','nin','drg','smn','blu','cor','dnc','sch',
};

-- job display labels (from Jobs.lua aliases if present)
local jobItems = {};
for _, tok in ipairs(jobTokens) do
    local upper = (jobsData.aliases and jobsData.aliases[tok]) or tok:upper();
    table.insert(jobItems, upper);
end

-- element filter combo
local elementItems = {
    'Any',
    'Fire','Wind','Lightning','Light',
    'Earth','Ice','Water','Dark',
};

local elementTokens = {
    '',
    'fire','wind','lightning','light',
    'earth','ice','water','dark',
};

local state = {
    initialized   = false,

    -- top section
    level         = 1,
    elementIndex  = 1,
    both          = false,

    -- middle section
    job1Index     = 1,
    job2Index     = 2,

    job1LastId    = nil,
    job2LastId    = nil,
    job1Weapons   = {},
    job2Weapons   = {},
};

local function DrawGradientHeader(text, width)
    local drawlist = imgui.GetWindowDrawList();
    local x, y     = imgui.GetCursorScreenPos();
    local lineH    = imgui.GetTextLineHeightWithSpacing();

    -- How far the gradient extends as a fraction of the header width.
    local fadeFraction = 0.75;
    local gradWidth    = width * fadeFraction;

    -- Editable start color (RGBA floats)
    local colLeft     = {0.25, 0.40, 0.85, 1.00};
    local colLeftU32  = imgui.GetColorU32(colLeft);

    -- Same color but alpha = 0 for transparent fade
    local colRight    = {colLeft[1], colLeft[2], colLeft[3], 0.00};
    local colRightU32 = imgui.GetColorU32(colRight);

    -- Draw gradient bar
    drawlist:AddRectFilledMultiColor(
        {x, y},
        {x + gradWidth, y + lineH},
        colLeftU32,    -- TL
        colRightU32,   -- TR
        colRightU32,   -- BR
        colLeftU32     -- BL
    );

    -- Small padding inside the gradient for the text
    local padX = 4;   -- left padding
    local padY = 2;   -- top padding
    imgui.SetCursorScreenPos({ x + padX, y + padY });
    imgui.Text(text);

    -- Move cursor to next line with a bit of space below header
    local _, newY = imgui.GetCursorScreenPos();
    imgui.SetCursorScreenPos({ x, newY });
    imgui.Spacing();
end

local function DrawCombo(label, items, currentIndex)
    local idx   = currentIndex or 1;
    local value = items[idx] or items[1];

    if imgui.BeginCombo(label, value) then
        for i = 1, #items do
            local selected = (i == idx);
            if imgui.Selectable(items[i], selected) then
                idx = i;
            end
            if selected then
                imgui.SetItemDefaultFocus();
            end
        end
        imgui.EndCombo();
    end

    return idx;
end

-- ensure each side gets a weapon selection table seeded from primaryWeapons (or all)
local function ensureJobWeaponSelection(side, jobId)
    if not jobId then return; end

    local lastId, selTable;
    if side == 1 then
        lastId   = state.job1LastId;
        selTable = state.job1Weapons;
    else
        lastId   = state.job2LastId;
        selTable = state.job2Weapons;
    end

    if jobId == lastId and selTable ~= nil then
        return;
    end

    selTable = {};
    local job = jobsData[jobId];
    if job and job.weapons then
        local prim = job.primaryWeapons or {};
        if prim and #prim > 0 then
            for _, w in ipairs(prim) do
                if job.weapons[w] then
                    selTable[w] = true;
                end
            end
        else
            for w, _ in pairs(job.weapons) do
                selTable[w] = true;
            end
        end
    end

    if side == 1 then
        state.job1LastId  = jobId;
        state.job1Weapons = selTable;
    else
        state.job2LastId  = jobId;
        state.job2Weapons = selTable;
    end
end

local function drawWeaponCheckboxes(jobId, weaponSel)
    local job = jobId and jobsData[jobId] or nil;
    if not job or not job.weapons then
        imgui.TextDisabled('(no weapons)');
        return;
    end

    for _, w in ipairs(weaponOrder) do
        if job.weapons[w] then
            local checked = { weaponSel[w] and true or false };
            if imgui.Checkbox(w, checked) then
                weaponSel[w] = checked[1];
            end
        end
    end
end

local function countJobWeapons(jobId)
    local job = jobId and jobsData[jobId] or nil;
    if not job or not job.weapons then
        return 0;
    end

    local count = 0;
    for _, w in ipairs(weaponOrder) do
        if job.weapons[w] then
            count = count + 1;
        end
    end
    return count;
end

function SkillchainGUI.Toggle()
    showWindow[1] = not showWindow[1];
end

function SkillchainGUI.SetVisible(v)
    showWindow[1] = v and true or false;
end

function SkillchainGUI.IsVisible()
    return showWindow[1];
end

function SkillchainGUI.DrawWindow(cache)
    if not showWindow[1] then
        return nil;
    end

    -- one-time sync from cache
    if (not state.initialized) and cache then
        state.level        = cache.level or 1;
        state.both         = cache.both or false;
        state.elementIndex = 1;
        if cache.scElement then
            local lower = cache.scElement:lower();
            for i, tok in ipairs(elementTokens) do
                if tok == lower then
                    state.elementIndex = i;
                    break;
                end
            end
        end
        state.initialized = true;
    end

    -- Current jobs based on indices
    local job1Token = jobTokens[state.job1Index] or jobTokens[1];
    local job2Token = jobTokens[state.job2Index] or jobTokens[2];

    local job1Id = jobsData.aliases[job1Token] or job1Token:upper();
    local job2Id = jobsData.aliases[job2Token] or job2Token:upper();

    -- Count weapons for current jobs
    local count1     = countJobWeapons(job1Id);
    local count2     = countJobWeapons(job2Id);
    local maxWeapons = math.max(count1, count2);

    -- Rough row-based height estimate to avoid scrollbars.
    -- Top: Filters header + element text/combo + level text/slider + both checkbox + separator.
    local rowsTop    = 6;
    -- Middle: jobs header + job combo row + a bit of spacing before weapons.
    local rowsMiddle = 3;
    -- Weapons: one row per weapon checkbox (max of the two jobs).
    local rowsWeapons = maxWeapons;
    -- Bottom: separator + buttons row + spacing.
    local rowsBottom  = 3;

    local totalRows = rowsTop + rowsMiddle + rowsWeapons + rowsBottom;

    local lineHeight = imgui.GetFrameHeightWithSpacing();
    local winHeight  = totalRows * lineHeight - 25;

    imgui.SetNextWindowSize({ 400, winHeight }, ImGuiCond_Always);

    local flags = bit.bor(
        ImGuiWindowFlags_NoSavedSettings,
        ImGuiWindowFlags_NoDocking
    );

    if not imgui.Begin('SkillchainCalc Input', showWindow, flags) then
        imgui.End();
        return nil;
    end

    local request = nil;

    -----------------------------------------------------------------------
    -- TOP SECTION: Filters
    -----------------------------------------------------------------------
    DrawGradientHeader('Filters', 380);   -- width matches your window width minus padding

    local filterWidth = JOB_COLUMN_WIDTH * 2;

    -- Element filter
    imgui.Text('Skillchain Element (sc:<element>)');

    local baseX = imgui.GetCursorPosX();
    local indent = 5;

    imgui.SetCursorPosX(baseX + indent);
    imgui.PushItemWidth(filterWidth - indent);
    state.elementIndex = DrawCombo('##scelement', elementItems, state.elementIndex);
    imgui.PopItemWidth();

    imgui.Spacing();

    -- Level filter
    local lvl = { state.level };
    imgui.Text('Skillchain Level (1, 2, 3)');

    imgui.SetCursorPosX(baseX + indent);
    imgui.PushItemWidth(filterWidth - indent);
    if imgui.SliderInt('##sclevel', lvl, 1, 3) then
        state.level = lvl[1];
    end
    imgui.PopItemWidth();

    imgui.Spacing();

    -- Both toggle
    local both = { state.both };
    if imgui.Checkbox('Both directions (both)', both) then
        state.both = both[1];
    end

    imgui.Separator();
    imgui.Spacing();

    -----------------------------------------------------------------------
    -- MIDDLE SECTION: Jobs + weapons
    -----------------------------------------------------------------------
    DrawGradientHeader('Jobs & Weapons', 380);

    -- resolve job IDs from tokens first
    local job1Token = jobTokens[state.job1Index];
    local job2Token = jobTokens[state.job2Index];

    local job1Id = jobsData.aliases[job1Token] or job1Token:upper();
    local job2Id = jobsData.aliases[job2Token] or job2Token:upper();

    ensureJobWeaponSelection(1, job1Id);
    ensureJobWeaponSelection(2, job2Id);

    -- Layout: 3 columns (left job, arrow, right job)
    imgui.Columns(3, 'scc_jobs_cols', false);
    imgui.SetColumnWidth(0, JOB_COLUMN_WIDTH);
    imgui.SetColumnWidth(1, 30);
    imgui.SetColumnWidth(2, JOB_COLUMN_WIDTH);

    -- Row 1: job combos + arrow (fixed width)
    imgui.PushItemWidth(JOB_COLUMN_WIDTH - 8);
    state.job1Index = DrawCombo('##fromjob', jobItems, state.job1Index);
    imgui.PopItemWidth();

    imgui.NextColumn();
    imgui.Text(state.both and '<->' or '->');

    imgui.NextColumn();
    imgui.PushItemWidth(JOB_COLUMN_WIDTH - 8);
    state.job2Index = DrawCombo('##tojob', jobItems, state.job2Index);
    imgui.PopItemWidth();

    -- Re-resolve IDs in case job selection changed
    job1Token = jobTokens[state.job1Index];
    job2Token = jobTokens[state.job2Index];

    job1Id = jobsData.aliases[job1Token] or job1Token:upper();
    job2Id = jobsData.aliases[job2Token] or job2Token:upper();

    ensureJobWeaponSelection(1, job1Id);
    ensureJobWeaponSelection(2, job2Id);

    -- Row 2: weapon checkboxes directly under each job
    imgui.NextColumn();
    drawWeaponCheckboxes(job1Id, state.job1Weapons);

    imgui.NextColumn();
    imgui.Dummy({ 0, 0 }); -- keep center column (arrow) empty on second row

    imgui.NextColumn();
    drawWeaponCheckboxes(job2Id, state.job2Weapons);

    imgui.Columns(1); -- back to single-column layout

    imgui.Separator();
    imgui.Spacing();

    -----------------------------------------------------------------------
    -- BOTTOM SECTION: Buttons (centered)
    -----------------------------------------------------------------------
    local availWidth   = imgui.GetContentRegionAvail(); -- scalar width
    local buttonWidth  = 120;
    local spacing      = 10;
    local totalWidth   = buttonWidth * 2 + spacing;

    if availWidth > totalWidth then
        local startX = imgui.GetCursorPosX() + ((availWidth - totalWidth) / 2);
        imgui.SetCursorPosX(startX);
    end

    if imgui.Button('Calculate', { buttonWidth, 0 }) then
        local function buildToken(jobTok, weaponSel)
            local selected = {};
            for _, w in ipairs(weaponOrder) do
                if weaponSel[w] then
                    table.insert(selected, w);
                end
            end
            if #selected > 0 then
                return string.format('%s:%s', jobTok, table.concat(selected, ','));
            else
                return jobTok;
            end
        end

        local wt1 = buildToken(job1Token, state.job1Weapons);
        local wt2 = buildToken(job2Token, state.job2Weapons);

        local lvlVal    = state.level or 1;
        local elemTok   = elementTokens[state.elementIndex] or '';
        local scElement = (elemTok ~= '' and elemTok) or nil;

        request = {
            mode      = 'pair',
            wt1       = wt1,
            wt2       = wt2,
            level     = lvlVal,
            both      = state.both,
            scElement = scElement,
        };
    end

    imgui.SameLine();
    if imgui.Button('Clear', { buttonWidth, 0 }) then
        request = { clear = true };
    end

    imgui.End();
    return request;
end

return SkillchainGUI;
