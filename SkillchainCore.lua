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

-- parse "job:weapon1,weapon2" style tokens
local function parseJobWeaponToken(token)
    if not token or type(token) ~= 'string' then
        return nil;
    end

    local jobPart, weaponPart = token:match('^([^:]+):(.+)$');
    if not jobPart or not weaponPart then
        return nil;
    end

    local jobId = SkillchainCore.getJobIdFromToken(jobPart);
    if not jobId then
        return nil;
    end

    local job = jobs[jobId];
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

    return jobId, allowedWeapons;
end

function SkillchainCore.isJobAllowedForWs(ws, jobId)
    local allowedJobs = ws.jobRestrictions;
    if not allowedJobs then
        -- No restriction: everyone with the skill can use it.
        return true;
    end

    for _, j in ipairs(allowedJobs) do
        if j == jobId then
            return true;
        end
    end

    return false;
end

-- allow optional weapon filter set
function SkillchainCore.buildSkillListForJob(jobId, allowedWeapons)
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
                    if wsSkill <= maxSkill and SkillchainCore.isJobAllowedForWs(ws, jobId) then
                        table.insert(result, ws);
                    end
                end
            end
        end
    end

    return (#result > 0) and result or nil;
end

function SkillchainCore.resolveTokenToSkills(token)
    if not token or type(token) ~= 'string' then
        return nil;
    end

    local raw   = token;
    local lower = token:lower();

    -- 0) Job+weapon filter, e.g. "thf:sword", "war:ga,polearm"
    local jobId, allowedWeapons = parseJobWeaponToken(raw);
    if jobId then
        return SkillchainCore.buildSkillListForJob(jobId, allowedWeapons);
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

    -- 2) Job name / abbreviation, e.g. "nin", "ninja", "drk"
    local plainJobId = SkillchainCore.getJobIdFromToken(raw);
    if plainJobId then
        return SkillchainCore.buildSkillListForJob(plainJobId);
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

function SkillchainCore.calculateSkillchains(wsList1, wsList2, both)
    local results  = {}
    local seen     = {}

    if not wsList1 or not wsList2 then
        return results
    end

    local function addCombo(ws1, ws2, suppress)
        local chains = resolveChainProperties(ws1, ws2, suppress)
        for _, chain in ipairs(chains) do
            local key = ws1.en .. '>' .. ws2.en .. '>' .. chain
            if not seen[key] then
                seen[key] = true
                table.insert(results, {
                    skill1 = ws1.en,
                    skill2 = ws2.en,
                    chain  = chain,
                })
            end
        end
    end

    for _, ws1 in ipairs(wsList1) do
        for _, ws2 in ipairs(wsList2) do
            addCombo(ws1, ws2, false)
        end
    end

    if both then
        for _, ws2 in ipairs(wsList2) do
            for _, ws1 in ipairs(wsList1) do
                addCombo(ws2, ws1, true)
            end
        end
    end

    return results
end

-- Public API
function SkillchainCore.calculateStepSkillchains(wsList)
    local results  = {};
    local seenKeys = {};

    if not wsList then
        return results;
    end

    for baseProperty, _ in pairs(skills.ChainInfo) do
        for _, ws in pairs(wsList) do
            local resultChains = resolveChainProperties(baseProperty, ws, false);

            for _, resultChain in ipairs(resultChains) do
                local opener = baseProperty;
                local closer = ws.en;
                local key    = opener .. '>' .. closer .. '>' .. resultChain;

                if not seenKeys[key] then
                    seenKeys[key] = true;
                    table.insert(results, {
                        skill1 = opener,      -- property, e.g. "Distortion"
                        skill2 = closer,      -- WS name, e.g. "Blade: Jin"
                        chain  = resultChain, -- e.g. "Darkness"
                    });
                end
            end
        end
    end

    return results;
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
