-- SkillchainGui.lua
-- ImGui input window for SkillchainCalc (GDI shows results).

require('common');
local imgui    = require('imgui');
local jobsData = require('Jobs');
local skills   = require('Skills');
local SkillRanks = require('SkillRanks');
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
-- State and Cache
-----------------------------------------------------------------------
-- STATE: Stores what the user is currently configuring in the GUI.
-- This represents "current dropdown selections, checkbox states, and UI widget values".
-- When "Calculate" button is clicked, state is used to build a calculation request
-- which then gets executed and stored in cache (the displayed results).
local state = {
    initialized   = false,        -- Whether GUI has been initialized
    openedFromCli = false,        -- Whether GUI was opened via CLI command

    -- Current job/subjob/weapon selections for both players (1 and 2)
    jobs = {
        [1] = {
            index      = 1,       -- Job dropdown index
            subIndex   = 2,       -- Subjob dropdown index (different from main job)
            lastId     = nil,     -- Last selected job ID (for change detection)
            weapons    = nil,     -- Weapon type checkboxes (table of weaponType = bool)
            favWsName  = nil,     -- Favorite WS name or nil for "Any"
        },
        [2] = {
            index      = 2,       -- Job dropdown index
            subIndex   = 1,       -- Subjob dropdown index (different from main job)
            lastId     = nil,     -- Last selected job ID (for change detection)
            weapons    = nil,     -- Weapon type checkboxes (table of weaponType = bool)
            favWsName  = nil,     -- Favorite WS name or nil for "Any"
        },
    },

    -- Current filter checkbox and dropdown selections
    filters = {
        scLevel      = 1,         -- Skillchain level dropdown (1-3)
        elementIndex = 1,         -- Element dropdown index (1 = "Any")
        both         = false,     -- "Both Directions" checkbox
        includeSubjob = false,    -- "Include Subjob" checkbox
        enableFavWs  = false,     -- "Favorite WS" checkbox
    },

    -- Custom level filter settings
    customLevel = {
        enabled = false,          -- Custom level checkbox
        value   = SkillchainCore.MAX_LEVEL,  -- Level slider value
    },

    -- UI state tracking
    activeTab = 'Calculator',     -- Current active tab (for dynamic height)
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
        local rowsSubjob = state.filters.includeSubjob and 1 or 0;
        -- Add extra row for favorite WS dropdown if enabled
        local rowsFavWs = state.filters.enableFavWs and 1 or 0;
        -- Add extra row for custom level dropdown if enabled
        local rowsLevel = state.customLevel.enabled and 2.5 or 0;
        return (rowsBase + rowsWeapons + rowsSubjob + rowsFavWs + rowsLevel) * lineHeight + paddingAdjust;
    elseif tabName == 'Filters' then
        paddingAdjust = 5;
        return 19 * lineHeight + paddingAdjust;
    elseif tabName == 'Settings' then
        --paddingAdjust = 0;
        return 19 * lineHeight + paddingAdjust;
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

-- Styled button helper: handles primary (blue) and ghost (transparent) button styles
local function styledButton(label, size, isPrimary)
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0);

    if isPrimary then
        -- Primary button style (blue)
        imgui.PushStyleColor(ImGuiCol_Button,        { 0.25, 0.40, 0.85, 1.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 0.30, 0.48, 0.95, 1.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 0.18, 0.32, 0.70, 1.00 });
    else
        -- Ghost button style (transparent)
        imgui.PushStyleColor(ImGuiCol_Button,        { 0.00, 0.00, 0.00, 0.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 1.00, 1.00, 1.00, 0.12 });
        imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 1.00, 1.00, 1.00, 0.20 });
    end

    local clicked = imgui.Button(label, size);

    imgui.PopStyleColor(3);
    imgui.PopStyleVar(1);

    return clicked;
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
    local list = SkillchainCore.GetWeaponsForJob(jobId);
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

-- Helper to find WS index in favorite WS dropdown items
-- Returns index (1 = "Any") or 1 if not found
local function findFavWsIndex(items, wsName)
    if not wsName then
        return 1;  -- nil = "Any"
    end

    for i, name in ipairs(items) do
        if name == wsName then
            return i;
        end
    end

    return 1;  -- Not found, default to "Any"
end

-- Ensure weapon selection is valid for a job state object
-- jobState: reference to state.jobs[1] or state.jobs[2]
local function ensureJobWeaponSelection(jobState)
    local jobId = jobItems[jobState.index] or jobItems[1];

    if not jobId then
        return;
    end

    -- If job changed, rebuild defaults from jobs.lua.
    if jobId ~= jobState.lastId then
        jobState.weapons = buildDefaultWeaponSelection(jobId, true);
        jobState.lastId = jobId;
        jobState.favWsName = nil;  -- Reset favorite WS when job changes

        -- If subjobs are enabled, set the default subjob for this job
        if state.filters.includeSubjob then
            local defaultSubjob = jobsData.GetDefaultSubjob(jobId);
            if defaultSubjob then
                local subIdx = findJobIndex(defaultSubjob);
                if subIdx then
                    jobState.subIndex = subIdx;
                end
            end
        end
    elseif type(jobState.weapons) ~= 'table' then
        -- Same job, but somehow no table yet.
        jobState.weapons = {};
    end
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
        state.filters.includeSubjob = true;  -- Auto-enable subjob filter if token contains subjob
    elseif state.filters.includeSubjob then
        -- No subjob in token, but subjobs are enabled - use default subjob
        local defaultSubjob = jobsData.GetDefaultSubjob(jobId);
        if defaultSubjob then
            subIdx = findJobIndex(defaultSubjob) or 1;
        end
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
        state.jobs[1].index    = idx;
        state.jobs[1].subIndex = subIdx;
        state.jobs[1].lastId   = jobId;
        state.jobs[1].weapons  = sel;
    else
        state.jobs[2].index    = idx;
        state.jobs[2].subIndex = subIdx;
        state.jobs[2].lastId   = jobId;
        state.jobs[2].weapons  = sel;
    end
end

-- Draw weapon checkboxes for a job state object
-- jobState: reference to state.jobs[1] or state.jobs[2]
local function drawWeaponCheckboxes(jobState)
    local jobId = jobItems[jobState.index] or jobItems[1];

    local job = jobId and jobsData[jobId] or nil;
    if not job or not job.weapons then
        imgui.TextDisabled('(no weapons)');
        return false;
    end

    local list = SkillchainCore.GetWeaponsForJob(jobId);

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

    local weaponsChanged = false;

    for _, w in ipairs(list) do
        -- Move text + checkbox inward
        imgui.SetCursorPosX(baseX + indent);

        local checked = { jobState.weapons[w] and true or false };

        if primarySet[w] then
            imgui.PushStyleColor(ImGuiCol_Text, { 1.00, 0.90, 0.40, 1.00 }); -- gold tint
        end

        if imgui.Checkbox(w, checked) then
            jobState.weapons[w] = checked[1];
            weaponsChanged = true;
        end

        if primarySet[w] then
            imgui.PopStyleColor();
        end
    end

    return weaponsChanged;
end

-- Build favorite WS dropdown items from selected weapons for a job state object
-- Returns: table of WS display names, starting with 'Any', in reverse skill order grouped by weapon type
-- jobState: reference to state.jobs[1] or state.jobs[2]
local function buildFavWsItems(jobState)
    local items = { 'Any' };

    local jobId = jobItems[jobState.index] or jobItems[1];
    local subJobId = state.filters.includeSubjob and (jobItems[jobState.subIndex] or nil) or nil;
    local charLevel = state.customLevel.enabled and state.customLevel.value or nil;

    if not jobId or not jobState.weapons then
        return items;
    end

    local job = jobsData[jobId];
    if not job or not job.weapons then
        return items;
    end

    local weaponList = SkillchainCore.GetWeaponsForJob(jobId);

    -- Collect weapon skills grouped by weapon type
    local weaponGroups = {};

    for _, weaponKey in ipairs(weaponList) do
        if jobState.weapons[weaponKey] then
            local weaponSkills = skills[weaponKey];
            if weaponSkills then
                local wsForWeapon = {};

                for index, ws in pairs(weaponSkills) do
                    if type(ws) == 'table' and ws.en then
                        -- Check skill level requirement
                        local wsSkill = ws.skill or 0;
                        local weaponCfg = job.weapons[weaponKey];
                        local skillRank = weaponCfg and weaponCfg.skillRank;

                        local maxSkill = 999;
                        if skillRank and SkillRanks and SkillRanks.Cap and SkillRanks.Cap[skillRank] then
                            local levelToUse = charLevel or SkillchainCore.MAX_LEVEL;
                            maxSkill = SkillRanks.Cap[skillRank][levelToUse] or 999;
                        end

                        -- Check job restrictions
                        if wsSkill <= maxSkill and SkillchainCore.IsJobAllowedForWs(ws, jobId, subJobId) then
                            table.insert(wsForWeapon, {
                                name = ws.en,
                                index = index
                            });
                        end
                    end
                end

                if #wsForWeapon > 0 then
                    -- Sort in reverse order (highest index first)
                    table.sort(wsForWeapon, function(a, b)
                        return a.index > b.index;
                    end);

                    weaponGroups[weaponKey] = wsForWeapon;
                end
            end
        end
    end

    -- Add weapon skills to items list, maintaining weapon type grouping order
    for _, weaponKey in ipairs(weaponList) do
        local group = weaponGroups[weaponKey];
        if group then
            -- Add all weapon skills for this weapon (no header)
            for _, ws in ipairs(group) do
                table.insert(items, ws.name);
            end
        end
    end

    return items;
end

-- Helper function to build calculation request from current state
local function buildCalculationRequest()
    local job1Id = jobItems[state.jobs[1].index] or jobItems[1];
    local job2Id = jobItems[state.jobs[2].index] or jobItems[2];

    local job1SubId = state.filters.includeSubjob and jobItems[state.jobs[1].subIndex] or nil;
    local job2SubId = state.filters.includeSubjob and jobItems[state.jobs[2].subIndex] or nil;

    local token1 = SkillchainCore.BuildTokenFromSelection(job1Id, state.jobs[1].weapons, job1SubId);
    local token2 = SkillchainCore.BuildTokenFromSelection(job2Id, state.jobs[2].weapons, job2SubId);

    local elemTok = elementTokens[state.filters.elementIndex] or '';

    -- Get favorite WS names directly from state (much simpler now!)
    local favWs1 = state.filters.enableFavWs and state.jobs[1].favWsName or nil;
    local favWs2 = state.filters.enableFavWs and state.jobs[2].favWsName or nil;

    -- Disable drag when Calculate is pressed
    cache.settings.enableDrag = false;

    return {
        mode      = 'pair',
        token1    = token1,
        token2    = token2,
        scLevel   = state.filters.scLevel or 1,
        both      = state.filters.both,
        scElement = (elemTok ~= '' and elemTok) or nil,
        charLevel = state.customLevel.enabled and state.customLevel.value or nil,
        favWs1    = favWs1,
        favWs2    = favWs2,
    };
end

local function drawCalculatorTab()
    local request = nil;

    -----------------------------------------------------------------------
    -- Custom Level section (if enabled)
    -----------------------------------------------------------------------
    if state.customLevel.enabled then
        drawGradientHeader('Character Level', imgui.GetContentRegionAvail());

        local indent = 5;

        imgui.SetCursorPosX(imgui.GetCursorPosX() + indent);
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
        state.customLevel.value = drawCombo('##charlevel', levelItems, state.customLevel.value);
        imgui.PopItemWidth();

        -- No reset needed - if WS becomes unavailable, dropdown will auto-reset to "Any"

        imgui.Spacing();
        imgui.Separator();
        imgui.Spacing();
    end

    -----------------------------------------------------------------------
    -- Jobs + weapons section
    -----------------------------------------------------------------------
    drawGradientHeader('Jobs & Weapons', imgui.GetContentRegionAvail());

    ensureJobWeaponSelection(state.jobs[1]);
    ensureJobWeaponSelection(state.jobs[2]);

    imgui.Columns(3, 'scc_jobs_cols', false);
    imgui.SetColumnWidth(0, JOB_COLUMN_WIDTH);
    imgui.SetColumnWidth(1, 30);
    imgui.SetColumnWidth(2, JOB_COLUMN_WIDTH);

    -- Row 1: job combos + arrow
    imgui.PushItemWidth(JOB_COLUMN_WIDTH - 18);
    local prevJob1Index = state.jobs[1].index;
    state.jobs[1].index = drawCombo('##fromjob', jobItems, state.jobs[1].index);
    imgui.PopItemWidth();

    imgui.NextColumn();
    do
        local arrow      = state.filters.both and '<->' or '->';
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
    local prevJob2Index = state.jobs[2].index;
    state.jobs[2].index = drawCombo('##tojob', jobItems, state.jobs[2].index);
    imgui.PopItemWidth();

    -- Row 1.5: subjob combos (if enabled)
    if state.filters.includeSubjob then
        imgui.NextColumn();
        local curX = imgui.GetCursorPosX();
        imgui.SetCursorPosX(curX + 5);
        imgui.Text('/');
        imgui.SameLine();
        imgui.PushItemWidth(JOB_COLUMN_WIDTH - 30);
        local prevJob1SubIndex = state.jobs[1].subIndex;
        state.jobs[1].subIndex = drawCombo('##fromsubjob', jobItems, state.jobs[1].subIndex);
        imgui.PopItemWidth();

        imgui.NextColumn();
        -- Empty center column for subjobs

        imgui.NextColumn();
        curX = imgui.GetCursorPosX();
        imgui.SetCursorPosX(curX + 5);
        imgui.Text('/');
        imgui.SameLine();
        imgui.PushItemWidth(JOB_COLUMN_WIDTH - 30);
        local prevJob2SubIndex = state.jobs[2].subIndex;
        state.jobs[2].subIndex = drawCombo('##tosubjob', jobItems, state.jobs[2].subIndex);
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

        state.jobs[1].index, state.jobs[1].subIndex = ensureJobsAreDifferent(state.jobs[1].index, state.jobs[1].subIndex, prevJob1Index, prevJob1SubIndex);
        state.jobs[2].index, state.jobs[2].subIndex = ensureJobsAreDifferent(state.jobs[2].index, state.jobs[2].subIndex, prevJob2Index, prevJob2SubIndex);

        -- No reset needed - if WS becomes unavailable due to subjob change, dropdown will auto-reset to "Any"
    end

    ensureJobWeaponSelection(state.jobs[1]);
    ensureJobWeaponSelection(state.jobs[2]);

    -- Row 1.75: favorite WS combos (if enabled)
    if state.filters.enableFavWs then
        local job1FavWsItems = buildFavWsItems(state.jobs[1]);
        local job2FavWsItems = buildFavWsItems(state.jobs[2]);

        imgui.NextColumn();
        imgui.PushItemWidth(JOB_COLUMN_WIDTH - 18);
        -- Convert name to index for dropdown, then convert back to name
        local job1Index = findFavWsIndex(job1FavWsItems, state.jobs[1].favWsName);

        -- If we have a stored WS but it's not in the list (index = 1/"Any"), clear it permanently
        if state.jobs[1].favWsName and job1Index == 1 then
            state.jobs[1].favWsName = nil;
        end

        local newJob1Index = drawCombo('##fromfavws', job1FavWsItems, job1Index);
        if newJob1Index ~= job1Index then
            -- Selection changed, update the stored name
            state.jobs[1].favWsName = (newJob1Index == 1) and nil or job1FavWsItems[newJob1Index];
        end
        imgui.PopItemWidth();

        imgui.NextColumn();
        -- Empty center column for favorite WS

        imgui.NextColumn();
        imgui.PushItemWidth(JOB_COLUMN_WIDTH - 18);
        -- Convert name to index for dropdown, then convert back to name
        local job2Index = findFavWsIndex(job2FavWsItems, state.jobs[2].favWsName);

        -- If we have a stored WS but it's not in the list (index = 1/"Any"), clear it permanently
        if state.jobs[2].favWsName and job2Index == 1 then
            state.jobs[2].favWsName = nil;
        end

        local newJob2Index = drawCombo('##tofavws', job2FavWsItems, job2Index);
        if newJob2Index ~= job2Index then
            -- Selection changed, update the stored name
            state.jobs[2].favWsName = (newJob2Index == 1) and nil or job2FavWsItems[newJob2Index];
        end
        imgui.PopItemWidth();
    end

    -- Row 2: weapons under each job
    imgui.NextColumn();
    imgui.PushID('job1_weapons');
    local job1WeaponsChanged = drawWeaponCheckboxes(state.jobs[1]);
    imgui.PopID();

    imgui.NextColumn();
    imgui.Dummy({ 0, 0 }); -- keep center empty

    imgui.NextColumn();
    imgui.PushID('job2_weapons');
    local job2WeaponsChanged = drawWeaponCheckboxes(state.jobs[2]);
    imgui.PopID();

    imgui.Columns(1);

    -- Smart reset: only reset favorite WS if it's no longer available after weapon change
    if job1WeaponsChanged and state.jobs[1].favWsName then
        local items = buildFavWsItems(state.jobs[1]);
        local found = false;
        for _, name in ipairs(items) do
            if name == state.jobs[1].favWsName then
                found = true;
                break;
            end
        end
        if not found then
            state.jobs[1].favWsName = nil;  -- WS no longer available, reset to "Any"
        end
    end

    if job2WeaponsChanged and state.jobs[2].favWsName then
        local items = buildFavWsItems(state.jobs[2]);
        local found = false;
        for _, name in ipairs(items) do
            if name == state.jobs[2].favWsName then
                found = true;
                break;
            end
        end
        if not found then
            state.jobs[2].favWsName = nil;  -- WS no longer available, reset to "Any"
        end
    end

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
    if styledButton('Calculate', { buttonWidth, 0 }, true) then
        request = buildCalculationRequest();
    end

    imgui.SameLine();

    -- Secondary action: Clear (ghost button style)
    if styledButton('Clear', { buttonWidth, 0 }, false) then
        local curJob1Id = jobItems[state.jobs[1].index];
        local curJob2Id = jobItems[state.jobs[2].index];

        state.jobs[1].weapons = buildDefaultWeaponSelection(curJob1Id, false);
        state.jobs[2].weapons = buildDefaultWeaponSelection(curJob2Id, false);

        request = { clear = true };
    end

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
    state.filters.elementIndex = drawCombo('##scelement', elementItems, state.filters.elementIndex);
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
    local lvl = { state.filters.scLevel };
    if imgui.SliderInt('##sclevel', lvl, 1, 3) then
        state.filters.scLevel = lvl[1];
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
    local useCustomLevel = { state.customLevel.enabled };
    if imgui.Checkbox('Enable custom character level', useCustomLevel) then
        state.customLevel.enabled = useCustomLevel[1];
        -- No reset needed - dropdown will auto-reset to "Any" if WS becomes unavailable
    end
    imgui.SameLine();
    helpMarker('When enabled, adds a level dropdown in Calculator tab\nfor skill-based weapon skill filtering.');

    -- Both Directions Checkbox
    imgui.SetCursorPosX(baseX + indent);
    local both = { state.filters.both };
    if imgui.Checkbox('Calculate skillchains in both directions', both) then
        state.filters.both = both[1];
    end
    imgui.SameLine();
    helpMarker('When enabled, calculates Job1->Job2 AND Job2->Job1');

    -- Include Subjob Checkbox
    imgui.SetCursorPosX(baseX + indent);
    local includeSubjob = { state.filters.includeSubjob };
    if imgui.Checkbox('Enable SubJob in Calculator', includeSubjob) then
        local wasEnabled = state.filters.includeSubjob;
        state.filters.includeSubjob = includeSubjob[1];

        -- When first enabling subjobs, populate default subjobs for both sides
        if not wasEnabled and state.filters.includeSubjob then
            for i = 1, 2 do
                local jobId = jobItems[state.jobs[i].index];
                if jobId then
                    local defaultSubjob = jobsData.GetDefaultSubjob(jobId);
                    if defaultSubjob then
                        local subIdx = findJobIndex(defaultSubjob);
                        if subIdx then
                            state.jobs[i].subIndex = subIdx;
                        end
                    end
                end
            end
        end

        -- No reset needed - dropdown will auto-reset to "Any" if WS becomes unavailable
    end
    imgui.SameLine();
    helpMarker('When enabled, adds subjob dropdowns in Calculator tab.\nThis allows filtering weaponskills based on subjob restrictions\n(e.g., marksmanship).');

    -- Enable Favorite WS Checkbox
    imgui.SetCursorPosX(baseX + indent);
    local enableFavWs = { state.filters.enableFavWs };
    if imgui.Checkbox('Enable favorite WS in Calculator', enableFavWs) then
        local wasEnabled = state.filters.enableFavWs;
        state.filters.enableFavWs = enableFavWs[1];

        -- Reset favorite WS when disabling the filter (clean slate for next time)
        if wasEnabled and not state.filters.enableFavWs then
            state.jobs[1].favWsName = nil;
            state.jobs[2].favWsName = nil;
        end
    end
    imgui.SameLine();
    helpMarker('When enabled, adds favorite weaponskill dropdowns in Calculator tab.\nThis allows filtering results to show only specific weapon skills.');

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
    if styledButton('Set as Defaults', { buttonWidth, 0 }, true) then
        local def = (cache and cache.settings and cache.settings.default) or {};
        def.scLevel = state.filters.scLevel;
        def.both  = state.filters.both;
        def.includeSubjob = state.filters.includeSubjob;
        def.useCharLevel = state.customLevel.enabled;
        def.enableFavWs = state.filters.enableFavWs;
        cache.settings.default = def;

        request = request or {};
        request.updateDefaults = true;
    end

    imgui.SameLine();

    -- Reset Filters button (ghost style)
    if styledButton('Reset Filters', { buttonWidth, 0 }, false) then
        -- Reset to stored defaults
        local def = (cache and cache.settings and cache.settings.default) or {};
        state.filters.scLevel = def.scLevel or 1;
        state.filters.both  = def.both  or false;
        state.filters.includeSubjob = def.includeSubjob or false;
        state.customLevel.enabled = def.useCharLevel or false;
        state.filters.enableFavWs = def.enableFavWs or false;
        state.filters.elementIndex = 1;
    end

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
    if styledButton('Calculate', { calcButtonWidth, 0 }, true) then
        -- Ensure weapon selections exist for current jobs
        ensureJobWeaponSelection(state.jobs[1]);
        ensureJobWeaponSelection(state.jobs[2]);

        request = buildCalculationRequest();
    end

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

    -- Use shared limit calculation from SkillchainRenderer
    local SkillchainRenderer = require('SkillchainRenderer');
    local limits = SkillchainRenderer.calculateAnchorLimits(cache.settings);
    local pad = limits.minX;
    local maxX = limits.maxX;
    local maxY = limits.maxY;

    drawGradientHeader('Results Window Anchor (top-left)', imgui.GetContentRegionAvail());
    imgui.Spacing();

    -- 5px indent
    local baseX  = imgui.GetCursorPosX();
    local indent = 5;

    imgui.SetCursorPosX(baseX + indent);
    local enableDrag = { cache.settings.enableDrag or false };
    if imgui.Checkbox('Enable Drag', enableDrag) then
        cache.settings.enableDrag = enableDrag[1];
        request = request or {};
        request.anchorChanged = true;
    end

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

    imgui.SetCursorPosX(baseX + indent);
    imgui.Text(string.format("Enable Fav WS:    %s", tostring(def.enableFavWs or false)));

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
    imgui.Text('/scc setfavws <true|false>');

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
    if not cache or cache.step.enabled then
        return;
    end

    local def = (cache.settings and cache.settings.default) or {};

    -- Filters from CLI (with fallback to defaults)
    state.filters.scLevel = cache.filters.scLevel or def.scLevel or 1;

    if cache.filters.both ~= nil then
        state.filters.both = cache.filters.both;
    else
        state.filters.both = def.both or false;
    end

    -- Don't set includeSubjob yet - let applyTokenToSide detect it from tokens first
    -- We'll set it from defaults after if it wasn't set by tokens
    local initialSubjob = def.includeSubjob or false;

    -- Element from cache.filters.scElement
    state.filters.elementIndex = 1;
    if cache.filters.scElement then
        local lower = cache.filters.scElement:lower();
        for i, tok in ipairs(elementTokens) do
            if tok == lower then
                state.filters.elementIndex = i;
                break;
            end
        end
    end

    -- Jobs + weapons from token1 / token2
    -- These may set state.filters.includeSubjob = true if tokens contain subjobs
    if cache.jobs.token1 then
        applyTokenToSide(1, cache.jobs.token1);
    end
    if cache.jobs.token2 then
        applyTokenToSide(2, cache.jobs.token2);
    end

    -- Only override includeSubjob if explicitly set to true in cache, or use defaults if tokens didn't enable it
    if cache.filters.includeSubjob == true then
        state.filters.includeSubjob = true;
    elseif not state.filters.includeSubjob then
        state.filters.includeSubjob = initialSubjob;
    end

    -- Custom level from CLI
    if cache.filters.charLevel then
        state.customLevel.enabled = true;
        state.customLevel.value = cache.filters.charLevel;
    else
        state.customLevel.enabled = def.useCharLevel or false;
    end

    -- Favorite WS filter from defaults (CLI doesn't support setting this directly)
    state.filters.enableFavWs = def.enableFavWs or false;

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
    end
end

function SkillchainGUI.SetVisible(v)
    showWindow[1] = v;
    if showWindow[1] then
        state.initialized = false;
        state.openedFromCli = false;
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
        -- Disable drag when GUI is closed
        if cache and cache.settings then
            cache.settings.enableDrag = false;
        end
        return nil;
    end

    -- one-time sync from settings defaults
    if (not state.initialized) and cache and cache.settings and cache.settings.default then
        local def = cache.settings.default;

        -- Only apply defaults when NOT opened from CLI
        if not state.openedFromCli then
            state.filters.scLevel = def.scLevel or 1;

            if def.both ~= nil then
                state.filters.both = def.both;
            else
                state.filters.both = false;
            end

            if def.includeSubjob ~= nil then
                state.filters.includeSubjob = def.includeSubjob;
            else
                state.filters.includeSubjob = false;
            end

            if def.enableFavWs ~= nil then
                state.filters.enableFavWs = def.enableFavWs;
            else
                state.filters.enableFavWs = false;
            end

            if def.useCharLevel ~= nil then
                state.customLevel.enabled = def.useCharLevel;
            else
                state.customLevel.enabled = false;
            end
        end

        state.filters.elementIndex = 1;
        if cache.filters.scElement then
            local lower = cache.filters.scElement:lower();
            for i, tok in ipairs(elementTokens) do
                if tok == lower then
                    state.filters.elementIndex = i;
                    break;
                end
            end
        end

        state.initialized   = true;
        state.openedFromCli = false;
    end

    -- derive current jobs to estimate height for Calculator tab
    local job1Id = jobItems[state.jobs[1].index] or jobItems[1];
    local job2Id = jobItems[state.jobs[2].index] or jobItems[2];

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
