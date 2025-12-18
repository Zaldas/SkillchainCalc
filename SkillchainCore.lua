-- SkillchainCore.lua
-- Core parsing / filtering / sorting logic for SkillchainCalc.

require('common');
local skills = require('skills');
local jobs   = require('jobs');

local SkillchainCore = {};

-- Job / WS resolution helpers
function SkillchainCore.getJobIdFromToken(token)
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

-- parse "job:weapon1,weapon2" or "mainjob/subjob:weapon1,weapon2" style tokens
local function parseJobWeaponToken(token)
    if not token or type(token) ~= 'string' then
        return nil;
    end

    local jobPart, weaponPart = token:match('^([^:]+):(.+)$');
    if not jobPart or not weaponPart then
        return nil;
    end

    -- Check if jobPart contains a subjob delimiter (/)
    local mainJobPart, subJobPart = jobPart:match('^([^/]+)/(.+)$');
    local mainJobId, subJobId;

    if mainJobPart and subJobPart then
        -- Has subjob: mainjob/subjob format
        mainJobId = SkillchainCore.getJobIdFromToken(mainJobPart);
        subJobId = SkillchainCore.getJobIdFromToken(subJobPart);
        if not mainJobId then
            return nil;
        end
    else
        -- No subjob: just mainjob
        mainJobId = SkillchainCore.getJobIdFromToken(jobPart);
        subJobId = nil;
        if not mainJobId then
            return nil;
        end
    end

    local job = jobs[mainJobId];
    if not job or not job.weapons then
        return nil;
    end

    local allowedWeapons = {};

    -- weaponPart can be "sword" or "ga,polearm" etc.
    for w in weaponPart:gmatch('[^,]+') do
        local key = w:lower():gsub('%s+', '');
        local weaponKey = key;

        if skills.aliases and skills.aliases[key] then
            weaponKey = skills.aliases[key];
        end

        if job.weapons[weaponKey] and skills[weaponKey] then
            allowedWeapons[weaponKey] = true;
        end
    end

    if not next(allowedWeapons) then
        -- nothing valid for this job, treat as invalid token
        return nil;
    end

    return mainJobId, allowedWeapons, subJobId;
end

function SkillchainCore.getJobAndWeaponsFromToken(token)
    if not token or type(token) ~= 'string' then
        return nil, nil, nil;
    end

    -- First try full job:weapon1,weapon2 or mainjob/subjob:weapon syntax
    local mainJobId, allowedWeapons, subJobId = parseJobWeaponToken(token);
    if mainJobId then
        return mainJobId, allowedWeapons, subJobId;
    end

    -- Fall back to plain job token ("nin", "NIN", etc.) or "nin/war" format
    local mainJobPart, subJobPart = token:match('^([^/]+)/(.+)$');
    if mainJobPart and subJobPart then
        -- Has subjob but no weapon specified
        local mainId = SkillchainCore.getJobIdFromToken(mainJobPart);
        local subId = SkillchainCore.getJobIdFromToken(subJobPart);
        if mainId then
            return mainId, nil, subId;
        end
    end

    -- Plain job token
    local plainJobId = SkillchainCore.getJobIdFromToken(token);
    if plainJobId then
        return plainJobId, nil, nil;
    end

    return nil, nil, nil;
end

function SkillchainCore.isJobAllowedForWs(ws, mainJobId, subJobId)
    local restrictions = ws.JobRestrictions;
    local subRestrict = ws.subRestrict or false;

    -- No restrictions means everyone can use it
    if not restrictions then
        return true;
    end

    -- Check if main job is in the restrictions list
    local mainInList = false;
    for _, j in ipairs(restrictions) do
        if j == mainJobId then
            mainInList = true;
            break;
        end
    end

    -- If subRestrict=true, the WS can be used by:
    -- 1. Main job in list (with any subjob), OR
    -- 2. Subjob in list (with any main job that has the weapon skill)
    if subRestrict then
        if mainInList then
            return true;  -- Main job matches, any subjob is fine
        end

        -- Check if subjob matches
        if subJobId then
            for _, j in ipairs(restrictions) do
                if j == subJobId then
                    return true;  -- Subjob matches, main job must have weapon access
                end
            end
        end

        return false;  -- Neither main nor sub matched
    else
        -- Normal behavior: only main job matters
        return mainInList;
    end
end

-- allow optional weapon filter set
-- subJobId is optional; if provided, it will be used to filter weaponskills that have subjob restrictions
function SkillchainCore.buildSkillListForJob(jobId, allowedWeapons, subJobId)
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

    for weaponKey, cfg in pairs(job.weapons) do
        if (not weaponFilter) or weaponFilter[weaponKey] then
            local maxSkill     = cfg.maxSkill or 999;
            local weaponSkills = skills[weaponKey];

            if weaponSkills then
                for _, ws in pairs(weaponSkills) do
                    local wsSkill = ws.skill or 0;
                    if wsSkill <= maxSkill and SkillchainCore.isJobAllowedForWs(ws, jobId, subJobId) then
                        table.insert(result, ws);
                    end
                end
            end
        end
    end

    return (#result > 0) and result or nil;
end

function SkillchainCore.resolveTokenToSkills(token, subJobId)
    if not token or type(token) ~= 'string' then
        return nil;
    end

    local raw   = token;
    local lower = token:lower();

    -- 0) Job+weapon filter, e.g. "thf:sword", "war:ga,polearm", "nin/war:dagger"
    local jobId, allowedWeapons, tokenSubJobId = parseJobWeaponToken(raw);
    if jobId then
        -- Use tokenSubJobId if present, otherwise fall back to parameter subJobId
        local effectiveSubJob = tokenSubJobId or subJobId;
        return SkillchainCore.buildSkillListForJob(jobId, allowedWeapons, effectiveSubJob);
    end

    -- 1) Weapon type or alias, e.g. "katana", "scythe", "ga", "greataxe"
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

    -- 2) Job name / abbreviation, e.g. "nin", "ninja", "drk", or "nin/war"
    local mainJobPart, subJobPart = raw:match('^([^/]+)/(.+)$');
    if mainJobPart and subJobPart then
        -- Has subjob but no weapon specified
        local mainJobId = SkillchainCore.getJobIdFromToken(mainJobPart);
        local parsedSubJobId = SkillchainCore.getJobIdFromToken(subJobPart);
        if mainJobId then
            return SkillchainCore.buildSkillListForJob(mainJobId, nil, parsedSubJobId);
        end
    end

    -- Plain job token
    local plainJobId = SkillchainCore.getJobIdFromToken(raw);
    if plainJobId then
        return SkillchainCore.buildSkillListForJob(plainJobId, nil, subJobId);
    end

    return nil;
end

-- Local helpers
local function findChainLevel(chainName)
    local chainInfo = skills.ChainInfo[chainName];
    return chainInfo and chainInfo.level or 0;
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

    -- 2) Weaponskill – use WS skill level
    for weaponType, weaponSkills in pairs(skills) do
        if type(weaponSkills) == 'table'
            and weaponType ~= 'aliases'
            and weaponType ~= 'ChainInfo'
        then
            for _, skill in pairs(weaponSkills) do
                if type(skill) == 'table' and skill.en == name then
                    return skill.skill or 0;
                end
            end
        end
    end

    return 0;
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

local function resolveChainProperties(source1, source2, suppress)
    local props1  = normalizeChainSource(source1);
    local props2  = normalizeChainSource(source2);
    local results = {};

    suppress = suppress or false;

    for _, chain1 in ipairs(props1) do
        local chainInfo = skills.ChainInfo[chain1];
        if chainInfo then
            for _, chain2 in ipairs(props2) do
                local link = chainInfo[chain2];
                if link then
                    local resultChain = link.skillchain;
                    if not suppress or (resultChain ~= 'Light' and resultChain ~= 'Darkness') then
                        table.insert(results, resultChain);
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

    local function addCombo(src1, src2, suppressLv3)
        local chains = resolveChainProperties(src1, src2, suppressLv3);
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
            addCombo(s1, s2, false);
        end
    end

    -- optional reverse pass (used for WS both-direction support)
    if both then
        for _, s2 in pairs(list2) do
            for _, s1 in pairs(list1) do
                -- suppress Lv3 Light/Darkness on reverse pass to avoid dup L/D
                addCombo(s2, s1, true);
            end
        end
    end

    return results;
end

-- Public API

-- Normal WS→WS combinations.
function SkillchainCore.calculateSkillchains(wsList1, wsList2, both)
    if not wsList1 or not wsList2 then
        return {};
    end
    return buildCombinations(wsList1, wsList2, { both = both });
end

-- Step mode: Property→WS combinations.
function SkillchainCore.calculateStepSkillchains(wsList)
    if not wsList then
        return {};
    end

    -- Build list of base properties (Compression, Distortion, etc.).
    local properties = {};
    for propName, _ in pairs(skills.ChainInfo) do
        table.insert(properties, propName);
    end

    -- No reverse/both meaning in step mode.
    return buildCombinations(properties, wsList, { both = false });
end

function SkillchainCore.filterSkillchainsByLevel(combinations, minLevel)
    local filteredResults = {};
    minLevel = minLevel or 1;

    for _, combo in ipairs(combinations) do
        local chainLevel = findChainLevel(combo.chain);
        if chainLevel >= minLevel then
            table.insert(filteredResults, combo);
        end
    end

    return filteredResults;
end

function SkillchainCore.filterSkillchainsByElement(combinations, elementToken)
    if not elementToken or elementToken == '' then
        return combinations;
    end

    local target = elementToken:lower();
    local filteredResults = {};

    for _, combo in ipairs(combinations) do
        local info = skills.ChainInfo[combo.chain];
        local burst = info and info.burst;
        if burst then
            for _, elem in ipairs(burst) do
                if elem:lower() == target then
                    table.insert(filteredResults, combo);
                    break;
                end
            end
        end
    end

    return filteredResults;
end

function SkillchainCore.buildSkillchainTable(skillchains)
    local resultsTable = {};

    for _, combo in ipairs(skillchains) do
        local opener     = combo.skill1;
        local closer     = combo.skill2;
        local chainLevel = findChainLevel(combo.chain);

        -- Check if opener/closer already exists under any chain
        local existingEntry;

        for chain, openers in pairs(resultsTable) do
            if openers[opener] then
                for _, entry in ipairs(openers[opener]) do
                    if entry.closer == closer then
                        existingEntry = { chain = chain, entry = entry };
                        break;
                    end
                end
            end
            if existingEntry then
                break;
            end
        end

        if existingEntry then
            local existingLevel = findChainLevel(existingEntry.chain);
            if chainLevel > existingLevel then
                -- Remove lower-level chain version
                local openers = resultsTable[existingEntry.chain];
                for i, entry in ipairs(openers[opener]) do
                    if entry.closer == closer then
                        table.remove(openers[opener], i);
                        break;
                    end
                end
                if #openers[opener] == 0 then
                    openers[opener] = nil;
                end
                if not next(openers) then
                    resultsTable[existingEntry.chain] = nil;
                end
            else
                -- Skip, higher-level version already exists
                goto continue;
            end
        end

        -- Add new chain
        resultsTable[combo.chain] = resultsTable[combo.chain] or {};
        resultsTable[combo.chain][opener] = resultsTable[combo.chain][opener] or {};
        table.insert(resultsTable[combo.chain][opener], { closer = closer });

        ::continue::
    end

    return resultsTable;
end

function SkillchainCore.sortSkillchainTable(resultsTable, debugMode)
    local sortedResults  = {};
    local orderedResults = {};

    if debugMode then
        print('[SkillchainCore] Starting level-based sorting');
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
            print(('[SkillchainCore] Sorting openers for chain %s'):format(chainName));
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
        print('[SkillchainCore] Sorting completed');
    end

    return sortedResults, orderedResults;
end

return SkillchainCore;
