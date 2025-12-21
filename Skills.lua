local skills = {};

skills.aliases = {
    -- Hand-to-Hand
    h2h = 'h2h', handtohand = 'h2h', hand2hand  = 'h2h',
    -- Dagger
    dagger = 'dagger', dag = 'dagger',
    -- Sword
    sword = 'sword',
    -- Great Sword
    gs  = 'gs', greatsword = 'gs',
    -- Axe / Great Axe
    axe  = 'axe', 
    ga = 'ga', greataxe = 'ga',
    -- Scythe
    scythe = 'scythe',
    -- Polearm
    polearm = 'polearm', pole = 'polearm',
    -- Katana / Great Katana
    katana = 'katana', 
    gkt = 'gkt', greatkatana = 'gkt',
    -- Club / Staff
    club  = 'club',
    staff = 'staff',
    -- Ranged
    archery      = 'archery',
    bow          = 'archery',
    mm           = 'mm',
    marksmanship = 'mm',
    gun          = 'mm',
    -- Pet skills bucket
    avatar = 'avatar',
}

skills.h2h = { -- Hand-to-Hand
    [1]  = {en='Combo',             skillchain={'Impaction'},                   skill=5},
    [2]  = {en='Shoulder Tackle',   skillchain={'Reverberation','Impaction'},   skill=40},
    [3]  = {en='One Inch Punch',    skillchain={'Compression'},                 skill=75,
                JobRestrictions={'MNK','PUP'},
                allowSubjob=true},
    [4]  = {en='Backhand Blow',     skillchain={'Detonation'},                  skill=100},
    [5]  = {en='Raging Fists',      skillchain={'Impaction'},                   skill=125,
                JobRestrictions={'MNK','PUP'},
                allowSubjob=true},
    [6]  = {en='Spinning Attack',   skillchain={'Liquefaction','Impaction'},    skill=150},
    [7]  = {en='Howling Fist',      skillchain={'Transfixion','Impaction'},     skill=200,
                JobRestrictions={'MNK','PUP'}},
    [8]  = {en='Dragon Kick',       skillchain={'Fragmentation'},               skill=225,
                JobRestrictions={'MNK','PUP'}},
    [9]  = {en='Asuran Fists¹',     skillchain={'Gravitation','Liquefaction'},  skill=250,
                JobRestrictions={'MNK','PUP'}},
    -- Relic WS treat as high end
    [10] = {en='Final Heaven²',     skillchain={'Light','Fusion'},              skill=250,
                JobRestrictions={'MNK','PUP'}},
};


skills.dagger = { -- Dagger
    [16] = {en='Wasp Sting',      skillchain={'Scission'},                       skill=5},
    [19] = {en='Gust Slash',      skillchain={'Detonation'},                     skill=40},
    [18] = {en='Shadowstitch',    skillchain={'Reverberation'},                  skill=70},   -- HorizonXI
    [17] = {en='Viper Bite',      skillchain={'Scission'},                       skill=100,
                JobRestrictions={'THF','RDM','BRD','RNG','NIN','DNC'},
                allowSubjob=true},
    [20] = {en='Cyclone',         skillchain={'Detonation','Impaction'},         skill=125},
    [23] = {en='Dancing Edge',    skillchain={'Scission','Detonation'},          skill=200,
                JobRestrictions={'THF','DNC'}},
    [24] = {en='Shark Bite',      skillchain={'Fragmentation'},                  skill=225,
                JobRestrictions={'THF','DNC'}},
    [25] = {en='Evisceration¹',   skillchain={'Gravitation','Transfixion'},      skill=230,
                JobRestrictions={'WAR','THF','RDM','BST','BRD','RNG','NIN','COR','DNC'}},
    -- Relic WS treat as high end
    [26] = {en='Mercy Stroke²',   skillchain={'Darkness','Gravitation'},         skill=230,
                JobRestrictions={'THF','RDM','BRD'}},
};

skills.sword = { -- Sword
    [32] = {en='Fast Blade',       skillchain={'Scission'},                      skill=5},
    [33] = {en='Burning Blade',    skillchain={'Liquefaction'},                  skill=30},
    [34] = {en='Red Lotus Blade',  skillchain={'Liquefaction','Detonation'},     skill=50,
                JobRestrictions={'WAR','RDM','PLD','DRK'},
                allowSubjob=true},
    [35] = {en='Flat Blade',       skillchain={'Impaction'},                     skill=75},
    [36] = {en='Shining Blade',    skillchain={'Scission'},                      skill=100},
    [37] = {en='Seraph Blade',     skillchain={'Scission','Transfixion'},        skill=125,
                JobRestrictions={'WAR','RDM','PLD','DRK'},
                allowSubjob=true},
    [38] = {en='Circle Blade',     skillchain={'Reverberation','Impaction'},     skill=150},
    [40] = {en='Vorpal Blade',     skillchain={'Scission','Impaction'},          skill=200,
                JobRestrictions={'WAR','RDM','PLD','DRK','BLU'},
                allowSubjob=true},
    [41] = {en='Swift Blade¹',     skillchain={'Gravitation'},                   skill=225,
                JobRestrictions={'PLD'}},
    [42] = {en='Savage Blade¹',    skillchain={'Fragmentation','Scission'},      skill=240,
                JobRestrictions={'WAR','RDM','PLD','DRK','BLU'}},
    -- Relic WS treat as high end
    [43] = {en='Knights of Round²',skillchain={'Light','Fusion'},                skill=240,
                JobRestrictions={'PLD','RDM'}},
};

skills.gs = { -- Great Sword
    [48] = {en='Hard Slash',      skillchain={'Scission'},                       skill=5},
    [49] = {en='Power Slash',     skillchain={'Transfixion'},                    skill=30},
    [50] = {en='Frostbite',       skillchain={'Induration'},                     skill=70},
    [51] = {en='Freezebite',      skillchain={'Detonation','Induration'},        skill=100},
    [52] = {en='Shockwave',       skillchain={'Reverberation'},                  skill=150},
    [53] = {en='Crescent Moon',   skillchain={'Scission','Compression'},         skill=175},
    [54] = {en='Sickle Moon',     skillchain={'Scission','Reverberation'},       skill=200,
                JobRestrictions={'PLD','DRK'}},
    [55] = {en='Spinning Slash',  skillchain={'Fragmentation'},                  skill=225,
                JobRestrictions={'PLD','DRK'}},
    [56] = {en='Ground Strike¹',  skillchain={'Fragmentation','Distortion'},     skill=250},
    -- Relic WS treat as high end
    [57] = {en='Scourge²',        skillchain={'Light','Fusion'},                 skill=250,
                JobRestrictions={'PLD','DRK'}},
};

skills.axe = { -- Axe
    [64] = {en='Raging Axe',      skillchain={'Detonation','Impaction'},         skill=5},
    [65] = {en='Smash Axe',       skillchain={'Induration','Reverberation'},     skill=40},
    [66] = {en='Gale Axe',        skillchain={'Detonation'},                     skill=70},
    [67] = {en='Avalanche Axe',   skillchain={'Induration'},                     skill=100}, -- HorizonXI
    [68] = {en='Spinning Axe',    skillchain={'Liquefaction','Scission'},        skill=150,  -- HorizonXI
                JobRestrictions={'WAR','DRK','BST'},
                allowSubjob=true},
    [69] = {en='Rampage',         skillchain={'Scission'},                       skill=175},
    [70] = {en='Calamity',        skillchain={'Scission','Impaction'},           skill=200,
                JobRestrictions={'WAR','BST'}},
    [71] = {en='Mistral Axe',     skillchain={'Fusion'},                         skill=225,
                JobRestrictions={'WAR','BST'}},
    [72] = {en='Decimation¹',     skillchain={'Fusion','Detonation'},            skill=240, -- HorizonXI
                JobRestrictions={'WAR','DRK','BST','RNG'}},
    -- Relic WS treat as high end
    [73] = {en='Onslaught²',      skillchain={'Darkness','Gravitation'},         skill=240,
                JobRestrictions={'BST'}},
};

skills.ga = { -- Great Axe
    [80] = {en='Shield Break',    skillchain={'Impaction'},                      skill=5},
    [81] = {en='Iron Tempest',    skillchain={'Scission'},                       skill=40},
    [82] = {en='Sturmwind',       skillchain={'Reverberation','Scission'},       skill=70,
                JobRestrictions={'WAR','DRK'},
                allowSubjob=true},
    [83] = {en='Armor Break',     skillchain={'Impaction'},                      skill=100},
    [84] = {en='Keen Edge',       skillchain={'Compression'},                    skill=150},
    [85] = {en='Weapon Break',    skillchain={'Impaction'},                      skill=175},
    [86] = {en='Raging Rush',     skillchain={'Induration','Reverberation'},     skill=200,
                JobRestrictions={'WAR'}},
    [87] = {en='Full Break¹',     skillchain={'Distortion'},                     skill=225,
                JobRestrictions={'WAR'}},
    [88] = {en='Steel Cyclone¹',  skillchain={'Distortion','Detonation'},        skill=240,
                JobRestrictions={'WAR','DRK'}},
    -- Relic WS treat as high end
    [89] = {en='Metatron Torment²',skillchain={'Light','Fusion'},                skill=240,
                JobRestrictions={'WAR'}},
};

skills.scythe = { -- Scythe
    [96] = {en='Slice',             skillchain={'Scission'},                    skill=5},
    [97] = {en='Dark Harvest',      skillchain={'Compression'},                 skill=30}, -- HorizonXI
    [98] = {en='Shadow of Death',   skillchain={'Induration','Reverberation'},  skill=70,
                JobRestrictions={'WAR','DRK'},
                allowSubjob=true},
    [99] = {en='Nightmare Scythe',  skillchain={'Compression','Scission'},      skill=100},
    [100]= {en='Spinning Scythe',   skillchain={'Reverberation','Scission'},    skill=125},
    [101]= {en='Vorpal Scythe',     skillchain={'Scission','Transfixion'},      skill=150},
    [102]= {en='Guillotine',        skillchain={'Induration'},                  skill=200,
                JobRestrictions={'DRK'}},
    [103]= {en='Cross Reaper',      skillchain={'Distortion'},                  skill=225,
                JobRestrictions={'DRK'}},
    [104]= {en='Spiral Hell¹',      skillchain={'Gravitation','Compression'},   skill=240, -- HorizonXI
                JobRestrictions={'WAR','DRK','BST'}},
    -- Relic WS treat as high end
    [105]= {en='Catastrophe²',      skillchain={'Darkness','Gravitation'},      skill=240,
                JobRestrictions={'DRK'}},
};

skills.polearm = { -- Polearm
    [112] = {en='Double Thrust',   skillchain={'Transfixion'},                  skill=5},
    [113] = {en='Thunder Thrust',  skillchain={'Transfixion','Impaction'},      skill=30},
    [114] = {en='Raiden Thrust',   skillchain={'Transfixion','Impaction'},      skill=70,
                JobRestrictions={'WAR','DRG','PLD'},
                allowSubjob=true},
    [115] = {en='Leg Sweep',       skillchain={'Impaction'},                    skill=100},
    [116] = {en='Penta Thrust',    skillchain={'Compression'},                  skill=150},
    [117] = {en='Vorpal Thrust',   skillchain={'Reverberation','Transfixion'},  skill=175},
    [118] = {en='Skewer',          skillchain={'Transfixion','Induration'},     skill=200,
                JobRestrictions={'DRG'}},
    [119] = {en='Wheeling Thrust¹',skillchain={'Fusion'},                       skill=225,
                JobRestrictions={'DRG'}},
    [120] = {en='Impulse Drive¹',  skillchain={'Gravitation','Induration'},     skill=240,
                JobRestrictions={'WAR','SAM','DRG'}},
    -- Relic WS treat as high end
    [121] = {en='Geirskogul²',     skillchain={'Light','Distortion'},           skill=240,
                JobRestrictions={'DRG'}},
};

skills.katana = { -- Katana; only NIN has skill
    [128] = {en='Blade: Rin',    skillchain={'Transfixion'},                    skill=5},
    [129] = {en='Blade: Retsu',  skillchain={'Scission'},                       skill=30},
    [130] = {en='Blade: Teki',   skillchain={'Reverberation'},                  skill=70},
    [131] = {en='Blade: To',     skillchain={'Induration','Detonation'},        skill=100},
    [132] = {en='Blade: Chi',    skillchain={'Impaction','Transfixion'},        skill=150},
    [133] = {en='Blade: Ei',     skillchain={'Compression'},                    skill=175},
    [134] = {en='Blade: Jin',    skillchain={'Detonation','Impaction'},         skill=200},
    [135] = {en='Blade: Ten',   skillchain={'Gravitation'},                     skill=225},
    [136] = {en='Blade: Ku¹',    skillchain={'Gravitation','Transfixion'},      skill=250},
    -- Relic WS treat as high end
    [137] = {en='Blade: Metsu²', skillchain={'Darkness','Fragmentation'},       skill=250},
};

skills.gkt = { -- Great Katana
    [144] = {en='Tachi: Enpi',    skillchain={'Transfixion','Scission'},        skill=5},
    [145] = {en='Tachi: Hobaku',  skillchain={'Induration'},                    skill=30},
    [146] = {en='Tachi: Goten',   skillchain={'Transfixion','Impaction'},       skill=70},
    [147] = {en='Tachi: Kagero',  skillchain={'Liquefaction'},                  skill=100},
    [148] = {en='Tachi: Jinpu',   skillchain={'Scission','Detonation'},         skill=150},
    [149] = {en='Tachi: Koki',    skillchain={'Reverberation','Impaction'},     skill=175},
    [150] = {en='Tachi: Yukikaze',skillchain={'Detonation','Induration'},       skill=200,
                JobRestrictions={'SAM'}},
    [151] = {en='Tachi: Gekko',   skillchain={'Distortion','Reverberation'},    skill=225,
                JobRestrictions={'SAM'}},
    [152] = {en='Tachi: Kasha',   skillchain={'Fusion','Compression'},          skill=250,
                JobRestrictions={'SAM'}},
    -- Relic WS treat as high end
    [153] = {en='Tachi: Kaiten²', skillchain={'Light','Fragmentation'},         skill=250,
                JobRestrictions={'SAM'}},
};

skills.club = { -- Club
    [160] = {en='Shining Strike', skillchain={'Transfixion'},                   skill=5},
    [162] = {en='Brainshaker',    skillchain={'Reverberation'},                 skill=70},
    [161] = {en='Seraph Strike',  skillchain={'Scission'},                      skill=100,
                JobRestrictions={'WAR','WHM','PLD','DRK','SAM'},
                allowSubjob=true},
    [165] = {en='Skullbreaker',   skillchain={'Induration','Reverberation'},    skill=150},
    [166] = {en='True Strike',    skillchain={'Detonation','Impaction'},        skill=175},
    [167] = {en='Judgment',       skillchain={'Impaction'},                     skill=200},
    [168] = {en='Hexa Strike',    skillchain={'Fusion'},                        skill=225,
                JobRestrictions={'WHM'}},
    [169] = {en='Black Halo¹',    skillchain={'Fragmentation','Compression'},   skill=230,
                JobRestrictions={'WAR','MNK','WHM','BLM','PLD','SMN'}},
    -- Relic WS treat as high end
    [170] = {en='Randgrith²',     skillchain={'Light','Fragmentation'},         skill=230,
                JobRestrictions={'WHM'}},
};

skills.staff = { -- Staff
    [176] = {en='Heavy Swing',     skillchain={'Impaction'},                    skill=5},
    [177] = {en='Rock Crusher',    skillchain={'Impaction'},                    skill=40},
    [178] = {en='Earth Crusher',   skillchain={'Detonation','Impaction'},       skill=70,
                JobRestrictions={'WAR','MNK','WHM','PLD'}},
    [179] = {en='Starburst',       skillchain={'Compression','Transfixion'},    skill=100},
    [180] = {en='Sunburst',        skillchain={'Transfixion','Reverberation'},  skill=150,
                JobRestrictions={'WAR','MNK','WHM','PLD'}},
    [181] = {en='Shell Crusher',   skillchain={'Detonation'},                   skill=175},
    [182] = {en='Full Swing',      skillchain={'Liquefaction','Impaction'},     skill=200},
    [183] = {en='Spirit Taker¹',   skillchain={'Compression','Induration'},     skill=215},
    [184] = {en='Retribution¹',    skillchain={'Gravitation','Reverberation'},  skill=230},
    -- Relic WS treat as high end
    [185] = {en='Gate of Tartarus²',skillchain={'Darkness','Distortion'},       skill=230,
                JobRestrictions={'BLM','SMN'}},
};

skills.archery = { -- Archery
    [192] = {en='Flaming Arrow',   skillchain={'Liquefaction','Transfixion'},   skill=5,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [193] = {en='Piercing Arrow',  skillchain={'Reverberation','Transfixion'},  skill=40,  -- HorizonXI
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [194] = {en='Dulling Arrow',   skillchain={'Transfixion', 'Liquefaction'},  skill=80,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [195] = {en='Sidewinder',      skillchain={'Reverberation','Transfixion','Detonation'},    skill=175,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [196] = {en='Blast Arrow',     skillchain={'Transfixion','Induration'},     skill=200,
                JobRestrictions={'RNG'}},
    [197] = {en='Arching Arrow',   skillchain={'Fusion'},                       skill=225,
                JobRestrictions={'RNG'}},
    [198] = {en='Empyreal Arrow¹', skillchain={'Fusion','Transfixion'},         skill=250,
                JobRestrictions={'RNG'}},
    -- Relic WS treat as high end
    [199] = {en='Namas Arrow²',    skillchain={'Light','Distortion'},           skill=250,
                JobRestrictions={'RNG','SAM'}},
};

skills.mm = { -- Marksmanship
    [208] = {en='Hot Shot',        skillchain={'Liquefaction','Transfixion'},   skill=5,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [209] = {en='Split Shot',      skillchain={'Reverberation','Transfixion'},  skill=40,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [210] = {en='Sniper Shot',     skillchain={'Transfixion','Liquefaction'},   skill=80,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [211] = {en='Slug Shot',       skillchain={'Reverberation','Transfixion','Detonation'},    skill=175,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [212] = {en='Blast Shot',      skillchain={'Transfixion','Induration'},     skill=200,
                JobRestrictions={'RNG'}},
    [213] = {en='Heavy Shot',      skillchain={'Fusion'},                       skill=225,
                JobRestrictions={'RNG'}},
    [214] = {en='Detonator¹',      skillchain={'Fusion','Transfixion'},         skill=250,
                JobRestrictions={'RNG','COR'}},
    -- Relic WS treat as high end
    [215] = {en='Coronach²',       skillchain={'Darkness','Fragmentation'},     skill=250,
                JobRestrictions={'RNG'}},
};

-- Pet skills as triggered by player.
skills.avatar = { -- SMN Player Pet Skills; skill is based on level
    [513] = {en='[C]Poison Nails',      skillchain={'Transfixion'},     skill=5},
    [528] = {en='[F]Moonlit Charge',    skillchain={'Compression'},     skill=5},
    [529] = {en='[F]Crescent Fang',     skillchain={'Transfixion'},     skill=10},
    [544] = {en='[I]Punch',             skillchain={'Liquefaction'},    skill=1},
    [546] = {en='[I]Burning Strike',    skillchain={'Impaction'},       skill=23},
    [547] = {en='[I]Double Punch',      skillchain={'Compression'},     skill=30},
    [560] = {en='[T]Rock Throw',        skillchain={'Scission'},        skill=1},
    [562] = {en='[T]Rock Buster',       skillchain={'Reverberation'},   skill=21},
    [563] = {en='[T]Megalith Throw',    skillchain={'Induration'},      skill=35},
    [576] = {en='[L]Barracuda Dive',    skillchain={'Reverberation'},   skill=1},
    [578] = {en='[L]Tail Whip',         skillchain={'Detonation'},      skill=26},
    [592] = {en='[G]Claw',              skillchain={'Detonation'},      skill=1},
    [608] = {en='[S]Axe Kick',          skillchain={'Induration'},      skill=1},
    [612] = {en='[S]Double Slap',       skillchain={'Scission'},        skill=50},
    [624] = {en='[R]Shock Strike',      skillchain={'Impaction'},       skill=1},
};

-- static information on skillchains
skills.ChainInfo = T{
    Radiance = T{level = 4, burst = T{'Lightning','Fire','Wind','Light'}},
    Umbra    = T{level = 4, burst = T{'Ice','Water','Earth','Dark'}},
    Light    = T{level = 3, burst = T{'Lightning','Fire','Wind','Light'},
        aeonic = T{level = 4, skillchain = 'Radiance'},
        Light  = T{level = 4, skillchain = 'Light'},
    },
    Darkness = T{level = 3, burst = T{'Ice','Water','Earth','Dark'},
        aeonic   = T{level = 4, skillchain = 'Umbra'},
        Darkness = T{level = 4, skillchain = 'Darkness'},
    },
    Gravitation = T{level = 2, burst = T{'Earth','Dark'},
        Distortion    = T{level = 3, skillchain = 'Darkness'},
        Fragmentation = T{level = 2, skillchain = 'Fragmentation'},
    },
    Fragmentation = T{level = 2, burst = T{'Lightning','Wind'},
        Fusion     = T{level = 3, skillchain = 'Light'},
        Distortion = T{level = 2, skillchain = 'Distortion'},
    },
    Distortion = T{level = 2, burst = T{'Ice','Water'},
        Gravitation = T{level = 3, skillchain = 'Darkness'},
        Fusion      = T{level = 2, skillchain = 'Fusion'},
    },
    Fusion = T{level = 2, burst = T{'Fire','Light'},
        Fragmentation = T{level = 3, skillchain = 'Light'},
        Gravitation   = T{level = 2, skillchain = 'Gravitation'},
    },
    Impaction = T{level = 1, burst = T{'Lightning'},
        Liquefaction = T{level = 1, skillchain = 'Liquefaction'},
        Detonation   = T{level = 1, skillchain = 'Detonation'},
    },
    Induration = T{level = 1, burst = T{'Ice'},
        Reverberation = T{level = 2, skillchain = 'Fragmentation'},
        Compression   = T{level = 1, skillchain = 'Compression'},
        Impaction     = T{level = 1, skillchain = 'Impaction'},
    },
    Liquefaction = T{level = 1, burst = T{'Fire'},
        Impaction = T{level = 2, skillchain = 'Fusion'},
        Scission  = T{level = 1, skillchain = 'Scission'},
    },
    Detonation = T{level = 1, burst = T{'Wind'},
        Compression = T{level = 2, skillchain = 'Gravitation'},
        Scission    = T{level = 1, skillchain = 'Scission'},
    },
    Reverberation = T{level = 1, burst = T{'Water'},
        Induration = T{level = 1, skillchain = 'Induration'},
        Impaction  = T{level = 1, skillchain = 'Impaction'},
    },
    Scission = T{level = 1, burst = T{'Earth'},
        Liquefaction  = T{level = 1, skillchain = 'Liquefaction'},
        Reverberation = T{level = 1, skillchain = 'Reverberation'},
        Detonation    = T{level = 1, skillchain = 'Detonation'},
    },
    Transfixion = T{level = 1, burst = T{'Light'},
        Scission      = T{level = 2, skillchain = 'Distortion'},
        Reverberation = T{level = 1, skillchain = 'Reverberation'},
        Compression   = T{level = 1, skillchain = 'Compression'},
    },
    Compression = T{level = 1, burst = T{'Dark'},
        Transfixion = T{level = 1, skillchain = 'Transfixion'},
        Detonation  = T{level = 1, skillchain = 'Detonation'},
    },
};

-- IMGUI RGB color format {red, green, blue, alpha}
local colors = {};   -- Color codes by Sammeh
colors.Light =         0xFFFFFFFF;
colors.Dark =          0xFF616161;
colors.Ice =           0xFF7FCDE6;
colors.Water =         0xFF2773C5;
colors.Earth =         0xFFC67643;
colors.Wind =          0xFF98FB98;
colors.Fire =          0xFFFF4500;
colors.Lightning =     0xFFDF70FF;
colors.Gravitation =   0xFF75604F;
colors.Fragmentation = 0xFF008080;
colors.Fusion =        0xFFFF4500;
colors.Distortion =    0xFF00AEE6;
colors.Darkness =      colors.Dark;
colors.Umbra =         colors.Dark;
colors.Compression =   colors.Dark;
colors.Radiance =      colors.Light;
colors.Transfixion =   colors.Light;
colors.Induration =    colors.Ice;
colors.Reverberation = colors.Water;
colors.Scission =      colors.Earth;
colors.Detonation =    colors.Wind;
colors.Liquefaction =  colors.Fire;
colors.Impaction =     colors.Lightning;

function skills.GetPropertyColor(t)
    return colors[t];
end

local displayOrder = {
    'Light', 'Darkness',
    'Fragmentation', 'Distortion', 'Fusion', 'Gravitation',
    'Impaction', 'Induration', 'Liquefaction', 'Detonation', 'Reverberation', 'Scission', 'Transfixion', 'Compression'
};

function skills.GetDisplayIndex(chain)
    for i, v in ipairs(displayOrder) do
        if v == chain then
            return i
        end
    end
    return #displayOrder + 1 -- Default to the end if not found
end

return skills;
