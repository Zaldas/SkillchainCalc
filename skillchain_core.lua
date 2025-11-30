local core = {}

local function trim(value)
    return (value or ''):match('^%s*(.-)%s*$')
end

local function to_allowed_lookup(list)
    if (not list) or (#list == 0) then
        return nil
    end

    local lookup = {}
    for _, value in ipairs(list) do
        lookup[value:lower()] = true
    end

    return lookup
end

-- Return a filtered copy of the skill list for the provided weapon entry.
function core.apply_weapon_filters(weaponEntry, skills_table)
    local weaponName = weaponEntry
    local maxTier
    local allowed

    if (type(weaponEntry) == 'table') then
        weaponName = weaponEntry.name
        maxTier = weaponEntry.max_tier
        allowed = weaponEntry.allowed_skills
    end

    local baseSkills = skills_table[weaponName]
    if (not baseSkills) then
        return nil
    end

    local allowedLookup = to_allowed_lookup(allowed)
    if (not maxTier) and (not allowedLookup) then
        return baseSkills
    end

    local filtered = {}
    for _, skill in pairs(baseSkills) do
        local ok = true

        if (maxTier and skill.tier and skill.tier > maxTier) then
            ok = false
        end

        if (ok and allowedLookup and (not allowedLookup[skill.en:lower()])) then
            ok = false
        end

        if ok then
            table.insert(filtered, skill)
        end
    end

    return filtered
end

-- Normalize job -> weapon mappings defined in Lua tables or parsed data. Unknown weapons are logged
-- via the optional logger. Supports optional max_tier and allowed_skills to filter job-specific
-- weapon skills.
function core.normalize_job_mappings(job_table, skills_table, logger)
    local mappings = {}
    local log = logger or function() end

    for job, weapons in pairs(job_table or {}) do
        local normalized = {}
        for _, weaponEntry in ipairs(weapons or {}) do
            local entry = weaponEntry
            if (type(entry) == 'string') then
                entry = { name = entry }
            end

            local weaponName = trim(entry.name or ''):lower()
            if (weaponName == '') then
                log(('Ignoring unnamed weapon entry for job %s.'):format(job))
            elseif skills_table[weaponName] then
                local normalizedEntry = {
                    name = weaponName,
                    max_tier = entry.max_tier,
                    allowed_skills = entry.allowed_skills,
                }

                local filtered = core.apply_weapon_filters(normalizedEntry, skills_table)
                if filtered and (#filtered > 0) then
                    table.insert(normalized, normalizedEntry)
                else
                    log(('No usable skills remain for weapon "%s" on job %s after filtering.'):format(weaponName, job))
                end
            else
                log(('Ignoring unknown weapon "%s" for job %s.'):format(weaponName, job))
            end
        end

        if (#normalized > 0) then
            mappings[job:lower()] = normalized
        else
            log(('No valid weapons found for job %s.'):format(job))
        end
    end

    return mappings
end

-- Parse job mappings from an XML string, then normalize them using the shared logic. Maintained for
-- backward compatibility.
function core.parse_job_mappings(xml_content, skills_table, logger)
    local parsed = {}

    for job, block in xml_content:gmatch('<job%s+name="(.-)"%s*>([\0-\255]-)</job>') do
        parsed[job] = {}

        for weaponAttrs, weaponBody in block:gmatch('<weapon(.-)>([\0-\255]-)</weapon>') do
            local nameAttr = weaponAttrs:match('name="(.-)"')
            local weaponName = trim(nameAttr or weaponBody):lower()
            local maxTier = weaponAttrs:match('max_tier="(%d+)"') or weaponBody:match('<max_tier>%s*(%d+)%s*</max_tier>')
            local skills = {}
            for skill in weaponBody:gmatch('<skill>%s*(.-)%s*</skill>') do
                table.insert(skills, trim(skill):lower())
            end

            table.insert(parsed[job], {
                name = weaponName,
                max_tier = maxTier and tonumber(maxTier) or nil,
                allowed_skills = skills,
            })
        end
    end

    return core.normalize_job_mappings(parsed, skills_table, logger)
end

-- Resolve a provided argument into one or more weapon types.
function core.resolve_weapons(input, skills_table, job_mappings)
    local lowered = input:lower()

    if (skills_table[lowered]) then
        return { lowered }, false
    end

    if (job_mappings[lowered]) then
        return job_mappings[lowered], true
    end

    return nil, false
end

local function parseSkillchain(skill1, skill2, results, parsedPairs, chain_info, suppress)
    local pairKey = skill1.en .. ">" .. skill2.en
    suppress = suppress or false

    for _, chain1 in ipairs(skill1.skillchain or {}) do
        for _, chain2 in ipairs(skill2.skillchain or {}) do
            local chainInfo = chain_info[chain1]

            if chainInfo and chainInfo[chain2] and not parsedPairs[pairKey] then
                if suppress and (chainInfo[chain2].skillchain == "Light" or chainInfo[chain2].skillchain == "Darkness") then
                    return
                end

                parsedPairs[pairKey] = true
                table.insert(results, {
                    skill1 = skill1.en,
                    skill2 = skill2.en,
                    chain = chainInfo[chain2].skillchain,
                })
                break
            end
        end
    end
end

-- Calculate skillchains between two weapon skill lists.
function core.calculate_skillchains(skills1, skills2, includeBothDirections, chain_info)
    local results = {}
    local parsedPairs = {}

    for _, skill1 in pairs(skills1) do
        for _, skill2 in pairs(skills2) do
            parseSkillchain(skill1, skill2, results, parsedPairs, chain_info)
        end
    end

    if (includeBothDirections) then
        for _, skill2 in pairs(skills2) do
            for _, skill1 in pairs(skills1) do
                parseSkillchain(skill2, skill1, results, parsedPairs, chain_info, true)
            end
        end
    end

    return results
end

-- Filter skillchains by their minimum level.
function core.filter_skillchains_by_level(combinations, minimumLevel, chain_info)
    local filteredResults = {}
    for _, combo in ipairs(combinations) do
        local chainLevel = 0
        local chainInfo = chain_info[combo.chain]
        if chainInfo and chainInfo.level then
            chainLevel = chainInfo.level
        end

        if chainLevel >= minimumLevel then
            table.insert(filteredResults, combo)
        end
    end
    return filteredResults
end

-- Build unique skillchain combinations between two weapon lists.
function core.build_combinations(weapons1, weapons2, skills_table, chain_info, includeBothDirections, minimumLevel)
    local combinations = {}
    local seen = {}

    for _, weapon1 in ipairs(weapons1) do
        local weapon1Skills = core.apply_weapon_filters(weapon1, skills_table)
        if (weapon1Skills) then
            for _, weapon2 in ipairs(weapons2) do
                local weapon2Skills = core.apply_weapon_filters(weapon2, skills_table)
                if (weapon2Skills) then
                    local combos = core.calculate_skillchains(weapon1Skills, weapon2Skills, includeBothDirections, chain_info)
                    for _, combo in ipairs(combos) do
                        local key = combo.skill1 .. '>' .. combo.skill2 .. ':' .. combo.chain
                        if (not seen[key]) then
                            seen[key] = true
                            table.insert(combinations, combo)
                        end
                    end
                end
            end
        end
    end

    if (minimumLevel) then
        return core.filter_skillchains_by_level(combinations, minimumLevel, chain_info)
    end

    return combinations
end

return core
