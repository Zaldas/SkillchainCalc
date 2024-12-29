local skills = {};

skills.h2h = { -- Hand-to-Hand
    [1] = {en='Combo',skillchain={'Impaction'},tier=1},
    [2] = {en='Shoulder Tackle',skillchain={'Reverberation','Impaction'},tier=2},
    [3] = {en='One Inch Punch',skillchain={'Compression'},tier=3},
    [4] = {en='Backhand Blow',skillchain={'Detonation'},tier=4},
    [5] = {en='Raging Fists',skillchain={'Impaction'},tier=5},
    [6] = {en='Spinning Attack',skillchain={'Liquefaction','Impaction'},tier=6},
    [7] = {en='Howling Fist',skillchain={'Transfixion','Impaction'},tier=7},
    [8] = {en='Dragon Kick',skillchain={'Fragmentation'},tier=8},
    [9] = {en='Asuran Fists',skillchain={'Gravitation','Liquefaction'},tier=9},
    [10] = {en='Final Heaven',skillchain={'Light','Fusion'},tier=10},
};

skills.dagger = { -- Dagger
    [16] = {en='Wasp Sting',skillchain={'Scission'},tier=1},
    [17] = {en='Viper Bite',skillchain={'Scission'},tier=2},
    [18] = {en='Shadowstitch',skillchain={'Reverberation'},tier=3},    -- HorizonXI
    [19] = {en='Gust Slash',skillchain={'Detonation'},tier=4},
    [20] = {en='Cyclone',skillchain={'Detonation','Impaction'},tier=5},
    [23] = {en='Dancing Edge',skillchain={'Scission','Detonation'},tier=6},
    [24] = {en='Shark Bite',skillchain={'Fragmentation'},tier=7},
    [25] = {en='Evisceration',skillchain={'Gravitation','Transfixion'},tier=8},
    [26] = {en='Mercy Stroke',skillchain={'Darkness','Gravitation'},tier=9},
};

skills.sword = { -- Sword
    [32] = {en='Fast Blade',skillchain={'Scission'},tier=1},
    [33] = {en='Burning Blade',skillchain={'Liquefaction'},tier=2},
    [34] = {en='Red Lotus Blade',skillchain={'Liquefaction','Detonation'},tier=3},
    [35] = {en='Flat Blade',skillchain={'Impaction'},tier=4},
    [36] = {en='Shining Blade',skillchain={'Scission'},tier=5},
    [37] = {en='Seraph Blade',skillchain={'Scission','Transfixion'},tier=6},
    [38] = {en='Circle Blade',skillchain={'Reverberation','Impaction'},tier=7},
    [40] = {en='Vorpal Blade',skillchain={'Scission','Impaction'},tier=8},
    [41] = {en='Swift Blade',skillchain={'Gravitation'},tier=9},
    [42] = {en='Savage Blade',skillchain={'Fragmentation','Scission'},tier=10},
    [43] = {en='Knights of Round',skillchain={'Light','Fusion'},tier=11},
};

skills.gs = { -- Great Sword
    [48] = {en='Hard Slash',skillchain={'Scission'},tier=1},
    [49] = {en='Power Slash',skillchain={'Transfixion'},tier=2},
    [50] = {en='Frostbite',skillchain={'Induration'},tier=3},
    [51] = {en='Freezebite',skillchain={'Induration','Detonation'},tier=4},
    [52] = {en='Shockwave',skillchain={'Reverberation'},tier=5},
    [53] = {en='Crescent Moon',skillchain={'Scission'},tier=6},
    [54] = {en='Sickle Moon',skillchain={'Scission','Impaction'},tier=7},
    [55] = {en='Spinning Slash',skillchain={'Fragmentation'},tier=8},
    [56] = {en='Ground Strike',skillchain={'Fragmentation','Distortion'},tier=9},
    [57] = {en='Scourge',skillchain={'Light','Fusion'},tier=10},
};

skills.axe = { -- Axe
    [64] = {en='Raging Axe',skillchain={'Detonation','Impaction'},tier=1},
    [65] = {en='Smash Axe',skillchain={'Induration','Reverberation'},tier=2},
    [66] = {en='Gale Axe',skillchain={'Detonation'},tier=3},
    [67] = {en='Avalanche Axe',skillchain={'Induration'},tier=4},  -- HorizonXI
    [68] = {en='Spinning Axe',skillchain={'Liquefaction','Scission'},tier=5},  -- HorizonXI
    [69] = {en='Rampage',skillchain={'Scission'},tier=6},
    [70] = {en='Calamity',skillchain={'Scission','Impaction'},tier=7},
    [71] = {en='Mistral Axe',skillchain={'Fusion'},tier=8},
    [72] = {en='Decimation',skillchain={'Fusion','Detonation'},tier=9},
    [73] = {en='Onslaught',skillchain={'Darkness','Gravitation'},tier=10},
};

skills.ga = { -- Great Axe
    [80] = {en='Shield Break',skillchain={'Impaction'},tier=1},
    [81] = {en='Iron Tempest',skillchain={'Scission'},tier=2},
    [82] = {en='Sturmwind',skillchain={'Reverberation','Scission'},tier=3},
    [83] = {en='Armor Break',skillchain={'Impaction'},tier=4},
    [84] = {en='Keen Edge',skillchain={'Compression'},tier=5},
    [85] = {en='Weapon Break',skillchain={'Impaction'},tier=6},
    [86] = {en='Raging Rush',skillchain={'Induration','Reverberation'},tier=7},
    [87] = {en='Full Break',skillchain={'Distortion'},tier=8},
    [88] = {en='Steel Cyclone',skillchain={'Distortion','Detonation'},tier=9},
    [89] = {en='Metatron Torment',skillchain={'Light','Fusion'},tier=10},
};

skills.scythe = { -- Scythe
    [96] = {en='Slice',skillchain={'Scission'},tier=1},
    [97] = {en='Dark Harvest',skillchain={'Compression'},tier=2},  -- HorizonXI
    [98] = {en='Shadow of Death',skillchain={'Induration','Reverberation'},tier=3}, 
    [99] = {en='Nightmare Scythe',skillchain={'Compression','Scission'},tier=4},
    [100] = {en='Spinning Scythe',skillchain={'Reverberation','Scission'},tier=5},
    [101] = {en='Vorpal Scythe',skillchain={'Transfixion','Scission'},tier=6},
    [102] = {en='Guillotine',skillchain={'Induration'},tier=7},
    [103] = {en='Cross Reaper',skillchain={'Distortion'},tier=8},
    [104] = {en='Spiral Hell',skillchain={'Gravitation','Compression'},tier=9}, -- HorizonXI
    [105] = {en='Catastrophe',skillchain={'Fusion','Compression'},tier=10},
};

skills.polearm = { -- Polearm
    [112] = {en='Double Thrust',skillchain={'Transfixion'},tier=1},
    [113] = {en='Thunder Thrust',skillchain={'Transfixion','Impaction'},tier=2},
    [114] = {en='Raiden Thrust',skillchain={'Transfixion','Impaction'},tier=3},
    [115] = {en='Leg Sweep',skillchain={'Impaction'},tier=4},
    [116] = {en='Penta Thrust',skillchain={'Compression'},tier=5},
    [117] = {en='Vorpal Thrust',skillchain={'Reverberation','Transfixion'},tier=6},
    [118] = {en='Skewer',skillchain={'Transfixion','Impaction'},tier=7},
    [119] = {en='Wheeling Thrust',skillchain={'Fusion'},tier=8},
    [120] = {en='Impulse Drive',skillchain={'Gravitation','Induration'},tier=9},
    [121] = {en='Geirskogul',skillchain={'Light','Distortion'},tier=10},
};

skills.katana = { -- Katana
    [128] = {en='Blade: Rin',skillchain={'Transfixion'},tier=1},
    [129] = {en='Blade: Retsu',skillchain={'Scission'},tier=2},
    [130] = {en='Blade: Teki',skillchain={'Reverberation'},tier=3},
    [131] = {en='Blade: To',skillchain={'Induration','Detonation'},tier=4},
    [132] = {en='Blade: Chi',skillchain={'Transfixion','Impaction'},tier=5},
    [133] = {en='Blade: Ei',skillchain={'Compression'},tier=6},
    [134] = {en='Blade: Jin',skillchain={'Detonation','Impaction'},tier=7},
    [135] = {en='Blade: Ten',skillchain={'Gravitation'},tier=8},
    [136] = {en='Blade: Ku',skillchain={'Gravitation','Transfixion'},tier=9},
    [137] = {en='Blade: Metsu',skillchain={'Darkness','Fragmentation'},tier=10},
};

skills.gkt = { -- Great Katana
    [144] = {en='Tachi: Enpi',skillchain={'Transfixion','Scission'},tier=1},
    [145] = {en='Tachi: Hobaku',skillchain={'Induration'},tier=2},
    [146] = {en='Tachi: Goten',skillchain={'Transfixion','Impaction'},tier=3},
    [147] = {en='Tachi: Kagero',skillchain={'Liquefaction'},tier=4},
    [148] = {en='Tachi: Jinpu',skillchain={'Scission','Detonation'},tier=5},
    [149] = {en='Tachi: Koki',skillchain={'Reverberation','Impaction'},tier=6},
    [150] = {en='Tachi: Yukikaze',skillchain={'Induration','Detonation'},tier=7},
    [151] = {en='Tachi: Gekko',skillchain={'Distortion','Reverberation'},tier=8},
    [152] = {en='Tachi: Kasha',skillchain={'Fusion','Compression'},tier=9},
    [153] = {en='Tachi: Kaiten',skillchain={'Light','Fragmentation'},tier=10},
};

skills.club = { -- Club
    [160] = {en='Shining Strike',skillchain={'Transfixion'},tier=1},
    [161] = {en='Seraph Strike',skillchain={'Scission'},tier=2},
    [162] = {en='Brainshaker',skillchain={'Reverberation'},tier=3},
    [165] = {en='Skullbreaker',skillchain={'Induration','Reverberation'},tier=4},
    [166] = {en='True Strike',skillchain={'Detonation','Impaction'},tier=5},
    [167] = {en='Judgment',skillchain={'Impaction'},tier=6},
    [168] = {en='Hexa Strike',skillchain={'Fusion'},tier=7},
    [169] = {en='Black Halo',skillchain={'Fragmentation','Compression'},tier=8},
    [170] = {en='Randgrith',skillchain={'Light','Fragmentation'},tier=9},
};

skills.staff = { -- Staff
    [176] = {en='Heavy Swing',skillchain={'Impaction'},tier=1},
    [177] = {en='Rock Crusher',skillchain={'Impaction'},tier=2},
    [178] = {en='Earth Crusher',skillchain={'Detonation','Impaction'},tier=3},
    [179] = {en='Starburst',skillchain={'Compression','Transfixion'},tier=4},
    [180] = {en='Sunburst',skillchain={'Transfixion','Reverberation'},tier=5},
    [181] = {en='Shell Crusher',skillchain={'Detonation'},tier=6},
    [182] = {en='Full Swing',skillchain={'Liquefaction','Impaction'},tier=7},
    [184] = {en='Retribution',skillchain={'Gravitation','Reverberation'},tier=8},
    [185] = {en='Gate of Tartarus',skillchain={'Darkness','Distortion'},tier=9},
};

skills.archery = { -- Archery
    [192] = {en='Flaming Arrow',skillchain={'Liquefaction','Transfixion'},tier=1},
    [193] = {en='Piercing Arrow',skillchain={'Induration','Transfixion'},tier=2},  -- HorizonXI
    [194] = {en='Dulling Arrow',skillchain={'Liquefaction','Transfixion'},tier=3},
    [196] = {en='Sidewinder',skillchain={'Reverberation','Transfixion','Detonation'},tier=4},
    [197] = {en='Blast Arrow',skillchain={'Induration','Transfixion'},tier=5},
    [198] = {en='Arching Arrow',skillchain={'Fusion'},tier=6},
    [199] = {en='Empyreal Arrow',skillchain={'Fusion','Transfixion'},tier=7},
    [200] = {en='Namas Arrow',skillchain={'Light','Distortion'},tier=8},
};

skills.mm = { -- Marksmanship
    [208] = {en='Hot Shot',skillchain={'Liquefaction','Transfixion'},tier=1},
    [209] = {en='Split Shot',skillchain={'Reverberation','Transfixion'},tier=2},
    [210] = {en='Sniper Shot',skillchain={'Liquefaction','Transfixion'},tier=3},
    [212] = {en='Slug Shot',skillchain={'Reverberation','Transfixion','Detonation'},tier=4},
    [213] = {en='Blast Shot',skillchain={'Induration','Transfixion'},tier=5},
    [214] = {en='Heavy Shot',skillchain={'Fusion'},tier=6},
    [215] = {en='Detonator',skillchain={'Fusion','Transfixion'},tier=7},
    [216] = {en='Coronach',skillchain={'Darkness','Fragmentation'},tier=8},
};

-- Pet skills as triggered by player.
-- Separated from skills as triggered by pet to ease support for private servers
skills.smn = { -- BST/SMN Player Pet Skills
    [513] = {en='Poison Nails',skillchain={'Transfixion'},tier=1},
    [528] = {en='Moonlit Charge',skillchain={'Compression'},tier=2},
    [529] = {en='Crescent Fang',skillchain={'Transfixion'},tier=3},
    [544] = {en='Punch',skillchain={'Liquefaction'},tier=4},
    [546] = {en='Burning Strike',skillchain={'Impaction'},tier=5},
    [547] = {en='Double Punch',skillchain={'Compression'},tier=6},
    [560] = {en='Rock Throw',skillchain={'Scission'},tier=7},
    [562] = {en='Rock Buster',skillchain={'Reverberation'},tier=8},
    [563] = {en='Megalith Throw',skillchain={'Induration'},tier=9},
    [576] = {en='Barracuda Dive',skillchain={'Reverberation'},tier=10},
    [578] = {en='Tail Whip',skillchain={'Detonation'},tier=11},
    [592] = {en='Claw',skillchain={'Detonation'},tier=12},
    [608] = {en='Axe Kick',skillchain={'Induration'},tier=13},
    [612] = {en='Double Slap',skillchain={'Scission'},tier=14},
    [624] = {en='Shock Strike',skillchain={'Impaction'},tier=15},
};

-- static information on skillchains
skills.ChainInfo = T{
    Radiance = T{level = 4, burst = T{'Fire','Wind','Lightning','Light'}},
    Umbra    = T{level = 4, burst = T{'Earth','Ice','Water','Dark'}},
    Light    = T{level = 3, burst = T{'Fire','Wind','Lightning','Light'},
        aeonic = T{level = 4, skillchain = 'Radiance'},
        Light  = T{level = 4, skillchain = 'Light'},
    },
    Darkness = T{level = 3, burst = T{'Earth','Ice','Water','Dark'},
        aeonic   = T{level = 4, skillchain = 'Umbra'},
        Darkness = T{level = 4, skillchain = 'Darkness'},
    },
    Gravitation = T{level = 2, burst = T{'Earth','Dark'},
        Distortion    = T{level = 3, skillchain = 'Darkness'},
        Fragmentation = T{level = 2, skillchain = 'Fragmentation'},
    },
    Fragmentation = T{level = 2, burst = T{'Wind','Lightning'},
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
    Compression = T{level = 1, burst = T{'Darkness'},
        Transfixion = T{level = 1, skillchain = 'Transfixion'},
        Detonation  = T{level = 1, skillchain = 'Detonation'},
    },
    Liquefaction = T{level = 1, burst = T{'Fire'},
        Impaction = T{level = 2, skillchain = 'Fusion'},
        Scission  = T{level = 1, skillchain = 'Scission'},
    },
    Induration = T{level = 1, burst = T{'Ice'},
        Reverberation = T{level = 2, skillchain = 'Fragmentation'},
        Compression   = T{level = 1, skillchain = 'Compression'},
        Impaction     = T{level = 1, skillchain = 'Impaction'},
    },
    Reverberation = T{level = 1, burst = T{'Water'},
        Induration = T{level = 1, skillchain = 'Induration'},
        Impaction  = T{level = 1, skillchain = 'Impaction'},
    },
    Transfixion = T{level = 1, burst = T{'Light'},
        Scission      = T{level = 2, skillchain = 'Distortion'},
        Reverberation = T{level = 1, skillchain = 'Reverberation'},
        Compression   = T{level = 1, skillchain = 'Compression'},
    },
    Scission = T{level = 1, burst = T{'Earth'},
        Liquefaction  = T{level = 1, skillchain = 'Liquefaction'},
        Reverberation = T{level = 1, skillchain = 'Reverberation'},
        Detonation    = T{level = 1, skillchain = 'Detonation'},
    },
    Detonation = T{level = 1, burst = T{'Wind'},
        Compression = T{level = 2, skillchain = 'Gravitation'},
        Scission    = T{level = 1, skillchain = 'Scission'},
    },
    Impaction = T{level = 1, burst = T{'Lightning'},
        Liquefaction = T{level = 1, skillchain = 'Liquefaction'},
        Detonation   = T{level = 1, skillchain = 'Detonation'},
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

return skills
