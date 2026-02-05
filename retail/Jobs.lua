-- Jobs.lua – Retail style job data (Level 99 cap)
--
-- Only includes weapon types that exist in skills.lua:
-- h2h, dagger, sword, gs (Great Sword), ga (Great Axe), axe, scythe,
-- polearm, katana, gkt (Great Katana), staff, club, archery, mm (Marksmanship).

local jobs = {}

-- Maximum character level for this version (Retail: 99)
jobs.MAX_LEVEL = 99

jobs.aliases = {
    -- Base jobs
    war = 'WAR', warrior     = 'WAR',
    mnk = 'MNK', monk        = 'MNK',
    whm = 'WHM', whitemage   = 'WHM',
    blm = 'BLM', blackmage   = 'BLM',
    rdm = 'RDM', redmage     = 'RDM',
    thf = 'THF', thief       = 'THF',
    pld = 'PLD', paladin     = 'PLD',
    drk = 'DRK', darkknight  = 'DRK',
    bst = 'BST', beastmaster = 'BST',
    brd = 'BRD', bard        = 'BRD',
    rng = 'RNG', ranger      = 'RNG',
    sam = 'SAM', samurai     = 'SAM',
    nin = 'NIN', ninja       = 'NIN',
    drg = 'DRG', dragoon     = 'DRG',
    smn = 'SMN', summoner    = 'SMN',

    -- ToAU jobs
    blu = 'BLU', bluemage     = 'BLU',
    cor = 'COR', corsair      = 'COR',
    pup = 'PUP', puppetmaster = 'PUP',

    -- WotG jobs
    dnc = 'DNC', dancer  = 'DNC',
    sch = 'SCH', scholar = 'SCH',

    -- SoA jobs
    geo = 'GEO', geomancer  = 'GEO',
    run = 'RUN', runefencer = 'RUN',
}

jobs.WAR = {
    defaultSubjob = 'NIN',
    primaryWeapons = { 'ga', 'axe' },
    weapons = {
        ga       = { skillRank = 'A+' },
        axe      = { skillRank = 'A-' },
        gs       = { skillRank = 'B+' },
        scythe   = { skillRank = 'B+' },
        sword    = { skillRank = 'B' },
        staff    = { skillRank = 'B' },
        polearm  = { skillRank = 'B-' },
        dagger   = { skillRank = 'B-' },
        club     = { skillRank = 'B-' },
        h2h      = { skillRank = 'D' },
        archery  = { skillRank = 'D' },
        mm       = { skillRank = 'E' },
    },
}

jobs.MNK = {
    defaultSubjob = 'WAR',
    primaryWeapons = { 'h2h' },
    weapons = {
        h2h   = { skillRank = 'A+' },
        staff = { skillRank = 'B' },
        club  = { skillRank = 'C+' },
    },
}

jobs.WHM = {
    defaultSubjob = 'BLM',
    primaryWeapons = { 'club' },
    weapons = {
        club  = { skillRank = 'B+' },
        staff = { skillRank = 'C+' },
    },
}

jobs.BLM = {
    defaultSubjob = 'RDM',
    primaryWeapons = { 'staff' },
    weapons = {
        staff  = { skillRank = 'B-' },
        club   = { skillRank = 'C+' },
        dagger = { skillRank = 'D' },
        scythe = { skillRank = 'F' },
    },
}

jobs.RDM = {
    defaultSubjob = 'WHM',
    primaryWeapons = { 'sword', 'dagger' },
    weapons = {
        dagger  = { skillRank = 'B' },
        sword   = { skillRank = 'B' },
        club    = { skillRank = 'D' },
        archery = { skillRank = 'D' },
        mm      = { skillRank = 'F' },
    },
}

jobs.THF = {
    defaultSubjob = 'NIN',
    primaryWeapons = { 'dagger' },
    weapons = {
        dagger  = { skillRank = 'A+' },
        mm      = { skillRank = 'C+' },
        archery = { skillRank = 'C-' },
        sword   = { skillRank = 'D' },
        club    = { skillRank = 'E' },
        h2h     = { skillRank = 'E' },
    },
}

jobs.PLD = {
    defaultSubjob = 'WAR',
    primaryWeapons = { 'sword', 'gs' },
    weapons = {
        sword   = { skillRank = 'A+' },
        club    = { skillRank = 'A-' },
        staff   = { skillRank = 'A-' },
        gs      = { skillRank = 'B' },
        dagger  = { skillRank = 'C-' },
        polearm = { skillRank = 'F' },
    },
}

jobs.DRK = {
    defaultSubjob = 'SAM',
    primaryWeapons = { 'scythe', 'gs' },
    weapons = {
        scythe = { skillRank = 'A+' },
        gs     = { skillRank = 'A-' },
        axe    = { skillRank = 'B-' },
        ga     = { skillRank = 'B-' },
        sword  = { skillRank = 'B-' },
        dagger = { skillRank = 'C' },
        club   = { skillRank = 'C-' },
    },
}

jobs.BST = {
    defaultSubjob = 'NIN',
    primaryWeapons = { 'axe' },
    weapons = {
        axe    = { skillRank = 'A+' },
        scythe = { skillRank = 'B-' },
        dagger = { skillRank = 'C+' },
        club   = { skillRank = 'D' },
        sword  = { skillRank = 'F' },
    },
}

jobs.BRD = {
    defaultSubjob = 'WHM',
    primaryWeapons = { 'dagger' },
    weapons = {
        dagger = { skillRank = 'B-' },
        staff  = { skillRank = 'C+' },
        sword  = { skillRank = 'C-' },
        club   = { skillRank = 'D' },
    },
}

jobs.RNG = {
    defaultSubjob = 'NIN',
    primaryWeapons = { 'archery', 'mm' },
    weapons = {
        axe     = { skillRank = 'B-' },
        dagger  = { skillRank = 'B-' },
        sword   = { skillRank = 'D' },
        club    = { skillRank = 'E' },
        archery = { skillRank = 'A-' },
        mm      = { skillRank = 'A-' },
    },
}

jobs.SAM = {
    defaultSubjob = 'WAR',
    primaryWeapons = { 'gkt' },
    weapons = {
        gkt     = { skillRank = 'A+' },
        polearm = { skillRank = 'B-' },
        sword   = { skillRank = 'C+' },
        archery = { skillRank = 'C+' },
        club    = { skillRank = 'E' },
        dagger  = { skillRank = 'E' },
    },
}

jobs.NIN = {
    defaultSubjob = 'WAR',
    primaryWeapons = { 'katana' },
    weapons = {
        katana  = { skillRank = 'A+' },
        dagger  = { skillRank = 'C+' },
        sword   = { skillRank = 'C' },
        gkt     = { skillRank = 'C-' },
        h2h     = { skillRank = 'E' },
        club    = { skillRank = 'E' },
        archery = { skillRank = 'E' },
        mm      = { skillRank = 'C' },
    },
}

jobs.DRG = {
    defaultSubjob = 'SAM',
    primaryWeapons = { 'polearm' },
    weapons = {
        polearm = { skillRank = 'A+' },
        staff   = { skillRank = 'B-' },
        sword   = { skillRank = 'C-' },
        club    = { skillRank = 'E' },
        dagger  = { skillRank = 'E' },
    },
}

jobs.SMN = {
    defaultSubjob = 'WHM',
    primaryWeapons = { 'avatar' },
    weapons = {
        avatar = { skillRank = 'Level' },
        staff  = { skillRank = 'B' },
        club   = { skillRank = 'C' },
        dagger = { skillRank = 'E' },
    },
}

-----------------------------------------------------------------------
-- ToAU Jobs
-----------------------------------------------------------------------

jobs.BLU = {
    defaultSubjob = 'NIN',
    primaryWeapons = { 'sword' },
    weapons = {
        sword = { skillRank = 'A+' },
        club  = { skillRank = 'B-' },
    },
}

jobs.COR = {
    defaultSubjob = 'NIN',
    primaryWeapons = { 'mm' },
    weapons = {
        dagger = { skillRank = 'B+' },
        sword  = { skillRank = 'B-' },
        mm     = { skillRank = 'B' },
    },
}

jobs.PUP = {
    defaultSubjob = 'WAR',
    primaryWeapons = { 'h2h' },
    weapons = {
        h2h    = { skillRank = 'A+' },
        dagger = { skillRank = 'C-' },
        club   = { skillRank = 'D' },
    },
}

-----------------------------------------------------------------------
-- WotG Jobs
-----------------------------------------------------------------------

jobs.DNC = {
    defaultSubjob = 'NIN',
    primaryWeapons = { 'dagger' },
    weapons = {
        dagger = { skillRank = 'A+' },
        sword  = { skillRank = 'D' },
        h2h    = { skillRank = 'D' },
    },
}

jobs.SCH = {
    defaultSubjob = 'RDM',
    primaryWeapons = { 'staff', 'club' },
    weapons = {
        staff  = { skillRank = 'C+' },
        club   = { skillRank = 'C+' },
        dagger = { skillRank = 'D' },
    },
}

-----------------------------------------------------------------------
-- SoA Jobs
-----------------------------------------------------------------------

jobs.GEO = {
    defaultSubjob = 'RDM',
    primaryWeapons = { 'club' },
    weapons = {
        club   = { skillRank = 'B+' },
        staff  = { skillRank = 'C+' },
        dagger = { skillRank = 'C-' },
    },
}

jobs.RUN = {
    defaultSubjob = 'NIN',
    primaryWeapons = { 'gs' },
    weapons = {
        gs   = { skillRank = 'A+' },
        sword = { skillRank = 'A' },
        ga   = { skillRank = 'B' },
        axe  = { skillRank = 'B-' },
        club = { skillRank = 'C-' },
    },
}

-----------------------------------------------------------------------
-- Helper function to get default subjob for a job
-----------------------------------------------------------------------
function jobs.GetDefaultSubjob(jobId)
    if not jobId then return nil end
    local jobData = jobs[jobId]
    if jobData and jobData.defaultSubjob then
        return jobData.defaultSubjob
    end
    return nil
end

return jobs
