-- SkillchainGui.lua
-- ImGui input window for SkillchainCalc (GDI shows results).

require('common');
local imgui    = require('imgui');
local jobsData = require('Jobs');
local skills   = require('Skills');
local SkillchainCore = require('SkillchainCore');
local SkillchainUI = require('SkillchainUI');
local uiTheme = require('libs/uiTheme');

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
-- Character level dropdown items "1".."MAX_LEVEL"; index i is level i.
-----------------------------------------------------------------------
local levelItems = {};
for i = 1, jobsData.MAX_LEVEL do
    table.insert(levelItems, tostring(i));
end

-----------------------------------------------------------------------
-- Burst element dropdown
-----------------------------------------------------------------------
local elementItems  = { 'Any' };
local elementTokens = { '' };
for _, elem in ipairs(SkillchainCore.BURST_ELEMENTS) do
    table.insert(elementItems,  elem);
    table.insert(elementTokens, elem:lower());
end

-- Resolves an element filter token (e.g. cache.filters.scElement, lowercase)
-- to its dropdown index, or 1 ("Any") if absent/unrecognized.
local function resolveElementIndex(elementToken)
    if not elementToken then
        return 1;
    end

    local lower = elementToken:lower();
    for i, tok in ipairs(elementTokens) do
        if tok == lower then
            return i;
        end
    end

    return 1;
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
        showRema     = false,     -- "Show REMA WS" checkbox (disabled by default)
    },

    -- Custom level filter settings
    customLevel = {
        enabled = false,          -- Custom level checkbox
        value   = jobsData.MAX_LEVEL,  -- Level slider value
    },
};

-- Module-level cache reference (set externally via SetCache)
local cache = nil;

-- True while a weapon-only CLI run is displayed; its tokens come from cache.jobs.
local function isCliLocked()
    return cache ~= nil and cache.cliCommand ~= nil;
end

-- Syncs the GUI-only filter fields (never mirrored into cache.filters) from
-- stored defaults, with the level back at max. Shared by Reset Filters,
-- OpenFromCli, and DrawWindow's one-time init.
local function syncGuiOnlyDefaults(def)
    state.filters.enableFavWs = def.enableFavWs or false;
    state.customLevel.enabled = def.useCharLevel or false;
    state.customLevel.value   = jobsData.MAX_LEVEL;
end

-----------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------
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

-- Sets a side's subjob dropdown to its job's default subjob, if it has one.
local function applyDefaultSubjob(jobState, jobId)
    local subJobId = SkillchainCore.ResolveSubjob(jobId, nil, true);
    local subIdx = subJobId and findJobIndex(subJobId);
    if subIdx then
        jobState.subIndex = subIdx;
    end
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

        if state.filters.includeSubjob then
            applyDefaultSubjob(jobState, jobId);
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

    -- A token naming a subjob other than the main job turns subjobs on.
    if subJobId and subJobId ~= jobId then
        state.filters.includeSubjob = true;
    end

    local idx = findJobIndex(jobId) or 1;
    local effectiveSub = SkillchainCore.ResolveSubjob(jobId, subJobId, state.filters.includeSubjob);
    local subIdx = effectiveSub and findJobIndex(effectiveSub) or 1;

    local sel = {};

    -- If the token had an explicit weapon list (job:weapon1,weapon2)
    if allowedWeapons and next(allowedWeapons) then
        for w, _ in pairs(allowedWeapons) do
            -- Check both weapons and frames (for PUP automaton frames)
            if job.weapons[w] or (job.frames and job.frames[w]) then
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
        return;
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

    for _, w in ipairs(list) do
        -- Move text + checkbox inward
        imgui.SetCursorPosX(baseX + indent);

        local checked = { jobState.weapons[w] and true or false };

        if primarySet[w] then
            imgui.PushStyleColor(ImGuiCol_Text, { 1.00, 0.90, 0.40, 1.00 }); -- gold tint
        end

        if imgui.Checkbox(w, checked) then
            jobState.weapons[w] = checked[1];
        end

        if primarySet[w] then
            imgui.PopStyleColor();
        end
    end
end

-- Cached fav WS item lists; invalidated by cache key when job/weapons/level/showRema changes
local favWsItemsCache = { [1] = { key = nil, items = nil }, [2] = { key = nil, items = nil } };

-- Build favorite WS dropdown items from selected weapons for a job state object.
-- Returns: table of WS display names, starting with 'Any', in reverse skill order grouped by weapon type.
-- side: 1 or 2, used as cache slot key.
local function buildFavWsItems(jobState, side)
    local jobId = jobItems[jobState.index] or jobItems[1];
    local subJobId = state.filters.includeSubjob and (jobItems[jobState.subIndex] or nil) or nil;
    local charLevel = state.customLevel.enabled and state.customLevel.value or nil;

    -- Build cache key from all inputs that affect the result
    local selectedWeapons = {};
    if jobState.weapons then
        for w, checked in pairs(jobState.weapons) do
            if checked then table.insert(selectedWeapons, w); end
        end
        table.sort(selectedWeapons);
    end
    local cacheKey = string.format('%s|%s|%s|%s|%s', jobId or '', subJobId or '', tostring(charLevel),
        tostring(state.filters.showRema), table.concat(selectedWeapons, ','));

    local cached = favWsItemsCache[side];
    if cached and cached.key == cacheKey then
        return cached.items;
    end

    local items = { 'Any' };

    if not jobId or not jobState.weapons then
        favWsItemsCache[side] = { key = cacheKey, items = items };
        return items;
    end

    local job = jobsData[jobId];
    if not job or not job.weapons then
        favWsItemsCache[side] = { key = cacheKey, items = items };
        return items;
    end

    local weaponList = SkillchainCore.GetWeaponsForJob(jobId);

    -- Collect weapon skills grouped by weapon type.
    --
    -- PUP automaton frames are excluded on purpose: their weapon skills fire on
    -- the automaton's own schedule, so pinning results to one of them isn't
    -- actionable. The skills[weaponKey] lookup drops them (frame WS live in
    -- skills.frameMelee / skills.frameRanged). Frames still participate in the
    -- results themselves -- this filter only governs the dropdown.
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

                        local maxSkill = SkillchainCore.GetSkillCapFromRank(skillRank, charLevel);

                        local remaAllowed = SkillchainCore.IsRemaAllowed(state.filters.showRema, charLevel);
                        if wsSkill <= maxSkill and SkillchainCore.IsJobAllowedForWs(ws, jobId, subJobId)
                            and (remaAllowed or not ws.rema) then
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
            for _, ws in ipairs(group) do
                table.insert(items, ws.name);
            end
        end
    end

    favWsItemsCache[side] = { key = cacheKey, items = items };
    return items;
end

-- Clears a side's fav WS when the current job/weapon/subjob/level/REMA
-- selection no longer offers it. Returns that side's fav WS items.
local function validateFavWs(side)
    local jobState = state.jobs[side];
    local items = buildFavWsItems(jobState, side);
    if jobState.favWsName and findFavWsIndex(items, jobState.favWsName) == 1 then
        jobState.favWsName = nil;
    end
    return items;
end

-- Helper function to build calculation request from current state, or the locked CLI tokens
local function buildCalculationRequest()
    local locked = isCliLocked();
    local token1, token2;
    if locked then
        token1, token2 = cache.jobs.token1, cache.jobs.token2;
    else
        local job1Id = jobItems[state.jobs[1].index] or jobItems[1];
        local job2Id = jobItems[state.jobs[2].index] or jobItems[2];

        local job1SubId = state.filters.includeSubjob and jobItems[state.jobs[1].subIndex] or nil;
        local job2SubId = state.filters.includeSubjob and jobItems[state.jobs[2].subIndex] or nil;

        token1 = SkillchainCore.BuildTokenFromSelection(job1Id, state.jobs[1].weapons, job1SubId);
        token2 = SkillchainCore.BuildTokenFromSelection(job2Id, state.jobs[2].weapons, job2SubId);
    end

    local elemTok = elementTokens[state.filters.elementIndex] or '';

    local useFavWs = state.filters.enableFavWs and not locked;
    if useFavWs then
        validateFavWs(1);
        validateFavWs(2);
    end

    local favWs1 = useFavWs and state.jobs[1].favWsName or nil;
    local favWs2 = useFavWs and state.jobs[2].favWsName or nil;

    return {
        token1    = token1,
        token2    = token2,
        scLevel   = state.filters.scLevel or 1,
        both      = state.filters.both,
        scElement = (elemTok ~= '' and elemTok) or nil,
        charLevel = state.customLevel.enabled and state.customLevel.value or nil,
        favWs1    = favWs1,
        favWs2    = favWs2,
        showRema  = state.filters.showRema,
    };
end

local function ensureJobsAreDifferent(mainIdx, subIdx, prevMainIdx, prevSubIdx)
    if mainIdx == subIdx then
        if prevSubIdx ~= subIdx then
            return prevSubIdx, subIdx;
        elseif prevMainIdx ~= mainIdx then
            return mainIdx, prevMainIdx;
        end
    end
    return mainIdx, subIdx;
end

-- Draws the favorite-WS combo for one side (1 = opener/"from", 2 = closer/"to").
local function drawFavWsCombo(side, comboId)
    local jobState = state.jobs[side];
    local items = validateFavWs(side);

    imgui.PushItemWidth(JOB_COLUMN_WIDTH - 18);
    local index = findFavWsIndex(items, jobState.favWsName);

    local newIndex = drawCombo(comboId, items, index);
    if newIndex ~= index then
        -- Selection changed, update the stored name
        if newIndex == 1 then
            jobState.favWsName = nil;
        else
            jobState.favWsName = items[newIndex];
        end
    end
    imgui.PopItemWidth();
end

-- Clear resets state.initialized so the filters re-sync from defaults.
local function drawCliCommandTab()
    uiTheme.header('CLI Command');

    imgui.Indent(uiTheme.indent);
    imgui.TextWrapped(cache.cliCommand);
    imgui.Unindent(uiTheme.indent);

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    local availWidth  = imgui.GetContentRegionAvail();
    local buttonWidth = 120;
    if availWidth > buttonWidth then
        imgui.SetCursorPosX(imgui.GetCursorPosX() + ((availWidth - buttonWidth) / 2));
    end

    if uiTheme.button('Clear', buttonWidth, 'primary') then
        state.initialized = false;
        return { clear = true };
    end

    return nil;
end

local function drawCalculatorTab()
    if isCliLocked() then
        return drawCliCommandTab();
    end

    local request = nil;

    -----------------------------------------------------------------------
    -- Custom Level section (if enabled)
    -----------------------------------------------------------------------
    if state.customLevel.enabled then
        uiTheme.header('Character Level');

        imgui.Indent(uiTheme.indent);
        imgui.SetNextItemWidth(uiTheme.comboWidth());
        state.customLevel.value = drawCombo('Level##charlevel', levelItems, state.customLevel.value);
        imgui.Unindent(uiTheme.indent);

        imgui.Spacing();
    end

    -----------------------------------------------------------------------
    -- Jobs + weapons section
    -----------------------------------------------------------------------
    uiTheme.header('Jobs & Weapons');

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

        state.jobs[1].index, state.jobs[1].subIndex = ensureJobsAreDifferent(state.jobs[1].index, state.jobs[1].subIndex, prevJob1Index, prevJob1SubIndex);
        state.jobs[2].index, state.jobs[2].subIndex = ensureJobsAreDifferent(state.jobs[2].index, state.jobs[2].subIndex, prevJob2Index, prevJob2SubIndex);
    end

    ensureJobWeaponSelection(state.jobs[1]);
    ensureJobWeaponSelection(state.jobs[2]);

    -- Row 1.75: favorite WS combos (if enabled)
    if state.filters.enableFavWs then
        imgui.NextColumn();
        drawFavWsCombo(1, '##fromfavws');

        imgui.NextColumn();
        -- Empty center column for favorite WS

        imgui.NextColumn();
        drawFavWsCombo(2, '##tofavws');
    end

    -- Row 2: weapons under each job
    imgui.NextColumn();
    imgui.PushID('job1_weapons');
    drawWeaponCheckboxes(state.jobs[1]);
    imgui.PopID();

    imgui.NextColumn();
    imgui.Dummy({ 0, 0 }); -- keep center empty

    imgui.NextColumn();
    imgui.PushID('job2_weapons');
    drawWeaponCheckboxes(state.jobs[2]);
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
    if uiTheme.button('Calculate', buttonWidth, 'primary') then
        request = buildCalculationRequest();
    end

    imgui.SameLine();

    -- Secondary action: Clear (ghost button style)
    if uiTheme.button('Clear', buttonWidth, 'ghost') then
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

    local filterWidth = JOB_COLUMN_WIDTH * 2;

    -----------------------------------------------------------------------
    -- Element Filter
    -----------------------------------------------------------------------
    uiTheme.header('Skillchain Element (sc:<element>)');

    imgui.Indent(uiTheme.indent);
    imgui.SetNextItemWidth(uiTheme.comboWidth());
    state.filters.elementIndex = drawCombo('Burst element##scelement', elementItems, state.filters.elementIndex);
    imgui.Unindent(uiTheme.indent);

    imgui.Spacing();

    -----------------------------------------------------------------------
    -- Level Filter
    -----------------------------------------------------------------------
    uiTheme.header('Skillchain Level (1, 2, 3)');

    imgui.Indent(uiTheme.indent);
    imgui.Text('Minimum skillchain tier:');
    imgui.PushItemWidth(filterWidth - uiTheme.indent);
    local lvl = { state.filters.scLevel };
    if imgui.SliderInt('##sclevel', lvl, 1, 3) then
        state.filters.scLevel = lvl[1];
    end
    imgui.PopItemWidth();

    imgui.Spacing();
    imgui.Text('  1 = All skillchains');
    imgui.Text('  2 = Level 2+ only');
    imgui.Text('  3 = Level 3 only');
    imgui.Unindent(uiTheme.indent);

    imgui.Spacing();

    -----------------------------------------------------------------------
    -- Advanced Filters Section
    -----------------------------------------------------------------------
    uiTheme.header('Advanced Filters');

    imgui.Indent(uiTheme.indent);

    -- Level, subjob and Fav WS add controls to the job-picker view, which a
    -- CLI-locked run replaces; a CLI lvl: still applies.
    if not isCliLocked() then
        -- Custom Level Checkbox
        local useCustomLevel = { state.customLevel.enabled };
        if imgui.Checkbox('Enable custom character level', useCustomLevel) then
            state.customLevel.enabled = useCustomLevel[1];
        end
        uiTheme.helpMarker('When enabled, adds a level dropdown in Calculator tab\nfor skill-based weapon skill filtering.');

        -- Include Subjob Checkbox
        local includeSubjob = { state.filters.includeSubjob };
        if imgui.Checkbox('Enable subjob in calculator', includeSubjob) then
            local wasEnabled = state.filters.includeSubjob;
            state.filters.includeSubjob = includeSubjob[1];

            -- When first enabling subjobs, populate default subjobs for both sides
            if not wasEnabled and state.filters.includeSubjob then
                for i = 1, 2 do
                    local jobId = jobItems[state.jobs[i].index];
                    if jobId then
                        applyDefaultSubjob(state.jobs[i], jobId);
                    end
                end
            end
        end
        uiTheme.helpMarker('When enabled, adds subjob dropdowns in Calculator tab.\nThis allows filtering weaponskills based on subjob restrictions\n(e.g., marksmanship).');

        -- Enable Favorite WS Checkbox
        local enableFavWs = { state.filters.enableFavWs };
        if imgui.Checkbox('Enable favorite WS in calculator', enableFavWs) then
            local wasEnabled = state.filters.enableFavWs;
            state.filters.enableFavWs = enableFavWs[1];

            -- Reset favorite WS when disabling the filter (clean slate for next time)
            if wasEnabled and not state.filters.enableFavWs then
                state.jobs[1].favWsName = nil;
                state.jobs[2].favWsName = nil;
            end
        end
        uiTheme.helpMarker('When enabled, adds favorite weaponskill dropdowns in Calculator tab.\nThis allows filtering results to show only specific weapon skills.');
    end

    -- Both Directions Checkbox
    local both = { state.filters.both };
    if imgui.Checkbox('Calculate skillchains in both directions', both) then
        state.filters.both = both[1];
    end
    uiTheme.helpMarker('When enabled, calculates Job1->Job2 AND Job2->Job1');

    -- Show REMA WS Checkbox
    local showRema = { state.filters.showRema };
    if imgui.Checkbox('Show REMA weapon skills (²)', showRema) then
        state.filters.showRema = showRema[1];
    end
    uiTheme.helpMarker('When enabled, includes Relic/Empyrean/Mythic/Aeonic weapon skills\n(marked with ²) in results. Disabled by default.');
    imgui.Unindent(uiTheme.indent);

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
    if uiTheme.button('Set as defaults', buttonWidth, 'primary') then
        local def = cache.settings.default or {};
        def.scLevel = state.filters.scLevel;
        def.both  = state.filters.both;
        def.includeSubjob = state.filters.includeSubjob;
        def.useCharLevel = state.customLevel.enabled;
        def.enableFavWs = state.filters.enableFavWs;
        def.showRema = state.filters.showRema;
        cache.settings.default = def;

        request = request or {};
        request.updateDefaults = true;
    end

    imgui.SameLine();

    -- Reset Filters button (ghost style)
    if uiTheme.button('Reset filters', buttonWidth, 'ghost') then
        -- Reset to stored defaults
        local def = (cache and cache.settings and cache.settings.default) or {};
        state.filters.scLevel = def.scLevel or 1;
        state.filters.both  = def.both  or false;
        state.filters.includeSubjob = def.includeSubjob or false;
        state.filters.showRema = def.showRema or false;
        syncGuiOnlyDefaults(def);
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
    if uiTheme.button('Calculate', calcButtonWidth, 'primary') then
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

    if SkillchainUI.drawResultsWindowSettings(cache.settings) then
        request = request or {};
        request.saveSettings = true;
    end

    -----------------------------------------------------------------------
    -- Stored Default Filter Status (read-only)
    -----------------------------------------------------------------------
    imgui.Spacing();
    uiTheme.header('Stored Defaults');

    local def = cache.settings.default or {};

    imgui.Indent(uiTheme.indent);

    imgui.Text(string.format("Max level:          %d", jobsData.MAX_LEVEL));
    imgui.Text(string.format("Skillchain level:   %s", tostring(def.scLevel)));
    imgui.Text(string.format("Enable char level:  %s", tostring(def.useCharLevel or false)));
    imgui.Text(string.format("Enable subjob:      %s", tostring(def.includeSubjob or false)));
    imgui.Text(string.format("Enable favorite WS: %s", tostring(def.enableFavWs or false)));
    imgui.Text(string.format("Show REMA WS:       %s", tostring(def.showRema or false)));
    imgui.Text(string.format("Enable both:        %s", tostring(def.both or false)));
    imgui.Unindent(uiTheme.indent);

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

    -- CLI runs carry no Fav WS (cache.jobs.favWs1/2 are cleared), so the window shows none.
    state.jobs[1].favWsName = nil;
    state.jobs[2].favWsName = nil;

    -- Filters from CLI (with fallback to defaults)
    state.filters.scLevel = cache.filters.scLevel or def.scLevel or 1;

    state.filters.both = cache.filters.both;

    -- Set includeSubjob from defaults first, so applyTokenToSide can use it
    state.filters.includeSubjob = def.includeSubjob or false;

    -- Element from cache.filters.scElement
    state.filters.elementIndex = resolveElementIndex(cache.filters.scElement);

    -- Jobs + weapons from token1 / token2
    -- These may set state.filters.includeSubjob = true if tokens contain explicit subjobs
    -- Skipped when locked: a subjob token would turn on the hidden subjob toggle, which Set as defaults saves.
    if not isCliLocked() then
        if cache.jobs.token1 then
            applyTokenToSide(1, cache.jobs.token1);
        end
        if cache.jobs.token2 then
            applyTokenToSide(2, cache.jobs.token2);
        end
    end

    -- Custom level from CLI, falling back to defaults (also syncs enableFavWs)
    syncGuiOnlyDefaults(def);
    if cache.filters.charLevel then
        state.customLevel.enabled = true;
        state.customLevel.value = cache.filters.charLevel;
    end

    -- REMA filter from defaults (CLI doesn't support setting this directly)
    state.filters.showRema = def.showRema or false;

    -- Tell DrawWindow "don't re-init from defaults"
    state.initialized = true;

    showWindow[1] = true;
end

function SkillchainGUI.SetVisible(v)
    showWindow[1] = v;
    if showWindow[1] then
        state.initialized = false;
    end
end

function SkillchainGUI.IsVisible()
    return showWindow[1];
end

function SkillchainGUI.SetCache(cacheRef)
    cache = cacheRef;
end

-- DrawWindow() renders the Calculator/Filters/Settings tabs and returns a request table.
-- The caller (SkillchainCalc.lua:d3d_present_cb) inspects the table and acts on set fields.
-- Fields not listed below are never set; nil / absent means "not requested this frame".
--
-- saveSettings         (bool)        Results window settings or window position changed; call settings.save
-- updateDefaults       (bool)        User saved new defaults; call applyDefaultsToCache + settings.save, re-parse if visible
-- clear                (bool)        User clicked Clear; call SkillchainRenderer.Clear + resetCacheFull
-- token1               (string)      Opener job token; presence triggers full skillchain recalculation
-- token2               (string)      Closer job token (always paired with token1)
-- scLevel              (number 1-3)  Skillchain level filter override
-- both                 (bool)        Calculate both opener→closer and closer→opener directions
-- scElement            (string|nil)  Burst element filter token (lowercase); nil = Any
-- charLevel            (number|nil)  Character level cap; nil = use maximum
-- favWs1               (string|nil)  Opener favorite WS name filter; nil = Any
-- favWs2               (string|nil)  Closer favorite WS name filter; nil = Any
-- showRema             (bool)        Include REMA (²) weapon skills in results
function SkillchainGUI.DrawWindow()
    if not showWindow[1] then
        return nil;
    end

    -- one-time sync from settings defaults
    if (not state.initialized) and cache and cache.settings and cache.settings.default then
        local def = cache.settings.default;

        -- cache.filters holds the last run's filters (the defaults until something
        -- runs); GUI-only state (enableFavWs, useCharLevel) reads from def.
        state.filters.scLevel       = cache.filters.scLevel;
        state.filters.both          = cache.filters.both;
        state.filters.includeSubjob = cache.filters.includeSubjob;
        state.filters.showRema      = cache.filters.showRema;
        syncGuiOnlyDefaults(def);

        state.filters.elementIndex = resolveElementIndex(cache.filters.scElement);

        state.initialized = true;
    end

    local guiPos = cache and cache.settings and cache.settings.guiPosition;

    local function drawBody()
        local request = nil;

        if imgui.BeginTabBar('##scc_tabs', ImGuiTabBarFlags_None) then
            -- Calculator tab
            if imgui.BeginTabItem('Calculator') then
                local r = drawCalculatorTab();
                if r then
                    request = r;
                end
                imgui.EndTabItem();
            end

            -- Filters tab
            if imgui.BeginTabItem('Filters') then
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

        -- Track window position changes for saving
        if SkillchainUI.trackWindowPosition(guiPos) then
            request = request or {};
            request.saveSettings = true;
        end

        return request;
    end

    local n = uiTheme.push();
    local flags = SkillchainUI.setupWindow(guiPos, nil);
    local ok, result = true, nil;
    if imgui.Begin('SkillchainCalc.' .. addon.version, showWindow, flags) then
        ok, result = pcall(drawBody);
    end
    imgui.End();
    uiTheme.pop(n);
    if not ok then error(result, 0); end

    return result;
end

return SkillchainGUI;
