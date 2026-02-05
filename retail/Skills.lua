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
    [10] = {en='Final Heaven²',      skillchain={'Light','Fusion'},               skill=276,
                JobRestrictions={'MNK'}},
    [11] = {en="Ascetic's Fury²",    skillchain={'Fusion','Transfixion'},         skill=276,
                JobRestrictions={'MNK'}},
    [12] = {en='Stringing Pummel²',  skillchain={'Gravitation','Liquefaction'},   skill=276,
                JobRestrictions={'PUP'}},
    [13] = {en='Tornado Kick',       skillchain={'Induration','Impaction','Detonation'}, skill=300,
                JobRestrictions={'MNK','PUP'},
                allowSubjob=true},
    [14] = {en='Victory Smite²',     skillchain={'Light','Fragmentation'},        skill=331,
                JobRestrictions={'MNK','PUP'}},
    [15] = {en='Shijin Spiral¹',     skillchain={'Fusion','Reverberation'},       skill=357,
                JobRestrictions={'MNK','PUP'}},
    -- Prime WS (inferred ID)
    [241] = {en='Maru Kala²',        skillchain={'Detonation','Compression','Distortion'}, skill=424},
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
                JobRestrictions={'RDM','THF','BRD','RNG','NIN','COR','DNC'},
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
    [26]  = {en='Mercy Stroke²',    skillchain={'Darkness','Gravitation'},         skill=240,
                JobRestrictions={'RDM','THF','BRD'}},
    [27]  = {en='Mandalic Stab²',   skillchain={'Fusion','Compression'},           skill=276,
                JobRestrictions={'THF'}},
    [28]  = {en='Mordant Rime²',    skillchain={'Fragmentation','Distortion'},     skill=240,
                JobRestrictions={'BRD'}},
    [29]  = {en='Pyrrhic Kleos²',   skillchain={'Distortion','Scission'},          skill=331,
                JobRestrictions={'DNC'}},
    [30]  = {en='Aeolian Edge',     skillchain={'Scission','Detonation','Impaction'}, skill=290,
                JobRestrictions={'RDM','THF','BRD','RNG','NIN','DNC'},
                allowSubjob=true},
    [31]  = {en="Rudra's Storm²",   skillchain={'Darkness','Distortion'},          skill=305,
                JobRestrictions={'THF','BRD','DNC'}},
    [224] = {en='Exenterator¹',     skillchain={'Fragmentation','Scission'},       skill=357,
                JobRestrictions={'WAR','RDM','THF','BST','BRD','RNG','NIN','COR','DNC'}},
    -- Prime WS (inferred ID)
    [242] = {en='Ruthless Stroke²', skillchain={'Liquefaction','Impaction','Fragmentation'}, skill=424},
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
    [43]  = {en='Knights of Round²', skillchain={'Light','Fusion'},                skill=250,
                JobRestrictions={'RDM','PLD','BLU'}},
    [44]  = {en='Death Blossom²',   skillchain={'Fragmentation','Distortion'},     skill=250,
                JobRestrictions={'RDM'}},
    [45]  = {en='Atonement²',       skillchain={'Fusion','Reverberation'},         skill=276,
                JobRestrictions={'PLD'}},
    [46]  = {en='Expiacion²',       skillchain={'Distortion','Scission'},          skill=331,
                JobRestrictions={'BLU'}},
    [47]  = {en='Sanguine Blade',   skillchain={},                                 skill=300,
                JobRestrictions={'WAR','RDM','PLD','DRK','BLU','RUN'},
                allowSubjob=true},
    [225] = {en='Chant du Cygne²',  skillchain={'Light','Distortion'},             skill=305,
                JobRestrictions={'RDM','PLD','BLU'}},
    [226] = {en='Requiescat¹',      skillchain={'Gravitation','Scission'},         skill=357,
                JobRestrictions={'WAR','RDM','PLD','DRK','SAM','BLU','COR','RUN'}},
    -- Prime WS (inferred ID)
    [243] = {en='Imperator²',       skillchain={'Detonation','Compression','Distortion'}, skill=424},
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
                JobRestrictions={'WAR','RUN','DRK','PLD'}},
    [56] = {en='Ground Strike¹',   skillchain={'Fragmentation','Distortion'},     skill=250,
                JobRestrictions={'WAR','PLD','DRK','RUN'}},
    [57] = {en='Scourge²',         skillchain={'Light','Fusion'},                 skill=250,
                JobRestrictions={'WAR','PLD','DRK'}},
    [58] = {en='Herculean Slash',  skillchain={'Induration','Impaction','Detonation'}, skill=290},
    [59] = {en='Torcleaver²',      skillchain={'Light','Distortion'},             skill=324,
                JobRestrictions={'DRK','PLD'}},
    [60] = {en='Resolution¹',      skillchain={'Fragmentation','Scission'},       skill=357},
    -- Aeonic/Prime WS (inferred IDs)
    [244] = {en='Dimidiation²',    skillchain={'Light','Fragmentation'},          skill=331,
                JobRestrictions={'RUN'}},
    [245] = {en='Fimbulvetr²',     skillchain={'Detonation','Compression','Distortion'}, skill=424},
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
    [73] = {en='Onslaught²',       skillchain={'Darkness','Gravitation'},         skill=269},
    [74] = {en='Primal Rend²',     skillchain={'Gravitation','Reverberation'},    skill=276,
                JobRestrictions={'BST'}},
    [75] = {en='Bora Axe',         skillchain={'Scission','Detonation'},          skill=290,
                JobRestrictions={'WAR','DRK','RUN','BST'},
                allowSubjob=true},
    [76] = {en='Cloudsplitter²',   skillchain={'Darkness','Fragmentation'},       skill=311,
                JobRestrictions={'WAR','BST'}},
    [77] = {en='Ruinator¹',        skillchain={'Distortion','Detonation'},        skill=357,
                JobRestrictions={'WAR','DRK','BST','RNG','RUN'}},
    -- Prime WS (inferred ID)
    [246] = {en='Blitz²',          skillchain={'Liquefaction','Impaction','Fragmentation'}, skill=424,
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
    [89] = {en='Metatron Torment²', skillchain={'Light','Fusion'},                skill=256},
    [90] = {en="King's Justice²",  skillchain={'Fragmentation','Scission'},       skill=276,
                JobRestrictions={'WAR'}},
    [91] = {en='Fell Cleave',      skillchain={'Impaction','Scission','Detonation'}, skill=300,
                JobRestrictions={'WAR','DRK','RUN'},
                allowSubjob=true},
    [92] = {en="Ukko's Fury²",     skillchain={'Light','Fragmentation'},          skill=331,
                JobRestrictions={'WAR'}},
    [93] = {en='Upheaval¹',        skillchain={'Fusion','Compression'},           skill=357,
                JobRestrictions={'WAR','DRK','RUN'}},
    -- Prime WS (inferred ID)
    [247] = {en='Disaster²',       skillchain={'Transfixion','Scission','Gravitation'}, skill=424,
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
    [105] = {en='Catastrophe²',     skillchain={'Darkness','Gravitation'},        skill=269,
                JobRestrictions={'DRK'}},
    [106] = {en='Insurgency²',      skillchain={'Fusion','Compression'},          skill=269,
                JobRestrictions={'DRK'}},
    [107] = {en='Infernal Scythe',  skillchain={'Compression','Reverberation'},   skill=300,
                JobRestrictions={'WAR','DRK'},
                allowSubjob=true},
    [108] = {en='Quietus²',         skillchain={'Darkness','Distortion'},         skill=324,
                JobRestrictions={'DRK'}},
    [109] = {en='Entropy¹',         skillchain={'Gravitation','Reverberation'},   skill=357,
                JobRestrictions={'WAR','DRK','BST'}},
    -- Prime WS (inferred ID)
    [248] = {en='Origin²',          skillchain={'Induration','Reverberation','Fusion'}, skill=424,
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
    [121] = {en='Geirskogul²',      skillchain={'Light','Distortion'},            skill=276},
    [122] = {en='Drakesbane²',      skillchain={'Fusion','Transfixion'},          skill=276,
                JobRestrictions={'DRG'}},
    [123] = {en='Sonic Thrust',     skillchain={'Transfixion','Scission'},        skill=300,
                JobRestrictions={'WAR','PLD','DRG'},
                allowSubjob=true},
    [124] = {en="Camlann's Torment²", skillchain={'Light','Fragmentation'},       skill=331,
                JobRestrictions={'DRG'}},
    [125] = {en='Stardiver¹',       skillchain={'Gravitation','Transfixion'},     skill=357,
                JobRestrictions={'WAR','SAM','DRG'}},
    -- Prime WS (inferred ID)
    [249] = {en='Diarmuid²',        skillchain={'Transfixion','Scission','Gravitation'}, skill=424,
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
    [137] = {en='Blade: Metsu²',    skillchain={'Darkness','Fragmentation'},      skill=230},
    [138] = {en='Blade: Kamu²',     skillchain={'Fragmentation','Compression'},   skill=276,
                JobRestrictions={'NIN'}},
    [139] = {en='Blade: Yu',        skillchain={'Reverberation','Scission'},      skill=290,
                JobRestrictions={'NIN'}},
    [140] = {en='Blade: Hi²',       skillchain={'Darkness','Gravitation'},        skill=331,
                JobRestrictions={'NIN'}},
    [141] = {en='Blade: Shun¹',     skillchain={'Fusion','Impaction'},            skill=357},
    -- Prime WS (inferred ID)
    [250] = {en='Zesho Meppo²',     skillchain={'Induration','Reverberation','Fusion'}, skill=424,
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
    [153] = {en='Tachi: Kaiten²',   skillchain={'Light','Fragmentation'},         skill=276},
    [154] = {en='Tachi: Rana²',     skillchain={'Gravitation','Induration'},      skill=276,
                JobRestrictions={'SAM'}},
    [155] = {en='Tachi: Ageha',     skillchain={'Compression','Scission'},        skill=300},
    [156] = {en='Tachi: Fudo²',     skillchain={'Light','Distortion'},            skill=331,
                JobRestrictions={'SAM'}},
    [157] = {en='Tachi: Shoha¹',    skillchain={'Fragmentation','Compression'},   skill=357,
                JobRestrictions={'SAM'}},
    -- Prime WS (inferred ID)
    [251] = {en='Tachi: Mumei²',    skillchain={'Transfixion','Scission','Gravitation'}, skill=424,
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
                JobRestrictions={'WAR','WHM','PLD','DRK','SAM','BLU','GEO'},
                allowSubjob=true},
    [165] = {en='Skullbreaker',     skillchain={'Induration','Reverberation'},    skill=150},
    [166] = {en='True Strike',      skillchain={'Detonation','Impaction'},        skill=175},
    [167] = {en='Judgment',         skillchain={'Impaction'},                     skill=200,
                JobRestrictions={'WAR','WHM','PLD','DRK','SAM','BLU','GEO'},
                allowSubjob=true},
    [168] = {en='Hexa Strike',      skillchain={'Fusion'},                        skill=220,
                JobRestrictions={'WHM','GEO'}},
    [169] = {en='Black Halo¹',      skillchain={'Fragmentation','Compression'},   skill=230,
                JobRestrictions={'WAR','MNK','WHM','BLM','PLD','SMN','BLU','SCH','GEO'}},
    [170] = {en='Randgrith²',       skillchain={'Light','Fragmentation'},         skill=230},
    [171] = {en='Mystic Boon²',     skillchain={},                                skill=256,
                JobRestrictions={'WHM'}},
    [172] = {en='Flash Nova',       skillchain={'Reverberation','Induration'},    skill=290,
                JobRestrictions={'WAR','WHM','PLD','DRK','SAM','BLU','GEO'},
                allowSubjob=true},
    [173] = {en='Dagan²',           skillchain={},                                skill=331,
                JobRestrictions={'WHM'}},
    [174] = {en='Realmrazer¹',      skillchain={'Fusion','Impaction'},            skill=357,
                JobRestrictions={'WAR','MNK','WHM','BLM','PLD','SMN','BLU','SCH','GEO'}},
    -- Prime WS (inferred IDs)
    [252] = {en='Exudation²',       skillchain={'Induration','Reverberation','Fusion'}, skill=424,
                JobRestrictions={'GEO'}},
    [253] = {en='Dagda²',           skillchain={'Liquefaction','Impaction','Fragmentation'}, skill=424,
                JobRestrictions={'WHM'}},
};

-----------------------------------------------------------------------
-- Staff
-----------------------------------------------------------------------
skills.staff = {
    [176] = {en='Heavy Swing',      skillchain={'Impaction'},                     skill=5},
    [177] = {en='Rock Crusher',     skillchain={'Impaction'},                     skill=40},
    [178] = {en='Earth Crusher',    skillchain={'Detonation','Impaction'},        skill=70,
                JobRestrictions={'WAR','MNK','WHM','PLD','GEO'},
                allowSubjob=true},
    [179] = {en='Starburst',        skillchain={'Compression','Reverberation'},   skill=100},
    [180] = {en='Sunburst',         skillchain={'Compression','Reverberation'},   skill=150,
                JobRestrictions={'WAR','MNK','WHM','PLD','GEO'},
                allowSubjob=true},
    [181] = {en='Shell Crusher',    skillchain={'Detonation'},                    skill=175},
    [182] = {en='Full Swing',       skillchain={'Liquefaction','Impaction'},      skill=200},
    [183] = {en='Spirit Taker',     skillchain={},                                skill=215},
    [184] = {en='Retribution¹',     skillchain={'Gravitation','Reverberation'},   skill=230,
                JobRestrictions={'WAR','MNK','WHM','BLM','PLD','BRD','DRG','SMN','SCH','GEO'}},
    [185] = {en='Gate of Tartarus²', skillchain={'Darkness','Distortion'},        skill=250},
    [186] = {en='Vidohunir²',       skillchain={'Fragmentation','Distortion'},    skill=240,
                JobRestrictions={'BLM'}},
    [187] = {en='Garland of Bliss²', skillchain={'Fusion','Reverberation'},       skill=250,
                JobRestrictions={'SMN'}},
    [188] = {en='Omniscience²',     skillchain={'Gravitation','Transfixion'},     skill=285,
                JobRestrictions={'SCH'}},
    [189] = {en='Cataclysm',        skillchain={'Compression','Reverberation'},   skill=290,
                JobRestrictions={'WAR','MNK','WHM','PLD','GEO'},
                allowSubjob=true},
    [190] = {en='Myrkr²',           skillchain={},                                skill=331,
                JobRestrictions={'BLM','SMN','SCH'}},
    [191] = {en='Shattersoul¹',     skillchain={'Gravitation','Induration'},      skill=357},
    -- Prime WS (inferred ID)
    [254] = {en='Oshala²',          skillchain={'Detonation','Compression','Distortion'}, skill=424,
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
    [200] = {en='Namas Arrow²',     skillchain={'Light','Distortion'},            skill=269},
    [201] = {en='Refulgent Arrow',  skillchain={'Reverberation','Transfixion'},   skill=290,
                JobRestrictions={'RNG'},
                allowSubjob=true},
    [202] = {en="Jishnu's Radiance²", skillchain={'Light','Fusion'},              skill=331,
                JobRestrictions={'RNG'}},
    [203] = {en='Apex Arrow¹',      skillchain={'Fragmentation','Transfixion'},   skill=357,
                JobRestrictions={'RNG','SAM'}},
    -- Prime WS (inferred ID)
    [255] = {en='Sarv²',            skillchain={'Transfixion','Scission','Gravitation'}, skill=424,
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
    [216] = {en='Coronach²',        skillchain={'Darkness','Fragmentation'},      skill=269},
    [217] = {en='Trueflight²',      skillchain={'Fragmentation','Scission'},      skill=269,
                JobRestrictions={'RNG'}},
    [218] = {en='Leaden Salute²',   skillchain={'Gravitation','Transfixion'},     skill=398,
                JobRestrictions={'COR'}},
    [219] = {en='Numbing Shot',     skillchain={'Induration','Detonation'},       skill=290,
                JobRestrictions={'RNG','COR'},
                allowSubjob=true},
    [220] = {en='Wildfire²',        skillchain={'Darkness','Gravitation'},        skill=324,
                JobRestrictions={'RNG','COR'}},
    [221] = {en='Last Stand¹',      skillchain={'Fusion','Reverberation'},        skill=357,
                JobRestrictions={'THF','RNG','COR'}},
    -- Prime WS (inferred ID)
    [256] = {en='Terminus²',        skillchain={'Detonation','Compression','Distortion'}, skill=424,
                JobRestrictions={'COR'}},
};

-----------------------------------------------------------------------
-- Avatar (SMN pet skills - level-based)
-----------------------------------------------------------------------
skills.avatar = {
    [301] = {en='Punch',            skillchain={'Impaction'},                     skill=1},
    [302] = {en='Rock Throw',       skillchain={'Scission'},                      skill=10},
    [303] = {en='Barracuda Dive',   skillchain={'Reverberation'},                 skill=10},
    [304] = {en='Claw',             skillchain={'Transfixion'},                   skill=10},
    [305] = {en='Axe Kick',         skillchain={'Liquefaction'},                  skill=10},
    [306] = {en='Shock Strike',     skillchain={'Impaction'},                     skill=10},
    [307] = {en='Aero II',          skillchain={'Detonation'},                    skill=10},
    [308] = {en='Tail Whip',        skillchain={'Compression'},                   skill=10},
    [309] = {en='Stone II',         skillchain={'Induration'},                    skill=1},
    [310] = {en='Double Punch',     skillchain={'Compression','Impaction'},       skill=21},
    [311] = {en='Rock Buster',      skillchain={'Reverberation','Scission'},      skill=26},
    [312] = {en='Tail Lash',        skillchain={'Reverberation'},                 skill=26},
    [313] = {en='Chaotic Strike',   skillchain={'Transfixion'},                   skill=26},
    [314] = {en='Double Slap',      skillchain={'Reverberation','Liquefaction'},  skill=26},
    [315] = {en='Thunderspark',     skillchain={'Detonation','Impaction'},        skill=26},
    [316] = {en='Aero IV',          skillchain={'Scission','Detonation'},         skill=26},
    [317] = {en='Whispering Wind',  skillchain={'Reverberation'},                 skill=26},
    [318] = {en='Geocrush',         skillchain={'Reverberation'},                 skill=70},
    [319] = {en='Grand Fall',       skillchain={'Distortion'},                    skill=70},
    [320] = {en='Predator Claws',   skillchain={'Fragmentation'},                 skill=70},
    [321] = {en='Flaming Crush',    skillchain={'Fusion'},                        skill=70},
    [322] = {en='Thunderstorm',     skillchain={'Fragmentation'},                 skill=70},
    [323] = {en='Nether Blast',     skillchain={'Compression'},                   skill=70},
    [324] = {en='Heavenly Strike',  skillchain={'Gravitation'},                   skill=70},
    [325] = {en='Wind Blade',       skillchain={'Distortion'},                    skill=70},
    [326] = {en='Meteor Strike',    skillchain={'Liquefaction','Fusion'},         skill=99},
    [327] = {en='Spinning Dive',    skillchain={'Reverberation','Distortion'},    skill=99},
    [328] = {en='Eclipse Bite',     skillchain={'Gravitation'},                   skill=99},
    [329] = {en='Conflag Strike',   skillchain={'Fusion'},                        skill=99},
    [330] = {en='Volt Strike',      skillchain={'Impaction','Fragmentation'},     skill=99},
    [331] = {en='Night Terror',     skillchain={'Darkness'},                      skill=99},
    [332] = {en='Holy Mist',        skillchain={'Light'},                         skill=99},
    [333] = {en='Cataclysmic Fury', skillchain={'Fragmentation','Detonation'},    skill=99},
};

-----------------------------------------------------------------------
-- Automaton (PUP pet skills - automaton skill-based)
-- Frame types: Harlequin (default), Valoredge (melee), Sharpshot (ranged)
-----------------------------------------------------------------------
skills.automaton = {
    -- Harlequin Frame
    [401] = {en='Slapstick',        skillchain={'Reverberation','Impaction'},     skill=0},
    [402] = {en='Knockout',         skillchain={'Scission','Detonation'},         skill=145},
    [403] = {en='Magic Mortar',     skillchain={'Fusion'},                        skill=225},
    -- Valoredge Frame
    [404] = {en='String Clipper',   skillchain={'Scission'},                      skill=0},
    [405] = {en='Chimera Ripper',   skillchain={'Detonation','Induration'},       skill=145},
    [406] = {en='Cannibal Blade',   skillchain={'Compression','Reverberation'},   skill=175},
    [407] = {en='Bone Crusher',     skillchain={'Fragmentation'},                 skill=245},
    -- Sharpshot Frame
    [408] = {en='Arcuballista',     skillchain={'Liquefaction','Transfixion'},    skill=0},
    [409] = {en='Daze',             skillchain={'Impaction','Transfixion'},       skill=145},
    [410] = {en='Armor Piercer',    skillchain={'Gravitation'},                   skill=175},
    [411] = {en='Armor Shatterer',  skillchain={'Fusion','Impaction'},            skill=205},
    [412] = {en='String Shredder',  skillchain={'Distortion','Scission'},         skill=245},
};

-----------------------------------------------------------------------
-- Blue Magic (BLU physical spells with skillchain properties)
-- skill = Blue Magic Skill required to learn
-----------------------------------------------------------------------
skills.blu = {
    -- Level 1-20 spells
    [501] = {en='Wild Oats',        skillchain={'Transfixion'},                   skill=0},
    [502] = {en='Battle Dance',     skillchain={'Impaction'},                     skill=8},
    [503] = {en='Head Butt',        skillchain={'Impaction'},                     skill=8},
    [504] = {en='Helldive',         skillchain={'Transfixion'},                   skill=20},
    [505] = {en='Bludgeon',         skillchain={'Liquefaction'},                  skill=26},
    [506] = {en='Claw Cyclone',     skillchain={'Scission'},                      skill=32},
    -- Level 21-50 spells
    [507] = {en='Screwdriver',      skillchain={'Transfixion','Scission'},        skill=50},
    [508] = {en='Smite of Rage',    skillchain={'Impaction'},                     skill=76},
    [509] = {en='Jet Stream',       skillchain={'Scission','Detonation'},         skill=92},
    -- Level 51-75 spells
    [510] = {en='Sickle Slash',     skillchain={'Compression'},                   skill=116},
    [511] = {en='Mandibular Bite',  skillchain={'Induration'},                    skill=128},
    [512] = {en='Death Scissors',   skillchain={'Scission'},                      skill=156},
    [513] = {en='Dimensional Death', skillchain={'Distortion'},                   skill=170},
    [514] = {en='Frenetic Rip',     skillchain={'Induration'},                    skill=186},
    [515] = {en='Spinal Cleave',    skillchain={'Scission','Detonation'},         skill=186},
    [516] = {en='Hysteric Barrage', skillchain={'Detonation'},                    skill=215},
    [517] = {en='Tail Slap',        skillchain={'Reverberation'},                 skill=215},
    [518] = {en='Cannonball',       skillchain={'Fusion'},                        skill=220},
    [519] = {en='Disseverment',     skillchain={'Distortion'},                    skill=230},
    [520] = {en='Ram Charge',       skillchain={'Fragmentation','Scission'},      skill=235},
    [521] = {en='Vertical Cleave',  skillchain={'Gravitation'},                   skill=245},
    -- Level 76-99 spells
    [522] = {en='Goblin Rush',      skillchain={'Fusion','Impaction'},            skill=276},
    [523] = {en='Vanity Dive',      skillchain={'Fragmentation'},                 skill=276},
    [524] = {en='Benthic Typhoon',  skillchain={'Gravitation','Transfixion'},     skill=288},
    [525] = {en='Quad. Continuum',  skillchain={'Distortion','Scission'},         skill=300},
    [526] = {en='Empty Thrash',     skillchain={'Compression','Scission'},        skill=312},
    [527] = {en='Delta Thrust',     skillchain={'Liquefaction','Detonation'},     skill=324},
    [528] = {en='Heavy Strike',     skillchain={'Fragmentation','Transfixion'},   skill=344},
    [529] = {en='Sudden Lunge',     skillchain={'Detonation'},                    skill=365},
    [530] = {en='Whirl of Rage',    skillchain={'Scission'},                      skill=379},
    [531] = {en='Amorphic Spikes',  skillchain={'Gravitation','Transfixion'},     skill=386},
    [532] = {en='Thrashing Assault', skillchain={'Fusion','Impaction'},           skill=393},
    [533] = {en='Sinker Drill',     skillchain={'Gravitation','Reverberation'},   skill=393},
    [534] = {en='Bloodrake',        skillchain={'Darkness','Distortion'},         skill=393},
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
