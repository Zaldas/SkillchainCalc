-- check-retail-parity.lua
-- Fails if Jobs.lua/Skills.lua export a top-level key that the retail
-- build's retail/Jobs.lua or retail/Skills.lua does not also export.
--
-- Run from the repo root:  lua5.3 ci/check-retail-parity.lua
--
-- This only checks key existence, not values -- retail data is expected to
-- diverge in skill ranks/levels, and retail is expected to have *extra*
-- top-level keys (DNC/SCH/GEO/RUN) for jobs not yet active on HorizonXI.
-- It is not expected to be missing anything the shared code relies on. This
-- is exactly the class of bug that shipped a broken retail build for two
-- release cycles: jobs.IdMap was added to the shared Jobs.lua but never
-- backported to retail/Jobs.lua, and the retail release zip overwrites
-- Jobs.lua wholesale rather than merging.
--
-- Skills.lua: main models PUP automaton weapon skills per-frame
-- (skills.frameMelee/skills.frameRanged, keyed off jobs.PUP.frames), while
-- retail models PUP as a flat 'automaton' weapon-skill bucket instead. This
-- is an intentional, unreconciled design split (see SkillchainCore.lua's
-- "TOAU – PUP Frame Support Functions" comment) -- frameMelee/frameRanged
-- are expected to be main-only.

-- Skills.lua/Jobs.lua expect the ambient T{} table constructor normally
-- provided by common.lua inside the addon runtime. It's a plain table
-- constructor at load time in these files (no metatable methods called),
-- so an identity passthrough is sufficient for this structural check.
_G.T = function(t) return t; end;

local function loadDataFile(path)
    local chunk, err = loadfile(path);
    if not chunk then
        io.stderr:write(string.format('Failed to load %s: %s\n', path, err));
        os.exit(1);
    end
    return chunk();
end

-- Sorted list of keys present in `a` but missing from `b`, excluding any key in `allowlist`.
local function missingKeys(a, b, allowlist)
    local missing = {};
    for key in pairs(a) do
        if b[key] == nil and not (allowlist and allowlist[key]) then
            table.insert(missing, tostring(key));
        end
    end
    table.sort(missing);
    return missing;
end

local pairsToCheck = {
    { name = 'Jobs.lua',   main = 'Jobs.lua',   retail = 'retail/Jobs.lua' },
    { name = 'Skills.lua', main = 'Skills.lua', retail = 'retail/Skills.lua',
      -- PUP's per-frame automaton design (main) vs flat 'automaton' bucket (retail) -- see header comment.
      mainOnlyAllowlist = { frameMelee = true, frameRanged = true } },
};

local failed = false;

for _, pair in ipairs(pairsToCheck) do
    local mainData   = loadDataFile(pair.main);
    local retailData = loadDataFile(pair.retail);

    local missing = missingKeys(mainData, retailData, pair.mainOnlyAllowlist);
    local extra   = missingKeys(retailData, mainData);

    if #missing > 0 then
        failed = true;
        io.stderr:write(string.format(
            '%s: retail variant is MISSING key(s) the shared file exports: %s\n',
            pair.name, table.concat(missing, ', ')
        ));
    else
        print(string.format('%s: OK -- retail exports everything %s does.', pair.name, pair.main));
    end

    if #extra > 0 then
        print(string.format('%s: retail-only additions (expected, not a failure): %s', pair.name, table.concat(extra, ', ')));
    end
end

if failed then
    io.stderr:write('\nRetail parity check FAILED -- the retail release zip would ship broken or incomplete.\n');
    os.exit(1);
end

print('\nRetail parity check passed.');
