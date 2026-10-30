-- SkillchainThreeStep.lua
-- 3-Step window: 3-4 job/weapon rows and a burst filter. Lists every
-- WS1 → WS2 → WS3 sequence whose two skillchains both burst one element, or
-- whose final skillchain is Light/Darkness.

require('common');
local imgui    = require('imgui');
local jobsData = require('Jobs');
local SkillchainCore = require('SkillchainCore');
local SkillchainUI = require('SkillchainUI');
local uiTheme = require('libs/uiTheme');

local SkillchainThreeStep = {};

local MIN_ROWS = 3;
local MAX_ROWS = 4;

-- Wider than the other windows so a row's favorite WS fits beside job and weapon.
local WINDOW_WIDTH = 450;

-- Step dropdown: index 1 is unlocked, index n+1 locks the row to step n.
local stepItems = { '-', '1', '2', '3' };

local DEFAULT_ELEMENT = 'Fire';
local ANY_ELEMENT     = 'Any';  -- Final chain mode only

-- Saved as threeStep.burstOn.
local burstOnItems = {
    { key = 'both',  label = 'Both chains' },
    { key = 'final', label = 'Final chain (T3)' },
};

-- Used for new settings and when a saved row is missing or names a job/weapon with no WS.
local defaultRows = {
    { job = 'WAR', weapon = 'ga' },
    { job = 'SAM', weapon = 'gkt' },
    { job = 'DRK', weapon = 'scythe' },
    { job = 'NIN', weapon = 'katana' },
};

local showWindow  = { false };
local cache       = nil;
local dirty       = true;   -- recalculate on the next frame
local resultCount = nil;    -- sequences found by the last calculation

-- Weapon keys with WS per job, primary weapons first, PUP automaton frames last; job data is static.
local weaponOptionsCache = {};
local function weaponOptions(jobId)
    local options = weaponOptionsCache[jobId];
    if not options then
        options = SkillchainCore.GetWsWeaponsForJob(jobId, true);
        weaponOptionsCache[jobId] = options;
    end
    return options;
end

-- Jobs offering at least one weapon with WS, alphabetical.
local jobItems = {};
do
    local seen = {};
    for _, jobId in pairs(jobsData.aliases or {}) do
        if type(jobId) == 'string' and not seen[jobId] then
            seen[jobId] = true;
            local job = jobsData[jobId];
            if job and job.weapons and #weaponOptions(jobId) > 0 then
                table.insert(jobItems, jobId);
            end
        end
    end
    table.sort(jobItems);
end

-- Saved 3-Step state lives in cache.settings.threeStep; read it through this
-- so a settings reload (character login) is picked up.
local fallbackSettings = { rowCount = MIN_ROWS, burstOn = 'both', element = DEFAULT_ELEMENT, showRema = false, rows = {} };
local function saved()
    return (cache and cache.settings and cache.settings.threeStep) or fallbackSettings;
end

local function rowCount()
    local count = tonumber(saved().rowCount) or MIN_ROWS;
    return math.max(MIN_ROWS, math.min(MAX_ROWS, math.floor(count)));
end

local function bothChains()
    return saved().burstOn ~= 'final';
end

-- Burst element filter, or nil for Any (Final chain mode only).
local function selectedElement()
    local element = saved().element;
    if element == ANY_ELEMENT and not bothChains() then
        return nil;
    end
    for _, elem in ipairs(SkillchainCore.BURST_ELEMENTS) do
        if elem == element then
            return elem;
        end
    end
    return DEFAULT_ELEMENT;
end

-- Saved step lock (1-3), or nil when unlocked or invalid.
local function rowStep(row)
    local step = row.step;
    if step == 1 or step == 2 or step == 3 then
        return step;
    end
    return nil;
end

local function contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true;
        end
    end
    return false;
end

-- Saved row i, repaired in place if missing or invalid.
local function getRow(index)
    local s = saved();
    if type(s.rows) ~= 'table' then
        s.rows = {};
    end
    local row = s.rows[index];
    if type(row) ~= 'table' then
        row = {};
        s.rows[index] = row;
    end
    if not contains(jobItems, row.job) then
        row.job    = defaultRows[index].job;
        row.weapon = defaultRows[index].weapon;
        row.favWs  = nil;
    end
    local options = weaponOptions(row.job);
    if not contains(options, row.weapon) then
        row.weapon = options[1];
        row.favWs  = nil;
    end
    return row;
end

-- Favorite WS order: skill requirement descending; at equal skill, REMA, then quested (¹), then name.
local QUESTED_SUFFIX = '\xC2\xB9';  -- UTF-8 ¹
local function favWsRank(ws)
    if ws.rema then
        return 2;
    end
    if ws.en:sub(-#QUESTED_SUFFIX) == QUESTED_SUFFIX then
        return 1;
    end
    return 0;
end

local function compareFavWs(a, b)
    local sa, sb = a.skill or 0, b.skill or 0;
    if sa ~= sb then
        return sa > sb;
    end
    local ra, rb = favWsRank(a), favWsRank(b);
    if ra ~= rb then
        return ra > rb;
    end
    return a.en < b.en;
end

-- Draws one step + job + weapon + favorite WS row. Returns true when any changed.
local function drawRow(index)
    local row     = getRow(index);
    local changed = false;
    local names   = SkillchainUI.WEAPON_DISPLAY_NAMES;

    local step = rowStep(row);
    imgui.PushItemWidth(40);
    if imgui.BeginCombo('##3sStep' .. index, stepItems[(step or 0) + 1]) then
        for n, label in ipairs(stepItems) do
            local value    = (n > 1) and (n - 1) or nil;
            local selected = (value == step);
            if imgui.Selectable(string.format('%s##3sSt%d', label, index), selected) and not selected then
                row.step = value;
                changed  = true;
            end
            if selected then imgui.SetItemDefaultFocus(); end
        end
        imgui.EndCombo();
    end
    imgui.PopItemWidth();
    imgui.SameLine();

    imgui.PushItemWidth(60);
    if imgui.BeginCombo('##3sJob' .. index, row.job) then
        for _, jobId in ipairs(jobItems) do
            local selected = (jobId == row.job);
            if imgui.Selectable(jobId, selected) and not selected then
                row.job    = jobId;
                row.weapon = weaponOptions(jobId)[1];
                row.favWs  = nil;
                changed    = true;
            end
            if selected then imgui.SetItemDefaultFocus(); end
        end
        imgui.EndCombo();
    end
    imgui.PopItemWidth();

    imgui.SameLine();
    imgui.PushItemWidth(125);
    if imgui.BeginCombo('##3sWpn' .. index, names[row.weapon] or row.weapon) then
        for _, w in ipairs(weaponOptions(row.job)) do
            local selected = (w == row.weapon);
            if imgui.Selectable(names[w] or w, selected) and not selected then
                row.weapon = w;
                row.favWs  = nil;
                changed    = true;
            end
            if selected then imgui.SetItemDefaultFocus(); end
        end
        imgui.EndCombo();
    end
    imgui.PopItemWidth();

    imgui.SameLine();
    imgui.PushItemWidth(-1);
    if imgui.BeginCombo('##3sFav' .. index, row.favWs or '(Any)') then
        -- Only resolved while the dropdown is open.
        local wsList = SkillchainCore.BuildThreeStepRowSkillList(row.job, row.weapon, saved().showRema == true) or {};
        table.sort(wsList, compareFavWs);

        if imgui.Selectable('(Any)', row.favWs == nil) and row.favWs ~= nil then
            row.favWs = nil;
            changed   = true;
        end
        if row.favWs == nil then imgui.SetItemDefaultFocus(); end
        for _, ws in ipairs(wsList) do
            local selected = (row.favWs == ws.en);
            if imgui.Selectable(string.format('%s##3sFw%d', ws.en, index), selected) and not selected then
                row.favWs = ws.en;
                changed   = true;
            end
            if selected then imgui.SetItemDefaultFocus(); end
        end
        imgui.EndCombo();
    end
    imgui.PopItemWidth();

    return changed;
end

-- Draws the window body. Returns a request table or nil.
local function drawBody()
    local s       = saved();
    local changed = false;

    uiTheme.header('Members', table.concat({
        '- Step: 1-3 locks the member to that step, and only members locked to a step can fill it. "-" fills any unlocked step.',
        '- Job: changing it picks that job\'s primary weapon.',
        '- Weapon: the weapon skills the member can use. PUP frames are the automaton.',
        '- Favorite WS: restricts the member to one weapon skill. (Any) uses every weapon skill for their weapon.',
    }, '\n\n'));

    imgui.Indent(uiTheme.indent);
    local count = rowCount();
    imgui.SetNextItemWidth(uiTheme.comboWidth());
    if imgui.BeginCombo('Members##3sCount', tostring(count)) then
        for n = MIN_ROWS, MAX_ROWS do
            local selected = (n == count);
            if imgui.Selectable(tostring(n), selected) and not selected then
                s.rowCount = n;
                changed    = true;
            end
            if selected then imgui.SetItemDefaultFocus(); end
        end
        imgui.EndCombo();
    end
    imgui.Spacing();

    for i = 1, rowCount() do
        if drawRow(i) then
            changed = true;
        end
    end
    imgui.Unindent(uiTheme.indent);

    imgui.Spacing();
    uiTheme.header('Filter');

    imgui.Indent(uiTheme.indent);
    local burstOn = bothChains() and 'both' or 'final';
    local burstOnLabel = burstOnItems[1].label;
    for _, item in ipairs(burstOnItems) do
        if item.key == burstOn then burstOnLabel = item.label; end
    end
    imgui.SetNextItemWidth(uiTheme.comboWidth());
    if imgui.BeginCombo('Burst on##3sBurstOn', burstOnLabel) then
        for _, item in ipairs(burstOnItems) do
            local selected = (item.key == burstOn);
            if imgui.Selectable(item.label, selected) and not selected then
                s.burstOn = item.key;
                changed   = true;
            end
            if selected then imgui.SetItemDefaultFocus(); end
        end
        imgui.EndCombo();
    end
    uiTheme.helpMarker(table.concat({
        '- Both chains: the first and final skillchain both burst the element.',
        '- Final chain (T3): the final skillchain is Light or Darkness. The element, if set, filters only the final chain.',
    }, '\n\n'));

    local element = selectedElement();
    local elementItems = SkillchainCore.BURST_ELEMENTS;
    if not bothChains() then
        elementItems = { ANY_ELEMENT };
        for _, elem in ipairs(SkillchainCore.BURST_ELEMENTS) do
            table.insert(elementItems, elem);
        end
    end
    imgui.SetNextItemWidth(uiTheme.comboWidth());
    if imgui.BeginCombo('Element##3sElement', element or ANY_ELEMENT) then
        for _, elem in ipairs(elementItems) do
            local selected = (elem == (element or ANY_ELEMENT));
            if imgui.Selectable(elem, selected) and not selected then
                s.element = elem;
                changed   = true;
            end
            if selected then imgui.SetItemDefaultFocus(); end
        end
        imgui.EndCombo();
    end

    local showRema = { s.showRema == true };
    if imgui.Checkbox('Include REMA', showRema) then
        s.showRema = showRema[1];
        if not showRema[1] then
            for i = 1, rowCount() do
                local row = getRow(i);
                if SkillchainCore.IsRemaWsName(row.favWs) then
                    row.favWs = nil;
                end
            end
        end
        changed = true;
    end
    uiTheme.helpMarker(string.format('Includes REMA (Relic, Empyrean, Mythic, Aeonic) weapon skills (%s) for every member.', SkillchainCore.REMA_SUFFIX));
    imgui.Unindent(uiTheme.indent);

    imgui.Spacing();
    imgui.Separator();
    imgui.Spacing();

    if resultCount == 0 then
        if bothChains() then
            imgui.TextDisabled(string.format('No 3-step chains burst %s on both chains with these members.', selectedElement()));
        elseif selectedElement() then
            imgui.TextDisabled(string.format('No 3-step chains end in a %s-bursting tier 3 with these members.', selectedElement()));
        else
            imgui.TextDisabled('No 3-step chains end in a tier 3 with these members.');
        end
    elseif resultCount then
        imgui.TextDisabled(string.format('%d sequence%s. Click a result to send it to chat.',
            resultCount, resultCount == 1 and '' or 's'));
    end

    local request = nil;
    if changed then
        request = { saveSettings = true };
        dirty   = true;
    end

    if dirty then
        dirty = false;
        local rows = {};
        for i = 1, rowCount() do
            local row = getRow(i);
            table.insert(rows, { jobId = row.job, weapon = row.weapon, favWs = row.favWs, step = rowStep(row) });
        end
        request = request or {};
        request.mode        = 'threeStep';
        request.rows        = rows;
        request.bothChains  = bothChains();
        request.element     = selectedElement();
        request.remaEnabled = s.showRema == true;
    end

    if SkillchainUI.trackWindowPosition(cache and cache.settings and cache.settings.guiPosition) then
        request = request or {};
        request.saveSettings = true;
    end

    return request;
end

-----------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------

-- DrawWindow() renders the 3-Step window and returns a request table, or nil.
-- saveSettings (bool)   threeStep settings or window position changed; call settings.save
-- mode         (string) 'threeStep' -- the window opened or a selection changed; recalculate
-- rows         (array)  { {jobId, weapon, favWs, step}, ... } -- present when mode == 'threeStep'
-- bothChains   (bool)   true: both chains burst element; false: final chain is tier 3+
-- element      (string) burst element, as in BURST_ELEMENTS; nil (Final chain mode only) = any
-- remaEnabled  (bool)   include REMA weapon skills
function SkillchainThreeStep.DrawWindow()
    if not showWindow[1] then
        return nil;
    end

    local guiPos = cache and cache.settings and cache.settings.guiPosition;

    local n = uiTheme.push();
    local flags = SkillchainUI.setupWindow(guiPos, { 50, 50 }, WINDOW_WIDTH);
    local ok, result = true, nil;
    if imgui.Begin('SkillchainCalc.' .. addon.version .. ' - 3-Step', showWindow, flags) then
        ok, result = pcall(drawBody);
    end
    imgui.End();
    uiTheme.pop(n);
    if not ok then error(result, 0); end

    return result;
end

-- Fresh default settings for cache.settings.threeStep.
function SkillchainThreeStep.DefaultSettings()
    local rows = {};
    for _, row in ipairs(defaultRows) do
        table.insert(rows, { job = row.job, weapon = row.weapon });
    end
    return { rowCount = MIN_ROWS, burstOn = 'both', element = DEFAULT_ELEMENT, showRema = false, rows = rows };
end

-- count: sequences the last calculation found, or nil when the results window shows something else.
function SkillchainThreeStep.SetResultCount(count)
    resultCount = count;
end

-- Recalculates on the next frame the window is open.
function SkillchainThreeStep.Invalidate()
    dirty = true;
end

function SkillchainThreeStep.SetCache(cacheRef)
    cache = cacheRef;
end

function SkillchainThreeStep.SetVisible(v)
    if v and not showWindow[1] then
        dirty = true;
    end
    showWindow[1] = v;
end

function SkillchainThreeStep.IsVisible()
    return showWindow[1];
end

return SkillchainThreeStep;
