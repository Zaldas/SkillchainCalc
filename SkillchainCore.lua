-- SkillchainCore.lua
-- Core parsing / filtering / sorting logic for SkillchainCalc.

require('common');
local skills         = require('Skills');
local jobs           = require('Jobs');
local SkillRanks     = require('SkillRanks');

local SkillchainCore = {};

SkillchainCore.REMA_SUFFIX = '\xC2\xB2'; -- UTF-8 encoding of ² (superscript 2) — marks REMA weapon skills, display only

-- Canonical WS-name -> is-REMA lookup, built once from Skills.lua's rema=true
-- field (the ² suffix in `en` is purely cosmetic; this is the source of truth
-- for filtering). Exported so callers that only have a WS name string (not
-- the ws table itself, e.g. resolved combo results) don't have to re-scan
-- Skills.lua or sniff the display suffix themselves.
local remaWsNameSet = {};
do
    for weaponType, weaponSkills in pairs(skills) do
        if type(weaponSkills) == 'table' and weaponType ~= 'aliases' and weaponType ~= 'ChainInfo' then
            for _, ws in pairs(weaponSkills) do
                if type(ws) == 'table' and ws.en and ws.rema then
                    remaWsNameSet[ws.en] = true;
                end
            end
        end
    end
end

function SkillchainCore.IsRemaWsName(wsName)
    return wsName ~= nil and remaWsNameSet[wsName] == true;
end

-- Get skill cap from rank and level. Exported so other modules (e.g. the
-- Calculator's Fav WS dropdown) don't reimplement this against SkillRanks
-- directly and risk drifting from the calculation's own eligibility rules.
function SkillchainCore.GetSkillCapFromRank(skillRank, level)
    if not skillRank or not SkillRanks.Cap[skillRank] then
        return 999;
    end

    local levelToUse = level or jobs.MAX_LEVEL;
    return SkillRanks.Cap[skillRank][levelToUse] or 999;
end
local getSkillCapFromRank = SkillchainCore.GetSkillCapFromRank;

-----------------------------------------------------------------------
-- TOAU – PUP Frame Support Functions
--
-- This "frames" design (job.frames + JobRestrictions naming a frame) is the
-- live path, driven by jobs.PUP.frames and skills.frameMelee/frameRanged.
-- retail/Jobs.lua and retail/Skills.lua instead model PUP as a plain
-- weapon-bucket job (an 'automaton' weapon type on jobs.PUP.weapons, no
-- frames) and never call into these functions. The two designs are
-- unreconciled: whoever unifies them needs to pick one.
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

-- Build skill list for a single PUP automaton frame.
-- Automaton TP moves require skill strictly above the listed requirement,
-- unlike player weaponskills which unlock at exactly the requirement.
local function buildFrameSkillList(frameName, frameConfig, charLevel)
    local result = {};
    local levelToUse = charLevel or jobs.MAX_LEVEL;

    -- Melee WS from skills.frameMelee
    if frameConfig.melee and skills.frameMelee then
        local meleeCap = getSkillCapFromRank(frameConfig.melee, levelToUse);
        for _, ws in pairs(skills.frameMelee) do
            if ws.skill < meleeCap and isFrameAllowed(ws, frameName) then
                table.insert(result, ws);
            end
        end
    end

    -- Ranged WS from skills.frameRanged
    if frameConfig.ranged and skills.frameRanged then
        local rangedCap = getSkillCapFromRank(frameConfig.ranged, levelToUse);
        for _, ws in pairs(skills.frameRanged) do
            if ws.skill < rangedCap and isFrameAllowed(ws, frameName) then
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
-- Weapons outside GetWeaponsForJob(jobId) are dropped, and a selection with
-- none left yields the bare job token, which resolves to its primaryWeapons.
-- Party members holding an off-job weapon use BuildMemberSkillList instead.
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

    if #selectedWeapons > 0 then
        return jobPart .. ':' .. table.concat(selectedWeapons, ',');
    end
    return jobPart;
end

-- REMA (Relic/Empyrean/Mythic/Aeonic) weapons can't be wielded below this level.
SkillchainCore.REMA_MIN_LEVEL = 75;

-- True if REMA weapon skills apply: showRema is on and the level reaches
-- REMA_MIN_LEVEL. nil/0 level (not given or not reported) counts as MAX_LEVEL.
function SkillchainCore.IsRemaAllowed(showRema, level)
    if not showRema then
        return false;
    end
    if type(level) ~= 'number' or level <= 0 then
        level = jobs.MAX_LEVEL;
    end
    return level >= SkillchainCore.REMA_MIN_LEVEL;
end

-- Effective subjob for a side: an explicit subjob other than the main job,
-- else the job's default subjob when subjobs are enabled, else nil.
function SkillchainCore.ResolveSubjob(jobId, explicitSubId, includeSubjob)
    if explicitSubId and explicitSubId ~= jobId then
        return explicitSubId;
    end
    if includeSubjob then
        local defaultSubjob = jobs.GetDefaultSubjob(jobId);
        if defaultSubjob and defaultSubjob ~= jobId then
            return defaultSubjob;
        end
    end
    return nil;
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
    if type(jobs[upper]) == 'table' and jobs[upper].weapons then
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
--   - Weapon tokens: "katana", "ga" (all skills for that weapon type, sorted by WS id;
--     charLevel caps at the best skill rank any job has in that weapon)
function SkillchainCore.ResolveTokenToSkills(token, charLevel)
    if not token or type(token) ~= 'string' then
        return nil;
    end

    local lower = token:lower();

    -- Strategy 1: Try parsing as job token (handles all job formats)
    local jobId, allowedWeapons, subJobId = SkillchainCore.GetJobAndWeaponsFromToken(token);
    if jobId then
        return SkillchainCore.BuildSkillListForJob(jobId, allowedWeapons, subJobId, charLevel);
    end

    -- Strategy 2: Try as weapon type or alias, e.g. "katana", "scythe", "ga", "greataxe"
    local weaponKey = lower;

    if skills.aliases and skills.aliases[lower] then
        weaponKey = skills.aliases[lower];
    end

    if skills[weaponKey] == nil then
        -- Fallback: direct lookup on the raw lower token (in case aliases table is incomplete)
        weaponKey = lower;
    end
    local weaponTable = skills[weaponKey];
    if type(weaponTable) ~= 'table' then
        return nil;
    end

    -- nil = uncapped: no level given, or no job has a known rank in this weapon
    -- (PUP frame buckets are modelled under jobs.PUP.frames, not weapons).
    local maxSkill = nil;
    if charLevel then
        for _, job in pairs(jobs) do
            local cfg = type(job) == 'table' and job.weapons and job.weapons[weaponKey];
            if cfg and SkillRanks.Cap[cfg.skillRank] then
                maxSkill = math.max(maxSkill or 0, getSkillCapFromRank(cfg.skillRank, charLevel));
            end
        end
    end

    -- Weapon tables are keyed by WS id (e.g. katana 128+), so ipairs-based
    -- consumers see nothing unless they get a dense array.
    local ids = {};
    for id, ws in pairs(weaponTable) do
        if type(id) == 'number' and type(ws) == 'table' then
            table.insert(ids, id);
        end
    end
    table.sort(ids);

    local list = {};
    for _, id in ipairs(ids) do
        local ws = weaponTable[id];
        if not maxSkill or (ws.skill or 0) <= maxSkill then
            table.insert(list, ws);
        end
    end
    return (#list > 0) and list or nil;
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
    local props1 = normalizeChainSource(source1);
    local props2 = normalizeChainSource(source2);

    for _, chain1 in ipairs(props1) do
        local chainInfo = skills.ChainInfo[chain1];
        if chainInfo then
            for _, chain2 in ipairs(props2) do
                local link = chainInfo[chain2];
                if link then
                    return { link.skillchain };
                end
            end
        end
    end

    return {};
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
    for _, s1 in ipairs(list1) do
        for _, s2 in ipairs(list2) do
            addCombo(s1, s2);
        end
    end

    -- reverse pass
    if both then
        for _, s2 in ipairs(list2) do
            for _, s1 in ipairs(list1) do
                addCombo(s2, s1);
            end
        end
    end

    -- Most L/D pairs are bidirectional, but not all: first-match resolution can
    -- intercept one direction with a lower-tier chain. Ground Strike
    -- [Fragmentation, Distortion] → Evisceration [Gravitation, Transfixion] is
    -- Darkness, but the reverse hits Fragmentation×Gravitation first and yields
    -- Fragmentation. Merge into one ↔ row only when BOTH directions actually
    -- resolve to the same chain; otherwise keep the direction that resolved.
    -- `seen` holds every combo produced by both passes, so it answers this
    -- directly -- the reverse pass has already run by this point.
    if both then
        local ldSeen    = {};
        local filtered  = {};
        for _, combo in ipairs(results) do
            if combo.chain == 'Light' or combo.chain == 'Darkness' then
                local reverseKey = combo.skill2 .. '>' .. combo.skill1 .. '>' .. combo.chain;
                if seen[reverseKey] then
                    local a, b = combo.skill1, combo.skill2;
                    if a > b then a, b = b, a; end
                    local key = a .. '|' .. b .. '|' .. combo.chain;
                    if not ldSeen[key] then
                        ldSeen[key] = true;
                        -- Always store in canonical (alphabetical) direction so the
                        -- merger key is stable regardless of which member is list1/list2.
                        table.insert(filtered, {
                            skill1     = a,
                            skill2     = b,
                            chain      = combo.chain,
                            reversible = true,
                        });
                    end
                else
                    -- One-way: keep the resolved opener→closer order. Canonicalizing
                    -- here would print the pair backwards, and in party mode would
                    -- attribute the opener to the wrong member.
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
-- stepFilter: optional filter value (tier number 1-3 or property name like "distortion")
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

-- CHAIN_NAMES: every ChainInfo property in display order.
-- BURST_ELEMENTS: the burst element of each single-element property, in the same order.
SkillchainCore.CHAIN_NAMES    = {};
SkillchainCore.BURST_ELEMENTS = {};
do
    for name, info in pairs(skills.ChainInfo or {}) do
        if type(info) == 'table' then
            table.insert(SkillchainCore.CHAIN_NAMES, name);
        end
    end
    table.sort(SkillchainCore.CHAIN_NAMES, function(a, b)
        local ia, ib = skills.GetDisplayIndex(a), skills.GetDisplayIndex(b);
        if ia ~= ib then
            return ia < ib;
        end
        return a < b;
    end);

    local seen = {};
    for _, name in ipairs(SkillchainCore.CHAIN_NAMES) do
        local burst = skills.ChainInfo[name].burst;
        if type(burst) == 'table' and #burst == 1 and not seen[burst[1]] then
            seen[burst[1]] = true;
            table.insert(SkillchainCore.BURST_ELEMENTS, burst[1]);
        end
    end
end

local function containsIgnoreCase(list, token)
    if type(token) ~= 'string' or token == '' then
        return false;
    end
    local lower = token:lower();
    for _, v in ipairs(list) do
        if v:lower() == lower then
            return true;
        end
    end
    return false;
end

-- True if token (any case) is a burst element -- the values FilterSkillchains
-- understands as scElement.
function SkillchainCore.IsScFilterToken(token)
    return containsIgnoreCase(SkillchainCore.BURST_ELEMENTS, token);
end

-- True if token (any case) names a skillchain property in ChainInfo.
function SkillchainCore.IsChainName(token)
    return containsIgnoreCase(SkillchainCore.CHAIN_NAMES, token);
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

        -- Filter 3: REMA weapon skills
        if pass then
            local remaAllowed = SkillchainCore.IsRemaAllowed(filters.showRema, filters.charLevel);
            if not remaAllowed then
                local isRema = SkillchainCore.IsRemaWsName(combo.skill1) or SkillchainCore.IsRemaWsName(combo.skill2);
                pass = not isRema;
            end
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

-- Append name to list if not already present
local function appendNameUnique(list, name)
    for _, existing in ipairs(list) do
        if existing == name then
            return;
        end
    end
    table.insert(list, name);
end

-- Groups results by chain -> opener -> closer for display: chains in display
-- order, openers and closers by WS skill level (highest first).
-- entries: CalculateSkillchains combos {skill1, skill2, chain, reversible}, or
--   CalculatePartySkillchains entries {opener, closer, chain, reversible, openerNames, closerNames}.
-- Returns sortedResults, orderedResults where:
--   orderedResults = array of chain names in display order
--   sortedResults[chainName] = array of {opener, level, closers = {{closer, reversible, openerNames, closerNames}}}
--   openerNames/closerNames are present only for party entries (the renderer keys party mode on them).
function SkillchainCore.BuildResultsTable(entries)
    -- Group: chain -> opener -> closer, in first-seen order
    local byChain = {};

    for _, entry in ipairs(entries) do
        local chainName = entry.chain;
        local opener    = entry.opener or entry.skill1;
        local closer    = entry.closer or entry.skill2;

        local chainGroup = byChain[chainName];
        if not chainGroup then
            chainGroup = { openers = {}, openerOrder = {} };
            byChain[chainName] = chainGroup;
        end

        local openerGroup = chainGroup.openers[opener];
        if not openerGroup then
            openerGroup = { closers = {}, closerOrder = {} };
            chainGroup.openers[opener] = openerGroup;
            table.insert(chainGroup.openerOrder, opener);
        end

        -- Names are kept per closer so names pruned for one closer don't
        -- bleed into other closers sharing the same opener WS.
        local closerEntry = openerGroup.closers[closer];
        if not closerEntry then
            closerEntry = { closer = closer, reversible = entry.reversible };
            if entry.openerNames then
                closerEntry.openerNames = {};
                closerEntry.closerNames = {};
            end
            openerGroup.closers[closer] = closerEntry;
            table.insert(openerGroup.closerOrder, closer);
        end
        if closerEntry.openerNames then
            for _, name in ipairs(entry.openerNames or {}) do
                appendNameUnique(closerEntry.openerNames, name);
            end
            for _, name in ipairs(entry.closerNames or {}) do
                appendNameUnique(closerEntry.closerNames, name);
            end
        end
    end

    local orderedResults = {};
    for chainName, _ in pairs(byChain) do
        table.insert(orderedResults, chainName);
    end
    table.sort(orderedResults, function(a, b)
        return skills.GetDisplayIndex(a) < skills.GetDisplayIndex(b);
    end);

    local sortedResults = {};
    for _, chainName in ipairs(orderedResults) do
        local chainGroup = byChain[chainName];

        local sortedOpeners = {};
        for _, opener in ipairs(chainGroup.openerOrder) do
            local openerGroup = chainGroup.openers[opener];

            local closers = {};
            for _, closer in ipairs(openerGroup.closerOrder) do
                table.insert(closers, openerGroup.closers[closer]);
            end
            table.sort(closers, function(a, b)
                return findSkillLevel(a.closer) > findSkillLevel(b.closer);
            end);

            table.insert(sortedOpeners, {
                opener  = opener,
                closers = closers,
                level   = findSkillLevel(opener),
            });
        end

        table.sort(sortedOpeners, function(a, b)
            return a.level > b.level;
        end);

        sortedResults[chainName] = sortedOpeners;
    end

    return sortedResults, orderedResults;
end

-- ============================================================================
-- Party Skillchain Calculation
-- ============================================================================

-- Level used for a member's skill caps. 0/nil (level not reported) returns nil,
-- so callers cap at jobs.MAX_LEVEL.
function SkillchainCore.GetMemberSkillLevel(member)
    local level = member and member.level;
    if type(level) == 'number' and level > 0 then
        return level;
    end
    return nil;
end

-- Weapon skills a party member can use with their selected weapon, capped by
-- their level; REMA WS only when remaEnabled and the member has REMA.
-- Returns an array (possibly empty), or nil if the job can't use the weapon.
function SkillchainCore.BuildMemberSkillList(member, remaEnabled)
    if not member or not member.jobId or not member.weapon then
        return nil;
    end
    local level = SkillchainCore.GetMemberSkillLevel(member);
    local list = SkillchainCore.BuildSkillListForJob(member.jobId, { [member.weapon] = true }, member.subJobId, level);
    if not list then
        return nil;
    end
    if SkillchainCore.IsRemaAllowed(remaEnabled and member.hasRema, level) then
        return list;
    end
    local noRema = {};
    for _, ws in ipairs(list) do
        if not ws.rema then
            table.insert(noRema, ws);
        end
    end
    return noRema;
end

-- Calculate all skillchains between every ordered pair of active members. This
-- is one flat pool regardless of alliance sub-party -- partyIndex (if present)
-- is a display-grouping detail only and plays no role in the calculation.
-- members: array of {name, jobId, subJobId, level, subLevel, enabled, weapon}
-- options: {remaEnabled, favWsEnabled} -- per-member hasRema/favWs apply only when enabled
-- Returns a flat array of:
--   {opener, closer, chain, chainLevel, openerNames, closerNames}
function SkillchainCore.CalculatePartySkillchains(members, options)
    if not members then
        return {};
    end
    options = options or {};

    -- Filter to active members with a chosen weapon, resolving skills once each.
    local active = {};
    for _, m in ipairs(members) do
        if m.enabled and m.weapon then
            local skillList = SkillchainCore.BuildMemberSkillList(m, options.remaEnabled);
            if skillList then
                -- With Fav WS enabled, a member's fav restricts them to that WS. A fav
                -- the member can't currently use (REMA off, level too low) is ignored.
                if options.favWsEnabled and m.favWs then
                    local favOnly = {};
                    for _, ws in ipairs(skillList) do
                        if ws.en == m.favWs then
                            table.insert(favOnly, ws);
                        end
                    end
                    if #favOnly > 0 then
                        skillList = favOnly;
                    end
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
        local wsSetI = {};
        for _, ws in ipairs(active[i].skills) do wsSetI[ws.en] = true; end

        for j = i + 1, #active do
            local mA    = active[i].member;
            local mB    = active[j].member;

            local wsSetJ = {};
            for _, ws in ipairs(active[j].skills) do wsSetJ[ws.en] = true; end

            -- both=true: covers A→B and B→A in one call; buildCombinations
            -- deduplicates Light/Darkness to a single direction only when the
            -- pair chains both ways (combo.reversible marks those).
            local combos = SkillchainCore.CalculateSkillchains(active[i].skills, active[j].skills, true);

            for _, combo in ipairs(combos) do
                -- Verify each direction independently: the opener must own skill1
                -- AND the closer must own skill2. Both can be true when WS overlap.
                local iOpens = wsSetI[combo.skill1] and wsSetJ[combo.skill2];
                local jOpens = wsSetJ[combo.skill1] and wsSetI[combo.skill2];

                if iOpens or jOpens then
                    local key   = combo.skill1 .. '|' .. combo.skill2 .. '|' .. combo.chain;
                    local entry = merged[key];
                    if not entry then
                        entry = {
                            opener      = combo.skill1,
                            closer      = combo.skill2,
                            chain       = combo.chain,
                            chainLevel  = findChainLevel(combo.chain),
                            reversible  = combo.reversible,
                            openerNames = {},
                            closerNames = {},
                        };
                        merged[key] = entry;
                        table.insert(order, key);
                    end
                    if iOpens then
                        appendNameUnique(entry.openerNames, mA.name);
                        appendNameUnique(entry.closerNames, mB.name);
                    end
                    if jOpens then
                        appendNameUnique(entry.openerNames, mB.name);
                        appendNameUnique(entry.closerNames, mA.name);
                    end
                end
            end
        end
    end

    local results = {};
    for _, key in ipairs(order) do
        table.insert(results, merged[key]);
    end

    -- If a name is the SOLE contributor to one position and also appears in the
    -- other, they must fill their unique role — remove them from the other side.
    -- When multiple names share a position, leave all of them (party decides).
    local function inList(list, name)
        for _, n in ipairs(list) do if n == name then return true; end end
        return false;
    end
    local function removeFrom(list, name)
        local out = {};
        for _, n in ipairs(list) do if n ~= name then table.insert(out, n); end end
        return out;
    end
    for _, entry in ipairs(results) do
        if #entry.closerNames == 1 and inList(entry.openerNames, entry.closerNames[1]) then
            local pruned = removeFrom(entry.openerNames, entry.closerNames[1]);
            if #pruned > 0 then entry.openerNames = pruned; end
        end
        if #entry.openerNames == 1 and inList(entry.closerNames, entry.openerNames[1]) then
            local pruned = removeFrom(entry.closerNames, entry.openerNames[1]);
            if #pruned > 0 then entry.closerNames = pruned; end
        end
    end

    return results;
end

return SkillchainCore;
