-- SkillchainGui.lua
-- ImGui input window for SkillchainCalc (GDI shows results).

require('common');
local imgui    = require('imgui');
local jobsData = require('Jobs');
local skills   = require('Skills');
local scaling  = require('scaling');
local SkillchainCore = require('SkillchainCore');

local SkillchainGUI = {};
local showWindow    = { false };

-- Constants
local JOB_COLUMN_WIDTH = 160; -- Shared width for each job column

-----------------------------------------------------------------------
-- Dynamic job list from jobs.lua (no hardcoded tokens)
-----------------------------------------------------------------------
local jobItems = {};
do
    local seen = {};
    if jobsData.aliases then
        for _, jobId in pairs(jobsData.aliases) do
            if type(jobId) == 'string' and not seen[jobId] then
                local job = jobsData[jobId];
                if job and job.weapons then
                    seen[jobId] = true;
                    table.insert(jobItems, jobId);
                end
            end
        end
    end
    table.sort(jobItems);
end

-----------------------------------------------------------------------
-- Dynamic element list from skills.ChainInfo using display order.
-- Only properties with a single burst element are considered.
-- Elements appear in the order of the first property that uses them.
-----------------------------------------------------------------------
local elementItems  = { 'Any' };
local elementTokens = { '' };
do
    local chainInfo = skills.ChainInfo or {};
    local props     = {};

    -- Collect properties that have exactly one burst element.
    for name, info in pairs(chainInfo) do
        if type(info) == 'table' and type(info.burst) == 'table' and #info.burst == 1 then
            table.insert(props, name);
        end
    end

    -- Sort properties by display order (skills.GetDisplayIndex),
    -- fall back to name if helper is missing / equal.
    table.sort(props, function(a, b)
        local ia = skills.GetDisplayIndex and skills.GetDisplayIndex(a) or 0;
        local ib = skills.GetDisplayIndex and skills.GetDisplayIndex(b) or 0;
        if ia ~= ib then
            return ia < ib;
        end
        return a < b;
    end)

    -- Walk properties in display order and add their single burst element
    -- once, in the order we encounter them.
    local seen = {};
    for _, name in ipairs(props) do
        local info  = chainInfo[name];
        local burst = info.burst;
        local elem  = burst[1];  -- exactly one
        if not seen[elem] then
            seen[elem] = true;
            table.insert(elementItems,  elem);
            table.insert(elementTokens, elem:lower());
        end
    end
end

-----------------------------------------------------------------------
-- Helper wrappers for Core functions (for backwards compatibility)
-----------------------------------------------------------------------
local function getJobWeaponList(jobId)
    return SkillchainCore.GetWeaponsForJob(jobId);
end

local function buildToken(jobId, weaponSel, subJobId)
    return SkillchainCore.BuildTokenFromSelection(jobId, weaponSel, subJobId);
end

-----------------------------------------------------------------------
-- State and Cache
-----------------------------------------------------------------------
local state = {
    initialized   = false,
    openedFromCli = false,

    -- top section
    scLevel       = 1,
    elementIndex  = 1,
    both          = false,

    -- subjob filter
    includeSubjob = false,

    -- custom level filter
    useCustomLevel = false,
    charLevel      = SkillchainCore.MAX_LEVEL,

    -- middle section
    job1Index     = 1,
    job2Index     = 2,

    job1SubIndex  = 2,  -- Different from job1Index
    job2SubIndex  = 1,  -- Different from job2Index

    job1LastId    = nil,
    job2LastId    = nil,
    job1Weapons   = nil,
    job2Weapons   = nil,

    -- track active tab for dynamic height
    activeTab     = 'Calculator',
};

-- Module-level cache reference (set externally via SetCache)
local cache = nil;

-----------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------
local function calculateTabHeight(tabName, maxWeapons)
    local lineHeight = imgui.GetFrameHeightWithSpacing();
    local paddingAdjust = 0;
    -- All values are manually tweaked to make GUI look good
    if tabName == 'Calculator' then
        paddingAdjust = -6;
        -- Base rows: header + job combos + buttons + spacing
        local rowsBase    = 6;
        local rowsWeapons = maxWeapons or 0;
        -- Add extra rows for subjob dropdowns if enabled
        local rowsSubjob = state.includeSubjob and 1 or 0;
        -- Add extra row for custom level dropdown if enabled
        local rowsLevel = state.useCustomLevel and 2.5 or 0;
        return (rowsBase + rowsWeapons + rowsSubjob + rowsLevel) * lineHeight + paddingAdjust;
    elseif tabName == 'Filters' then
        paddingAdjust = 5;
        return 18 * lineHeight + paddingAdjust;
    elseif tabName == 'Settings' then
        --paddingAdjust = 0;
        return 17 * lineHeight + paddingAdjust;
    end

    return 400; -- fallback
end

local function drawCombo(label, items, currentIndex)
    local idx   = currentIndex or 1;
    if idx < 1 or idx > #items then
        idx = 1;
    end
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

local function helpMarker(text)
    imgui.SameLine();
    imgui.TextDisabled('(?)');
    if imgui.IsItemHovered() then
        imgui.BeginTooltip();
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0);
        imgui.TextUnformatted(text);
        imgui.PopTextWrapPos();
        imgui.EndTooltip();
    end
end

-- Gradient header helper: color > transparent with small text padding.
local function drawGradientHeader(text, width)
    local drawlist = imgui.GetWindowDrawList();
    local x, y     = imgui.GetCursorScreenPos();
    local lineH    = imgui.GetTextLineHeightWithSpacing();

    local fadeFraction = 0.75;
    local gradWidth    = width * fadeFraction;

    local colLeft      = {0.25, 0.40, 0.85, 1.00};
    local colLeftU32   = imgui.GetColorU32(colLeft);
    local colRight     = {colLeft[1], colLeft[2], colLeft[3], 0.00};
    local colRightU32  = imgui.GetColorU32(colRight);

    drawlist:AddRectFilledMultiColor(
        {x, y},
        {x + gradWidth, y + lineH},
        colLeftU32,
        colRightU32,
        colRightU32,
        colLeftU32
    );

    local padX = 4;
    local padY = 2;
    imgui.SetCursorScreenPos({ x + padX, y + padY });
    imgui.Text(text);

    local _, newY = imgui.GetCursorScreenPos();
    imgui.SetCursorScreenPos({ x, newY });
    imgui.Spacing();
end

local function countJobWeapons(jobId)
    local list = getJobWeaponList(jobId);
    return #list;
end

-- Build default weapon selection for a job
-- If includeFallback is true, selects all weapons when no primaryWeapons exist
-- If includeFallback is false, returns empty selection when no primaryWeapons exist
local function buildDefaultWeaponSelection(jobId, includeFallback)
    local job = jobsData[jobId];
    local sel = {};

    if not job or not job.weapons then
        return sel;
    end

    local prim = job.primaryWeapons or {};
    if type(prim) == 'table' and #prim > 0 then
        for _, w in ipairs(prim) do
            if job.weapons[w] then
                sel[w] = true;
            end
        end
    elseif includeFallback then
        for w, _ in pairs(job.weapons) do
            sel[w] = true;
        end
    end

    return sel;
end

local function ensureJobWeaponSelection(side, jobId)
    if not jobId then
        return {};
    end

    local lastId, selTable;

    if side == 1 then
        lastId   = state.job1LastId;
        selTable = state.job1Weapons;
    else
        lastId   = state.job2LastId;
        selTable = state.job2Weapons;
    end

    -- If job changed, rebuild defaults from jobs.lua.
    if jobId ~= lastId then
        selTable = buildDefaultWeaponSelection(jobId, true);

        if side == 1 then
            state.job1LastId = jobId;
        else
            state.job2LastId = jobId;
        end
    elseif type(selTable) ~= 'table' then
        -- Same job, but somehow no table yet.
        selTable = {};
    end

    if side == 1 then
        state.job1Weapons = selTable;
    else
        state.job2Weapons = selTable;
    end

    return selTable;
end

-- Helper to find job index in jobItems for dropdown
local function findJobIndex(jobId)
    if not jobId then return nil; end
    for i, id in ipairs(jobItems) do
        if id == jobId then
            return i;
        end
    end
    return nil;
end

local function applyTokenToSide(side, token)
    if not token or type(token) ~= 'string' then
        return;
    end

    -- Let core parse "job", "job:weapon1,weapon2", or "mainjob/subjob:weapon"
    local jobId, allowedWeapons, subJobId = SkillchainCore.GetJobAndWeaponsFromToken(token);
    if not jobId then
        return;
    end

    local job = jobsData[jobId];
    if not job or not job.weapons then
        return;
    end

    -- Ignore subjob if it's the same as main job
    if subJobId and subJobId == jobId then
        subJobId = nil;
    end

    local idx = findJobIndex(jobId) or 1;
    local subIdx = 1;
    if subJobId then
        subIdx = findJobIndex(subJobId) or 1;
        state.includeSubjob = true;  -- Auto-enable subjob filter if token contains subjob
    end

    local sel = {};

    -- If the token had an explicit weapon list (job:weapon1,weapon2)
    if allowedWeapons and next(allowedWeapons) then
        for w, _ in pairs(allowedWeapons) do
            if job.weapons[w] then
                sel[w] = true;
            end
        end
    end

    -- Fallback: primaryWeapons, else all weapons for that job
    if not next(sel) then
        sel = buildDefaultWeaponSelection(jobId, true);
    end

    if side == 1 then
        state.job1Index    = idx;
        state.job1SubIndex = subIdx;
        state.job1LastId   = jobId;
        state.job1Weapons  = sel;
    else
        state.job2Index    = idx;
        state.job2SubIndex = subIdx;
        state.job2LastId   = jobId;
        state.job2Weapons  = sel;
    end
end

local function drawWeaponCheckboxes(jobId, weaponSel)
    local job = jobId and jobsData[jobId] or nil;
    if not job or not job.weapons then
        imgui.TextDisabled('(no weapons)');
        return;
    end

    local list = getJobWeaponList(jobId);

    -- Primary weapons for this job.
    local primarySet = {};
    if type(job.primaryWeapons) == 'table' then
        for _, pw in ipairs(job.primaryWeapons) do
            primarySet[pw] = true;
        end
    end

    -- Indent offset
    local baseX = imgui.GetCursorPosX();
    local indent = 5;

    for _, w in ipairs(list) do
        -- Move text + checkbox inward
        imgui.SetCursorPosX(baseX + indent);

        local checked = { weaponSel[w] and true or false };

        if primarySet[w] then
            imgui.PushStyleColor(ImGuiCol_Text, { 1.00, 0.90, 0.40, 1.00 }); -- gold tint
        end

        if imgui.Checkbox(w, checked) then
            weaponSel[w] = checked[1];
        end

        if primarySet[w] then
            imgui.PopStyleColor();
        end
    end
end

-- Helper function to build calculation request from current state
local function buildCalculationRequest()
    local job1Id = jobItems[state.job1Index] or jobItems[1];
    local job2Id = jobItems[state.job2Index] or jobItems[2];

    local job1SubId = nil;
    local job2SubId = nil;

    if state.includeSubjob then
        job1SubId = jobItems[state.job1SubIndex];
        job2SubId = jobItems[state.job2SubIndex];
    end

    local token1 = buildToken(job1Id, state.job1Weapons, job1SubId);
    local token2 = buildToken(job2Id, state.job2Weapons, job2SubId);

    local lvlVal    = state.scLevel or 1;
    local elemTok   = elementTokens[state.elementIndex] or '';
    local scElement = (elemTok ~= '' and elemTok) or nil;

    return {
        mode      = 'pair',
        token1    = token1,
        token2    = token2,
        scLevel   = lvlVal,
        both      = state.both,
        scElement = scElement,
        charLevel = state.useCustomLevel and state.charLevel or nil,
    };
end

local function drawCalculatorTab()
    -- Current job IDs based on indices
    local job1Id = jobItems[state.job1Index] or jobItems[1];
    local job2Id = jobItems[state.job2Index] or jobItems[2];

    -- Count weapons for current jobs (used for layout decisions if needed)
    local count1     = countJobWeapons(job1Id);
    local count2     = countJobWeapons(job2Id);
    local maxWeapons = math.max(count1, count2);

    local request = nil;

    -----------------------------------------------------------------------
    -- Custom Level section (if enabled)
    -----------------------------------------------------------------------
    if state.useCustomLevel then
        drawGradientHeader('Character Level', imgui.GetContentRegionAvail());

        local baseX  = imgui.GetCursorPosX();
        local indent = 5;
        local filterWidth = JOB_COLUMN_WIDTH * 2;

        imgui.SetCursorPosX(baseX + indent);
        local LABEL_PADDING = 3
        imgui.SetCursorPosY(imgui.GetCursorPosY() + LABEL_PADDING);
        imgui.Text('Level:');
        imgui.SameLine();
        imgui.SetCursorPosY(imgui.GetCursorPosY() - LABEL_PADDING);

        -- Build character level dropdown (MAX_LEVEL to 1, descending)
        local levelItems = {};
        for i = 1, SkillchainCore.MAX_LEVEL do
            table.insert(levelItems, tostring(i));
        end

        imgui.PushItemWidth(100);
        state.charLevel = drawCombo('##charlevel', levelItems, state.charLevel);
        imgui.PopItemWidth();

        imgui.Spacing();
        imgui.Separator();
        imgui.Spacing();
    end

    -----------------------------------------------------------------------
    -- Jobs + weapons section
    -----------------------------------------------------------------------
    drawGradientHeader('Jobs & Weapons', imgui.GetContentRegionAvail());

    ensureJobWeaponSelection(1, job1Id);
    ensureJobWeaponSelection(2, job2Id);

    imgui.Columns(3, 'scc_jobs_cols', false);
    imgui.SetColumnWidth(0, JOB_COLUMN_WIDTH);
    imgui.SetColumnWidth(1, 30);
    imgui.SetColumnWidth(2, JOB_COLUMN_WIDTH);

    -- Row 1: job combos + arrow
    imgui.PushItemWidth(JOB_COLUMN_WIDTH - 18);
    local prevJob1Index = state.job1Index;
    state.job1Index = drawCombo('##fromjob', jobItems, state.job1Index);
    imgui.PopItemWidth();

    imgui.NextColumn();
    do
        local arrow      = state.both and '<->' or '->';
        local curX, curY = imgui.GetCursorPos();
        local comboH     = imgui.GetFrameHeight();
        local textH      = imgui.GetTextLineHeight();
        local yOffset    = math.max(0, (comboH - textH) * 0.5);
        imgui.SetCursorPos({ curX, curY + yOffset });
        imgui.Text(arrow);
        imgui.SetCursorPos({ curX, curY });
    end

    imgui.NextColumn();
    imgui.PushItemWidth(JOB_COLUMN_WIDTH - 18);
    local prevJob2Index = state.job2Index;
    state.job2Index = drawCombo('##tojob', jobItems, state.job2Index);
    imgui.PopItemWidth();

    -- Row 1.5: subjob combos (if enabled)
    if state.includeSubjob then
        imgui.NextColumn();
        local curX = imgui.GetCursorPosX();
        imgui.SetCursorPosX(curX + 5);
        imgui.Text('/');
        imgui.SameLine();
        imgui.PushItemWidth(JOB_COLUMN_WIDTH - 30);
        local prevJob1SubIndex = state.job1SubIndex;
        state.job1SubIndex = drawCombo('##fromsubjob', jobItems, state.job1SubIndex);
        imgui.PopItemWidth();

        imgui.NextColumn();
        -- Empty center column for subjobs

        imgui.NextColumn();
        curX = imgui.GetCursorPosX();
        imgui.SetCursorPosX(curX + 5);
        imgui.Text('/');
        imgui.SameLine();
        imgui.PushItemWidth(JOB_COLUMN_WIDTH - 30);
        local prevJob2SubIndex = state.job2SubIndex;
        state.job2SubIndex = drawCombo('##tosubjob', jobItems, state.job2SubIndex);
        imgui.PopItemWidth();

        -- Prevent main and subjob from being the same - swap them if they match
        local function ensureJobsAreDifferent(mainIdx, subIdx, prevMainIdx, prevSubIdx)
            if mainIdx == subIdx then
                -- If subjob was just changed to match main, swap main to previous subjob
                if prevSubIdx ~= subIdx then
                    return prevSubIdx, subIdx;
                -- If main was just changed to match subjob, swap subjob to previous main
                elseif prevMainIdx ~= mainIdx then
                    return mainIdx, prevMainIdx;
                end
            end
            return mainIdx, subIdx;
        end

        state.job1Index, state.job1SubIndex = ensureJobsAreDifferent(state.job1Index, state.job1SubIndex, prevJob1Index, prevJob1SubIndex);
        state.job2Index, state.job2SubIndex = ensureJobsAreDifferent(state.job2Index, state.job2SubIndex, prevJob2Index, prevJob2SubIndex);
    end

    -- Re-resolve job IDs after selection
    job1Id = jobItems[state.job1Index] or jobItems[1];
    job2Id = jobItems[state.job2Index] or jobItems[2];

    local job1Sel = ensureJobWeaponSelection(1, job1Id);
    local job2Sel = ensureJobWeaponSelection(2, job2Id);

    -- Row 2: weapons under each job
    imgui.NextColumn();
    imgui.PushID('job1_weapons');
    drawWeaponCheckboxes(job1Id, job1Sel);
    imgui.PopID();

    imgui.NextColumn();
    imgui.Dummy({ 0, 0 }); -- keep center empty

    imgui.NextColumn();
    imgui.PushID('job2_weapons');
    drawWeaponCheckboxes(job2Id, job2Sel);
    imgui.PopID();

    imgui.Columns(1);

    imgui.Separator();
    imgui.Spacing();

    -----------------------------------------------------------------------
    -- BOTTOM SECTION: Buttons (centered)
    -----------------------------------------------------------------------
    local availWidth   = imgui.GetContentRegionAvail();
    local buttonWidth  = 120;
    local spacing      = 10;
    local totalWidth   = buttonWidth * 2 + spacing;

    if availWidth > totalWidth then
        local startX = imgui.GetCursorPosX() + ((availWidth - totalWidth) / 2);
        imgui.SetCursorPosX(startX);
    end

    -- Primary action: Calculate
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0);
    imgui.PushStyleColor(ImGuiCol_Button,        { 0.25, 0.40, 0.85, 1.00 });
    imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 0.30, 0.48, 0.95, 1.00 });
    imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 0.18, 0.32, 0.70, 1.00 });

    if imgui.Button('Calculate', { buttonWidth, 0 }) then
        request = buildCalculationRequest();
    end

    imgui.PopStyleColor(3);
    imgui.PopStyleVar(1);

    imgui.SameLine();

    -- Secondary action: Clear (ghost button style)
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0);
    imgui.PushStyleColor(ImGuiCol_Button,        { 0.00, 0.00, 0.00, 0.00 });
    imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 1.00, 1.00, 1.00, 0.12 });
    imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 1.00, 1.00, 1.00, 0.20 });

    if imgui.Button('Clear', { buttonWidth, 0 }) then
        local curJob1Id = jobItems[state.job1Index];
        local curJob2Id = jobItems[state.job2Index];

        state.job1Weapons = buildDefaultWeaponSelection(curJob1Id, false);
        state.job2Weapons = buildDefaultWeaponSelection(curJob2Id, false);

        request = { clear = true };
    end

    imgui.PopStyleColor(3);
    imgui.PopStyleVar(1);

    return request;
end

local function drawFiltersTab()
    local request = nil;

    local baseX  = imgui.GetCursorPosX();
    local indent = 5;
    local filterWidth = JOB_COLUMN_WIDTH * 2;

    -----------------------------------------------------------------------
    -- Element Filter
    -----------------------------------------------------------------------
    drawGradientHeader('Skillchain Element (sc:<element>)', imgui.GetContentRegionAvail());

    imgui.Text('Filter results by burst element:');
    imgui.SetCursorPosX(baseX + indent);
    imgui.PushItemWidth(filterWidth - indent);
    state.elementIndex = drawCombo('##scelement', elementItems, state.elementIndex);
    imgui.PopItemWidth();

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    -----------------------------------------------------------------------
    -- Level Filter
    -----------------------------------------------------------------------
    drawGradientHeader('Skillchain Level (1, 2, 3)', imgui.GetContentRegionAvail());

    imgui.Text('Minimum skillchain tier:');
    imgui.SetCursorPosX(baseX + indent);
    imgui.PushItemWidth(filterWidth - indent);
    local lvl = { state.scLevel };
    if imgui.SliderInt('##sclevel', lvl, 1, 3) then
        state.scLevel = lvl[1];
    end
    imgui.PopItemWidth();

    imgui.Spacing();
    imgui.Text('  1 = All skillchains');
    imgui.Text('  2 = Level 2+ only');
    imgui.Text('  3 = Level 3 only');

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    -----------------------------------------------------------------------
    -- Advanced Filters Section
    -----------------------------------------------------------------------
    drawGradientHeader('Advanced Filters', imgui.GetContentRegionAvail());

    -- Custom Level Checkbox
    imgui.SetCursorPosX(baseX + indent);
    local useCustomLevel = { state.useCustomLevel };
    if imgui.Checkbox('Enable custom character level', useCustomLevel) then
        state.useCustomLevel = useCustomLevel[1];
    end
    imgui.SameLine();
    helpMarker('When enabled, adds a level dropdown in Calculator tab\nfor skill-based weapon skill filtering.');

    -- Both Directions Checkbox
    imgui.SetCursorPosX(baseX + indent);
    local both = { state.both };
    if imgui.Checkbox('Calculate skillchains in both directions', both) then
        state.both = both[1];
    end
    imgui.SameLine();
    helpMarker('When enabled, calculates Job1->Job2 AND Job2->Job1');

    -- Include Subjob Checkbox
    imgui.SetCursorPosX(baseX + indent);
    local includeSubjob = { state.includeSubjob };
    if imgui.Checkbox('Enable subjob selection in Calculator tab', includeSubjob) then
        state.includeSubjob = includeSubjob[1];
    end
    imgui.SameLine();
    helpMarker('When enabled, adds subjob dropdowns in Calculator tab.\nThis allows filtering weaponskills based on subjob restrictions\n(e.g., marksmanship).');

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    -----------------------------------------------------------------------
    -- Action Buttons
    -----------------------------------------------------------------------
    local availWidth   = imgui.GetContentRegionAvail();
    local buttonWidth  = 140;
    local spacing      = 10;
    local totalWidth   = buttonWidth * 2 + spacing;

    if availWidth > totalWidth then
        local startX = imgui.GetCursorPosX() + ((availWidth - totalWidth) / 2);
        imgui.SetCursorPosX(startX);
    end

    -- Set Defaults button
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0);
    imgui.PushStyleColor(ImGuiCol_Button,        { 0.25, 0.40, 0.85, 1.00 });
    imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 0.30, 0.48, 0.95, 1.00 });
    imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 0.18, 0.32, 0.70, 1.00 });

    if imgui.Button('Set as Defaults', { buttonWidth, 0 }) then
        local def = (cache and cache.settings and cache.settings.default) or {};
        def.scLevel = state.scLevel;
        def.both  = state.both;
        def.includeSubjob = state.includeSubjob;
        def.useCharLevel = state.useCustomLevel;
        cache.settings.default = def;

        request = request or {};
        request.updateDefaults = true;
    end

    imgui.PopStyleColor(3);
    imgui.PopStyleVar(1);

    imgui.SameLine();

    -- Reset Filters button (ghost style)
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0);
    imgui.PushStyleColor(ImGuiCol_Button,        { 0.00, 0.00, 0.00, 0.00 });
    imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 1.00, 1.00, 1.00, 0.12 });
    imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 1.00, 1.00, 1.00, 0.20 });

    if imgui.Button('Reset Filters', { buttonWidth, 0 }) then
        -- Reset to stored defaults
        local def = (cache and cache.settings and cache.settings.default) or {};
        state.scLevel = def.scLevel or 1;
        state.both  = def.both  or false;
        state.includeSubjob = def.includeSubjob or false;
        state.useCustomLevel = def.useCharLevel or false;
        state.elementIndex = 1;
    end

    imgui.PopStyleColor(3);
    imgui.PopStyleVar(1);

    imgui.Spacing();
    imgui.Spacing();

    -----------------------------------------------------------------------
    -- Calculate Button (centered)
    -----------------------------------------------------------------------
    local calcButtonWidth = 200;
    availWidth = imgui.GetContentRegionAvail();

    if availWidth > calcButtonWidth then
        local startX = imgui.GetCursorPosX() + ((availWidth - calcButtonWidth) / 2);
        imgui.SetCursorPosX(startX);
    end

    -- Calculate button (primary style)
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0);
    imgui.PushStyleColor(ImGuiCol_Button,        { 0.25, 0.40, 0.85, 1.00 });
    imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 0.30, 0.48, 0.95, 1.00 });
    imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 0.18, 0.32, 0.70, 1.00 });

    if imgui.Button('Calculate', { calcButtonWidth, 0 }) then
        -- Ensure weapon selections exist for current jobs
        local job1Id = jobItems[state.job1Index] or jobItems[1];
        local job2Id = jobItems[state.job2Index] or jobItems[2];
        ensureJobWeaponSelection(1, job1Id);
        ensureJobWeaponSelection(2, job2Id);

        request = buildCalculationRequest();
    end

    imgui.PopStyleColor(3);
    imgui.PopStyleVar(1);

    return request;
end

local function drawSettingsTab()
    local request = nil;

    if not cache or not cache.settings or not cache.settings.anchor then
        imgui.Text('Settings not available.');
        return nil;
    end

    -----------------------------------------------------------------------
    -- Anchor adjustment position
    -----------------------------------------------------------------------
    local anchor = cache.settings.anchor;

    local pad    = 20;
    local layoutSettings = cache.settings.layout;
    local colW   = (layoutSettings and layoutSettings.columnWidth) or pad;
    local colH   = (layoutSettings and layoutSettings.entriesPerColumn * layoutSettings.entriesHeight) or pad;
    -- X max = screen width - one column width - padding
    local maxX   = scaling.window.w - colW - pad;
    if maxX < pad then maxX = pad; end

    -- Y can still use full height padding
    local maxY   = scaling.window.h - colH - pad;
    if maxY < pad then maxY = pad; end

    drawGradientHeader('Results Window Anchor (top-left)', imgui.GetContentRegionAvail());
    imgui.Spacing();

    -- 5px indent
    local baseX  = imgui.GetCursorPosX();
    local indent = 5;

    imgui.SetCursorPosX(baseX + indent);
    local x = { anchor.x or 0 };
    if imgui.SliderInt('X', x, pad, maxX) then
        anchor.x = x[1];
        request = request or {};
        request.anchorChanged = true;
    end

    imgui.SetCursorPosX(baseX + indent);
    local y = { anchor.y or 0 };
    if imgui.SliderInt('Y', y, pad, maxY) then
        anchor.y = y[1];
        request = request or {};
        request.anchorChanged = true;
    end

    -----------------------------------------------------------------------
    -- Stored Default Filter Status (read-only)
    -----------------------------------------------------------------------
    imgui.Separator();
    drawGradientHeader('Stored Defaults', imgui.GetContentRegionAvail());

    local def = cache.settings.default or {};

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text(string.format("SkillChain Level: %s", tostring(def.scLevel)));

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text(string.format("Enable Char Lvl:  %s", tostring(def.useCharLevel or false)));

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text(string.format("Enable Both:      %s", tostring(def.both or false)));

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text(string.format("Enable Subjob:    %s", tostring(def.includeSubjob or false)));

    -----------------------------------------------------------------------
    -- How to update defaults (CLI instructions)
    -----------------------------------------------------------------------
    imgui.Spacing();
    imgui.Separator();
    drawGradientHeader('How to Update Defaults (CLI)', imgui.GetContentRegionAvail());

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text('/scc setsclevel <1-3>');

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text('/scc setcharlevel <true|false>');

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text('/scc setboth <true|false>');

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text('/scc setsubjob <true|false>');

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text('/scc setx <value>');

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text('/scc sety <value>');

    return request;
end

-----------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------
function SkillchainGUI.OpenFromCli()
    if not cache or cache.stepMode then
        return;
    end

    local def = (cache.settings and cache.settings.default) or {};

    -- Filters from CLI (with fallback to defaults)
    state.scLevel = cache.scLevel or def.scLevel or 1;

    if cache.both ~= nil then
        state.both = cache.both;
    else
        state.both = def.both or false;
    end

    -- Don't set includeSubjob yet - let applyTokenToSide detect it from tokens first
    -- We'll set it from defaults after if it wasn't set by tokens
    local initialSubjob = def.includeSubjob or false;

    -- Element from cache.scElement
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

    -- Jobs + weapons from token1 / token2
    -- These may set state.includeSubjob = true if tokens contain subjobs
    if cache.token1 then
        applyTokenToSide(1, cache.token1);
    end
    if cache.token2 then
        applyTokenToSide(2, cache.token2);
    end

    -- Only override includeSubjob if explicitly set to true in cache, or use defaults if tokens didn't enable it
    if cache.includeSubjob == true then
        state.includeSubjob = true;
    elseif not state.includeSubjob then
        state.includeSubjob = initialSubjob;
    end

    -- Custom level from CLI
    if cache.charLevel then
        state.useCustomLevel = true;
        state.charLevel = cache.charLevel;
    else
        state.useCustomLevel = def.useCharLevel or false;
    end

    -- Tell DrawWindow "don't re-init from defaults"
    state.initialized   = true;
    state.openedFromCli = true;

    showWindow[1] = true;
end

function SkillchainGUI.Toggle()
    showWindow[1] = not showWindow[1];
    if showWindow[1] then
        state.initialized = false;
        state.openedFromCli = false;
        state.activeTab = 'Calculator';
    end
end

function SkillchainGUI.SetVisible(v)
    showWindow[1] = v;
    if showWindow[1] then
        state.initialized = false;
        state.openedFromCli = false;
        state.activeTab = 'Calculator';
    end
end

function SkillchainGUI.IsVisible()
    return showWindow[1];
end

function SkillchainGUI.SetCache(cacheRef)
    cache = cacheRef;
end

function SkillchainGUI.DrawWindow()
    if not showWindow[1] then
        return nil;
    end

    -- one-time sync from settings defaults
    if (not state.initialized) and cache and cache.settings and cache.settings.default then
        local def = cache.settings.default;

        -- Only apply defaults when NOT opened from CLI
        if not state.openedFromCli then
            state.scLevel = def.scLevel or 1;

            if def.both ~= nil then
                state.both = def.both;
            else
                state.both = false;
            end

            if def.includeSubjob ~= nil then
                state.includeSubjob = def.includeSubjob;
            else
                state.includeSubjob = false;
            end

            if def.useCharLevel ~= nil then
                state.useCustomLevel = def.useCharLevel;
            else
                state.useCustomLevel = false;
            end
        end

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

        state.initialized   = true;
        state.openedFromCli = false;
    end

    -- derive current jobs to estimate height for Calculator tab
    local job1Id = jobItems[state.job1Index] or jobItems[1];
    local job2Id = jobItems[state.job2Index] or jobItems[2];

    local count1     = countJobWeapons(job1Id);
    local count2     = countJobWeapons(job2Id);
    local maxWeapons = math.max(count1, count2);

    -- Calculate window height based on active tab
    local winHeight = calculateTabHeight(state.activeTab, maxWeapons);

    imgui.SetNextWindowSize({ 380, winHeight }, ImGuiCond_Always);

    local flags = bit.bor(
        ImGuiWindowFlags_NoSavedSettings,
        ImGuiWindowFlags_NoDocking,
        ImGuiWindowFlags_NoResize
    );

    if not imgui.Begin('SkillchainCalc', showWindow, flags) then
        imgui.End();
        return nil;
    end

    local request = nil;

    if imgui.BeginTabBar('##scc_tabs', ImGuiTabBarFlags_None) then
        -- Calculator tab
        if imgui.BeginTabItem('Calculator') then
            if state.activeTab ~= 'Calculator' then
                state.activeTab = 'Calculator';
            end
            local r = drawCalculatorTab();
            if r then
                request = r;
            end
            imgui.EndTabItem();
        end

        -- Filters tab
        if imgui.BeginTabItem('Filters') then
            if state.activeTab ~= 'Filters' then
                state.activeTab = 'Filters';
            end
            local r = drawFiltersTab();
            if r then
                request = request or {};
                for k, v in pairs(r) do
                    request[k] = v;
                end
            end
            imgui.EndTabItem();
        end

        -- Settings tab
        if imgui.BeginTabItem('Settings') then
            if state.activeTab ~= 'Settings' then
                state.activeTab = 'Settings';
            end
            local r = drawSettingsTab();
            if r then
                request = request or {};
                for k, v in pairs(r) do
                    request[k] = v;
                end
            end
            imgui.EndTabItem();
        end

        imgui.EndTabBar();
    end

    imgui.End();
    return request;
end

return SkillchainGUI;
