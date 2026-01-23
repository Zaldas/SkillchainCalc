--[[
    Autotranslate.lua - Auto-translate phrase mappings for SkillchainCalc

    Contains byte codes for FFXI auto-translate phrases for:
    - Skillchain properties (Liquefaction, Distortion, Light, etc.)
    - Weaponskills (all weapon types)
    - SMN Blood Pacts

    Auto-translate format:
    - Phrase bytes: \xFD\x02\x02\xXX\xYY\xFD (category/index encoding)
    - Display brackets: \xEF\x27 (open) and \xEF\x28 (close)
]]

local Autotranslate = {};

-- Skillchain property auto-translate codes
Autotranslate.Skillchains = {
    -- Level 1 properties
    ['Liquefaction']   = '\xFD\x02\x02\x1E\xC3\xFD',
    ['Impaction']      = '\xFD\x02\x02\x1E\xC9\xFD',
    ['Detonation']     = '\xFD\x02\x02\x1E\xC8\xFD',
    ['Scission']       = '\xFD\x02\x02\x1E\xC7\xFD',
    ['Reverberation']  = '\xFD\x02\x02\x1E\xC5\xFD',
    ['Induration']     = '\xFD\x02\x02\x1E\xC4\xFD',
    ['Transfixion']    = '\xFD\x02\x02\x1E\xC6\xFD',
    ['Compression']    = '\xFD\x02\x02\x1E\xC2\xFD',
    -- Level 2 properties
    ['Fusion']         = '\xFD\x02\x02\x1E\xC1\xFD',
    ['Fragmentation']  = '\xFD\x02\x02\x1E\xBF\xFD',
    ['Gravitation']    = '\xFD\x02\x02\x1E\xBE\xFD',
    ['Distortion']     = '\xFD\x02\x02\x1E\xC0\xFD',
    -- Level 3 properties
    ['Light']          = '\xFD\x02\x02\x1E\x4B\xFD',
    ['Darkness']       = '\xFD\x02\x02\x1E\xCA\xFD',
};

-- Weaponskill auto-translate codes (keyed by display name)
Autotranslate.Weaponskills = {
    -- Hand-to-Hand
    ['Combo']              = '\xFD\x02\x02\x21\x25\xFD',
    ['Shoulder Tackle']    = '\xFD\x02\x02\x21\x02\xFD',
    ['One Inch Punch']     = '\xFD\x02\x02\x21\x16\xFD',
    ['Backhand Blow']      = '\xFD\x02\x02\x21\x05\xFD',
    ['Raging Fists']       = '\xFD\x02\x02\x21\x14\xFD',
    ['Spinning Attack']    = '\xFD\x02\x02\x21\x15\xFD',
    ['Howling Fist']       = '\xFD\x02\x02\x21\x3B\xFD',
    ['Dragon Kick']        = '\xFD\x02\x02\x21\x68\xFD',
    ['Asuran Fists']       = '\xFD\x02\x02\x21\x75\xFD',
    ['Final Heaven']       = '\xFD\x02\x02\x21\xCB\xFD',
    ['Ascetic\'s Fury']    = '\xFD\x02\x02\x21\x84\xFD',
    ['Stringing Pummel']   = '\xFD\x02\x02\x21\x95\xFD',
    ['Tornado Kick']       = '\xFD\x02\x02\x21\xA7\xFD',
    ['Shijin Spiral']      = '\xFD\x02\x02\x21\x99\xFD',
    ['Victory Smite']      = '\xFD\x02\x02\x21\xB7\xFD',

    -- Dagger
    ['Wasp Sting']         = '\xFD\x02\x02\x21\x13\xFD',
    ['Gust Slash']         = '\xFD\x02\x02\x21\x24\xFD',
    ['Shadowstitch']       = '\xFD\x02\x02\x21\x2B\xFD',
    ['Viper Bite']         = '\xFD\x02\x02\x21\x27\xFD',
    ['Cyclone']            = '\xFD\x02\x02\x21\x17\xFD',
    ['Energy Steal']       = '\xFD\x02\x02\x21\x29\xFD',
    ['Energy Drain']       = '\xFD\x02\x02\x21\x19\xFD',
    ['Dancing Edge']       = '\xFD\x02\x02\x21\x1A\xFD',
    ['Shark Bite']         = '\xFD\x02\x02\x21\x71\xFD',
    ['Evisceration']       = '\xFD\x02\x02\x21\x76\xFD',
    ['Mercy Stroke']       = '\xFD\x02\x02\x21\xCD\xFD',
    ['Mandalic Stab']      = '\xFD\x02\x02\x21\x89\xFD',
    ['Mordant Rime']       = '\xFD\x02\x02\x21\x8D\xFD',
    ['Pyrrhic Kleos']      = '\xFD\x02\x02\x21\x96\xFD',
    ['Aeolian Edge']       = '\xFD\x02\x02\x21\xA8\xFD',
    ['Exenterator']        = '\xFD\x02\x02\x21\x9A\xFD',
    ['Rudra\'s Storm']     = '\xFD\x02\x02\x21\xB8\xFD',

    -- Sword
    ['Fast Blade']         = '\xFD\x02\x02\x21\x07\xFD',
    ['Burning Blade']      = '\xFD\x02\x02\x21\x0F\xFD',
    ['Red Lotus Blade']    = '\xFD\x02\x02\x21\x03\xFD',
    ['Flat Blade']         = '\xFD\x02\x02\x21\x08\xFD',
    ['Shining Blade']      = '\xFD\x02\x02\x21\x1E\xFD',
    ['Seraph Blade']       = '\xFD\x02\x02\x21\x1B\xFD',
    ['Circle Blade']       = '\xFD\x02\x02\x21\x1C\xFD',
    ['Spirits Within']     = '\xFD\x02\x02\x21\x04\xFD',
    ['Vorpal Blade']       = '\xFD\x02\x02\x21\x39\xFD',
    ['Swift Blade']        = '\xFD\x02\x02\x21\x6E\xFD',
    ['Savage Blade']       = '\xFD\x02\x02\x21\x74\xFD',
    ['Knights of Round']   = '\xFD\x02\x02\x21\xCE\xFD',
    ['Sanguine Blade']     = '\xFD\x02\x02\x21\xA9\xFD',
    ['Chant du Cygne']     = '\xFD\x02\x02\x21\xB9\xFD',
    ['Death Blossom']      = '\xFD\x02\x02\x21\x88\xFD',
    ['Expiacion']          = '\xFD\x02\x02\x21\x93\xFD',
    ['Requiescat']         = '\xFD\x02\x02\x21\x9B\xFD',

    -- Great Sword
    ['Hard Slash']         = '\xFD\x02\x02\x21\x11\xFD',
    ['Power Slash']        = '\xFD\x02\x02\x21\x06\xFD',
    ['Frostbite']          = '\xFD\x02\x02\x21\x0B\xFD',
    ['Freezebite']         = '\xFD\x02\x02\x21\x09\xFD',
    ['Shockwave']          = '\xFD\x02\x02\x21\x4F\xFD',
    ['Crescent Moon']      = '\xFD\x02\x02\x21\x50\xFD',
    ['Sickle Moon']        = '\xFD\x02\x02\x21\x51\xFD',
    ['Spinning Slash']     = '\xFD\x02\x02\x21\x72\xFD',
    ['Ground Strike']      = '\xFD\x02\x02\x21\x7C\xFD',
    ['Herculean Slash']    = '\xFD\x02\x02\x21\xAA\xFD',
    ['Resolution']         = '\xFD\x02\x02\x21\x9C\xFD',
    ['Torcleaver']         = '\xFD\x02\x02\x21\xBA\xFD',
    ['Scourge']            = '\xFD\x02\x02\x21\xCF\xFD',

    -- Axe
    ['Raging Axe']         = '\xFD\x02\x02\x21\x10\xFD',
    ['Smash Axe']          = '\xFD\x02\x02\x21\x30\xFD',
    ['Gale Axe']           = '\xFD\x02\x02\x21\x1D\xFD',
    ['Avalanche Axe']      = '\xFD\x02\x02\x21\x23\xFD',
    ['Spinning Axe']       = '\xFD\x02\x02\x21\x52\xFD',
    ['Rampage']            = '\xFD\x02\x02\x21\x53\xFD',
    ['Calamity']           = '\xFD\x02\x02\x21\x61\xFD',
    ['Mistral Axe']        = '\xFD\x02\x02\x21\x73\xFD',
    ['Decimation']         = '\xFD\x02\x02\x21\x78\xFD',
    ['Onslaught']          = '\xFD\x02\x02\x21\xD0\xFD',
    ['Primal Rend']        = '\xFD\x02\x02\x21\x8C\xFD',
    ['Bora Axe']           = '\xFD\x02\x02\x21\xAB\xFD',
    ['Cloudsplitter']      = '\xFD\x02\x02\x21\xBB\xFD',

    -- Great Axe
    ['Shield Break']       = '\xFD\x02\x02\x21\x36\xFD',
    ['Iron Tempest']       = '\xFD\x02\x02\x21\x21\xFD',
    ['Sturmwind']          = '\xFD\x02\x02\x21\x2C\xFD',
    ['Armor Break']        = '\xFD\x02\x02\x21\x20\xFD',
    ['Keen Edge']          = '\xFD\x02\x02\x21\x55\xFD',
    ['Weapon Break']       = '\xFD\x02\x02\x21\x4E\xFD',
    ['Raging Rush']        = '\xFD\x02\x02\x21\x56\xFD',
    ['Full Break']         = '\xFD\x02\x02\x21\x69\xFD',
    ['Steel Cyclone']      = '\xFD\x02\x02\x21\x7B\xFD',
    ['Fell Cleave']        = '\xFD\x02\x02\x21\xAC\xFD',
    ['Ukko\'s Fury']       = '\xFD\x02\x02\x21\xBC\xFD',
    ['Upheaval']           = '\xFD\x02\x02\x21\x9E\xFD',
    ['Metatron Torment']   = '\xFD\x02\x02\x21\xD1\xFD',

    -- Scythe
    ['Slice']              = '\xFD\x02\x02\x21\x31\xFD',
    ['Dark Harvest']       = '\xFD\x02\x02\x21\x33\xFD',
    ['Shadow of Death']    = '\xFD\x02\x02\x21\x2A\xFD',
    ['Nightmare Scythe']   = '\xFD\x02\x02\x21\x35\xFD',
    ['Spinning Scythe']    = '\xFD\x02\x02\x21\x57\xFD',
    ['Vorpal Scythe']      = '\xFD\x02\x02\x21\x58\xFD',
    ['Guillotine']         = '\xFD\x02\x02\x21\x59\xFD',
    ['Cross Reaper']       = '\xFD\x02\x02\x21\x64\xFD',
    ['Spiral Hell']        = '\xFD\x02\x02\x21\x79\xFD',
    ['Infernal Scythe']    = '\xFD\x02\x02\x21\xAE\xFD',
    ['Catastrophe']        = '\xFD\x02\x02\x21\xD2\xFD',
    ['Insurgency']         = '\xFD\x02\x02\x21\x8B\xFD',
    ['Quietus']            = '\xFD\x02\x02\x21\xBD\xFD',
    ['Entropy']            = '\xFD\x02\x02\x21\x9F\xFD',

    -- Polearm
    ['Double Thrust']      = '\xFD\x02\x02\x21\x34\xFD',
    ['Thunder Thrust']     = '\xFD\x02\x02\x21\x26\xFD',
    ['Raiden Thrust']      = '\xFD\x02\x02\x21\x0E\xFD',
    ['Leg Sweep']          = '\xFD\x02\x02\x21\x22\xFD',
    ['Penta Thrust']       = '\xFD\x02\x02\x21\x5A\xFD',
    ['Vorpal Thrust']      = '\xFD\x02\x02\x21\x5B\xFD',
    ['Skewer']             = '\xFD\x02\x02\x21\x62\xFD',
    ['Wheeling Thrust']    = '\xFD\x02\x02\x21\x70\xFD',
    ['Impulse Drive']      = '\xFD\x02\x02\x21\x7D\xFD',
    ['Sonic Thrust']       = '\xFD\x02\x02\x21\xAF\xFD',
    ['Stardiver']          = '\xFD\x02\x02\x21\xA0\xFD',
    ['Camlann\'s Torment'] = '\xFD\x02\x02\x21\xBE\xFD',
    ['Drakesbane']         = '\xFD\x02\x02\x21\x91\xFD',
    ['Geirskogul']         = '\xFD\x02\x02\x21\xD3\xFD',

    -- Katana
    ['Blade: Rin']         = '\xFD\x02\x02\x21\x5C\xFD',
    ['Blade: Retsu']       = '\xFD\x02\x02\x21\x5D\xFD',
    ['Blade: Teki']        = '\xFD\x02\x02\x21\x5E\xFD',
    ['Blade: To']          = '\xFD\x02\x02\x21\x5F\xFD',
    ['Blade: Chi']         = '\xFD\x02\x02\x21\x60\xFD',
    ['Blade: Ei']          = '\xFD\x02\x02\x21\x41\xFD',
    ['Blade: Jin']         = '\xFD\x02\x02\x21\x38\xFD',
    ['Blade: Ten']         = '\xFD\x02\x02\x21\x65\xFD',
    ['Blade: Ku']          = '\xFD\x02\x02\x21\x80\xFD',
    ['Blade: Metsu']       = '\xFD\x02\x02\x21\xD4\xFD',
    ['Blade: Kamu']        = '\xFD\x02\x02\x21\x90\xFD',
    ['Blade: Yu']          = '\xFD\x02\x02\x21\xB3\xFD',
    ['Blade: Hi']          = '\xFD\x02\x02\x21\xBF\xFD',
    ['Blade: Shun']        = '\xFD\x02\x02\x21\xA1\xFD',

    -- Great Katana
    ['Tachi: Enpi']        = '\xFD\x02\x02\x21\x43\xFD',
    ['Tachi: Hobaku']      = '\xFD\x02\x02\x21\x3A\xFD',
    ['Tachi: Goten']       = '\xFD\x02\x02\x21\x54\xFD',
    ['Tachi: Kagero']      = '\xFD\x02\x02\x21\x3C\xFD',
    ['Tachi: Jinpu']       = '\xFD\x02\x02\x21\x3D\xFD',
    ['Tachi: Koki']        = '\xFD\x02\x02\x21\x3E\xFD',
    ['Tachi: Yukikaze']    = '\xFD\x02\x02\x21\x3F\xFD',
    ['Tachi: Gekko']       = '\xFD\x02\x02\x21\x6F\xFD',
    ['Tachi: Kasha']       = '\xFD\x02\x02\x21\x81\xFD',
    ['Tachi: Kaiten']      = '\xFD\x02\x02\x21\xD5\xFD',
    ['Tachi: Ageha']       = '\xFD\x02\x02\x21\xB4\xFD',
    ['Tachi: Rana']        = '\xFD\x02\x02\x21\x8F\xFD',
    ['Tachi: Shoha']       = '\xFD\x02\x02\x21\xA2\xFD',
    ['Tachi: Fudo']        = '\xFD\x02\x02\x21\xC0\xFD',
    ['Tachi: Mumei']       = '\xFD\x02\x02\x21\xE1\xFD',

    -- Club
    ['Shining Strike']     = '\xFD\x02\x02\x21\x28\xFD',
    ['Seraph Strike']      = '\xFD\x02\x02\x21\x32\xFD',
    ['Brainshaker']        = '\xFD\x02\x02\x21\x0A\xFD',
    ['Skullbreaker']       = '\xFD\x02\x02\x21\x4D\xFD',
    ['True Strike']        = '\xFD\x02\x02\x21\x42\xFD',
    ['Judgment']           = '\xFD\x02\x02\x21\x37\xFD',
    ['Hexa Strike']        = '\xFD\x02\x02\x21\x6C\xFD',
    ['Black Halo']         = '\xFD\x02\x02\x21\x7A\xFD',
    ['Randgrith']          = '\xFD\x02\x02\x21\xD6\xFD',
    ['Flash Nova']         = '\xFD\x02\x02\x21\xB0\xFD',
    ['Realmrazer']         = '\xFD\x02\x02\x21\xA3\xFD',
    ['Mystic Boon']        = '\xFD\x02\x02\x21\x85\xFD',
    ['Dagan']              = '\xFD\x02\x02\x21\xC1\xFD',
    ['Exudation']          = '\xFD\x02\x02\x21\xC6\xFD',

    -- Staff
    ['Heavy Swing']        = '\xFD\x02\x02\x21\x0C\xFD',
    ['Rock Crusher']       = '\xFD\x02\x02\x21\x12\xFD',
    ['Earth Crusher']      = '\xFD\x02\x02\x21\x1F\xFD',
    ['Starburst']          = '\xFD\x02\x02\x21\x2E\xFD',
    ['Sunburst']           = '\xFD\x02\x02\x21\x44\xFD',
    ['Shell Crusher']      = '\xFD\x02\x02\x21\x45\xFD',
    ['Full Swing']         = '\xFD\x02\x02\x21\x46\xFD',
    ['Spirit Taker']       = '\xFD\x02\x02\x21\x6D\xFD',
    ['Retribution']        = '\xFD\x02\x02\x21\x7F\xFD',
    ['Gate of Tartarus']   = '\xFD\x02\x02\x21\xD7\xFD',
    ['Vidohunir']          = '\xFD\x02\x02\x21\x86\xFD',
    ['Garland of Bliss']   = '\xFD\x02\x02\x21\x92\xFD',
    ['Omniscience']        = '\xFD\x02\x02\x21\x97\xFD',
    ['Myrkr']              = '\xFD\x02\x02\x21\xC2\xFD',
    ['Cataclysm']          = '\xFD\x02\x02\x21\xB2\xFD',
    ['Shattersoul']        = '\xFD\x02\x02\x21\xA4\xFD',

    -- Archery
    ['Flaming Arrow']      = '\xFD\x02\x02\x21\x47\xFD',
    ['Piercing Arrow']     = '\xFD\x02\x02\x21\x48\xFD',
    ['Dulling Arrow']      = '\xFD\x02\x02\x21\x49\xFD',
    ['Sidewinder']         = '\xFD\x02\x02\x21\x4A\xFD',
    ['Blast Arrow']        = '\xFD\x02\x02\x21\x66\xFD',
    ['Arching Arrow']      = '\xFD\x02\x02\x21\x63\xFD',
    ['Empyreal Arrow']     = '\xFD\x02\x02\x21\x82\xFD',
    ['Refulgent Arrow']    = '\xFD\x02\x02\x21\xB5\xFD',
    ['Apex Arrow']         = '\xFD\x02\x02\x21\xA5\xFD',
    ['Jishnu\'s Radiance'] = '\xFD\x02\x02\x21\xC3\xFD',
    ['Namas Arrow']        = '\xFD\x02\x02\x21\xD8\xFD',

    -- Marksmanship
    ['Hot Shot']           = '\xFD\x02\x02\x21\x4B\xFD',
    ['Split Shot']         = '\xFD\x02\x02\x21\x4C\xFD',
    ['Sniper Shot']        = '\xFD\x02\x02\x21\x18\xFD',
    ['Slug Shot']          = '\xFD\x02\x02\x21\x01\xFD',
    ['Blast Shot']         = '\xFD\x02\x02\x21\x67\xFD',
    ['Heavy Shot']         = '\xFD\x02\x02\x21\x6A\xFD',
    ['Detonator']          = '\xFD\x02\x02\x21\x98\xFD',
    ['Numbing Shot']       = '\xFD\x02\x02\x21\xB6\xFD',
    ['Last Stand']         = '\xFD\x02\x02\x21\xA6\xFD',
    ['Leaden Salute']      = '\xFD\x02\x02\x21\x94\xFD',
    ['Wildfire']           = '\xFD\x02\x02\x21\xC4\xFD',
    ['Trueflight']         = '\xFD\x02\x02\x21\x8E\xFD',
    ['Coronach']           = '\xFD\x02\x02\x21\xD9\xFD',

    -- SMN Blood Pacts (Physical)
    ['Poison Nails']       = '\xFD\x02\x02\x24\x1D\xFD',
    ['Moonlit Charge']     = '\xFD\x02\x02\x24\x35\xFD',
    ['Crescent Fang']      = '\xFD\x02\x02\x24\x36\xFD',
    ['Punch']              = '\xFD\x02\x02\x24\x1F\xFD',
    ['Burning Strike']     = '\xFD\x02\x02\x24\x0D\xFD',
    ['Double Punch']       = '\xFD\x02\x02\x24\x10\xFD',
    ['Rock Throw']         = '\xFD\x02\x02\x24\x21\xFD',
    ['Rock Buster']        = '\xFD\x02\x02\x24\x20\xFD',
    ['Megalith Throw']     = '\xFD\x02\x02\x24\x1A\xFD',
    ['Barracuda Dive']     = '\xFD\x02\x02\x24\x0C\xFD',
    ['Tail Whip']          = '\xFD\x02\x02\x24\x2A\xFD',
    ['Claw']               = '\xFD\x02\x02\x24\x0F\xFD',
    ['Axe Kick']           = '\xFD\x02\x02\x24\x0B\xFD',
    ['Double Slap']        = '\xFD\x02\x02\x24\x12\xFD',
    ['Shock Strike']       = '\xFD\x02\x02\x24\x25\xFD',
    ['Rush']               = '\xFD\x02\x02\x24\x23\xFD',
    ['Meteor Strike']      = '\xFD\x02\x02\x24\x50\xFD',
    ['Geocrush']           = '\xFD\x02\x02\x24\x51\xFD',
    ['Wind Blade']         = '\xFD\x02\x02\x24\x53\xFD',
    ['Grand Fall']         = '\xFD\x02\x02\x24\x52\xFD',
    ['Heavenly Strike']    = '\xFD\x02\x02\x24\x54\xFD',
    ['Thunderspark']       = '\xFD\x02\x02\x24\x2B\xFD',
    ['Nether Blast']       = '\xFD\x02\x02\x24\x43\xFD',
    ['Flaming Crush']      = '\xFD\x02\x02\x24\x14\xFD',
    ['Mountain Buster']    = '\xFD\x02\x02\x24\x1C\xFD',

    -----------------------------------------------------------------------
    -- TOAU – Blue Magic physical spells
    -----------------------------------------------------------------------
    ['Foot Kick']          = '\xFD\x02\x02\x26\x35\xFD',
    ['Sprout Smack']       = '\xFD\x02\x02\x26\x43\xFD',
    ['Wild Oats']          = '\xFD\x02\x02\x26\x46\xFD',
    ['Power Attack']       = '\xFD\x02\x02\x26\x22\xFD',
    ['Queasyshroom']       = '\xFD\x02\x02\x26\x45\xFD',
    ['Battle Dance']       = '\xFD\x02\x02\x26\x57\xFD',
    ['Feather Storm']      = '\xFD\x02\x02\x26\x65\xFD',
    ['Head Butt']          = '\xFD\x02\x02\x26\x5A\xFD',
    ['Helldive']           = '\xFD\x02\x02\x26\x2D\xFD',
    ['Bludgeon']           = '\xFD\x02\x02\x26\x0B\xFD',
    ['Claw Cyclone']       = '\xFD\x02\x02\x26\x3B\xFD',
    ['Screwdriver']        = '\xFD\x02\x02\x26\x04\xFD',
    ['Grand Slam']         = '\xFD\x02\x02\x26\x59\xFD',
    ['Smite of Rage']      = '\xFD\x02\x02\x26\x0A\xFD',
    ['Pinecone Bomb']      = '\xFD\x02\x02\x26\x42\xFD',
    ['Jet Stream']         = '\xFD\x02\x02\x26\x2E\xFD',
    ['Uppercut']           = '\xFD\x02\x02\x26\x40\xFD',
    ['Terror Touch']       = '\xFD\x02\x02\x26\x16\xFD',
    ['Mandibular Bite']    = '\xFD\x02\x02\x26\x1A\xFD',
    ['Sickle Slash']       = '\xFD\x02\x02\x26\x1D\xFD',
    ['Dimensional Death']  = '\xFD\x02\x02\x26\x3D\xFD',
    ['Spiral Spin']        = '\xFD\x02\x02\x26\x74\xFD',
    ['Death Scissors']     = '\xFD\x02\x02\x26\x23\xFD',
    ['Seedspray']          = '\xFD\x02\x02\x26\x72\xFD',
    ['Body Slam']          = '\xFD\x02\x02\x26\x2A\xFD',
    ['Hydro Shot']         = '\xFD\x02\x02\x26\x5F\xFD',
    ['Frypan']             = '\xFD\x02\x02\x26\x5C\xFD',
    ['Frenetic Rip']       = '\xFD\x02\x02\x26\x26\xFD',
    ['Spinal Cleave']      = '\xFD\x02\x02\x26\x17\xFD',
    ['Tail Slap']          = '\xFD\x02\x02\x26\x66\xFD',
    ['Hysteric Barrage']   = '\xFD\x02\x02\x26\x67\xFD',
    ['Asuran Claws']       = '\xFD\x02\x02\x26\x75\xFD',
    ['Cannonball']         = '\xFD\x02\x02\x26\x6A\xFD',
    ['Disseverment']       = '\xFD\x02\x02\x26\x4C\xFD',
    ['Sub-zero Smash']     = '\xFD\x02\x02\x26\x76\xFD',
    ['Ram Charge']         = '\xFD\x02\x02\x26\x3A\xFD',
    ['Vertical Cleave']    = '\xFD\x02\x02\x26\x54\xFD',

    -----------------------------------------------------------------------
    -- TOAU – PUP Automaton Frame Weaponskills
    -- Note: Auto-translate codes not yet available in HorizonXI DAT files
    -- These will display as plain text until codes are added
    -----------------------------------------------------------------------
};

--[[
    Strips tier markers (¹, ², ᵇ, ᶠ) and avatar prefixes from weaponskill names.
    Example: "Asuran Fists¹" -> "Asuran Fists"
    Example: "Foot Kickᵇ" -> "Foot Kick"
    Example: "Chimera Ripperᶠ" -> "Chimera Ripper"
    Example: "[I]Burning Strike" -> "Burning Strike"

    @param name (string) The weaponskill name to normalize
    @return (string) The normalized name
]]
function Autotranslate.NormalizeName(name)
    if not name then return nil; end

    -- Remove tier markers: ¹ (quested), ² (relic), ᵇ (blu), ᶠ (frame)
    local normalized = name:gsub('[¹²]', '');
    normalized = normalized:gsub('ᵇ', '');
    normalized = normalized:gsub('ᶠ', '');

    -- Remove avatar prefixes like [I], [T], [L], [G], [S], [R], [C], [F]
    normalized = normalized:gsub('^%[.%]', '');

    return normalized;
end

--[[
    Looks up the auto-translate code for a weaponskill name.
    Handles tier markers and avatar prefixes automatically.

    @param name (string) The weaponskill name
    @return (string|nil) The auto-translate byte code, or nil if not found
]]
function Autotranslate.GetWeaponskillCode(name)
    local normalized = Autotranslate.NormalizeName(name);
    if not normalized then return nil; end

    return Autotranslate.Weaponskills[normalized];
end

--[[
    Looks up the auto-translate code for a skillchain name.

    @param name (string) The skillchain property name
    @return (string|nil) The auto-translate byte code, or nil if not found
]]
function Autotranslate.GetSkillchainCode(name)
    if not name then return nil; end
    return Autotranslate.Skillchains[name];
end

--[[
    Returns the auto-translate code for a name if it exists.
    Falls back to plain text if no auto-translate code is found.

    Note: The \xFD...\xFD byte sequence is displayed by FFXI with
    auto-translate brackets automatically - no need to add \xEF\x27/\xEF\x28.

    @param name (string) The name to look up
    @param lookupType (string) 'weaponskill' or 'skillchain'
    @return (string) The auto-translate code or plain text name
]]
function Autotranslate.Format(name, lookupType)
    if not name then return ''; end

    local code = nil;
    if lookupType == 'weaponskill' then
        code = Autotranslate.GetWeaponskillCode(name);
    elseif lookupType == 'skillchain' then
        code = Autotranslate.GetSkillchainCode(name);
    end

    if code then
        return code;
    else
        -- No auto-translate code found, return normalized plain text
        return Autotranslate.NormalizeName(name) or name;
    end
end

--[[
    Formats a complete skillchain combo for output.
    Wraps opener, closer, and chain name in auto-translate format.

    @param opener (string) The opening weaponskill name
    @param closer (string) The closing weaponskill name
    @param chainName (string) The resulting skillchain property name
    @return (string) The formatted combo string
]]
function Autotranslate.FormatCombo(opener, closer, chainName)
    local openerFmt = Autotranslate.Format(opener, 'weaponskill');
    local closerFmt = Autotranslate.Format(closer, 'weaponskill');
    local chainFmt = Autotranslate.Format(chainName, 'skillchain');

    return string.format('%s > %s > %s', openerFmt, closerFmt, chainFmt);
end

return Autotranslate;
