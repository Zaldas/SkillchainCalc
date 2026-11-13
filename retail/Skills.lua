-- Skills.lua – Retail weapon skill data
-- Superscript legend:
--   ¹ = Quest or Merit weapon skill
--   ² = REMA/Prime weapon skill (requires specific weapon)
-- WS IDs sourced from http://wiki.dspt.info/index.php/Weapon_Skill_IDs

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
    -- Automaton (PUP pet)
    automaton = 'automaton', auto = 'automaton', puppet = 'automaton',
    -- Blue Magic
    blu = 'blu', bluemagic = 'blu',
}

-----------------------------------------------------------------------
-- Hand-to-Hand
-----------------------------------------------------------------------
skills.h2h = {
    [1]  = {en='Combo',              skillchain={'Impaction'},                    skill=5},
    [2]  = {en='Shoulder Tackle',    skillchain={'Reverberation','Impaction'},    skill=40},
    [3]  = {en='One Inch Punch',     skillchain={'Compression'},                  skill=75,
                JobRestrictions={'MNK','PUP'},
                allowSubjob=true},
    [4]  = {en='Backhand Blow',      skillchain={'Detonation'},                   skill=100},
    [5]  = {en='Raging Fists',       skillchain={'Impaction'},                    skill=125,
                JobRestrictions={'MNK','PUP'},
                allowSubjob=true},
    [6]  = {en='Spinning Attack',    skillchain={'Liquefaction','Impaction'},     skill=150},
    [7]  = {en='Howling Fist',       skillchain={'Transfixion','Impaction'},      skill=200,
                JobRestrictions={'MNK','PUP'}},
    [8]  = {en='Dragon Kick',        skillchain={'Fragmentation'},                skill=225,
                JobRestrictions={'MNK','PUP'}},
    [9]  = {en='Asuran Fists¹',      skillchain={'Gravitation','Liquefaction'},   skill=250,
                JobRestrictions={'MNK','PUP'}},
    [10] = {en='Final Heaven²', rema=true,      skillchain={'Light','Fusion'},               skill=276,
                JobRestrictions={'MNK'}},
    [11] = {en="Ascetic's Fury²", rema=true,    skillchain={'Fusion','Transfixion'},         skill=276,
                JobRestrictions={'MNK'}},
    [12] = {en='Stringing Pummel²', rema=true,  skillchain={'Gravitation','Liquefaction'},   skill=276,
                JobRestrictions={'PUP'}},
    [13] = {en='Tornado Kick',       skillchain={'Induration','Impaction','Detonation'}, skill=300,
                JobRestrictions={'MNK','PUP'},
                allowSubjob=true},
    [14] = {en='Victory Smite²', rema=true,     skillchain={'Light','Fragmentation'},        skill=331,
                JobRestrictions={'MNK','PUP'}},
    [15] = {en='Shijin Spiral¹',     skillchain={'Fusion','Reverberation'},       skill=357,
                JobRestrictions={'MNK','PUP'}},
    -- Prime WS (inferred ID)
    [241] = {en='Maru Kala²', rema=true,        skillchain={'Detonation','Compression','Distortion'}, skill=424},
};

-----------------------------------------------------------------------
-- Dagger
-----------------------------------------------------------------------
skills.dagger = {
    [16]  = {en='Wasp Sting',       skillchain={'Scission'},                       skill=5},
    [17]  = {en='Viper Bite',       skillchain={'Scission'},                       skill=100,
                JobRestrictions={'RDM','THF','BRD','RNG','NIN','DNC'},
                allowSubjob=true},
    [18]  = {en='Shadowstitch',     skillchain={'Reverberation'},                  skill=70},
    [19]  = {en='Gust Slash',       skillchain={'Detonation'},                     skill=40},
    [20]  = {en='Cyclone',          skillchain={'Detonation','Impaction'},         skill=125,
                JobRestrictions={'RDM','THF','BRD','RNG','NIN','DNC'},
                allowSubjob=true},
    [21]  = {en='Energy Steal',     skillchain={},                                 skill=150},
    [22]  = {en='Energy Drain',     skillchain={},                                 skill=175,
                JobRestrictions={'RDM','THF','BRD','RNG','NIN','DNC'},
                allowSubjob=true},
    [23]  = {en='Dancing Edge',     skillchain={'Scission','Detonation'},          skill=200,
                JobRestrictions={'THF','DNC'}},
    [24]  = {en='Shark Bite',       skillchain={'Fragmentation'},                  skill=225,
                JobRestrictions={'THF','DNC'}},
    [25]  = {en='Evisceration¹',    skillchain={'Gravitation','Transfixion'},      skill=230,
                JobRestrictions={'WAR','RDM','THF','BST','BRD','RNG','NIN','COR','DNC'}},
    [26]  = {en='Mercy Stroke²', rema=true,    skillchain={'Darkness','Gravitation'},         skill=240,
                JobRestrictions={'RDM','THF','BRD'}},
    [27]  = {en='Mandalic Stab²', rema=true,   skillchain={'Fusion','Compression'},           skill=276,
                JobRestrictions={'THF'}},
    [28]  = {en='Mordant Rime²', rema=true,    skillchain={'Fragmentation','Distortion'},     skill=240,
                JobRestrictions={'BRD'}},
    [29]  = {en='Pyrrhic Kleos²', rema=true,   skillchain={'Distortion','Scission'},          skill=331,
                JobRestrictions={'DNC'}},
    [30]  = {en='Aeolian Edge',     skillchain={'Scission','Detonation','Impaction'}, skill=290,
                JobRestrictions={'RDM','THF','BRD','RNG','NIN','DNC'},
                allowSubjob=true},
    [31]  = {en="Rudra's Storm²", rema=true,   skillchain={'Darkness','Distortion'},          skill=305,
                JobRestrictions={'THF','BRD','DNC'}},
    [224] = {en='Exenterator¹',     skillchain={'Fragmentation','Scission'},       skill=357,
                JobRestrictions={'WAR','RDM','THF','BST','BRD','RNG','NIN','COR','DNC'}},
    -- Prime WS (inferred ID)
    [242] = {en='Ruthless Stroke²', rema=true, skillchain={'Liquefaction','Impaction','Fragmentation'}, skill=424},
};

-----------------------------------------------------------------------
-- Sword
-----------------------------------------------------------------------
skills.sword = {
    [32]  = {en='Fast Blade',       skillchain={'Scission'},                       skill=5},
    [33]  = {en='Burning Blade',    skillchain={'Liquefaction'},                   skill=30},
    [34]  = {en='Red Lotus Blade',  skillchain={'Liquefaction','Detonation'},      skill=50,
                JobRestrictions={'WAR','RDM','PLD','DRK','BLU','RUN'},
                allowSubjob=true},
    [35]  = {en='Flat Blade',       skillchain={'Impaction'},                      skill=75},
    [36]  = {en='Shining Blade',    skillchain={'Scission'},                       skill=100},
    [37]  = {en='Seraph Blade',     skillchain={'Scission','Transfixion'},         skill=125,
                JobRestrictions={'WAR','RDM','PLD','DRK','BLU','RUN'},
                allowSubjob=true},
    [38]  = {en='Circle Blade',     skillchain={'Reverberation','Impaction'},      skill=150},
    [39]  = {en='Spirits Within',   skillchain={},                                 skill=175},
    [40]  = {en='Vorpal Blade',     skillchain={'Scission','Impaction'},           skill=200,
                JobRestrictions={'WAR','RDM','PLD','DRK','BLU','RUN'},
                allowSubjob=true},
    [41]  = {en='Swift Blade',      skillchain={'Gravitation'},                    skill=225,
                JobRestrictions={'PLD','RUN'}},
    [42]  = {en='Savage Blade¹',    skillchain={'Fragmentation','Scission'},       skill=240,
                JobRestrictions={'WAR','RDM','PLD','DRK','BLU','COR','RUN'}},
    [43]  = {en='Knights of Round²', rema=true, skillchain={'Light','Fusion'},                skill=250,
                JobRestrictions={'RDM','PLD'}},
    [44]  = {en='Death Blossom²', rema=true,   skillchain={'Fragmentation','Distortion'},     skill=250,
                JobRestrictions={'RDM'}},
    [45]  = {en='Atonement²', rema=true,       skillchain={'Fusion','Reverberation'},         skill=276,
                JobRestrictions={'PLD'}},
    [46]  = {en='Expiacion²', rema=true,       skillchain={'Distortion','Scission'},          skill=331,
                JobRestrictions={'BLU'}},
    [47]  = {en='Sanguine Blade',   skillchain={},                                 skill=300,
                JobRestrictions={'WAR','RDM','PLD','DRK','BLU','RUN'},
                allowSubjob=true},
    [225] = {en='Chant du Cygne²', rema=true,  skillchain={'Light','Distortion'},             skill=305,
                JobRestrictions={'RDM','PLD','BLU'}},
    [226] = {en='Requiescat¹',      skillchain={'Gravitation','Scission'},         skill=357,
                JobRestrictions={'WAR','RDM','PLD','DRK','SAM','BLU','COR','RUN'}},
    -- Prime WS (inferred ID)
    [243] = {en='Imperator²', rema=true,       skillchain={'Detonation','Compression','Distortion'}, skill=424},
};

-----------------------------------------------------------------------
-- Great Sword
-----------------------------------------------------------------------
skills.gs = {
    [48] = {en='Hard Slash',       skillchain={'Scission'},                       skill=5},
    [49] = {en='Power Slash',      skillchain={'Transfixion'},                    skill=30},
    [50] = {en='Frostbite',        skillchain={'Induration'},                     skill=70},
    [51] = {en='Freezebite',       skillchain={'Induration','Detonation'},        skill=100},
    [52] = {en='Shockwave',        skillchain={'Reverberation'},                  skill=150},
    [53] = {en='Crescent Moon',    skillchain={'Scission'},                       skill=175},
    [54] = {en='Sickle Moon',      skillchain={'Scission','Impaction'},           skill=200,
                JobRestrictions={'RUN','DRK','PLD'}},
    [55] = {en='Spinning Slash',   skillchain={'Fragmentation'},                  skill=225,
                JobRestrictions={'PLD','DRK','RUN'}},
    [56] = {en='Ground Strike¹',   skillchain={'Fragmentation','Distortion'},     skill=250,
                JobRestrictions={'WAR','PLD','DRK','RUN'}},
    [57] = {en='Scourge²', rema=true,         skillchain={'Light','Fusion'},                 skill=250,
                JobRestrictions={'WAR','PLD','DRK'}},
    [58] = {en='Herculean Slash',  skillchain={'Induration','Impaction','Detonation'}, skill=290},
    [59] = {en='Torcleaver²', rema=true,      skillchain={'Light','Distortion'},             skill=324,
                JobRestrictions={'DRK','PLD'}},
    [60] = {en='Resolution¹',      skillchain={'Fragmentation','Scission'},       skill=357},
    -- Aeonic/Prime WS (inferred IDs)
    [244] = {en='Dimidiation²', rema=true,    skillchain={'Light','Fragmentation'},          skill=331,
                JobRestrictions={'RUN'}},
    [245] = {en='Fimbulvetr²', rema=true,     skillchain={'Detonation','Compression','Distortion'}, skill=424},
};

-----------------------------------------------------------------------
-- Axe
-----------------------------------------------------------------------
skills.axe = {
    [64] = {en='Raging Axe',       skillchain={'Detonation','Impaction'},         skill=5},
    [65] = {en='Smash Axe',        skillchain={'Induration','Reverberation'},     skill=40},
    [66] = {en='Gale Axe',         skillchain={'Detonation'},                     skill=70},
    [67] = {en='Avalanche Axe',    skillchain={'Scission','Impaction'},           skill=100},
    [68] = {en='Spinning Axe',     skillchain={'Liquefaction','Scission'},        skill=150,
                JobRestrictions={'WAR','DRK','RUN','BST'},
                allowSubjob=true},
    [69] = {en='Rampage',          skillchain={'Scission'},                       skill=175},
    [70] = {en='Calamity',         skillchain={'Scission','Impaction'},           skill=200,
                JobRestrictions={'WAR','BST'}},
    [71] = {en='Mistral Axe',      skillchain={'Fusion'},                         skill=225,
                JobRestrictions={'WAR','BST'}},
    [72] = {en='Decimation¹',      skillchain={'Fusion','Reverberation'},         skill=240,
                JobRestrictions={'WAR','DRK','BST','RNG','RUN'}},
    [73] = {en='Onslaught²', rema=true,       skillchain={'Darkness','Gravitation'},         skill=269,
                JobRestrictions={'BST'}},
    [74] = {en='Primal Rend²', rema=true,     skillchain={'Gravitation','Reverberation'},    skill=276,
                JobRestrictions={'BST'}},
    [75] = {en='Bora Axe',         skillchain={'Scission','Detonation'},          skill=290,
                JobRestrictions={'WAR','BST'},
                allowSubjob=true},
    [76] = {en='Cloudsplitter²', rema=true,   skillchain={'Darkness','Fragmentation'},       skill=311,
                JobRestrictions={'WAR','BST'}},
    [77] = {en='Ruinator¹',        skillchain={'Distortion','Detonation'},        skill=357,
                JobRestrictions={'WAR','DRK','BST','RNG','RUN'}},
    -- Prime WS (inferred ID)
    [246] = {en='Blitz²', rema=true,          skillchain={'Liquefaction','Impaction','Fragmentation'}, skill=424,
                JobRestrictions={'BST'}},
};

-----------------------------------------------------------------------
-- Great Axe
-----------------------------------------------------------------------
skills.ga = {
    [80] = {en='Shield Break',     skillchain={'Impaction'},                      skill=5},
    [81] = {en='Iron Tempest',     skillchain={'Scission'},                       skill=40},
    [82] = {en='Sturmwind',        skillchain={'Reverberation','Scission'},       skill=70,
                JobRestrictions={'WAR','DRK','RUN'},
                allowSubjob=true},
    [83] = {en='Armor Break',      skillchain={'Impaction'},                      skill=100},
    [84] = {en='Keen Edge',        skillchain={'Compression'},                    skill=150},
    [85] = {en='Weapon Break',     skillchain={'Impaction'},                      skill=175},
    [86] = {en='Raging Rush',      skillchain={'Induration','Reverberation'},     skill=200,
                JobRestrictions={'WAR'}},
    [87] = {en='Full Break',       skillchain={'Distortion'},                     skill=225,
                JobRestrictions={'WAR'}},
    [88] = {en='Steel Cyclone¹',   skillchain={'Distortion','Detonation'},        skill=240,
                JobRestrictions={'WAR','DRK','RUN'}},
    [89] = {en='Metatron Torment²', rema=true, skillchain={'Light','Fusion'},                skill=256,
                JobRestrictions={'WAR'}},
    [90] = {en="King's Justice²", rema=true,  skillchain={'Fragmentation','Scission'},       skill=276,
                JobRestrictions={'WAR'}},
    [91] = {en='Fell Cleave',      skillchain={'Impaction','Scission','Detonation'}, skill=300,
                JobRestrictions={'WAR','DRK','RUN'},
                allowSubjob=true},
    [92] = {en="Ukko's Fury²", rema=true,     skillchain={'Light','Fragmentation'},          skill=331,
                JobRestrictions={'WAR'}},
    [93] = {en='Upheaval¹',        skillchain={'Fusion','Compression'},           skill=357,
                JobRestrictions={'WAR','DRK','RUN'}},
    -- Prime WS (inferred ID)
    [247] = {en='Disaster²', rema=true,       skillchain={'Transfixion','Scission','Gravitation'}, skill=424,
                JobRestrictions={'WAR'}},
};

-----------------------------------------------------------------------
-- Scythe
-----------------------------------------------------------------------
skills.scythe = {
    [96]  = {en='Slice',            skillchain={'Scission'},                      skill=5},
    [97]  = {en='Dark Harvest',     skillchain={'Reverberation'},                 skill=30},
    [98]  = {en='Shadow of Death',  skillchain={'Induration','Reverberation'},    skill=70,
                JobRestrictions={'WAR','DRK'},
                allowSubjob=true},
    [99]  = {en='Nightmare Scythe', skillchain={'Compression','Scission'},        skill=100},
    [100] = {en='Spinning Scythe',  skillchain={'Reverberation','Scission'},      skill=125},
    [101] = {en='Vorpal Scythe',    skillchain={'Transfixion','Scission'},        skill=150},
    [102] = {en='Guillotine',       skillchain={'Induration'},                    skill=200,
                JobRestrictions={'DRK'}},
    [103] = {en='Cross Reaper',     skillchain={'Distortion'},                    skill=225,
                JobRestrictions={'DRK'}},
    [104] = {en='Spiral Hell¹',     skillchain={'Distortion','Scission'},         skill=240,
                JobRestrictions={'WAR','DRK','BST'}},
    [105] = {en='Catastrophe²', rema=true,     skillchain={'Darkness','Gravitation'},        skill=269,
                JobRestrictions={'DRK'}},
    [106] = {en='Insurgency²', rema=true,      skillchain={'Fusion','Compression'},          skill=269,
                JobRestrictions={'DRK'}},
    [107] = {en='Infernal Scythe',  skillchain={'Compression','Reverberation'},   skill=300,
                JobRestrictions={'WAR','BLM','DRK','BST'},
                allowSubjob=true},
    [108] = {en='Quietus²', rema=true,         skillchain={'Darkness','Distortion'},         skill=324,
                JobRestrictions={'DRK'}},
    [109] = {en='Entropy¹',         skillchain={'Gravitation','Reverberation'},   skill=357,
                JobRestrictions={'WAR','DRK','BST'}},
    -- Prime WS (inferred ID)
    [248] = {en='Origin²', rema=true,          skillchain={'Induration','Reverberation','Fusion'}, skill=424,
                JobRestrictions={'DRK'}},
};

-----------------------------------------------------------------------
-- Polearm
-----------------------------------------------------------------------
skills.polearm = {
    [112] = {en='Double Thrust',    skillchain={'Transfixion'},                   skill=5},
    [113] = {en='Thunder Thrust',   skillchain={'Transfixion','Impaction'},       skill=30},
    [114] = {en='Raiden Thrust',    skillchain={'Transfixion','Impaction'},       skill=70,
                JobRestrictions={'WAR','PLD','DRG'},
                allowSubjob=true},
    [115] = {en='Leg Sweep',        skillchain={'Impaction'},                     skill=100},
    [116] = {en='Penta Thrust',     skillchain={'Compression'},                   skill=150},
    [117] = {en='Vorpal Thrust',    skillchain={'Reverberation','Transfixion'},   skill=175},
    [118] = {en='Skewer',           skillchain={'Transfixion','Impaction'},       skill=200,
                JobRestrictions={'DRG'}},
    [119] = {en='Wheeling Thrust',  skillchain={'Fusion'},                        skill=225,
                JobRestrictions={'DRG'}},
    [120] = {en='Impulse Drive¹',   skillchain={'Gravitation','Induration'},      skill=240,
                JobRestrictions={'WAR','SAM','DRG'}},
    [121] = {en='Geirskogul²', rema=true,      skillchain={'Light','Distortion'},            skill=276,
                JobRestrictions={'DRG'}},
    [122] = {en='Drakesbane²', rema=true,      skillchain={'Fusion','Transfixion'},          skill=276,
                JobRestrictions={'DRG'}},
    [123] = {en='Sonic Thrust',     skillchain={'Transfixion','Scission'},        skill=300,
                JobRestrictions={'WAR','PLD','DRG'},
                allowSubjob=true},
    [124] = {en="Camlann's Torment²", rema=true, skillchain={'Light','Fragmentation'},       skill=331,
                JobRestrictions={'DRG'}},
    [125] = {en='Stardiver¹',       skillchain={'Gravitation','Transfixion'},     skill=357,
                JobRestrictions={'WAR','SAM','DRG'}},
    -- Prime WS (inferred ID)
    [249] = {en='Diarmuid²', rema=true,        skillchain={'Transfixion','Scission','Gravitation'}, skill=424,
                JobRestrictions={'DRG'}},
};

-----------------------------------------------------------------------
-- Katana
-----------------------------------------------------------------------
skills.katana = {
    [128] = {en='Blade: Rin',       skillchain={'Transfixion'},                   skill=5},
    [129] = {en='Blade: Retsu',     skillchain={'Scission'},                      skill=30},
    [130] = {en='Blade: Teki',      skillchain={'Reverberation'},                 skill=70},
    [131] = {en='Blade: To',        skillchain={'Induration','Detonation'},       skill=100},
    [132] = {en='Blade: Chi',       skillchain={'Impaction','Transfixion'},       skill=150},
    [133] = {en='Blade: Ei',        skillchain={'Compression'},                   skill=175},
    [134] = {en='Blade: Jin',       skillchain={'Detonation','Impaction'},        skill=200,
                JobRestrictions={'NIN'}},
    [135] = {en='Blade: Ten',       skillchain={'Gravitation'},                   skill=225,
                JobRestrictions={'NIN'}},
    [136] = {en='Blade: Ku¹',       skillchain={'Gravitation','Transfixion'},     skill=250,
                JobRestrictions={'NIN'}},
    [137] = {en='Blade: Metsu²', rema=true,    skillchain={'Darkness','Fragmentation'},      skill=230,
                JobRestrictions={'NIN'}},
    [138] = {en='Blade: Kamu²', rema=true,     skillchain={'Fragmentation','Compression'},   skill=276,
                JobRestrictions={'NIN'}},
    [139] = {en='Blade: Yu',        skillchain={'Reverberation','Scission'},      skill=290,
                JobRestrictions={'NIN'}},
    [140] = {en='Blade: Hi²', rema=true,       skillchain={'Darkness','Gravitation'},        skill=331,
                JobRestrictions={'NIN'}},
    [141] = {en='Blade: Shun¹',     skillchain={'Fusion','Impaction'},            skill=357},
    -- Prime WS (inferred ID)
    [250] = {en='Zesho Meppo²', rema=true,     skillchain={'Induration','Reverberation','Fusion'}, skill=424,
                JobRestrictions={'NIN'}},
};

-----------------------------------------------------------------------
-- Great Katana
-----------------------------------------------------------------------
skills.gkt = {
    [144] = {en='Tachi: Enpi',      skillchain={'Transfixion','Scission'},        skill=5},
    [145] = {en='Tachi: Hobaku',    skillchain={'Induration'},                    skill=30},
    [146] = {en='Tachi: Goten',     skillchain={'Transfixion','Impaction'},       skill=70},
    [147] = {en='Tachi: Kagero',    skillchain={'Liquefaction'},                  skill=100},
    [148] = {en='Tachi: Jinpu',     skillchain={'Scission','Detonation'},         skill=150},
    [149] = {en='Tachi: Koki',      skillchain={'Reverberation','Impaction'},     skill=175},
    [150] = {en='Tachi: Yukikaze',  skillchain={'Induration','Detonation'},       skill=200,
                JobRestrictions={'SAM'}},
    [151] = {en='Tachi: Gekko',     skillchain={'Distortion','Reverberation'},    skill=225,
                JobRestrictions={'SAM'}},
    [152] = {en='Tachi: Kasha¹',    skillchain={'Fusion','Compression'},          skill=250,
                JobRestrictions={'SAM'}},
    [153] = {en='Tachi: Kaiten²', rema=true,   skillchain={'Light','Fragmentation'},         skill=276,
                JobRestrictions={'SAM'}},
    [154] = {en='Tachi: Rana²', rema=true,     skillchain={'Gravitation','Induration'},      skill=276,
                JobRestrictions={'SAM'}},
    [155] = {en='Tachi: Ageha',     skillchain={'Compression','Scission'},        skill=300},
    [156] = {en='Tachi: Fudo²', rema=true,     skillchain={'Light','Distortion'},            skill=331,
                JobRestrictions={'SAM'}},
    [157] = {en='Tachi: Shoha¹',    skillchain={'Fragmentation','Compression'},   skill=357,
                JobRestrictions={'SAM'}},
    -- Prime WS (inferred ID)
    [251] = {en='Tachi: Mumei²', rema=true,    skillchain={'Transfixion','Scission','Gravitation'}, skill=424,
                JobRestrictions={'SAM'}},
};

-----------------------------------------------------------------------
-- Club
-----------------------------------------------------------------------
skills.club = {
    [160] = {en='Shining Strike',   skillchain={'Impaction'},                     skill=5},
    [161] = {en='Seraph Strike',    skillchain={'Impaction'},                     skill=40,
                JobRestrictions={'WAR','WHM','PLD','DRK','SAM','BLU','GEO'},
                allowSubjob=true},
    [162] = {en='Brainshaker',      skillchain={'Reverberation'},                 skill=70},
    [163] = {en='Starlight',        skillchain={},                                skill=100},
    [164] = {en='Moonlight',        skillchain={},                                skill=125,
                JobRestrictions={'WAR','WHM','PLD','DRK','SAM','BLU','SCH','GEO'},
                allowSubjob=true},
    [165] = {en='Skullbreaker',     skillchain={'Induration','Reverberation'},    skill=150},
    [166] = {en='True Strike',      skillchain={'Detonation','Impaction'},        skill=175},
    [167] = {en='Judgment',         skillchain={'Impaction'},                     skill=200,
                JobRestrictions={'WAR','WHM','PLD','DRK','SAM','BLU','SCH','GEO','RUN'},
                allowSubjob=true},
    [168] = {en='Hexa Strike',      skillchain={'Fusion'},                        skill=220,
                JobRestrictions={'WHM','GEO'}},
    [169] = {en='Black Halo¹',      skillchain={'Fragmentation','Compression'},   skill=230,
                JobRestrictions={'WAR','MNK','WHM','BLM','PLD','SMN','BLU','SCH','GEO','RUN'}},
    [170] = {en='Randgrith²', rema=true,       skillchain={'Light','Fragmentation'},         skill=230,
                JobRestrictions={'WHM'}},
    [171] = {en='Mystic Boon²', rema=true,     skillchain={},                                skill=256,
                JobRestrictions={'WHM'}},
    [172] = {en='Flash Nova',       skillchain={'Reverberation','Induration'},    skill=290,
                JobRestrictions={'WAR','WHM','PLD','BLU','GEO'},
                allowSubjob=true},
    [173] = {en='Dagan²', rema=true,           skillchain={},                                skill=331,
                JobRestrictions={'WHM'}},
    [174] = {en='Realmrazer¹',      skillchain={'Fusion','Impaction'},            skill=357,
                JobRestrictions={'WAR','MNK','WHM','BLM','PLD','SMN','BLU','SCH','GEO','RUN'}},
    -- Prime WS (inferred IDs)
    [252] = {en='Exudation²', rema=true,       skillchain={'Induration','Reverberation','Fusion'}, skill=424,
                JobRestrictions={'GEO'}},
    [253] = {en='Dagda²', rema=true,           skillchain={'Liquefaction','Impaction','Fragmentation'}, skill=424,
                JobRestrictions={'WHM'}},
};

-----------------------------------------------------------------------
-- Staff
-----------------------------------------------------------------------
skills.staff = {
    [176] = {en='Heavy Swing',      skillchain={'Impaction'},                     skill=5},
    [177] = {en='Rock Crusher',     skillchain={'Impaction'},                     skill=40},
    [178] = {en='Earth Crusher',    skillchain={'Detonation','Impaction'},        skill=70,
                JobRestrictions={'WAR','MNK','WHM','PLD','SCH','GEO'},
                allowSubjob=true},
    [179] = {en='Starburst',        skillchain={'Compression','Reverberation'},   skill=100},
    [180] = {en='Sunburst',         skillchain={'Compression','Reverberation'},   skill=150,
                JobRestrictions={'WAR','MNK','WHM','PLD','SCH','GEO'},
                allowSubjob=true},
    [181] = {en='Shell Crusher',    skillchain={'Detonation'},                    skill=175},
    [182] = {en='Full Swing',       skillchain={'Liquefaction','Impaction'},      skill=200},
    [183] = {en='Spirit Taker',     skillchain={},                                skill=215},
    [184] = {en='Retribution¹',     skillchain={'Gravitation','Reverberation'},   skill=230,
                JobRestrictions={'WAR','MNK','WHM','BLM','PLD','BRD','DRG','SMN','SCH','GEO'}},
    [185] = {en='Gate of Tartarus²', rema=true, skillchain={'Darkness','Distortion'},        skill=250,
                JobRestrictions={'BLM','SMN'}},
    [186] = {en='Vidohunir²', rema=true,       skillchain={'Fragmentation','Distortion'},    skill=240,
                JobRestrictions={'BLM'}},
    [187] = {en='Garland of Bliss²', rema=true, skillchain={'Fusion','Reverberation'},       skill=250,
                JobRestrictions={'SMN'}},
    [188] = {en='Omniscience²', rema=true,     skillchain={'Gravitation','Transfixion'},     skill=285,
                JobRestrictions={'SCH'}},
    [189] = {en='Cataclysm',        skillchain={'Compression','Reverberation'},   skill=290,
                JobRestrictions={'MNK','PLD','SMN','GEO'},
                allowSubjob=true},
    [190] = {en='Myrkr²', rema=true,           skillchain={},                                skill=331,
                JobRestrictions={'BLM','SMN','SCH'}},
    [191] = {en='Shattersoul¹',     skillchain={'Gravitation','Induration'},      skill=357},
    -- Prime WS (inferred ID)
    [254] = {en='Oshala²', rema=true,          skillchain={'Detonation','Compression','Distortion'}, skill=424,
                JobRestrictions={'SCH'}},
};

-----------------------------------------------------------------------
-- Archery
-----------------------------------------------------------------------
skills.archery = {
    [192] = {en='Flaming Arrow',    skillchain={'Liquefaction','Transfixion'},    skill=5,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [193] = {en='Piercing Arrow',   skillchain={'Reverberation','Transfixion'},   skill=40,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [194] = {en='Dulling Arrow',    skillchain={'Liquefaction','Transfixion'},    skill=80,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [196] = {en='Sidewinder',       skillchain={'Reverberation','Transfixion','Detonation'}, skill=175,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [197] = {en='Blast Arrow',      skillchain={'Induration','Transfixion'},      skill=200,
                JobRestrictions={'RNG'}},
    [198] = {en='Arching Arrow',    skillchain={'Fusion'},                        skill=225,
                JobRestrictions={'RNG'}},
    [199] = {en='Empyreal Arrow¹',  skillchain={'Fusion','Transfixion'},          skill=250,
                JobRestrictions={'RNG'}},
    [200] = {en='Namas Arrow²', rema=true,     skillchain={'Light','Distortion'},            skill=269,
                JobRestrictions={'RNG','SAM'}},
    [201] = {en='Refulgent Arrow',  skillchain={'Reverberation','Transfixion'},   skill=290,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [202] = {en="Jishnu's Radiance²", rema=true, skillchain={'Light','Fusion'},              skill=331,
                JobRestrictions={'RNG'}},
    [203] = {en='Apex Arrow¹',      skillchain={'Fragmentation','Transfixion'},   skill=357,
                JobRestrictions={'RNG','SAM'}},
    -- Prime WS (inferred ID)
    [255] = {en='Sarv²', rema=true,            skillchain={'Transfixion','Scission','Gravitation'}, skill=424,
                JobRestrictions={'RNG'}},
};

-----------------------------------------------------------------------
-- Marksmanship
-----------------------------------------------------------------------
skills.mm = {
    [208] = {en='Hot Shot',         skillchain={'Liquefaction','Transfixion'},    skill=5,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [209] = {en='Split Shot',       skillchain={'Reverberation','Transfixion'},   skill=40,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [210] = {en='Sniper Shot',      skillchain={'Liquefaction','Transfixion'},    skill=80,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [212] = {en='Slug Shot',        skillchain={'Reverberation','Transfixion','Detonation'}, skill=175,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [213] = {en='Blast Shot',       skillchain={'Induration','Transfixion'},      skill=200,
                JobRestrictions={'RNG'}},
    [214] = {en='Heavy Shot',       skillchain={'Fusion'},                        skill=225,
                JobRestrictions={'RNG'}},
    [215] = {en='Detonator¹',       skillchain={'Fusion','Transfixion'},          skill=250,
                JobRestrictions={'RNG','COR'}},
    [216] = {en='Coronach²', rema=true,        skillchain={'Darkness','Fragmentation'},      skill=269,
                JobRestrictions={'RNG'}},
    [217] = {en='Trueflight²', rema=true,      skillchain={'Fragmentation','Scission'},      skill=269,
                JobRestrictions={'RNG'}},
    [218] = {en='Leaden Salute²', rema=true,   skillchain={'Gravitation','Transfixion'},     skill=398,
                JobRestrictions={'COR'}},
    [219] = {en='Numbing Shot',     skillchain={'Induration','Detonation'},       skill=290,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [220] = {en='Wildfire²', rema=true,        skillchain={'Darkness','Gravitation'},        skill=324,
                JobRestrictions={'RNG','COR'}},
    [221] = {en='Last Stand¹',      skillchain={'Fusion','Reverberation'},        skill=357,
                JobRestrictions={'THF','RNG','COR'}},
    -- Prime WS (inferred ID)
    [256] = {en='Terminus²', rema=true,        skillchain={'Detonation','Compression','Distortion'}, skill=424,
                JobRestrictions={'COR'}},
};

-----------------------------------------------------------------------
-- Avatar (SMN pet skills - level-based)
-- Only physical Blood Pacts have skillchain properties
-- Magical Blood Pacts (elemental damage) do NOT produce skillchains
-----------------------------------------------------------------------
skills.avatar = {
    -- Carbuncle
    [513] = {en='Poison Nails',     skillchain={'Transfixion'},                   skill=5},
    -- Cait Sith
    [521] = {en='Regal Scratch',    skillchain={'Scission'},                      skill=1},
    -- Fenrir
    [528] = {en='Moonlit Charge',   skillchain={'Compression'},                   skill=5},
    [529] = {en='Crescent Fang',    skillchain={'Transfixion'},                   skill=10},
    [534] = {en='Eclipse Bite',     skillchain={'Gravitation','Scission'},        skill=65},
    -- Ifrit
    [544] = {en='Punch',            skillchain={'Liquefaction'},                  skill=1},
    [546] = {en='Burning Strike',   skillchain={'Impaction'},                     skill=23},
    [547] = {en='Double Punch',     skillchain={'Compression'},                   skill=30},
    [550] = {en='Flaming Crush',    skillchain={'Fusion','Reverberation'},        skill=70},
    -- Titan
    [560] = {en='Rock Throw',       skillchain={'Scission'},                      skill=1},
    [562] = {en='Rock Buster',      skillchain={'Reverberation'},                 skill=21},
    [563] = {en='Megalith Throw',   skillchain={'Induration'},                    skill=35},
    [566] = {en='Mountain Buster',  skillchain={'Gravitation','Induration'},      skill=70},
    [570] = {en='Crag Throw',       skillchain={'Gravitation','Scission'},        skill=99},
    -- Leviathan
    [576] = {en='Barracuda Dive',   skillchain={'Reverberation'},                 skill=1},
    [578] = {en='Tail Whip',        skillchain={'Detonation'},                    skill=26},
    [582] = {en='Spinning Dive',    skillchain={'Distortion','Detonation'},       skill=70},
    -- Garuda
    [592] = {en='Claw',             skillchain={'Detonation'},                    skill=1},
    [598] = {en='Predator Claws',   skillchain={'Fragmentation','Scission'},      skill=70},
    -- Shiva
    [608] = {en='Axe Kick',         skillchain={'Induration'},                    skill=1},
    [612] = {en='Double Slap',      skillchain={'Scission'},                      skill=50},
    [614] = {en='Rush',             skillchain={'Distortion','Scission'},         skill=70},
    -- Ramuh
    [624] = {en='Shock Strike',     skillchain={'Impaction'},                     skill=1},
    [630] = {en='Chaotic Strike',   skillchain={'Fragmentation','Transfixion'},   skill=70},
    [634] = {en='Volt Strike',      skillchain={'Fragmentation','Scission'},      skill=99},
    -- Diabolos
    [656] = {en='Camisado',         skillchain={'Compression'},                   skill=1},
    [667] = {en='Blindside',        skillchain={'Gravitation','Transfixion'},     skill=99},
};

-----------------------------------------------------------------------
-- Automaton (PUP pet skills - automaton skill-based)
-- Frame types: Harlequin (default), Valoredge (melee), Sharpshot (ranged)
-----------------------------------------------------------------------
skills.automaton = {
    -- Harlequin Frame (shared with Stormwaker -- no unique Stormwaker weaponskills)
    [401] = {en='Slapstick',        skillchain={'Reverberation','Impaction'},     skill=0},
    [402] = {en='Knockout',         skillchain={'Scission','Detonation'},         skill=145},
    [403] = {en='Magic Mortar',     skillchain={'Fusion','Liquefaction'},         skill=225},
    -- Valoredge Frame
    [404] = {en='String Clipper',   skillchain={'Scission'},                      skill=0},
    [405] = {en='Chimera Ripper',   skillchain={'Detonation','Induration'},       skill=0},
    [406] = {en='Cannibal Blade',   skillchain={'Compression','Reverberation'},   skill=150},
    [407] = {en='Bone Crusher',     skillchain={'Fragmentation'},                 skill=245},
    [412] = {en='String Shredder',  skillchain={'Distortion','Scission'},         skill=324},
    -- Sharpshot Frame
    [408] = {en='Arcuballista',     skillchain={'Liquefaction','Transfixion'},    skill=0},
    [409] = {en='Daze',             skillchain={'Impaction','Transfixion'},       skill=150},
    [410] = {en='Armor Piercer',    skillchain={'Gravitation'},                   skill=245},
    [411] = {en='Armor Shatterer',  skillchain={'Fusion','Impaction'},            skill=324},
};

-----------------------------------------------------------------------
-- Blue Magic (BLU physical spells with skillchain properties)
-- skill = BLU level that learns the spell
-----------------------------------------------------------------------
skills.blu = {
    -- Level 1-20 spells
    [577] = {en='Foot Kick',        skillchain={'Detonation'},                    skill=1},
    [551] = {en='Power Attack',     skillchain={'Reverberation'},                 skill=4},
    [597] = {en='Sprout Smack',     skillchain={'Reverberation'},                 skill=4},
    [603] = {en='Wild Oats',        skillchain={'Transfixion'},                   skill=4},
    [599] = {en='Queasyshroom',     skillchain={'Compression'},                   skill=8},
    [620] = {en='Battle Dance',     skillchain={'Impaction'},                     skill=12},
    [623] = {en='Head Butt',        skillchain={'Impaction'},                     skill=12},
    [638] = {en='Feather Storm',    skillchain={'Transfixion'},                   skill=12},
    [567] = {en='Helldive',         skillchain={'Transfixion'},                   skill=16},
    [529] = {en='Bludgeon',         skillchain={'Liquefaction'},                  skill=18},
    [587] = {en='Claw Cyclone',     skillchain={'Scission'},                      skill=20},
    -- Level 21-50 spells
    [519] = {en='Screwdriver',      skillchain={'Transfixion','Scission'},        skill=26},
    [622] = {en='Grand Slam',       skillchain={'Induration'},                    skill=30},
    [527] = {en='Smite of Rage',    skillchain={'Detonation'},                    skill=34},
    [596] = {en='Pinecone Bomb',    skillchain={'Liquefaction'},                  skill=36},
    [569] = {en='Jet Stream',       skillchain={'Impaction'},                     skill=38},
    [594] = {en='Uppercut',         skillchain={'Liquefaction','Impaction'},      skill=38},
    [539] = {en='Terror Touch',     skillchain={'Compression','Reverberation'},   skill=40},
    [543] = {en='Mandibular Bite',  skillchain={'Induration'},                    skill=44},
    [545] = {en='Sickle Slash',     skillchain={'Compression'},                   skill=48},
    -- Level 51-75 spells
    [554] = {en='Death Scissors',   skillchain={'Compression','Reverberation'},   skill=60},
    [589] = {en='Dimensional Death', skillchain={'Transfixion','Impaction'},      skill=60},
    [652] = {en='Spiral Spin',      skillchain={'Transfixion'},                   skill=60},
    [650] = {en='Seedspray',        skillchain={'Induration','Detonation'},       skill=61},
    [564] = {en='Body Slam',        skillchain={'Impaction'},                     skill=62},
    [540] = {en='Spinal Cleave',    skillchain={'Scission','Detonation'},         skill=63},
    [560] = {en='Frenetic Rip',     skillchain={'Induration'},                    skill=63},
    [628] = {en='Frypan',           skillchain={'Impaction'},                     skill=63},
    [631] = {en='Hydro Shot',       skillchain={'Reverberation'},                 skill=63},
    [640] = {en='Tail Slap',        skillchain={'Reverberation'},                 skill=69},
    [641] = {en='Hysteric Barrage', skillchain={'Detonation'},                    skill=69},
    [643] = {en='Cannonball',       skillchain={'Fusion'},                        skill=70},
    [653] = {en='Asuran Claws',     skillchain={'Liquefaction','Impaction'},      skill=70},
    [611] = {en='Disseverment',     skillchain={'Distortion'},                    skill=72},
    [654] = {en='Sub-zero Smash',   skillchain={'Fragmentation'},                 skill=72},
    [585] = {en='Ram Charge',       skillchain={'Fragmentation'},                 skill=73},
    [617] = {en='Vertical Cleave',  skillchain={'Gravitation'},                   skill=75},
    -- Level 76-99 spells
    [665] = {en='Final Sting',      skillchain={'Fusion'},                        skill=81},
    [666] = {en='Goblin Rush',      skillchain={'Fusion','Impaction'},            skill=81},
    [669] = {en='Whirl of Rage',    skillchain={'Scission','Detonation'},         skill=83},
    [670] = {en='Benthic Typhoon',  skillchain={'Gravitation','Transfixion'},     skill=83},
    [673] = {en='Quad. Continuum',  skillchain={'Distortion','Scission'},         skill=85},
    [677] = {en='Empty Thrash',     skillchain={'Compression','Scission'},        skill=87},
    [682] = {en='Delta Thrust',     skillchain={'Liquefaction','Detonation'},     skill=89},
    [688] = {en='Heavy Strike',     skillchain={'Fragmentation','Transfixion'},   skill=92},
    [692] = {en='Sudden Lunge',     skillchain={'Detonation'},                    skill=95},
    [693] = {en='Quadrastrike',     skillchain={'Liquefaction','Scission'},       skill=96},
    [740] = {en='Tourbillion',      skillchain={'Light','Fragmentation'},         skill=97},
    [697] = {en='Amorphic Spikes',  skillchain={'Gravitation','Transfixion'},     skill=98},
    [699] = {en='Barbed Crescent',  skillchain={'Distortion','Scission'},         skill=99},
    [709] = {en='Thrashing Assault', skillchain={'Fusion','Impaction'},           skill=99},
    [714] = {en='Sinker Drill',     skillchain={'Gravitation','Reverberation'},   skill=99},
    [742] = {en='Bilgestorm',       skillchain={'Darkness','Gravitation'},        skill=99},
    [743] = {en='Bloodrake',        skillchain={'Darkness','Distortion'},         skill=99},
};

-----------------------------------------------------------------------
-- Skillchain Properties Info
-----------------------------------------------------------------------
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

-----------------------------------------------------------------------
-- Colors
-----------------------------------------------------------------------
local colors = {};
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
    'Radiance', 'Umbra',
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
    return #displayOrder + 1
end

return skills;
