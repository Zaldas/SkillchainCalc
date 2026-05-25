-- SkillchainCore.lua
-- Core parsing / filtering / sorting logic for SkillchainCalc.

require('common');
local skills         = require('Skills');
local jobs           = require('Jobs');
local SkillRanks     = require('SkillRanks');
local chat           = require('chat');

local SkillchainCore = {};

local REMA_SUFFIX = '\xC2\xB2'; -- UTF-8 encoding of ² (superscript 2) — marks REMA weapon skills

-- Helper function to get skill cap from rank and level
local function getSkillCapFromRank(skillRank, level)
    if not skillRank or not SkillRanks.Cap[skillRank] then
        return 999;
    end

    local levelToUse = level or jobs.MAX_LEVEL;
    return SkillRanks.Cap[skillRank][levelToUse] or 999;
end

-----------------------------------------------------------------------
-- TOAU – PUP Frame Support Functions
-----------------------------------------------------------------------

local function isFrameAllowed(ws, frameName)
    if not ws.JobRestrictions then
        return true;
    end
    for _, allowed in ipairs(ws.JobRestrictions) do
        if allowed == frameName then
            return true;
        end
    end
    return false;
end

local function appendFramesToWeaponList(jobId, job, list, listed)
    if jobId ~= 'PUP' or not job.frames then
        return list;
    end

    for frameName, _ in pairs(job.frames) do
        if not listed[frameName] then
            table.insert(list, frameName);
            listed[frameName] = true;
        end
    end

    return list;
end

-- Build skill list for a single PUP automaton frame
local function buildFrameSkillList(frameName, frameConfig, charLevel)
    local result = {};
    local levelToUse = charLevel or jobs.MAX_LEVEL;

    -- Melee WS from skills.frameMelee
    if frameConfig.melee and skills.frameMelee then
        local meleeCap = getSkillCapFromRank(frameConfig.melee, levelToUse);
        for _, ws in pairs(skills.frameMelee) do
            if ws.skill <= meleeCap and isFrameAllowed(ws, frameName) then
                table.insert(result, ws);
            end
        end
    end

    -- Ranged WS from skills.frameRanged
    if frameConfig.ranged and skills.frameRanged then
        local rangedCap = getSkillCapFromRank(frameConfig.ranged, levelToUse);
        for _, ws in pairs(skills.frameRanged) do
            if ws.skill <= rangedCap and isFrameAllowed(ws, frameName) then
                table.insert(result, ws);
            end
        end
    end

    return result;
end

-- Append frame skills to result list for PUP job
-- Returns modified result table
local function appendFrameSkills(jobId, job, weaponFilter, charLevel, result)
    if jobId ~= 'PUP' or not job.frames then
        return result;
    end

    for frameName, frameConfig in pairs(job.frames) do
        if (not weaponFilter) or weaponFilter[frameName] then
            local frameSkills = buildFrameSkillList(frameName, frameConfig, charLevel);
            for _, ws in ipairs(frameSkills) do
                table.insert(result, ws);
            end
        end
    end

    return result;
end

-- ============================================================================
-- Parses tokens in the following formats:
--   "nin"                    -> NIN job, no weapons, no subjob
--   "nin/war"                -> NIN main, WAR subjob, no weapons
--   "nin:dagger"             -> NIN job, dagger only, no subjob
--   "nin:dagger,katana"      -> NIN job, dagger+katana, no subjob
--   "nin/war:dagger"         -> NIN/WAR, dagger only
--   "nin/war:dagger,katana"  -> NIN/WAR, dagger+katana
-- ============================================================================

-- ============================================================================
-- Job and Weapon Utilities
-- ============================================================================

-- Cache for ordered weapon lists per job
local jobWeaponListCache = {};

-- Public: Get ordered weapon list for a job
-- Returns weapons in order: primaryWeapons first, then remaining weapons
function SkillchainCore.GetWeaponsForJob(jobId)
    if not jobId then
        return {};
    end

    -- Check cache
    local cached = jobWeaponListCache[jobId];
    if cached then
        return cached;
    end

    local job = jobs[jobId];
    if not job or not job.weapons then
        jobWeaponListCache[jobId] = {};
        return jobWeaponListCache[jobId];
    end

    local list = {};
    local listed = {};

    -- Primary weapons first (if defined)
    if type(job.primaryWeapons) == 'table' then
        for _, w in ipairs(job.primaryWeapons) do
            if job.weapons[w] and not listed[w] then
                table.insert(list, w);
                listed[w] = true;
            end
        end
    end

    -- Then all remaining weapons
    for w, _ in pairs(job.weapons) do
        if not listed[w] then
            table.insert(list, w);
            listed[w] = true;
        end
    end

    -- TOAU: Append PUP frames to weapon list
    list = appendFramesToWeaponList(jobId, job, list, listed);

    jobWeaponListCache[jobId] = list;
    return list;
end

-- Public: Build a token string from job, weapon selection, and optional subjob
-- Input: jobId (string), weaponSelection (table like {dagger=true, katana=true}), subJobId (string, optional)
-- Output: token string like "nin:dagger,katana" or "nin/war:dagger"
function SkillchainCore.BuildTokenFromSelection(jobId, weaponSelection, subJobId)
    if not jobId then
        return nil;
    end

    -- Build job portion (with optional subjob)
    local jobPart = jobId:lower();
    if subJobId then
        jobPart = jobPart .. '/' .. subJobId:lower();
    end

    -- Build weapon list in proper order
    local selectedWeapons = {};
    local weaponList = SkillchainCore.GetWeaponsForJob(jobId);

    for _, w in ipairs(weaponList) do
        if weaponSelection and weaponSelection[w] then
            table.insert(selectedWeapons, w);
        end
    end

    -- Combine job and weapons (if any)
    if #selectedWeapons > 0 then
        return jobPart .. ':' .. table.concat(selectedWeapons, ',');
    end

    return jobPart;
end

-- Helper: Resolve job abbreviation or name to job ID
function SkillchainCore.GetJobIdFromToken(token)
    if not token or type(token) ~= 'string' then
        return nil;
    end

    local lower = token:lower();
    if jobs.aliases and jobs.aliases[lower] then
        return jobs.aliases[lower];         -- e.g. "nin" -> "NIN"
    end

    local upper = token:upper();
    if jobs[upper] and jobs[upper].weapons then
        return upper;                       -- e.g. "NIN"
    end

    return nil;
end

-- Helper: Parse weapon list string into a set of valid weapon keys for a job
-- Input: "dagger,katana", jobId
-- Output: { dagger = true, katana = true } or nil if no valid weapons
local function parseWeaponList(weaponString, jobId)
    if not weaponString or not jobId then
        return nil;
    end

    local job = jobs[jobId];
    if not job or not job.weapons then
        return nil;
    end

    local allowedWeapons = {};

    -- weaponString can be "sword" or "ga,polearm" etc.
    for w in weaponString:gmatch('[^,]+') do
        local key = w:lower():gsub('%s+', '');  -- normalize
        local weaponKey = key;

        -- Resolve aliases (e.g., "ga" -> "greataxe")
        if skills.aliases and skills.aliases[key] then
            weaponKey = skills.aliases[key];
        end

        -- Only add if job can use this weapon and it exists in skills data
        if job.weapons[weaponKey] and skills[weaponKey] then
            allowedWeapons[weaponKey] = true;
        -- TOAU: Also accept PUP frames (e.g., "ve" -> "valoredge")
        elseif job.frames and job.frames[weaponKey] then
            allowedWeapons[weaponKey] = true;
        end
    end

    return next(allowedWeapons) and allowedWeapons or nil;
end

-- Helper: Parse job part of token (handles "job" or "job/subjob")
-- Returns: mainJobId, subJobId (or nil if no subjob)
local function parseJobPart(jobString)
    if not jobString or type(jobString) ~= 'string' then
        return nil, nil;
    end

    -- Check for subjob delimiter
    local mainJobPart, subJobPart = jobString:match('^([^/]+)/(.+)$');

    if mainJobPart and subJobPart then
        -- Has subjob: "nin/war"
        local mainJobId = SkillchainCore.GetJobIdFromToken(mainJobPart);
        local subJobId = SkillchainCore.GetJobIdFromToken(subJobPart);
        return mainJobId, subJobId;
    else
        -- No subjob: just "nin"
        local jobId = SkillchainCore.GetJobIdFromToken(jobString);
        return jobId, nil;
    end
end

-- Public: Parse a complete token into its components
-- This is the unified token parser that handles all formats
function SkillchainCore.GetJobAndWeaponsFromToken(token)
    if not token or type(token) ~= 'string' then
        return nil, nil, nil;
    end

    -- Try to split on colon first: "job:weapons" or "job/subjob:weapons"
    local jobPart, weaponPart = token:match('^([^:]+):(.+)$');

    if jobPart and weaponPart then
        -- Has weapon specification
        local mainJobId, subJobId = parseJobPart(jobPart);
        if not mainJobId then
            return nil, nil, nil;
        end

        local allowedWeapons = parseWeaponList(weaponPart, mainJobId);
        if not allowedWeapons then
            -- Invalid weapons for this job
            return nil, nil, nil;
        end

        return mainJobId, allowedWeapons, subJobId;
    else
        -- No weapon specification, just job or job/subjob
        local mainJobId, subJobId = parseJobPart(token);
        if mainJobId then
            return mainJobId, nil, subJobId;
        end

        return nil, nil, nil;
    end
end

function SkillchainCore.IsJobAllowedForWs(ws, mainJobId, subJobId)
    local restrictions = ws.JobRestrictions;
    local allowSubjob = ws.allowSubjob or false;

    -- No restrictions means everyone can use it
    if not restrictions then
        return true;
    end

    -- Check both jobs in a single pass
    local mainInList = false;
    local subInList = false;

    for _, j in ipairs(restrictions) do
        if j == mainJobId then
            mainInList = true;
        end
        if allowSubjob and subJobId and j == subJobId then
            subInList = true;
        end
        -- Early exit if we found what we need
        if mainInList or (allowSubjob and subInList) then
            break;
        end
    end

    -- If allowSubjob=true, the WS can be used by:
    -- 1. Main job in list (with any subjob), OR
    -- 2. Subjob in list (with any main job that has the weapon skill)
    if allowSubjob then
        return mainInList or subInList;
    else
        -- Normal behavior: only main job matters
        return mainInList;
    end
end

-- allow optional weapon filter set
-- subJobId is optional; if provided, it will be used to filter weaponskills that have subjob restrictions
-- charLevel is optional; if provided, it will be used to calculate skill caps instead of jobs.MAX_LEVEL
function SkillchainCore.BuildSkillListForJob(jobId, allowedWeapons, subJobId, charLevel)
    local job = jobs[jobId];
    if not job or not job.weapons then
        return nil;
    end

    -- If no explicit weapons given, fall back to job.primaryWeapons (if any)
    local weaponFilter = allowedWeapons;
    if not weaponFilter and job.primaryWeapons and #job.primaryWeapons > 0 then
        weaponFilter = {};
        for _, w in ipairs(job.primaryWeapons) do
            weaponFilter[w] = true;
        end
    end

    local result = {};
    local levelToUse = charLevel or jobs.MAX_LEVEL;

    for weaponKey, cfg in pairs(job.weapons) do
        if (not weaponFilter) or weaponFilter[weaponKey] then
            local maxSkill = getSkillCapFromRank(cfg.skillRank, levelToUse);
            local weaponSkills = skills[weaponKey];

            if weaponSkills then
                for _, ws in pairs(weaponSkills) do
                    local wsSkill = ws.skill or 0;
                    if wsSkill <= maxSkill and SkillchainCore.IsJobAllowedForWs(ws, jobId, subJobId) then
                        table.insert(result, ws);
                    end
                end
            end
        end
    end

    -- TOAU: Append PUP frame skills
    result = appendFrameSkills(jobId, job, weaponFilter, charLevel, result);

    return (#result > 0) and result or nil;
end

-- Public: Resolve a token to a list of weapon skills
-- Token formats supported:
--   - Job tokens: "nin", "nin/war", "thf:dagger", "nin/war:katana,dagger"
--   - Weapon tokens: "katana", "ga" (returns all skills for that weapon type)
-- The subJobId parameter is used as a fallback if the token doesn't specify a subjob
function SkillchainCore.ResolveTokenToSkills(token, subJobId, charLevel)
    if not token or type(token) ~= 'string' then
        return nil;
    end

    local lower = token:lower();

    -- Strategy 1: Try parsing as job token (handles all job formats)
    local jobId, allowedWeapons, tokenSubJobId = SkillchainCore.GetJobAndWeaponsFromToken(token);
    if jobId then
        -- Use tokenSubJobId if present, otherwise fall back to parameter subJobId
        local effectiveSubJob = tokenSubJobId or subJobId;
        return SkillchainCore.BuildSkillListForJob(jobId, allowedWeapons, effectiveSubJob, charLevel);
    end

    -- Strategy 2: Try as weapon type or alias, e.g. "katana", "scythe", "ga", "greataxe"
    local weaponKey = lower;

    if skills.aliases and skills.aliases[lower] then
        weaponKey = skills.aliases[lower];
    end

    -- Try alias-resolved key first
    if skills[weaponKey] ~= nil then
        return skills[weaponKey];
    end

    -- Fallback: direct lookup on the raw lower token (in case aliases table is incomplete)
    if skills[lower] ~= nil then
        return skills[lower];
    end

    -- No match found
    return nil;
end

-- Local helpers
local function findChainLevel(chainName)
    local chainInfo = skills.ChainInfo[chainName];
    return chainInfo and chainInfo.level or 0;
end

-- Built once at load time; keyed by WS display name → skill array index for sort ordering
local wsNameToSortIndex = {};
do
    for weaponType, weaponSkills in pairs(skills) do
        if type(weaponSkills) == 'table'
            and weaponType ~= 'aliases'
            and weaponType ~= 'ChainInfo'
        then
            for index, ws in pairs(weaponSkills) do
                if type(ws) == 'table' and ws.en then
                    wsNameToSortIndex[ws.en] = index;
                end
            end
        end
    end
end

local function findSkillLevel(name)
    -- 1) Property (Darkness, Distortion, etc.) – use displayOrder
    if skills.ChainInfo[name] then
        local idx = skills.GetDisplayIndex(name);
        if idx ~= nil then
            -- smaller idx = earlier in displayOrder, so invert to sort highest first
            return 1000 - idx;
        end
        return 0;
    end

    -- 2) Weaponskill – O(1) lookup instead of linear scan
    return wsNameToSortIndex[name] or 0;
end

local function normalizeChainSource(source)
    -- source can be:
    --  * WS table with .skillchain = { 'Gravitation', ... }
    --  * string property, e.g. 'Distortion'
    if type(source) == 'string' then
        return { source };
    elseif type(source) == 'table' then
        return source.skillchain or {};
    end

    return {};
end

local function resolveChainProperties(source1, source2)
    local props1   = normalizeChainSource(source1);
    local props2   = normalizeChainSource(source2);
    local maxTier  = 0;
    local results  = {};

    for _, chain1 in ipairs(props1) do
        local chainInfo = skills.ChainInfo[chain1];
        if chainInfo then
            for _, chain2 in ipairs(props2) do
                local link = chainInfo[chain2];
                if link then
                    if link.level > maxTier then
                        maxTier = link.level;
                        results = { link.skillchain };
                    elseif link.level == maxTier then
                        results[#results + 1] = link.skillchain;
                    end
                end
            end
        end
    end

    return results;
end

local function getSourceName(source)
    if type(source) == 'string' then
        return source;
    elseif type(source) == 'table' then
        return source.en or '';
    end
    return '';
end

-- Generic combo builder: works for WS→WS and Property→WS.
local function buildCombinations(list1, list2, opts)
    local results = {};
    local seen    = {};

    opts = opts or {};
    local both = opts.both and true or false;

    if not list1 or not list2 then
        return results;
    end

    local function addCombo(src1, src2)
        local chains = resolveChainProperties(src1, src2);
        local name1  = getSourceName(src1);
        local name2  = getSourceName(src2);

        if name1 ~= '' and name2 ~= '' then
            for _, chain in ipairs(chains) do
                local key = name1 .. '>' .. name2 .. '>' .. chain;
                if not seen[key] then
                    seen[key] = true;
                    table.insert(results, {
                        skill1 = name1,
                        skill2 = name2,
                        chain  = chain,
                    });
                end
            end
        end
    end

    -- forward pass
    for _, s1 in pairs(list1) do
        for _, s2 in pairs(list2) do
            addCombo(s1, s2);
        end
    end

    -- reverse pass
    if both then
        for _, s2 in pairs(list2) do
            for _, s1 in pairs(list1) do
                addCombo(s2, s1);
            end
        end
    end

    -- L/D chains are always reversible in-game: if A→B and B→A both produce
    -- Darkness/Light, deduplicate to one direction (the ↔ arrow covers both).
    if both then
        local ldSeen    = {};
        local filtered  = {};
        for _, combo in ipairs(results) do
            if combo.chain == 'Light' or combo.chain == 'Darkness' then
                local a, b = combo.skill1, combo.skill2;
                if a > b then a, b = b, a; end
                local key = a .. '|' .. b .. '|' .. combo.chain;
                if not ldSeen[key] then
                    ldSeen[key] = true;
                    table.insert(filtered, combo);
                end
            else
                table.insert(filtered, combo);
            end
        end
        results = filtered;
    end

    return results;
end

-- Public API

-- Normal WS→WS combinations.
function SkillchainCore.CalculateSkillchains(wsList1, wsList2, both)
    if not wsList1 or not wsList2 then
        return {};
    end
    return buildCombinations(wsList1, wsList2, { both = both });
end

-- Step mode: Property→WS combinations.
-- stepFilter: optional filter value (tier number 1-4 or property name like "distortion")
-- stepFilterType: "tier" or "property" or nil
function SkillchainCore.CalculateStepSkillchains(wsList, stepFilter, stepFilterType)
    if not wsList then
        return {};
    end

    -- Build list of base properties (Compression, Distortion, etc.).
    local properties = {};

    if stepFilterType == 'tier' then
        -- Filter by tier level: include properties at or above the specified tier
        for propName, propInfo in pairs(skills.ChainInfo) do
            if propInfo.level and propInfo.level >= stepFilter then
                table.insert(properties, propName);
            end
        end
    elseif stepFilterType == 'property' then
        -- Filter by specific property name
        -- Normalize the property name (capitalize first letter)
        local normalizedProp = stepFilter:sub(1, 1):upper() .. stepFilter:sub(2):lower();

        -- Validate the property exists
        if skills.ChainInfo[normalizedProp] then
            table.insert(properties, normalizedProp);
        else
            -- Property name not found, return empty (caller should handle error)
            return {};
        end
    else
        -- No filter: include all properties
        for propName, _ in pairs(skills.ChainInfo) do
            table.insert(properties, propName);
        end
    end

    -- No reverse/both meaning in step mode.
    return buildCombinations(properties, wsList, { both = false });
end

-- Consolidated single-pass filter: applies all filters in one iteration
-- filters: {scLevel, scElement, favWs1, favWs2, both}
function SkillchainCore.FilterSkillchains(combinations, filters)
    if not filters then
        return combinations;
    end

    local results = {};
    local minLevel = filters.scLevel or 1;
    local elementToken = filters.scElement;
    local favWs1 = filters.favWs1;
    local favWs2 = filters.favWs2;

    -- Normalize element for comparison
    local targetElement = elementToken and elementToken:lower() or nil;

    for _, combo in ipairs(combinations) do
        local pass = true;

        -- Filter 1: Skillchain level
        if pass and minLevel > 1 then
            local chainLevel = findChainLevel(combo.chain);
            pass = chainLevel >= minLevel;
        end

        -- Filter 2: Burst element
        if pass and targetElement then
            local info = skills.ChainInfo[combo.chain];
            local burst = info and info.burst;
            local elementMatch = false;

            if burst then
                for _, elem in ipairs(burst) do
                    if elem:lower() == targetElement then
                        elementMatch = true;
                        break;
                    end
                end
            end

            pass = elementMatch;
        end

        -- Filter 3: REMA weapon skills (² suffix)
        if pass and not filters.showRema then
            local isRema = combo.skill1:find(REMA_SUFFIX, 1, true) or combo.skill2:find(REMA_SUFFIX, 1, true);
            pass = not isRema;
        end

        -- Filter 4: Weaponskill names
        -- In both-directions mode the reverse pass swaps skill1/skill2 roles, so a
        -- favorite WS can appear in either position.
        if pass and (favWs1 or favWs2) then
            local ws1Match, ws2Match;
            if filters.both then
                ws1Match = not favWs1 or favWs1 == '' or combo.skill1 == favWs1 or combo.skill2 == favWs1;
                ws2Match = not favWs2 or favWs2 == '' or combo.skill2 == favWs2 or combo.skill1 == favWs2;
            else
                ws1Match = not favWs1 or favWs1 == '' or combo.skill1 == favWs1;
                ws2Match = not favWs2 or favWs2 == '' or combo.skill2 == favWs2;
            end
            pass = ws1Match and ws2Match;
        end

        if pass then
            table.insert(results, combo);
        end
    end

    return results;
end

function SkillchainCore.BuildSkillchainTable(skillchains)
    local resultsTable = {};

    for _, combo in ipairs(skillchains) do
        local opener = combo.skill1;
        local closer = combo.skill2;

        resultsTable[combo.chain]         = resultsTable[combo.chain] or {};
        resultsTable[combo.chain][opener] = resultsTable[combo.chain][opener] or {};
        table.insert(resultsTable[combo.chain][opener], { closer = closer });
    end

    return resultsTable;
end

function SkillchainCore.SortSkillchainTable(resultsTable, debugMode)
    local sortedResults  = {};
    local orderedResults = {};

    if debugMode then
        print(chat.header(addon.name):append(chat.message('[Debug] Starting level-based sorting')));
    end

    -- Sort chains by display order (via skills.GetDisplayIndex)
    local chainLevels = {};
    for chainName, _ in pairs(resultsTable) do
        table.insert(chainLevels, {
            chain = chainName,
            level = findChainLevel(chainName),
        });
    end

    table.sort(chainLevels, function(a, b)
        return skills.GetDisplayIndex(a.chain) < skills.GetDisplayIndex(b.chain);
    end);

    for _, chainData in ipairs(chainLevels) do
        local chainName = chainData.chain;
        sortedResults[chainName] = resultsTable[chainName];
        table.insert(orderedResults, chainName);
    end

    -- Sort openers and closers by WS skill level
    for chainName, openers in pairs(sortedResults) do
        local sortedOpeners = {};

        if debugMode then
            print(chat.header(addon.name):append(chat.message(('[Debug] Sorting openers for chain %s'):format(chainName))));
        end

        for opener, closers in pairs(openers) do
            local openerLevel = findSkillLevel(opener);

            table.sort(closers, function(a, b)
                local levelA = findSkillLevel(a.closer);
                local levelB = findSkillLevel(b.closer);
                return levelA > levelB;
            end);

            table.insert(sortedOpeners, {
                opener  = opener,
                closers = closers,
                level   = openerLevel,
            });
        end

        table.sort(sortedOpeners, function(a, b)
            return a.level > b.level;
        end);

        sortedResults[chainName] = sortedOpeners;
    end

    if debugMode then
        print(chat.header(addon.name):append(chat.message('[Debug] Sorting completed')));
    end

    return sortedResults, orderedResults;
end

-- ============================================================================
-- Party Skillchain Calculation
-- ============================================================================

-- Append name to list if not already present
local function appendNameUnique(list, name)
    for _, existing in ipairs(list) do
        if existing == name then
            return;
        end
    end
    table.insert(list, name);
end

-- Calculate all skillchains between every ordered pair of active party members.
-- members: array of {name, jobId, subJobId, level, subLevel, enabled, weapon}
-- Returns a flat array of:
--   {opener, closer, chain, chainLevel, openerNames, closerNames}
function SkillchainCore.CalculatePartySkillchains(members)
    if not members then
        return {};
    end

    -- Filter to active members with a chosen weapon, resolving skills once each.
    local active = {};
    for _, m in ipairs(members) do
        if m.enabled and m.weapon then
            local token = m.jobId:lower()
                .. (m.subJobId and ('/' .. m.subJobId:lower()) or '')
                .. ':' .. m.weapon;
            local skillList = SkillchainCore.ResolveTokenToSkills(token, nil, nil);
            if skillList then
                if not m.hasRema then
                    local noRema = {};
                    for _, ws in ipairs(skillList) do
                        if not ws.en:find(REMA_SUFFIX, 1, true) then
                            table.insert(noRema, ws);
                        end
                    end
                    skillList = noRema;
                end
                if #skillList > 0 then
                    table.insert(active, { member = m, skills = skillList });
                end
            end
        end
    end

    local merged = {};
    local order  = {};

    for i = 1, #active do
        -- Build a WS-name set for active[i] to resolve direction per combo.
        local wsSetI = {};
        for _, ws in ipairs(active[i].skills) do wsSetI[ws.en] = true; end

        for j = i + 1, #active do
            local mA    = active[i].member;
            local mB    = active[j].member;
            -- both=true: covers A→B and B→A in one call; buildCombinations
            -- already deduplicates Light/Darkness to a single direction.
            local combos = SkillchainCore.CalculateSkillchains(active[i].skills, active[j].skills, true);

            for _, combo in ipairs(combos) do
                -- skill1 belongs to whichever member opened the chain.
                local opMember = wsSetI[combo.skill1] and mA or mB;
                local clMember = wsSetI[combo.skill1] and mB or mA;
                local key      = combo.skill1 .. '|' .. combo.skill2 .. '|' .. combo.chain;
                local entry    = merged[key];
                if not entry then
                    entry = {
                        opener      = combo.skill1,
                        closer      = combo.skill2,
                        chain       = combo.chain,
                        chainLevel  = findChainLevel(combo.chain),
                        openerNames = { opMember.name },
                        closerNames = { clMember.name },
                    };
                    merged[key] = entry;
                    table.insert(order, key);
                else
                    appendNameUnique(entry.openerNames, opMember.name);
                    appendNameUnique(entry.closerNames, clMember.name);
                end
            end
        end
    end

    local results = {};
    for _, key in ipairs(order) do
        table.insert(results, merged[key]);
    end

    return results;
end

-- Build the display table for party results in the same shape as SortSkillchainTable,
-- extended with per-WS member-name lists.
-- partyResults: flat array from CalculatePartySkillchains (already SC-level filtered).
-- Returns sortedResults, orderedResults where:
--   orderedResults = array of chain names in display order
--   sortedResults[chainName] = array of {opener, openerNames, closers={{closer, closerNames}}}
function SkillchainCore.BuildPartySkillchainTable(partyResults)
    local sortedResults  = {};
    local orderedResults = {};

    -- Group: chain -> opener -> { openerNames, closers = { closer -> closerNames } }
    local byChain = {};

    for _, entry in ipairs(partyResults) do
        local chainName = entry.chain;

        local chainGroup = byChain[chainName];
        if not chainGroup then
            chainGroup = { openers = {}, openerOrder = {} };
            byChain[chainName] = chainGroup;
        end

        local openerGroup = chainGroup.openers[entry.opener];
        if not openerGroup then
            openerGroup = { openerNames = {}, closers = {}, closerOrder = {} };
            chainGroup.openers[entry.opener] = openerGroup;
            table.insert(chainGroup.openerOrder, entry.opener);
        end

        -- Union opener names for this opener WS + chain
        for _, name in ipairs(entry.openerNames or {}) do
            appendNameUnique(openerGroup.openerNames, name);
        end

        local closerNameList = openerGroup.closers[entry.closer];
        if not closerNameList then
            closerNameList = {};
            openerGroup.closers[entry.closer] = closerNameList;
            table.insert(openerGroup.closerOrder, entry.closer);
        end
        for _, name in ipairs(entry.closerNames or {}) do
            appendNameUnique(closerNameList, name);
        end
    end

    -- Order chains by display index (same as the rest of the codebase)
    local chainList = {};
    for chainName, _ in pairs(byChain) do
        table.insert(chainList, chainName);
    end
    table.sort(chainList, function(a, b)
        return skills.GetDisplayIndex(a) < skills.GetDisplayIndex(b);
    end);

    for _, chainName in ipairs(chainList) do
        local chainGroup = byChain[chainName];

        -- Sort openers by WS skill level (highest first), matching SortSkillchainTable
        local sortedOpeners = {};
        for _, openerName in ipairs(chainGroup.openerOrder) do
            local openerGroup = chainGroup.openers[openerName];

            local closers = {};
            for _, closerName in ipairs(openerGroup.closerOrder) do
                table.insert(closers, {
                    closer      = closerName,
                    closerNames = openerGroup.closers[closerName],
                });
            end

            table.sort(closers, function(a, b)
                return findSkillLevel(a.closer) > findSkillLevel(b.closer);
            end);

            table.insert(sortedOpeners, {
                opener      = openerName,
                openerNames = openerGroup.openerNames,
                closers     = closers,
                level       = findSkillLevel(openerName),
            });
        end

        table.sort(sortedOpeners, function(a, b)
            return a.level > b.level;
        end);

        sortedResults[chainName] = sortedOpeners;
        table.insert(orderedResults, chainName);
    end

    return sortedResults, orderedResults;
end

return SkillchainCore;
