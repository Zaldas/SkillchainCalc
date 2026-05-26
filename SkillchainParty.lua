-- SkillchainParty.lua
-- Party Skillchains tab: read party from memory, select weapons, calculate SCs.

require('common');
local imgui    = require('imgui');
local jobsData = require('Jobs');
local skills   = require('Skills');
local SkillchainCore = require('SkillchainCore');
local SkillchainRenderer = require('SkillchainRenderer');

local SkillchainParty = {};

-----------------------------------------------------------------------
-- Party SC filter: grouped by skillchain family.
-- Each entry's chains set lists every chain name the option should match.
-- nil chains = no filter (Any).
-- T2 options include their T3 upgrade; Light/Darkness share one option.
-----------------------------------------------------------------------
local partyScFilters = {
    { label = 'All',              chains = nil },
    { label = 'Any Tier 2+',      chains = { Fragmentation = true, Fusion = true, Gravitation = true, Distortion = true, Light = true, Darkness = true } },
    { label = 'Fragmentation',    chains = { Fragmentation = true, Light     = true } },
    { label = 'Fusion',           chains = { Fusion        = true, Light     = true } },
    { label = 'Gravitation',      chains = { Gravitation   = true, Darkness  = true } },
    { label = 'Distortion',       chains = { Distortion    = true, Darkness  = true } },
    { label = 'Light / Darkness', chains = { Light         = true, Darkness  = true } },
};

local REMA_SUFFIX = '\xC2\xB2';

-- Jobs defaulted to disabled at seed time (casters/support with no melee WS contribution)
local defaultDisabledJobs = { BLM=true, WHM=true, SMN=true, BRD=true, RDM=true };

-- Party state: seeded snapshot of party members + party-specific filters
local partyState = {
    loaded    = false,
    activeTab = 'Party',
    members   = {},  -- array of {name, jobId, subJobId, level, subLevel, enabled, weapon, hasRema, favWs}
    filters   = {
        scFilterIndex = 1,  -- index into partyScFilters (1 = 'All')
        remaOpen      = false,
        favWsOpen     = false,
        showRema      = false,
        showFavWs     = false,
        localRemaOpen = false,
    },
};

local cache = nil;

-- Human-readable weapon names for dropdown display
local weaponDisplayNames = {
    h2h     = 'Hand-to-Hand',
    dagger  = 'Dagger',
    sword   = 'Sword',
    gs      = 'Great Sword',
    ga      = 'Great Axe',
    axe     = 'Axe',
    scythe  = 'Scythe',
    polearm = 'Polearm',
    katana  = 'Katana',
    gkt     = 'Great Katana',
    staff   = 'Staff',
    club    = 'Club',
    archery = 'Archery',
    mm      = 'Marksmanship',
    avatar  = 'Avatar (Pet)',
};

-- Weapon types that have at least one REMA weapon skill, sorted for stable display.
local remaWeaponTypes = {};
do
    for weaponKey, _ in pairs(weaponDisplayNames) do
        local weaponSkills = skills[weaponKey];
        if type(weaponSkills) == 'table' then
            for _, ws in pairs(weaponSkills) do
                if type(ws) == 'table' and ws.en and ws.en:find(REMA_SUFFIX, 1, true) then
                    table.insert(remaWeaponTypes, weaponKey);
                    break;
                end
            end
        end
    end
    table.sort(remaWeaponTypes);
end

-- Maps FFXI CombatSkill enum IDs (item.Skill from resource manager) to weapon keys
local skillIdToWeapon = {
    [1]  = 'h2h',
    [2]  = 'dagger',
    [3]  = 'sword',
    [4]  = 'gs',
    [5]  = 'axe',
    [6]  = 'ga',
    [7]  = 'scythe',
    [8]  = 'polearm',
    [9]  = 'katana',
    [10] = 'gkt',
    [11] = 'club',
    [12] = 'staff',
    [25] = 'archery',
    [26] = 'mm',
};

-- Returns all weapon keys the job+sub combo can wield that have actual WS entries,
-- primary weapons first (via GetWeaponsForJob ordering), then subjob additions.
local function buildWeaponOptions(jobId, subJobId)
    local seen    = {};
    local options = {};

    local function addWeapon(w)
        if not seen[w] and type(skills[w]) == 'table' and next(skills[w]) ~= nil then
            seen[w] = true;
            table.insert(options, w);
        end
    end

    for _, w in ipairs(SkillchainCore.GetWeaponsForJob(jobId)) do
        addWeapon(w);
    end

    if subJobId then
        for _, w in ipairs(SkillchainCore.GetWeaponsForJob(subJobId)) do
            addWeapon(w);
        end
    end

    return options;
end

-- Reads the local player's main-hand equipped weapon key from inventory.
-- Returns a weapon key string (e.g. 'gkt') or nil if unequipped/unrecognised.
local function readLocalPlayerWeapon()
    local inv   = AshitaCore:GetMemoryManager():GetInventory();
    local eitem = inv:GetEquippedItem(0);  -- slot 0 = Main hand
    if eitem == nil or eitem.Index == 0 then
        return nil;
    end

    local container = bit.band(eitem.Index, 0xFF00) / 0x0100;
    local index     = eitem.Index % 0x0100;
    local iitem     = inv:GetContainerItem(container, index);
    if iitem == nil or iitem.Id == 0 or iitem.Id == 65535 then
        return nil;
    end

    local itemInfo = AshitaCore:GetResourceManager():GetItemById(iitem.Id);
    if itemInfo == nil then
        return nil;
    end

    return skillIdToWeapon[itemInfo.Skill];
end

-- Styled button helper: handles primary (blue) and ghost (transparent) button styles
local function styledButton(label, size, isPrimary)
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0);

    if isPrimary then
        imgui.PushStyleColor(ImGuiCol_Button,        { 0.25, 0.40, 0.85, 1.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 0.30, 0.48, 0.95, 1.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 0.18, 0.32, 0.70, 1.00 });
    else
        imgui.PushStyleColor(ImGuiCol_Button,        { 0.00, 0.00, 0.00, 0.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 1.00, 1.00, 1.00, 0.12 });
        imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 1.00, 1.00, 1.00, 0.20 });
    end

    local clicked = imgui.Button(label, size);

    imgui.PopStyleColor(3);
    imgui.PopStyleVar(1);

    return clicked;
end

local function getPartyWarnings()
    local warnings = {};
    if not partyState.loaded or #partyState.members == 0 then
        return warnings;
    end

    local party = AshitaCore:GetMemoryManager():GetParty();

    -- Build live snapshot keyed by name
    local live = {};
    for i = 0, 5 do
        if party:GetMemberIsActive(i) ~= 0 then
            local name = party:GetMemberName(i);
            if name and name ~= '' then
                live[name] = {
                    jobId    = jobsData.IdMap[party:GetMemberMainJob(i)],
                    subJobId = jobsData.IdMap[party:GetMemberSubJob(i)],
                    level    = party:GetMemberMainJobLevel(i),
                    subLevel = party:GetMemberSubJobLevel(i),
                };
            end
        end
    end

    -- Check seeded members against live; remove matched names
    for _, m in ipairs(partyState.members) do
        local cur = live[m.name];
        if not cur then
            table.insert(warnings, m.name .. ' is no longer in the party');
        else
            if cur.jobId ~= m.jobId then
                table.insert(warnings, m.name .. ': job changed (' .. (m.jobId or '?') .. ' -> ' .. (cur.jobId or '?') .. ')');
            end
            if cur.subJobId ~= m.subJobId then
                table.insert(warnings, m.name .. ': subjob changed (' .. (m.subJobId or '?') .. ' -> ' .. (cur.subJobId or '?') .. ')');
            end
            if cur.level ~= m.level then
                table.insert(warnings, m.name .. ': level changed (' .. (m.level or '?') .. ' -> ' .. (cur.level or '?') .. ')');
            end
            live[m.name] = nil;
        end
    end

    -- Any remaining live members weren't in the seed
    for name in pairs(live) do
        table.insert(warnings, name .. ' joined the party after loading');
    end

    return warnings;
end

local function loadParty()
    local party = AshitaCore:GetMemoryManager():GetParty();
    partyState.members = {};

    for i = 0, 5 do
        if party:GetMemberIsActive(i) ~= 0 then
            local jobNum = party:GetMemberMainJob(i);
            local subNum = party:GetMemberSubJob(i);
            local jobId  = jobsData.IdMap[jobNum];
            local subId  = jobsData.IdMap[subNum];

            if jobId and jobsData[jobId] and jobsData[jobId].weapons then
                local job           = jobsData[jobId];
                local defaultWeapon = (job.primaryWeapons or {})[1];

                -- For the local player (slot 0), read their actual equipped weapon
                if i == 0 then
                    local equipped = readLocalPlayerWeapon();
                    if equipped then
                        defaultWeapon = equipped;
                    end
                end

                local isLocal = (i == 0);
                local isRema  = false;
                if isLocal and cache and cache.settings and cache.settings.localPlayer then
                    local remaOwned = cache.settings.localPlayer.remaWeapons or {};
                    isRema = defaultWeapon ~= nil and (remaOwned[defaultWeapon] == true);
                end

                table.insert(partyState.members, {
                    name     = party:GetMemberName(i) or ('Member ' .. i),
                    jobId    = jobId,
                    subJobId = subId,
                    level    = party:GetMemberMainJobLevel(i),
                    subLevel = party:GetMemberSubJobLevel(i),
                    enabled  = not defaultDisabledJobs[jobId],
                    weapon   = defaultWeapon,
                    isLocal  = isLocal,
                    hasRema  = isRema,
                    favWs    = nil,
                });
            end
        end
    end

    partyState.loaded = true;
end

local function drawCenteredButton(label, isPrimary, contentWidth)
    local buttonWidth = contentWidth * 0.80;
    local startX = imgui.GetCursorPosX() + ((contentWidth - buttonWidth) / 2);
    imgui.SetCursorPosX(startX);
    return styledButton(label, { buttonWidth, 0 }, isPrimary);
end

local function drawMemberRow(member, index, contentWidth)
    local enabled = { member.enabled };
    if imgui.Checkbox('##en' .. index, enabled) then
        member.enabled = enabled[1];
    end
    imgui.SameLine();
    imgui.Text(member.hasRema and (member.name .. REMA_SUFFIX) or member.name);

    -- Job/sub label: right-aligned flush against the weapon dropdown
    local comboWidth = 130;
    local gap        = 6;
    local jobLabel   = string.format('%s%d/%s%d',
        member.jobId,
        member.level or 0,
        member.subJobId or '—',
        member.subLevel or 0);
    local jobLabelW  = imgui.CalcTextSize(jobLabel);

    imgui.SameLine();
    imgui.SetCursorPosX(contentWidth - comboWidth - gap - jobLabelW);
    imgui.Text(jobLabel);

    imgui.SameLine();
    imgui.SetCursorPosX(contentWidth - comboWidth);
    imgui.PushItemWidth(comboWidth);

    local weaponOptions = buildWeaponOptions(member.jobId, member.subJobId);
    if #weaponOptions == 0 then
        imgui.TextDisabled('(no WS)');
    else
        local displayName = member.weapon and (weaponDisplayNames[member.weapon] or member.weapon) or '(select)';
        if imgui.BeginCombo('##wpn' .. index, displayName) then
            for _, w in ipairs(weaponOptions) do
                local selected = (member.weapon == w);
                if imgui.Selectable(weaponDisplayNames[w] or w, selected) then
                    member.weapon = w;
                    member.favWs  = nil;
                    if member.isLocal and cache and cache.settings and cache.settings.localPlayer then
                        local remaOwned = cache.settings.localPlayer.remaWeapons or {};
                        member.hasRema = remaOwned[w] == true;
                    else
                        member.hasRema = false;
                    end
                end
                if selected then imgui.SetItemDefaultFocus(); end
            end
            imgui.EndCombo();
        end
    end

    imgui.PopItemWidth();
end

-- Gradient section header (mirrors SkillchainGui.drawGradientHeader)
local function drawGradientHeader(text, width)
    local drawlist = imgui.GetWindowDrawList();
    local x, y    = imgui.GetCursorScreenPos();
    local lineH   = imgui.GetTextLineHeightWithSpacing();

    local gradWidth  = width * 0.75;
    local colLeft    = { 0.25, 0.40, 0.85, 1.00 };
    local colLeftU32 = imgui.GetColorU32(colLeft);
    local colRight   = { colLeft[1], colLeft[2], colLeft[3], 0.00 };
    local colRightU32 = imgui.GetColorU32(colRight);

    drawlist:AddRectFilledMultiColor(
        { x, y }, { x + gradWidth, y + lineH },
        colLeftU32, colRightU32, colRightU32, colLeftU32
    );

    imgui.SetCursorScreenPos({ x + 4, y + 2 });
    imgui.Text(text);

    local _, newY = imgui.GetCursorScreenPos();
    imgui.SetCursorScreenPos({ x, newY });
    imgui.Spacing();
end

-----------------------------------------------------------------------
-- Window visibility state
-----------------------------------------------------------------------
local showWindow = { false };

local partyGuiState = { enableDrag = false };

-----------------------------------------------------------------------
-- Public API
-----------------------------------------------------------------------

function SkillchainParty.DrawWindow()
    if not showWindow[1] then
        -- Disable drag and reset checkbox state when window is closed
        SkillchainRenderer.setEnableDrag(false);
        partyGuiState.enableDrag = false;
        return nil;
    end

    local lineHeight   = imgui.GetFrameHeightWithSpacing();
    local memberCount  = #partyState.members;
    local remaRows    = (partyState.filters.showRema and partyState.filters.remaOpen) and memberCount or 0;
    local favWsRows    = (partyState.filters.showFavWs and partyState.filters.favWsOpen) and memberCount or 0;
    local remaFixed   = partyState.filters.showRema  and 1 or 0;
    local favWsFixed   = partyState.filters.showFavWs and 1 or 0;

    local partyTabRows    = (memberCount == 0) and 5 or (memberCount + 7 + remaFixed + remaRows + favWsFixed + favWsRows);
    local localRemaRows   = partyState.filters.localRemaOpen and math.ceil(#remaWeaponTypes / 2) or 0;
    local settingsTabRows = 12 + localRemaRows;
    local contentRows     = (partyState.activeTab == 'Settings') and settingsTabRows or partyTabRows;
    local padding         = (partyState.activeTab == 'Settings') and 0 or (remaFixed * 4 + favWsFixed * 4 + 4);
    local winHeight       = (contentRows + 1) * lineHeight + padding;

    imgui.SetNextWindowSize({ 380, winHeight }, ImGuiCond_Always);
    local guiPos = cache and cache.settings and cache.settings.guiPosition;
    if guiPos then
        imgui.SetNextWindowPos({ guiPos.x, guiPos.y }, ImGuiCond_Once);
    else
        imgui.SetNextWindowPos({ 50, 50 }, ImGuiCond_Once);
    end

    local flags = bit.bor(
        ImGuiWindowFlags_NoSavedSettings,
        ImGuiWindowFlags_NoDocking or 0,
        ImGuiWindowFlags_NoResize
    );

    if not imgui.Begin('SkillchainCalc - Party', showWindow, flags) then
        imgui.End();
        return nil;
    end

    local request      = nil;
    local contentWidth = imgui.GetContentRegionAvail();

    if imgui.BeginTabBar('##ptTabs') then
        -------------------------------------------------------------------
        -- Party tab
        -------------------------------------------------------------------
        if imgui.BeginTabItem('Party') then
            partyState.activeTab = 'Party';

            -- Update Party | Clear Party (no category header, top of tab)
            do
                local btnW   = (contentWidth - 8) * 0.5;
                local startX = imgui.GetCursorPosX() + (contentWidth - btnW * 2 - 8) * 0.5;
                imgui.SetCursorPosX(startX);
                if styledButton('Update Party', { btnW, 0 }, false) then
                    loadParty();
                end
                imgui.SameLine(0, 8);
                if styledButton('Clear Party', { btnW, 0 }, false) then
                    partyState.loaded  = false;
                    partyState.members = {};
                end
            end

            imgui.Spacing();

            -----------------------------------------------------------------------
            -- Party section
            -----------------------------------------------------------------------
            drawGradientHeader('Party', contentWidth);

            if (not partyState.loaded) or (#partyState.members == 0) then
                local hint  = 'No party loaded — press Update Party';
                local textW = imgui.CalcTextSize(hint);
                imgui.SetCursorPosX(imgui.GetCursorPosX() + (contentWidth - textW) * 0.5);
                imgui.TextDisabled(hint);
            else
                for i, member in ipairs(partyState.members) do
                    drawMemberRow(member, i, contentWidth);
                end

                imgui.Spacing();

                -----------------------------------------------------------------------
                -- Filters section
                -----------------------------------------------------------------------
                drawGradientHeader('Filter', contentWidth);

                do
                    local fidx    = partyState.filters.scFilterIndex;
                    local fLabel  = partyScFilters[fidx] and partyScFilters[fidx].label or 'All';
                    local scLabel  = 'Skillchain:';
                    local scLabelW = imgui.CalcTextSize(scLabel);
                    local comboW   = contentWidth * 0.65;
                    local startX   = imgui.GetCursorPosX() + (contentWidth - scLabelW - 6 - comboW) * 0.5;
                    local baseY    = imgui.GetCursorPosY();
                    imgui.SetCursorPosX(startX);
                    imgui.SetCursorPosY(baseY + 4);
                    imgui.Text(scLabel);
                    imgui.SameLine(0, 6);
                    imgui.SetCursorPosY(baseY);
                    imgui.PushItemWidth(comboW);
                    if imgui.BeginCombo('##ptScFilter', fLabel) then
                        for i = 1, #partyScFilters do
                            local selected = (i == fidx);
                            if imgui.Selectable(partyScFilters[i].label, selected) then
                                partyState.filters.scFilterIndex = i;
                            end
                            if selected then imgui.SetItemDefaultFocus(); end
                        end
                        imgui.EndCombo();
                    end
                    imgui.PopItemWidth();
                end

                if partyState.filters.showRema then
                    imgui.Spacing();

                    do
                        local remaLabel = partyState.filters.remaOpen and '\xe2\x96\xb2 REMA' or '\xe2\x96\xbc REMA';
                        local remaW     = contentWidth * 0.80;
                        imgui.SetCursorPosX(imgui.GetCursorPosX() + (contentWidth - remaW) * 0.5);
                        if styledButton(remaLabel, { remaW, 0 }, false) then
                            partyState.filters.remaOpen = not partyState.filters.remaOpen;
                            if partyState.filters.remaOpen then partyState.filters.favWsOpen = false; end
                        end
                        if imgui.IsItemHovered() then
                            imgui.BeginTooltip();
                            imgui.PushTextWrapPos(imgui.GetFontSize() * 18.0);
                            imgui.TextUnformatted('REMA: Relic, Empyrean, Mythic, or Aeonic weapons. Check a player\'s name here if they have a REMA weapon to include those weapon skills (' .. REMA_SUFFIX .. ') in the calculation.');
                            imgui.PopTextWrapPos();
                            imgui.EndTooltip();
                        end
                    end
                    if partyState.filters.remaOpen then
                        imgui.Indent(contentWidth * 0.15);
                        for i, member in ipairs(partyState.members) do
                            local hr = { member.hasRema or false };
                            if imgui.Checkbox(member.name .. '##rema' .. i, hr) then
                                member.hasRema = hr[1];
                            end
                        end
                        imgui.Unindent(contentWidth * 0.15);
                    end
                end

                if partyState.filters.showFavWs then
                    imgui.Spacing();

                    do
                        local favWsLabel = partyState.filters.favWsOpen and '\xe2\x96\xb2 Fav WS' or '\xe2\x96\xbc Fav WS';
                        local favWsW     = contentWidth * 0.80;
                        imgui.SetCursorPosX(imgui.GetCursorPosX() + (contentWidth - favWsW) * 0.5);
                        if styledButton(favWsLabel, { favWsW, 0 }, false) then
                            partyState.filters.favWsOpen = not partyState.filters.favWsOpen;
                            if partyState.filters.favWsOpen then partyState.filters.remaOpen = false; end
                        end
                        if imgui.IsItemHovered() then
                            imgui.BeginTooltip();
                            imgui.PushTextWrapPos(imgui.GetFontSize() * 18.0);
                            imgui.TextUnformatted('Fav WS: Choose a preferred weapon skill per member. Only skillchains that include at least one member\'s favored WS will be shown.');
                            imgui.PopTextWrapPos();
                            imgui.EndTooltip();
                        end
                    end
                    if partyState.filters.favWsOpen then
                        imgui.Indent(contentWidth * 0.12);
                        for i, member in ipairs(partyState.members) do
                            imgui.Text(member.name);
                            imgui.SameLine();
                            imgui.SetCursorPosX(contentWidth * 0.50);
                            imgui.PushItemWidth(contentWidth * 0.40);

                            local wsList = nil;
                            if member.weapon then
                                local token = member.jobId:lower()
                                    .. (member.subJobId and ('/' .. member.subJobId:lower()) or '')
                                    .. ':' .. member.weapon;
                                wsList = SkillchainCore.ResolveTokenToSkills(token, nil, nil);
                            end

                            local curLabel = member.favWs or '(Any)';
                            if not member.weapon then
                                imgui.TextDisabled('(no weapon)');
                            elseif imgui.BeginCombo('##favws' .. i, curLabel) then
                                if imgui.Selectable('(Any)', member.favWs == nil) then
                                    member.favWs = nil;
                                end
                                if member.favWs == nil then imgui.SetItemDefaultFocus(); end
                                if wsList then
                                    for _, ws in ipairs(wsList) do
                                        local isRema = ws.en:find(REMA_SUFFIX, 1, true) ~= nil;
                                        if not isRema or member.hasRema then
                                            local selected = (member.favWs == ws.en);
                                            if imgui.Selectable(ws.en .. '##fw' .. i, selected) then
                                                member.favWs = ws.en;
                                            end
                                            if selected then imgui.SetItemDefaultFocus(); end
                                        end
                                    end
                                end
                                imgui.EndCombo();
                            end

                            imgui.PopItemWidth();
                        end
                        imgui.Unindent(contentWidth * 0.12);
                    end
                end

                imgui.Spacing();
                imgui.Separator();
                imgui.Spacing();

                if drawCenteredButton('Calculate Skillchains', true, contentWidth) then
                    partyState.filters.remaOpen   = false;
                    partyState.filters.favWsOpen  = false;
                    local fidx = partyState.filters.scFilterIndex;
                    request = {
                        mode         = 'party',
                        members      = partyState.members,
                        partyFilters = {
                            chains = partyScFilters[fidx] and partyScFilters[fidx].chains or nil,
                        },
                        warnings = getPartyWarnings(),
                    };
                end
            end

            imgui.EndTabItem();
        end

        -------------------------------------------------------------------
        -- Settings tab
        -------------------------------------------------------------------
        if imgui.BeginTabItem('Settings') then
            partyState.activeTab = 'Settings';

            local baseX  = imgui.GetCursorPosX();
            local indent = 5;

            drawGradientHeader('Results Window', contentWidth);
            imgui.Spacing();

            if cache and cache.settings and cache.settings.anchor then
                local anchor = cache.settings.anchor;
                local limits = SkillchainRenderer.calculateAnchorLimits(cache.settings);

                imgui.SetCursorPosX(baseX + indent);
                local enableDrag = { partyGuiState.enableDrag };
                if imgui.Checkbox('Enable Mouse Drag', enableDrag) then
                    partyGuiState.enableDrag = enableDrag[1];
                    SkillchainRenderer.setEnableDrag(enableDrag[1]);
                end

                imgui.SetCursorPosX(baseX + indent);
                local x = { anchor.x or 0 };
                if imgui.SliderInt('X', x, limits.minX, limits.maxX) then
                    anchor.x = x[1];
                    request = request or {};
                    request.anchorChanged = true;
                end

                imgui.SetCursorPosX(baseX + indent);
                local y = { anchor.y or 0 };
                if imgui.SliderInt('Y', y, limits.minY, limits.maxY) then
                    anchor.y = y[1];
                    request = request or {};
                    request.anchorChanged = true;
                end
            else
                imgui.TextDisabled('Settings not available.');
            end

            imgui.Spacing();
            imgui.Separator();
            imgui.Spacing();

            -----------------------------------------------------------------------
            -- Advanced Filters
            -----------------------------------------------------------------------
            drawGradientHeader('Advanced Filters', contentWidth);
            imgui.Spacing();

            imgui.SetCursorPosX(baseX + indent);
            local showRema = { partyState.filters.showRema };
            if imgui.Checkbox('Enable REMA', showRema) then
                partyState.filters.showRema = showRema[1];
                if not partyState.filters.showRema then partyState.filters.remaOpen = false; end
                if cache and cache.settings and cache.settings.partyFilters then
                    cache.settings.partyFilters.showRema = showRema[1];
                end
                request = request or {};
                request.settingsChanged = true;
            end

            imgui.SetCursorPosX(baseX + indent);
            local showFavWs = { partyState.filters.showFavWs };
            if imgui.Checkbox('Enable Fav WS', showFavWs) then
                partyState.filters.showFavWs = showFavWs[1];
                if not partyState.filters.showFavWs then partyState.filters.favWsOpen = false; end
                if cache and cache.settings and cache.settings.partyFilters then
                    cache.settings.partyFilters.showFavWs = showFavWs[1];
                end
                request = request or {};
                request.settingsChanged = true;
            end

            imgui.Spacing();
            imgui.Separator();
            imgui.Spacing();

            -----------------------------------------------------------------------
            -- Local Player
            -----------------------------------------------------------------------
            drawGradientHeader('Local Player', contentWidth);
            imgui.Spacing();

            do
                local remaSettings = (cache and cache.settings and cache.settings.localPlayer and
                                      cache.settings.localPlayer.remaWeapons) or {};

                local remaToggleLabel = partyState.filters.localRemaOpen
                    and '\xe2\x96\xb2 REMA Weapons'
                    or  '\xe2\x96\xbc REMA Weapons';
                local remaToggleW = contentWidth * 0.80;
                imgui.SetCursorPosX(imgui.GetCursorPosX() + (contentWidth - remaToggleW) * 0.5);
                if styledButton(remaToggleLabel, { remaToggleW, 0 }, false) then
                    partyState.filters.localRemaOpen = not partyState.filters.localRemaOpen;
                end
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip();
                    imgui.PushTextWrapPos(imgui.GetFontSize() * 18.0);
                    imgui.TextUnformatted('Select weapon types you own a REMA (Relic/Empyrean/Mythic/Aeonic) weapon for. When loaded into the party list, your REMA status will be set automatically based on your equipped weapon.');
                    imgui.PopTextWrapPos();
                    imgui.EndTooltip();
                end

                if partyState.filters.localRemaOpen then
                    imgui.Indent(contentWidth * 0.08);
                    imgui.Columns(2, 'localrema_cols', false);
                    for _, weaponKey in ipairs(remaWeaponTypes) do
                        local owned = { remaSettings[weaponKey] == true };
                        if imgui.Checkbox(weaponDisplayNames[weaponKey] or weaponKey, owned) then
                            if cache and cache.settings and cache.settings.localPlayer then
                                if owned[1] then
                                    cache.settings.localPlayer.remaWeapons[weaponKey] = true;
                                else
                                    cache.settings.localPlayer.remaWeapons[weaponKey] = nil;
                                end
                            end
                            request = request or {};
                            request.settingsChanged = true;
                        end
                        imgui.NextColumn();
                    end
                    imgui.Columns(1);
                    imgui.Unindent(contentWidth * 0.08);
                end
            end

            imgui.EndTabItem();
        end

        imgui.EndTabBar();
    end

    -- Track position changes (shared with calc window — they're mutually exclusive)
    if guiPos then
        local curPosX, curPosY = imgui.GetWindowPos();
        if curPosX then
            local cx = curPosX - (curPosX % 1);
            local cy = curPosY - (curPosY % 1);
            if cx ~= guiPos.x or cy ~= guiPos.y then
                guiPos.x = cx;
                guiPos.y = cy;
                request = request or {};
                request.partyPositionChanged = true;
            end
        end
    end

    imgui.End();
    return request;
end

function SkillchainParty.SetCache(cacheRef)
    cache = cacheRef;
    if cache and cache.settings and cache.settings.partyFilters then
        local pf = cache.settings.partyFilters;
        partyState.filters.showRema  = pf.showRema  or false;
        partyState.filters.showFavWs = pf.showFavWs or false;
    end
end

function SkillchainParty.Toggle()
    showWindow[1] = not showWindow[1];
end

function SkillchainParty.SetVisible(v)
    showWindow[1] = v;
end

function SkillchainParty.IsVisible()
    return showWindow[1];
end

return SkillchainParty;
