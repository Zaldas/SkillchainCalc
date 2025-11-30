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
    drk = 'DRK', darkknight  = 'DRK', ['dark_knight'] = 'DRK',
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
        ga       = { maxSkill = 276 }, -- Great Axe
        axe      = { maxSkill = 269 },
        gs       = { maxSkill = 256 }, -- Great Sword
        scythe   = { maxSkill = 256 },
        sword    = { maxSkill = 250 },
        staff    = { maxSkill = 250 },
        polearm  = { maxSkill = 240 },
        dagger   = { maxSkill = 240 },
        club     = { maxSkill = 240 },
        h2h      = { maxSkill = 210 },
        archery  = { maxSkill = 210 },
        mm       = { maxSkill = 210 }, -- Marksmanship
    },
}
-- Primary Weapons per Job

jobs.MNK = {
    primaryWeapons = { 'h2h' },
    weapons = {
        h2h   = { maxSkill = 276 },
        staff = { maxSkill = 250 },
        club  = { maxSkill = 230 },
    },
}

jobs.WHM = {
    primaryWeapons = { 'club' },
    weapons = {
        club  = { maxSkill = 256 },
        staff = { maxSkill = 230 },
    },
}

jobs.BLM = {
    primaryWeapons = { 'staff' },
    weapons = {
        staff  = { maxSkill = 240 },
        club   = { maxSkill = 230 },
        dagger = { maxSkill = 210 },
        scythe = { maxSkill = 200 },
    },
}

jobs.RDM = {
    primaryWeapons = { 'sword', 'dagger' },
    weapons = {
        dagger  = { maxSkill = 250 },
        sword   = { maxSkill = 250 },
        club    = { maxSkill = 210 },
        archery = { maxSkill = 210 },
        mm      = { maxSkill = 189 }, -- Marksmanship / Throwing equivalent cap
    },
}

jobs.THF = {
    primaryWeapons = { 'dagger' },
    weapons = {
        dagger  = { maxSkill = 269 },
        mm      = { maxSkill = 230 },
        archery = { maxSkill = 220 },
        sword   = { maxSkill = 210 },
        club    = { maxSkill = 200 },
        h2h     = { maxSkill = 200 },
    },
}

jobs.PLD = {
    primaryWeapons = { 'sword', 'gs' },
    weapons = {
        sword   = { maxSkill = 276 },
        club    = { maxSkill = 269 },
        staff   = { maxSkill = 269 },
        gs      = { maxSkill = 250 },
        dagger  = { maxSkill = 220 },
        polearm = { maxSkill = 200 },
    },
}

jobs.DRK = {
    primaryWeapons = { 'scythe', 'gs' },
    weapons = {
        scythe = { maxSkill = 276 },
        gs     = { maxSkill = 269 },
        axe    = { maxSkill = 240 },
        ga     = { maxSkill = 240 },
        sword  = { maxSkill = 240 },
        dagger = { maxSkill = 225 },
        club   = { maxSkill = 220 },
    },
}

jobs.BST = {
    primaryWeapons = { 'axe' },
    weapons = {
        axe    = { maxSkill = 269 },
        scythe = { maxSkill = 240 },
        dagger = { maxSkill = 230 },
        club   = { maxSkill = 210 },
        sword  = { maxSkill = 200 },
    },
}

jobs.BRD = {
    primaryWeapons = { 'dagger' },
    weapons = {
        dagger = { maxSkill = 240 },
        staff  = { maxSkill = 230 },
        sword  = { maxSkill = 220 },
        club   = { maxSkill = 210 },
    },
}

jobs.RNG = {
    primaryWeapons = { 'archery', 'mm' },
    weapons = {
        axe     = { maxSkill = 240 },
        dagger  = { maxSkill = 240 },
        sword   = { maxSkill = 210 },
        club    = { maxSkill = 200 },
        archery = { maxSkill = 269 },
        mm      = { maxSkill = 269 }, -- Marksmanship
    },
}

jobs.SAM = {
    primaryWeapons = { 'gkt' },
    weapons = {
        gkt     = { maxSkill = 276 }, -- Great Katana
        polearm = { maxSkill = 240 },
        sword   = { maxSkill = 250 },
        archery = { maxSkill = 225 },
        club    = { maxSkill = 210 },
        dagger  = { maxSkill = 200 },
    },
}

jobs.NIN = {
    primaryWeapons = { 'katana' },
    weapons = {
        katana  = { maxSkill = 269 },
        dagger  = { maxSkill = 230 },
        sword   = { maxSkill = 225 },
        gkt     = { maxSkill = 220 },
        h2h     = { maxSkill = 200 },
        club    = { maxSkill = 200 },
        archery = { maxSkill = 200 },
        mm      = { maxSkill = 225 }, -- Marksmanship
    },
}

jobs.DRG = {
    primaryWeapons = { 'polearm' },
    weapons = {
        polearm = { maxSkill = 276 },
        staff   = { maxSkill = 240 },
        sword   = { maxSkill = 220 },
        club    = { maxSkill = 200 },
        dagger  = { maxSkill = 200 },
    },
}

jobs.SMN = {
    primaryWeapons = { 'staff' },
    weapons = {
        staff  = { maxSkill = 250 },
        club   = { maxSkill = 230 },
        dagger = { maxSkill = 200 },
    },
}

-----------------------------------------------------------------------
-- TOAU/WotG jobs – basic melee caps for future use
-- (not critical for current SCC flow; safe to leave weapons empty if unused)
-----------------------------------------------------------------------

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

return jobs
