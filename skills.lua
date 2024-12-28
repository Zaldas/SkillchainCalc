-- Changes?
-- Dancing Edge > Double Punch = Gravitation
--[[
Copyright © 2017, Ivaar
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of SkillChains nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IVAAR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local skills = {};

skills.h2h = { --Hand-to-Hand
    [1] = {en='Combo',skillchain={'Impaction'}},
    [2] = {en='Shoulder Tackle',skillchain={'Reverberation','Impaction'}},
    [3] = {en='One Inch Punch',skillchain={'Compression'}},
    [4] = {en='Backhand Blow',skillchain={'Detonation'}},
    [5] = {en='Raging Fists',skillchain={'Impaction'}},
    [6] = {en='Spinning Attack',skillchain={'Liquefaction','Impaction'}},
    [7] = {en='Howling Fist',skillchain={'Transfixion','Impaction'}},
    [8] = {en='Dragon Kick',skillchain={'Fragmentation'}},
    [9] = {en='Asuran Fists',skillchain={'Gravitation','Liquefaction'}},
    [10] = {en='Final Heaven',skillchain={'Light','Fusion'}},
};
skills.dagger = { --Dagger
    [16] = {en='Wasp Sting',skillchain={'Scission'}},
    [17] = {en='Viper Bite',skillchain={'Scission'}},
    [18] = {en='Shadowstitch',skillchain={'Reverberation'}},    -- HorizonXI
    [19] = {en='Gust Slash',skillchain={'Detonation'}},
    [20] = {en='Cyclone',skillchain={'Detonation','Impaction'}},
    [23] = {en='Dancing Edge',skillchain={'Scission','Detonation'}},
    [24] = {en='Shark Bite',skillchain={'Fragmentation'}},
    [25] = {en='Evisceration',skillchain={'Gravitation','Transfixion'}},
    [26] = {en='Mercy Stroke',skillchain={'Darkness','Gravitation'}},
};
skills.sword = { --Sword
    [32] = {en='Fast Blade',skillchain={'Scission'}},
    [33] = {en='Burning Blade',skillchain={'Liquefaction'}},
    [34] = {en='Red Lotus Blade',skillchain={'Liquefaction','Detonation'}},
    [35] = {en='Flat Blade',skillchain={'Impaction'}},
    [36] = {en='Shining Blade',skillchain={'Scission'}},
    [37] = {en='Seraph Blade',skillchain={'Scission','Transfixion'}},
    [38] = {en='Circle Blade',skillchain={'Reverberation','Impaction'}},
    [40] = {en='Vorpal Blade',skillchain={'Scission','Impaction'}},
    [41] = {en='Swift Blade',skillchain={'Gravitation'}},
    [42] = {en='Savage Blade',skillchain={'Fragmentation','Scission'}},
    [43] = {en='Knights of Round',skillchain={'Light','Fusion'}},
};
skills.gs = { --Great Sword
    [48] = {en='Hard Slash',skillchain={'Scission'}},
    [49] = {en='Power Slash',skillchain={'Transfixion'}},
    [50] = {en='Frostbite',skillchain={'Induration'}},
    [51] = {en='Freezebite',skillchain={'Induration','Detonation'}},
    [52] = {en='Shockwave',skillchain={'Reverberation'}},
    [53] = {en='Crescent Moon',skillchain={'Scission'}},
    [54] = {en='Sickle Moon',skillchain={'Scission','Impaction'}},
    [55] = {en='Spinning Slash',skillchain={'Fragmentation'}},
    [56] = {en='Ground Strike',skillchain={'Fragmentation','Distortion'}},
    [57] = {en='Scourge',skillchain={'Light','Fusion'}},
};
skills.axe = { --Axe
    [64] = {en='Raging Axe',skillchain={'Detonation','Impaction'}},
    [65] = {en='Smash Axe',skillchain={'Induration','Reverberation'}},
    [66] = {en='Gale Axe',skillchain={'Detonation'}},
    [67] = {en='Avalanche Axe',skillchain={'Induration'}},  -- HorizonXI
    [68] = {en='Spinning Axe',skillchain={'Liquefaction','Scission'}},  -- HorizonXI
    [69] = {en='Rampage',skillchain={'Scission'}},
    [70] = {en='Calamity',skillchain={'Scission','Impaction'}},
    [71] = {en='Mistral Axe',skillchain={'Fusion'}},
    [72] = {en='Decimation',skillchain={'Fusion','Detonation'}},
    [73] = {en='Onslaught',skillchain={'Darkness','Gravitation'}},
};
skills.ga = { --Great Axe
    [80] = {en='Shield Break',skillchain={'Impaction'}},
    [81] = {en='Iron Tempest',skillchain={'Scission'}},
    [82] = {en='Sturmwind',skillchain={'Reverberation','Scission'}},
    [83] = {en='Armor Break',skillchain={'Impaction'}},
    [84] = {en='Keen Edge',skillchain={'Compression'}},
    [85] = {en='Weapon Break',skillchain={'Impaction'}},
    [86] = {en='Raging Rush',skillchain={'Induration','Reverberation'}},
    [87] = {en='Full Break',skillchain={'Distortion'}},
    [88] = {en='Steel Cyclone',skillchain={'Distortion','Detonation'}},
    [89] = {en='Metatron Torment',skillchain={'Light','Fusion'}},
};
skills.scythe = { --Scythe
    [96] = {en='Slice',skillchain={'Scission'}},
    [97] = {en='Dark Harvest',skillchain={'Compression'}},  -- HorizonXI
    [98] = {en='Shadow of Death',skillchain={'Induration','Reverberation'}}, 
    [99] = {en='Nightmare Scythe',skillchain={'Compression','Scission'}},
    [100] = {en='Spinning Scythe',skillchain={'Reverberation','Scission'}},
    [101] = {en='Vorpal Scythe',skillchain={'Transfixion','Scission'}},
    [102] = {en='Guillotine',skillchain={'Induration'}},
    [103] = {en='Cross Reaper',skillchain={'Distortion'}},
    [104] = {en='Spiral Hell',skillchain={'Gravitation','Compression'}}, -- HorizonXI
    [105] = {en='Catastrophe',skillchain={'Fusion','Compression'}},
};
skills.polearm = { --Polearm
    [112] = {en='Double Thrust',skillchain={'Transfixion'}},
    [113] = {en='Thunder Thrust',skillchain={'Transfixion','Impaction'}},
    [114] = {en='Raiden Thrust',skillchain={'Transfixion','Impaction'}},
    [115] = {en='Leg Sweep',skillchain={'Impaction'}},
    [116] = {en='Penta Thrust',skillchain={'Compression'}},
    [117] = {en='Vorpal Thrust',skillchain={'Reverberation','Transfixion'}},
    [118] = {en='Skewer',skillchain={'Transfixion','Impaction'}},
    [119] = {en='Wheeling Thrust',skillchain={'Fusion'}},
    [120] = {en='Impulse Drive',skillchain={'Gravitation','Induration'}},
    [121] = {en='Geirskogul',skillchain={'Light','Distortion'}},
};
skills.katana = { --Katana
    [128] = {en='Blade: Rin',skillchain={'Transfixion'}},
    [129] = {en='Blade: Retsu',skillchain={'Scission'}},
    [130] = {en='Blade: Teki',skillchain={'Reverberation'}},
    [131] = {en='Blade: To',skillchain={'Induration','Detonation'}},
    [132] = {en='Blade: Chi',skillchain={'Transfixion','Impaction'}},
    [133] = {en='Blade: Ei',skillchain={'Compression'}},
    [134] = {en='Blade: Jin',skillchain={'Detonation','Impaction'}},
    [135] = {en='Blade: Ten',skillchain={'Gravitation'}},
    [136] = {en='Blade: Ku',skillchain={'Gravitation','Transfixion'}},
    [137] = {en='Blade: Metsu',skillchain={'Darkness','Fragmentation'}},
};
skills.gkt = { --Great Katana
    [144] = {en='Tachi: Enpi',skillchain={'Transfixion','Scission'}},
    [145] = {en='Tachi: Hobaku',skillchain={'Induration'}},
    [146] = {en='Tachi: Goten',skillchain={'Transfixion','Impaction'}},
    [147] = {en='Tachi: Kagero',skillchain={'Liquefaction'}},
    [148] = {en='Tachi: Jinpu',skillchain={'Scission','Detonation'}},
    [149] = {en='Tachi: Koki',skillchain={'Reverberation','Impaction'}},
    [150] = {en='Tachi: Yukikaze',skillchain={'Induration','Detonation'}},
    [151] = {en='Tachi: Gekko',skillchain={'Distortion','Reverberation'}},
    [152] = {en='Tachi: Kasha',skillchain={'Fusion','Compression'}},
    [153] = {en='Tachi: Kaiten',skillchain={'Light','Fragmentation'}},
};
skills.club = { --Club
    [160] = {en='Shining Strike',skillchain={'Transfixion'}},
    [161] = {en='Seraph Strike',skillchain={'Scission'}},
    [162] = {en='Brainshaker',skillchain={'Reverberation'}},
    [165] = {en='Skullbreaker',skillchain={'Induration','Reverberation'}},
    [166] = {en='True Strike',skillchain={'Detonation','Impaction'}},
    [167] = {en='Judgment',skillchain={'Impaction'}},
    [168] = {en='Hexa Strike',skillchain={'Fusion'}},
    [169] = {en='Black Halo',skillchain={'Fragmentation','Compression'}},
    [170] = {en='Randgrith',skillchain={'Light','Fragmentation'}},
};
skills.staff = { --Staff
    [176] = {en='Heavy Swing',skillchain={'Impaction'}},
    [177] = {en='Rock Crusher',skillchain={'Impaction'}},
    [178] = {en='Earth Crusher',skillchain={'Detonation','Impaction'}},
    [179] = {en='Starburst',skillchain={'Compression','Transfixion'}},
    [180] = {en='Sunburst',skillchain={'Transfixion','Reverberation'}},
    [181] = {en='Shell Crusher',skillchain={'Detonation'}},
    [182] = {en='Full Swing',skillchain={'Liquefaction','Impaction'}},
    [184] = {en='Retribution',skillchain={'Gravitation','Reverberation'}},
    [185] = {en='Gate of Tartarus',skillchain={'Darkness','Distortion'}},
};
skills.archery = { --Archery
    [192] = {en='Flaming Arrow',skillchain={'Liquefaction','Transfixion'}},
    [193] = {en='Piercing Arrow',skillchain={'Induration','Transfixion'}},  -- HorizonXI
    [194] = {en='Dulling Arrow',skillchain={'Liquefaction','Transfixion'}},
    [196] = {en='Sidewinder',skillchain={'Reverberation','Transfixion','Detonation'}},
    [197] = {en='Blast Arrow',skillchain={'Induration','Transfixion'}},
    [198] = {en='Arching Arrow',skillchain={'Fusion'}},
    [199] = {en='Empyreal Arrow',skillchain={'Fusion','Transfixion'}},
    [200] = {en='Namas Arrow',skillchain={'Light','Distortion'}},
};
skills.mm = { --Marksmanship
    [208] = {en='Hot Shot',skillchain={'Liquefaction','Transfixion'}},
    [209] = {en='Split Shot',skillchain={'Reverberation','Transfixion'}},
    [210] = {en='Sniper Shot',skillchain={'Liquefaction','Transfixion'}},
    [212] = {en='Slug Shot',skillchain={'Reverberation','Transfixion','Detonation'}},
    [213] = {en='Blast Shot',skillchain={'Induration','Transfixion'}},
    [214] = {en='Heavy Shot',skillchain={'Fusion'}},
    [215] = {en='Detonator',skillchain={'Fusion','Transfixion'}},
    [216] = {en='Coronach',skillchain={'Darkness','Fragmentation'}},
};

-- Pet skills as triggered by player.
-- Separated from skills as triggered by pet to ease support for private servers
skills.smn = { -- BST/SMN Player Pet Skills
    [513] = {en='Poison Nails',skillchain={'Transfixion'}},
    [528] = {en='Moonlit Charge',skillchain={'Compression'}},
    [529] = {en='Crescent Fang',skillchain={'Transfixion'}},
    [544] = {en='Punch',skillchain={'Liquefaction'}},
    [546] = {en='Burning Strike',skillchain={'Impaction'}},
    [547] = {en='Double Punch',skillchain={'Compression'}},
    [560] = {en='Rock Throw',skillchain={'Scission'}},
    [562] = {en='Rock Buster',skillchain={'Reverberation'}},
    [563] = {en='Megalith Throw',skillchain={'Induration'}},
    [576] = {en='Barracuda Dive',skillchain={'Reverberation'}},
    [578] = {en='Tail Whip',skillchain={'Detonation'}},
    [592] = {en='Claw',skillchain={'Detonation'}},
    [608] = {en='Axe Kick',skillchain={'Induration'}},
    [612] = {en='Double Slap',skillchain={'Scission'}},
    [624] = {en='Shock Strike',skillchain={'Impaction'}},
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
colors.Dark =          0x0000CCFF;
colors.Ice =           0x00FFFFFF;
colors.Water =         0x00FFFFFF;
colors.Earth =         0x997600FF;
colors.Wind =          0x66FF66FF;
colors.Fire =          0xFF0000FF;
colors.Lightning =     0xFF00FFFF;
colors.Gravitation =   0x663300FF;
colors.Fragmentation = 0xFA9CF7FF;
colors.Fusion =        0xFF6666FF;
colors.Distortion =    0x3399FFFF;
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


skills.StatusID = {
    AL  = 163, -- Azure Lore
    CA  = 164, -- Chain Affinity
    AM1 = 270, -- Aftermath: Lv.1
    AM2 = 271, -- Aftermath: Lv.2
    AM3 = 272, -- Aftermath: Lv.3
    IM  = 470  -- Immanence
};

skills.SkillPropNames = T{
    [1] = 'Light',
    [2] = 'Darkness',
    [3] = 'Gravitation',
    [4] = 'Fragmentation',
    [5] = 'Distortion',
    [6] = 'Fusion',
    [7] = 'Compression',
    [8] = 'Liquefaction',
    [9] = 'Induration',
    [10] = 'Reverberation',
    [11] = 'Transfixion',
    [12] = 'Scission',
    [13] = 'Detonation',
    [14] = 'Impaction',
    [15] = 'Radiance',
    [16] = 'Umbra'
};


return skills
