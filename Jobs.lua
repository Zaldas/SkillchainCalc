-- jobs.lua
-- Maps FFXI jobs to the weapon type keys used in skills.lua.

local jobs = {}

-- weapon keys must match skills.lua:
-- h2h, dagger, sword, gs, axe, ga, scythe, polearm,
-- katana, gkt, club, staff, archery, mm, smn

jobs.WAR = { 'h2h','dagger','sword','gs','axe','ga','scythe','polearm','club','staff','archery' }
jobs.MNK = { 'h2h','staff','club' }
jobs.WHM = { 'club','staff','dagger' }
jobs.BLM = { 'staff','club','dagger' }
jobs.RDM = { 'sword','dagger','club','staff' }
jobs.THF = { 'dagger','sword','h2h' }
jobs.PLD = { 'sword','gs','club','staff' }

-- your example:
jobs.DRK = { 'scythe','gs','sword','club','staff' }
jobs.BST = { 'axe','ga','club','staff','dagger' }
jobs.BRD = { 'dagger','sword','club','staff' }
jobs.RNG = { 'archery','mm','dagger','sword','axe' }
jobs.SAM = { 'polearm','gkt','gs','archery' }
jobs.NIN = { 'katana','dagger','sword' }
jobs.DRG = { 'polearm','staff' }
jobs.SMN = { 'smn','staff','club' }
jobs.BLU = { 'sword','dagger','club','staff' }
jobs.COR = { 'mm','sword','dagger' }
jobs.PUP = { 'h2h','staff','club' }
jobs.DNC = { 'dagger','h2h','sword' }
jobs.SCH = { 'staff','club' }
jobs.GEO = { 'club','staff','dagger' }
jobs.RUN = { 'gs','sword','dagger','club' }

-- simple alias map: supports nin/ninja, drk, etc.
local aliases = {
    war = 'WAR', warrior = 'WAR',
    mnk = 'MNK', monk = 'MNK',
    whm = 'WHM', whiteMage = 'WHM', whitemage = 'WHM',
    blm = 'BLM', blackmage = 'BLM',
    rdm = 'RDM', redmage = 'RDM',
    thf = 'THF', thief = 'THF',
    pld = 'PLD', paladin = 'PLD',
    drk = 'DRK', darkknight = 'DRK', ['dark knight'] = 'DRK',
    bst = 'BST', beastmaster = 'BST',
    brd = 'BRD', bard = 'BRD',
    rng = 'RNG', ranger = 'RNG',
    sam = 'SAM', samurai = 'SAM',
    nin = 'NIN', ninja = 'NIN',
    drg = 'DRG', dragoon = 'DRG',
    smn = 'SMN', summoner = 'SMN',
    blu = 'BLU', blueMage = 'BLU', bluemage = 'BLU',
    cor = 'COR', corsair = 'COR',
    pup = 'PUP', puppetmaster = 'PUP',
    dnc = 'DNC', dancer = 'DNC',
    sch = 'SCH', scholar = 'SCH',
    geo = 'GEO', geomancer = 'GEO',
    run = 'RUN', runeFencer = 'RUN', runefencer = 'RUN',
}

local function normalize_job(job)
    if type(job) ~= 'string' then return nil end
    local key = job:lower():gsub('%s+', '')
    return aliases[key] or job:upper()
end

function jobs.GetWeaponsForJob(job)
    local id = normalize_job(job)
    if not id then return nil end
    return jobs[id]
end

return jobs
