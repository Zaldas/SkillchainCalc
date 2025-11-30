-- SkillchainCore.lua
-- Core parsing / filtering / sorting logic for SkillchainCalc.

require('common');
local skills = require('skills');
local jobs   = require('jobs');   -- NEW

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

function SkillchainCore.buildSkillListForJob(jobId)
    local job = jobs[jobId];
    if not job or not job.weapons then
        return nil;
    end

    local result = {};

    for weaponKey, cfg in pairs(job.weapons) do
        local maxSkill     = cfg.maxSkill or 999;
        local weaponSkills = skills[weaponKey];

        if weaponSkills then
            for _, ws in pairs(weaponSkills) do
                local wsSkill = ws.skill or 0;   -- **skill only**
                if wsSkill <= maxSkill and SkillchainCore.isJobAllowedForWs(ws, jobId) then
                    table.insert(result, ws);
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

    -- 1) Weapon type direct, e.g. "katana", "scythe"
    if skills[lower] ~= nil then
        return skills[lower];
    end

    -- 2) Job name / abbreviation, e.g. "nin", "ninja", "drk"
    local jobId = SkillchainCore.getJobIdFromToken(raw);
    if jobId then
        return SkillchainCore.buildSkillListForJob(jobId);
    end

    return nil;
end

-- Local helpers
local function findChainLevel(chainName)
    local chainInfo = skills.ChainInfo[chainName];
    return chainInfo and chainInfo.level or 0;
end

local function findSkillLevel(skillName)
    for weaponType, weaponSkills in pairs(skills) do
        if type(weaponSkills) == 'table' then
            for _, skill in pairs(weaponSkills) do
                if skill.en == skillName then
                    return skill.skill or 0;
                end
            end
        end
    end
    return 0;
end

local function parseSkillchain(skill1, skill2, results, parsedPairs, suppress)
    local pairKey = skill1.en .. ">" .. skill2.en;
    suppress = suppress or false;

    for _, chain1 in ipairs(skill1.skillchain or {}) do
        for _, chain2 in ipairs(skill2.skillchain or {}) do
            local chainInfo = skills.ChainInfo[chain1];

            if chainInfo and chainInfo[chain2] and not parsedPairs[pairKey] then
                local resultChain = chainInfo[chain2].skillchain;

                -- Optional suppression for reversible Light / Darkness
                if suppress and (resultChain == 'Light' or resultChain == 'Darkness') then
                    return;
                end

                parsedPairs[pairKey] = true;
                table.insert(results, {
                    skill1 = skill1.en,
                    skill2 = skill2.en,
                    chain  = resultChain,
                });
                break;
            end
        end
    end
end

-- Public API

function SkillchainCore.calculateSkillchains(skills1, skills2, both)
    local results     = {};
    local parsedPairs = {};

    -- Normal direction (skills1 → skills2)
    for _, skill1 in pairs(skills1) do
        for _, skill2 in pairs(skills2) do
            parseSkillchain(skill1, skill2, results, parsedPairs, false);
        end
    end

    -- Optional reverse direction (skills2 → skills1), suppress Light/Darkness
    if both then
        for _, skill2 in pairs(skills2) do
            for _, skill1 in pairs(skills1) do
                parseSkillchain(skill2, skill1, results, parsedPairs, true);
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
