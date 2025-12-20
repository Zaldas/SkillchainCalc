-- Jobs.lua – level 75 weapon skill caps (Era/Horizon style)
-- Only includes weapon types that exist in skills.lua:
-- h2h, dagger, sword, gs (Great Sword), ga (Great Axe), axe, scythe,
-- polearm, katana, gkt (Great Katana), staff, club, archery, mm (Marksmanship).

local jobs = {}

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

    -- ToAU+ jobs – stubs for now (empty weapons is fine)
    blu = 'BLU', bluemage    = 'BLU',
    cor = 'COR', corsair     = 'COR',
    pup = 'PUP', puppetmaster = 'PUP',
    dnc = 'DNC', dancer      = 'DNC',
    sch = 'SCH', scholar     = 'SCH',
}

jobs.WAR = {
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
-- Primary Weapons per Job

jobs.MNK = {
    primaryWeapons = { 'h2h' },
    weapons = {
        h2h   = { skillRank = 'A+' },
        staff = { skillRank = 'B' },
        club  = { skillRank = 'C+' },
    },
}

jobs.WHM = {
    primaryWeapons = { 'club' },
    weapons = {
        club  = { skillRank = 'B+' },
        staff = { skillRank = 'C+' },
    },
}

jobs.BLM = {
    primaryWeapons = { 'staff' },
    weapons = {
        staff  = { skillRank = 'B-' },
        club   = { skillRank = 'C+' },
        dagger = { skillRank = 'D' },
        scythe = { skillRank = 'F' },
    },
}

jobs.RDM = {
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
    primaryWeapons = { 'dagger' },
    weapons = {
        dagger = { skillRank = 'B-' },
        staff  = { skillRank = 'C+' },
        sword  = { skillRank = 'C-' },
        club   = { skillRank = 'D' },
    },
}

jobs.RNG = {
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
    primaryWeapons = { 'avatar' },
    weapons = {
        avatar = { skillRank = 'lvl' },     -- avatar skills are based on level
        staff  = { skillRank = 'B' },
        club   = { skillRank = 'C' },
        dagger = { skillRank = 'E' },
    },
}

-----------------------------------------------------------------------
-- TOAU/WotG jobs – basic melee caps for future use
-- (not critical for current SCC flow; safe to leave weapons empty if unused)
-----------------------------------------------------------------------
--[[
jobs.BLU = {
    weapons = {
        -- add weapons
    },
}

jobs.COR = {
    weapons = {
        -- add sword / dagger / gun (mm) once needed
    },
}

jobs.PUP = {
    weapons = {
        -- h2h, etc.
    },
}

jobs.DNC = {
    weapons = {
        -- dagger, sword etc.
    },
}

jobs.SCH = {
    weapons = {
        -- staff, club, dagger once you care about SCH WS here
    },
}
]]

return jobs
