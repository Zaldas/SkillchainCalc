local core = require('skillchain_core')
local skills = require('skills')

local function read_file(path)
    local file, err = io.open(path, 'r')
    if not file then
        error('Failed to open ' .. path .. ': ' .. tostring(err))
    end
    local content = file:read('*all')
    file:close()
    return content
end

local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error((message or 'Values did not match') .. string.format(' (expected %s, got %s)', tostring(expected), tostring(actual)))
    end
end

local function assert_true(condition, message)
    if not condition then
        error(message or 'Assertion failed')
    end
end

local function main()
    local jobs_xml = read_file('jobs.xml')
    local job_mappings = core.parse_job_mappings(jobs_xml, skills)

    -- Ensure key jobs are parsed correctly
    assert_true(job_mappings.drk ~= nil, 'Dark Knight mapping missing')
    assert_equal(#job_mappings.drk, 2, 'Dark Knight should have two weapons')
    assert_equal(job_mappings.drk[1].name, 'scythe', 'Dark Knight first weapon should be scythe')
    assert_equal(job_mappings.drk[2].name, 'gs', 'Dark Knight second weapon should be great sword (gs)')

    -- Verify weapon resolution prefers weapons before jobs
    local weaponOnly, isJob = core.resolve_weapons('scythe', skills, job_mappings)
    assert_true(not isJob and weaponOnly[1] == 'scythe', 'Weapon resolution should detect direct weapon input')

    local jobResolved, jobFlag = core.resolve_weapons('drk', skills, job_mappings)
    assert_true(jobFlag, 'Job resolution should flag job inputs')
    assert_equal(#jobResolved, 2, 'Job resolution should return all mapped weapons')

    -- Ensure relic and high-tier weapon skills are filtered per job mapping
    local cor_mm_skills = core.apply_weapon_filters(job_mappings.cor[1], skills)
    for _, skill in ipairs(cor_mm_skills) do
        assert_true((skill.tier or 0) <= 7, 'Corsair marksmanship should exclude relic-tier weapon skills')
    end

    local pld_sword_skills = core.apply_weapon_filters(job_mappings.pld[1], skills)
    local foundKnights = false
    for _, skill in ipairs(pld_sword_skills) do
        if skill.en == 'Knights of Round²' then
            foundKnights = true
        end
    end
    assert_true(foundKnights, 'Paladin sword list should retain Knights of Round relic weapon skill')

    -- Calculate combinations for a representative cross-job matchup
    local drk_vs_sam = core.build_combinations(job_mappings.drk, job_mappings.sam, skills, skills.ChainInfo, true, 1)
    assert_true(#drk_vs_sam > 0, 'Expected at least one combination for Dark Knight vs Samurai')

    -- Run through every job pairing to ensure the calculator handles all mappings without errors
    for job1, weapons1 in pairs(job_mappings) do
        for job2, weapons2 in pairs(job_mappings) do
            local _ = core.build_combinations(weapons1, weapons2, skills, skills.ChainInfo, true, 1)
        end
    end

    local job_count = 0
    for _ in pairs(job_mappings) do
        job_count = job_count + 1
    end

    print(('All %d job mappings validated across pairings.'):format(job_count))
end

main()
