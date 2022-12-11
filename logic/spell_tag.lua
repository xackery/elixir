---@type Mq
local mq = require('mq')

---@class SpellTag # Keeps cached information about a spell
---@field IsHeal boolean # Is spell a heal
---@field IsHot boolean # Is spell a heal over time hot
---@field IsDebuff boolean # Is spell a debuff (slows, snares, things that don't break mez)
---@field IsBuff boolean # Is spell a buff (beneficial ally spell)
---@field IsNuke boolean # Is spell a nuke (damage component attached)
---@field IsDot boolean # Is spell a debuff with damage over time
---@field IsLifetap boolean # Is spell a lifetap (subcategory of nuke that heals self too)
---@field IsMana boolean # Is spell a mana (gives or takes mana)
---@field IsInvis boolean # Is spell one that gives invis
---@field IsCharm boolean # Is spell a charm
---@field IsSnare boolean # Is spell a snare
---@field IsSow boolean # Is spell a sow
---@field IsTaunt boolean # Is spell a taunt
---@field IsSingleTargetSpell boolean # Is spell a singletargetspell
---@field IsPetSummon boolean # Is spell a petsummon
---@field IsTransport boolean # Is spell a transport
---@field IsGroupSpell boolean # Is spell a groupspell
---@field IsBardSong boolean # Is spell a bardsong
---@field IsMez boolean # Is spell a mez
---@field IsLull boolean # Is spell a lull
---@field IsCureDisease boolean # Is spell a curedisease
---@field IsCurePoison boolean # Is spell a curepoison
---@field IsSummonItem boolean # Is spell a summonitem
---@field IsInvulnerability boolean # Is spell a invulnerability
---@field IsRessurect boolean # Is spell a ressurect
---@field IsHaste boolean # Is spell a haste
---@field IsSlow boolean # Is spell a slow
---@field IsFeignDeath boolean # Is spell one that triggers FD
---@field IsDeathPact boolean # Is spell a divine intervention line spell
---@field StunDuration number
---@field DamageAmount number
---@field HealAmount number
---@field BodyType number
---@field SpellGroup number
---@field Ticks number
---@field Targets number
---@field TargetType number
---@field Skill number
SpellTag = {}

--- local cache of existing spells
local spellTagCache = {}

---initialize spelltag information, this is built to be cached in elixir
---@param spellID number
---@return SpellTag # SpellTag generated or an error
local function initializeSpellTag(spellID)
    local spellTag = {} ---@type SpellTag

    local currentSpell = mq.TLO.Spell(spellID)
    if not currentSpell then
        return spellTag
    end

    for i = 1, currentSpell.NumEffects() do
        local attr = currentSpell.Attrib(i)()
        local base = currentSpell.Base(i)()
        local base2 = currentSpell.Base2(i)()
        local max = currentSpell.Max(i)()
        if attr == 0 then --- SPA_HP    
            if base > 0 then
                if currentSpell.Duration.Ticks() == 0 then
                    spellTag.IsHeal = true
                    spellTag.HealAmount = base
                end

                if currentSpell.Duration.Ticks() > 1 and currentSpell.Duration.Ticks() < 20 then
                    spellTag.IsHot = true
                    spellTag.HealAmount = base * currentSpell.Duration.Ticks()
                end
            end

            if currentSpell.Duration.Ticks() > 0 and base == 0 then
                spellTag.IsBuff = true
            end
            if currentSpell.CategoryID == 114 then
                spellTag.IsLifetap = true
            end
            
            if base < 0 then
                if currentSpell.Duration.Ticks() > 0 then
                    spellTag.IsDoT = true
                else
                    spellTag.IsNuke = true
                end
                spellTag.DamageAmount = -base
            end
        end

        if attr == 1 or --- SPA_AC
        attr == 2 or --- SPA_ATTACK
        attr == 4 or --- SPA_STR
        attr == 5 or --- SPA_DEX
        attr == 6 or --- SPA_AGI
        attr == 7 or --- SPA_STA
        attr == 8 or --- SPA_INT
        attr == 9 then --- SPA_WIS
            if base > 0 then spellTag.IsBuff = true end
            if base < 0 then spellTag.IsDebuff = true end
        end

        if attr == 3 then -- SPA_MOVEMENT_RATE
            if base > 0 then
                spellTag.IsBuff = true
                spellTag.IsSow = true
            end
            if base < 0 then
                spellTag.IsDebuff = true
                spellTag.IsSnare = true
            end
        end

        if attr == 10 then -- SPA_CHA
            if base > 0 then spellTag.IsBuff = true end
            if base < 0 then spellTag.IsDebuff = true end
        end

        if attr == 11 then -- SPA_HASTE
            if base > 0 then
                spellTag.IsBuff = true
                spellTag.IsHaste = true
            end
            if base < 0 then
                spellTag.IsDebuff = true
                spellTag.IsSlow = true
            end
        end

        if attr == 12 then -- SPA_INVISIBILITY
            spellTag.IsBuff = true
            spellTag.IsInvis = true
        end

        if attr == 13 then -- SPA_SEE_INVIS
            spellTag.IsBuff = true
        end

        if attr == 14 then -- SPA_ENDURING_BREATH
            spellTag.IsBuff = true
        end

        if attr == 14 then -- SPA_MANA
            spellTag.IsMana = true
            spellTag.IsBuff = true
        end

        if attr == 16 then -- SPA_NPC_FRENZY
            spellTag.IsLull = true
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 17 then -- SPA_NPC_AWARENESS
            spellTag.IsLull = true
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 18 then -- SPA_NPC_AGGRO
            spellTag.IsLull = true
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 21 then -- SPA_STUN
            spellTag.StunDuration = base2
            if currentSpell.TargetType() == "PB AE" or currentSpell.TargetType() == "AE PC v1" then
                spellTag.IsSingleTargetSpell = true
            end
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 22 then -- SPA_CHARM
            spellTag.IsCharm = true
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 23 then -- SPA_FEAR
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 26 then -- SPA_GATE
            spellTag.IsTransport = true
        end

        if attr == 30 then -- SPA_NPC_AGGRO_RADIUS
            spellTag.IsLull = true
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 31 then -- SPA_MEZ
            spellTag.IsMez = true
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 32 then -- SPA_CREATE_ITEM
            spellTag.IsSummonItem = true
        end

        if attr == 33 then -- SPA_SUMMON_PET
            spellTag.IsPetSummon = true
        end

        if attr == 34 then -- SPA_CONFUSE
        end

        if attr == 35 then -- SPA_SUMMON_PET
            spellTag.IsPetSummon = true
        end

        if attr == 35 then -- SPA_DISEASE
            if currentSpell.SpellType() == "Beneficial" or currentSpell.SpellType() == "Beneficial(Group)" then
                spellTag.IsCureDisease = true
            else
                spellTag.IsDebuff = true
            end
        end

        if attr == 36 then -- SPA_POISON
            if currentSpell.SpellType() == "Beneficial" or currentSpell.SpellType() == "Beneficial(Group)" then
                spellTag.IsCurePoison = true
            else
                spellTag.IsDebuff = true
            end
        end

        if attr == 37 then -- SPA_DETECT_HOSTILE
        end

        if attr == 38 then -- SPA_DETECT_MAGIC
        end

        if attr == 39 then -- SPA_NO_TWINCAST
        end

        if attr == 40 then -- SPA_INVULNERABILITY
            spellTag.IsInvulnerability = true
        end

        if attr == 41 then -- SPA_BANISH
        end

        if attr == 42 then -- SPA_SHADOW_STEP
        end

        if attr == 43 then -- SPA_BERSERK
        end

        if attr == 44 then -- SPA_LYCANTHROPY
        end

        if attr == 45 then -- SPA_VAMPIRISM
        end

        if attr == 46 then -- SPA_RESIST_FIRE
            spellTag.IsBuff = true
        end

        if attr == 47 then -- SPA_RESIST_COLD
            spellTag.IsBuff = true
        end

        if attr == 48 then -- SPA_RESIST_POISON
            spellTag.IsBuff = true
        end

        if attr == 49 then -- SPA_RESIST_DISEASE
            spellTag.IsBuff = true
        end

        if attr == 50 then -- SPA_RESIST_MAGIC            
            spellTag.IsBuff = true
        end

        if attr == 51 then -- SPA_DETECT_TRAPS
        end

        if attr == 52 then -- SPA_DETECT_UNDEAD
        end

        if attr == 53 then -- SPA_DETECT_SUMMONED
        end

        if attr == 54 then -- SPA_DETECT_ANIMALS
        end

        if attr == 55 then -- SPA_STONESKIN
            spellTag.IsBuff = true
        end

        if attr == 56 then -- SPA_TRUE_NORTH
        end

        if attr == 57 then -- SPA_LEVITATION
            spellTag.IsBuff = true
        end

        if attr == 58 then -- SPA_CHANGE_FORM
        end

        if attr == 59 then -- SPA_DAMAGE_SHIELD
            spellTag.IsBuff = true
        end

        if attr == 60 then -- SPA_TRANSFER_ITEM
        end

        if attr == 61 then -- SPA_ITEM_LORE
        end

        if attr == 62 then -- SPA_ITEM_IDENTIFY
        end

        if attr == 63 then -- SPA_NPC_WIPE_HATE_LIST

        end

        if attr == 64 then -- SPA_SPIN_STUN
            spellTag.StunDuration = base2
            if currentSpell.TargetType() == "PB AE" or currentSpell.TargetType() == "AE PC v1" then
                spellTag.IsSingleTargetSpell = true
            end
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 65 then -- SPA_INFRAVISION
            spellTag.IsBuff = true
        end

        if attr == 66 then -- SPA_ULTRAVISION
            spellTag.IsBuff = true
        end

        if attr == 67 then -- SPA_EYE_OF_ZOMM
        end

        if attr == 68 then -- SPA_RECLAIM_ENERGY            
        end

        if attr == 69 then -- SPA_MAX_HP
            spellTag.IsBuff = true
        end

        if attr == 70 then -- SPA_CORPSE_BOMB
        end

        if attr == 71 then -- SPA_CREATE_UNDEAD
            spellTag.IsPetSummon = true
        end

        if attr == 72 then -- SPA_PRESERVE_CORPSE
        end

        if attr == 73 then -- SPA_BIND_SIGHT
        end

        if attr == 74 then -- SPA_FEIGN_DEATH
            spellTag.IsFeignDeath = true
        end

        if attr == 75 then -- SPA_VENTRILOQUISM
        end

        if attr == 76 then -- SPA_SENTINEL
        end

        if attr == 77 then -- SPA_LOCATE_CORPSE
        end

        if attr == 78 then -- SPA_SPELL_SHIELD
        end

        if attr == 79 then -- SPA_INSTANT_HP
        end

        if attr == 80 then -- SPA_ENCHANT_LIGHT
        end

        if attr == 81 then -- SPA_RESURRECT
            spellTag.IsRessurect = true
        end

        if attr == 82 then -- SPA_SUMMON_TARGET
        end

        if attr == 83 then -- SPA_PORTAL
            spellTag.IsTransport = true
        end

        if attr == 84 then -- SPA_HP_NPC_ONLY
        end

        if attr == 85 then -- SPA_MELEE_PROC
        end

        if attr == 86 then -- SPA_NPC_HELP_RADIUS
            spellTag.IsLull = true
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 87 then -- SPA_MAGNIFICATION
        end

        if attr == 88 then -- SPA_EVACUATE
            spellTag.IsTransport = true
        end

        if attr == 89 then -- SPA_HEIGHT
        end

        if attr == 90 then -- SPA_IGNORE_PET
        end

        if attr == 91 then -- SPA_SUMMON_CORPSE
        end

        if attr == 92 then -- SPA_HATE
        end

        if attr == 93 then -- SPA_WEATHER_CONTROL
        end

        if attr == 94 then -- SPA_FRAGILE
        end

        if attr == 95 then -- SPA_SACRIFICE
        end

        if attr == 96 then -- SPA_SILENCE
        end

        if attr == 97 then -- SPA_MAX_MANA
            spellTag.IsMana = true
            spellTag.IsBuff = true
        end

        if attr == 98 then -- SPA_BARD_HASTE
            spellTag.IsHaste = true
            spellTag.IsBuff = true
        end

        if attr == 99 then -- SPA_ROOT
            spellTag.IsDebuff = true
        end

        if attr == 100 then -- SPA_HEALDOT
            spellTag.IsHot = true
            spellTag.HealAmount = base * currentSpell.Duration.Ticks()
        end

        if attr == 101 then -- SPA_COMPLETEHEAL
            spellTag.IsHeal = true
            spellTag.HealAmount = base
        end

        if attr == 102 then -- SPA_PET_FEARLESS
        end

        if attr == 103 then -- SPA_CALL_PET
        end

        if attr == 104 then -- SPA_TRANSLOCATE
            spellTag.IsTransport = true
        end

        if attr == 105 then -- SPA_NPC_ANTI_GATE
            spellTag.IsDebuff = true
            spellTag.IsDetrimental = true
        end

        if attr == 106 then -- SPA_BEASTLORD_PET
            spellTag.IsPetSummon = true
        end

        if attr == 107 then -- SPA_ALTER_PET_LEVEL
        end

        if attr == 108 then -- SPA_FAMILIAR
            spellTag.IsPetSummon = true
        end

        if attr == 109 then -- SPA_CREATE_ITEM_IN_BAG
            spellTag.IsSummonItem = true
        end

        if attr == 110 then -- SPA_ARCHERY
            spellTag.IsBuff = true
        end

        if attr == 111 then -- SPA_RESIST_ALL
            spellTag.IsBuff = true
        end

        if attr == 112 then -- SPA_FIZZLE_SKILL
            spellTag.IsBuff = true
        end

        if attr == 113 then -- SPA_SUMMON_MOUNT            
        end

        if attr == 114 then -- SPA_MODIFY_HATE
            spellTag.IsBuff = true
        end

        if attr == 115 then -- SPA_CORNUCOPIA
            spellTag.IsSummonItem = true
        end

        if attr == 116 then -- SPA_CURSE
            spellTag.IsDebuff = true
        end

        if attr == 117 then -- SPA_HIT_MAGIC
        end

        if attr == 118 then -- SPA_AMPLIFICATION
            spellTag.IsBuff = true
        end

        if attr == 119 then -- SPA_ATTACK_SPEED_MAX
            spellTag.IsBuff = true
        end

        if attr == 120 then -- SPA_HEALMOD
            spellTag.IsBuff = true
        end

        if attr == 121 then -- SPA_IRONMAIDEN
        end

        if attr == 122 then -- SPA_REDUCESKILL
        end

        if attr == 123 then -- SPA_IMMUNITY
            spellTag.IsBuff = true
        end

        if attr == 124 then -- SPA_FOCUS_DAMAGE_MOD
            spellTag.IsBuff = true
        end

        if attr == 125 then -- SPA_FOCUS_HEAL_MOD
            spellTag.IsBuff = true
        end

        if attr == 126 then -- SPA_FOCUS_RESIST_MOD
            spellTag.IsBuff = true
        end

        if attr == 127 then -- SPA_FOCUS_CAST_TIME_MOD
            spellTag.IsBuff = true
        end

        if attr == 128 then -- SPA_FOCUS_DURATION_MOD
            spellTag.IsBuff = true
        end

        if attr == 129 then -- SPA_FOCUS_RANGE_MOD
            spellTag.IsBuff = true
        end

        if attr == 130 then -- SPA_FOCUS_HATE_MOD
            spellTag.IsBuff = true
        end

        if attr == 131 then -- SPA_FOCUS_REAGENT_MOD
            spellTag.IsBuff = true
        end

        if attr == 132 then -- SPA_FOCUS_MANACOST_MOD
            spellTag.IsBuff = true
        end

        if attr == 133 then -- SPA_FOCUS_STUNTIME_MOD
            spellTag.IsBuff = true
        end

        if attr == 134 then -- SPA_FOCUS_LEVEL_MAX
        end

        if attr == 135 then -- SPA_FOCUS_RESIST_TYPE
            spellTag.IsBuff = true
        end

        if attr == 136 then -- SPA_FOCUS_TARGET_TYPE
        end

        if attr == 137 then -- SPA_FOCUS_WHICH_SPA
        end

        if attr == 138 then -- SPA_FOCUS_BENEFICIAL
        end

        if attr == 139 then -- SPA_FOCUS_WHICH_SPELL
        end

        if attr == 140 then -- SPA_FOCUS_DURATION_MIN
        end

        if attr == 141 then -- SPA_FOCUS_INSTANT_ONLY
        end

        if attr == 142 then -- SPA_FOCUS_LEVEL_MIN
        end

        if attr == 143 then -- SPA_FOCUS_CASTTIME_MIN
        end

        if attr == 144 then -- SPA_FOCUS_CASTTIME_MAX
        end

        if attr == 145 then -- SPA_NPC_PORTAL_WARDER_BANISH
        end

        if attr == 146 then -- SPA_PORTAL_LOCATIONS
        end

        if attr == 147 then -- SPA_PERCENT_HEAL
        end

        if attr == 148 then -- SPA_STACKING_BLOCK
        end

        if attr == 149 then -- SPA_STRIP_VIRTUAL_SLOT
        end

        if attr == 150 then -- SPA_DIVINE_INTERVENTION
            spellTag.IsDeathPact = true
        end

        if attr == 151 then -- SPA_POCKET_PET
        end

        if attr == 152 then -- SPA_PET_SWARM
        end

        if attr == 153 then -- SPA_HEALTH_BALANCE
        end

        if attr == 154 then -- SPA_CANCEL_NEGATIVE_MAGIC
        end

        if attr == 155 then -- SPA_POP_RESURRECT
        end

        if attr == 156 then -- SPA_MIRROR
        end

        if attr == 157 then -- SPA_FEEDBACK
        end

        if attr == 158 then -- SPA_REFLECT
        end

        if attr == 159 then -- SPA_MODIFY_ALL_STATS
        end

        if attr == 160 then -- SPA_CHANGE_SOBRIETY
        end

        if attr == 161 then -- SPA_SPELL_GUARD
            spellTag.IsBuff = true
        end

        if attr == 162 then -- SPA_MELEE_GUARD
            spellTag.IsBuff = true
        end

        if attr == 163 then -- SPA_ABSORB_HIT
            spellTag.IsBuff = true
        end

        if attr == 164 then -- SPA_OBJECT_SENSE_TRAP
        end

        if attr == 165 then -- SPA_OBJECT_DISARM_TRAP
        end

        if attr == 166 then -- SPA_OBJECT_PICKLOCK
        end

        if attr == 167 then -- SPA_FOCUS_PET
            spellTag.IsBuff = true
        end

        if attr == 168 then -- SPA_DEFENSIVE
            spellTag.IsBuff = true
        end

        if attr == 169 then -- SPA_CRITICAL_MELEE
        end

        if attr == 170 then -- SPA_CRITICAL_SPELL
        end

        if attr == 171 then -- SPA_CRIPPLING_BLOW
        end

        if attr == 172 then -- SPA_EVASION
            spellTag.IsBuff = true
        end

        if attr == 173 then -- SPA_RIPOSTE
            spellTag.IsBuff = true
        end

        if attr == 174 then -- SPA_DODGE
            spellTag.IsBuff = true
        end

        if attr == 175 then -- SPA_PARRY
            spellTag.IsBuff = true
        end

        if attr == 176 then -- SPA_DUAL_WIELD
        end

        if attr == 177 then -- SPA_DOUBLE_ATTACK
        end

        if attr == 178 then -- SPA_MELEE_LIFETAP
        end

        if attr == 179 then -- SPA_PURETONE
        end

        if attr == 180 then -- SPA_SANCTIFICATION
        end

        if attr == 181 then -- SPA_FEARLESS
        end

        if attr == 182 then -- SPA_HUNDRED_HANDS
        end

        if attr == 183 then -- SPA_SKILL_INCREASE_CHANCE
            spellTag.IsBuff = true
        end

        if attr == 184 then -- SPA_ACCURACY
        end

        if attr == 185 then -- SPA_SKILL_DAMAGE_MOD
        end

        if attr == 186 then -- SPA_MIN_DAMAGE_DONE_MOD
        end

        if attr == 187 then -- SPA_MANA_BALANCE
        end

        if attr == 188 then -- SPA_BLOCK
        end

        if attr == 189 then -- SPA_ENDURANCE
        end

        if attr == 190 then -- SPA_INCREASE_MAX_ENDURANCE
        end

        if attr == 191 then -- SPA_AMNESIA
        end

        if attr == 192 then -- SPA_HATE_OVER_TIME
            spellTag.IsTaunt = true
        end

        if attr == 193 then -- SPA_SKILL_ATTACK
        end

        if attr == 194 then -- SPA_FADE
        end

        if attr == 195 then -- SPA_STUN_RESIST
        end

        if attr == 19 then -- SPA_STRIKETHROUGH1
        end

        if attr == 197 then -- SPA_SKILL_DAMAGE_TAKEN
        end

        if attr == 198 then -- SPA_INSTANT_ENDURANCE
        end

        if attr == 199 then -- SPA_TAUNT
            spellTag.IsTaunt = true
        end

        if attr == 200 then -- SPA_PROC_CHANCE
        end

        if attr == 201 then -- SPA_RANGE_ABILITY
        end

        if attr == 202 then -- SPA_ILLUSION_OTHERS
        end

        if attr == 203 then -- SPA_MASS_GROUP_BUFF
        end

        if attr == 204 then -- SPA_GROUP_FEAR_IMMUNITY
        end

        if attr == 205 then -- SPA_RAMPAGE
        end

        if attr == 206 then -- SPA_AE_TAUNT
        end

        if attr == 207 then -- SPA_FLESH_TO_BONE
        end

        if attr == 208 then -- SPA_PURGE_POISON
        end

        if attr == 209 then -- SPA_CANCEL_BENEFICIAL
        end

        if attr == 210 then -- SPA_SHIELD_CASTER
        end

        if attr == 211 then -- SPA_DESTRUCTIVE_FORCE
        end

        if attr == 212 then -- SPA_FOCUS_FRENZIED_DEVASTATION
        end

        if attr == 213 then -- SPA_PET_PCT_MAX_HP
        end

        if attr == 214 then -- SPA_HP_MAX_HP
            spellTag.IsBuff = true
        end

        if attr == 215 then -- SPA_PET_PCT_AVOIDANCE
        end

        if attr == 216 then -- SPA_MELEE_ACCURACY
        end

        if attr == 217 then -- SPA_HEADSHOT
        end

        if attr == 218 then -- SPA_PET_CRIT_MELEE
        end

        if attr == 219 then -- SPA_SLAY_UNDEAD
        end

        if attr == 220 then -- SPA_INCREASE_SKILL_DAMAGE
        end

        if attr == 221 then -- SPA_REDUCE_WEIGHT
        end

        if attr == 222 then -- SPA_BLOCK_BEHIND
        end

        if attr == 223 then -- SPA_DOUBLE_RIPOSTE
        end

        if attr == 224 then -- SPA_ADD_RIPOSTE
        end

        if attr == 225 then -- SPA_GIVE_DOUBLE_ATTACK
        end

        if attr == 226 then -- SPA_2H_BASH
        end

        if attr == 227 then -- SPA_REDUCE_SKILL_TIMER
        end

        if attr == 228 then -- SPA_ACROBATICS
        end

        if attr == 229 then -- SPA_CAST_THROUGH_STUN
        end

        if attr == 230 then -- SPA_EXTENDED_SHIELDING
        end

        if attr == 231 then -- SPA_BASH_CHANCE
        end

        if attr == 232 then -- SPA_DIVINE_SAVE
            spellTag.IsBuff = true
        end

        if attr == 233 then -- SPA_METABOLISM
        end

        if attr == 234 then -- SPA_POISON_MASTERY
        end

        if attr == 235 then -- SPA_FOCUS_CHANNELING
        end

        if attr == 236 then -- SPA_FREE_PET
        end

        if attr == 237 then -- SPA_PET_AFFINITY
        end

        if attr == 238 then -- SPA_PERM_ILLUSION
        end

        if attr == 239 then -- SPA_STONEWALL
        end

        if attr == 240 then -- SPA_STRING_UNBREAKABLE
        end

        if attr == 241 then -- SPA_IMPROVE_RECLAIM_ENERGY
        end

        if attr == 242 then -- SPA_INCREASE_CHANGE_MEMWIPE
        end

        if attr == 243 then -- SPA_ENHANCED_CHARM
        end

        if attr == 244 then -- SPA_ENHANCED_ROOT
        end

        if attr == 245 then -- SPA_TRAP_CIRCUMVENTION
        end

        if attr == 246 then -- SPA_INCREASE_AIR_SUPPLY
        end

        if attr == 247 then -- SPA_INCREASE_MAX_SKILL
        end

        if attr == 248 then -- SPA_EXTRA_SPECIALIZATION
        end

        if attr == 249 then -- SPA_OFFHAND_MIN_WEAPON_DAMAGE
        end

        if attr == 250 then -- SPA_INCREASE_PROC_CHANCE
        end

        if attr == 251 then -- SPA_ENDLESS_QUIVER
        end

        if attr == 252 then -- SPA_BACKSTAB_FRONT
        end

        if attr == 253 then -- SPA_CHAOTIC_STAB
        end

        if attr == 254 then -- SPA_NOSPELL
        end

        if attr == 255 then -- SPA_SHIELDING_DURATION_MOD
        end

        if attr == 256 then -- SPA_SHROUD_OF_STEALTH
        end

        if attr == 25 then -- SPA_GIVE_PET_HOLD
        end

        if attr == 258 then -- SPA_TRIPLE_BACKSTAB
        end

        if attr == 259 then -- SPA_AC_LIMIT_MOD
        end

        if attr == 260 then -- SPA_ADD_INSTRUMENT_MOD
        end

        if attr == 261 then -- SPA_SONG_MOD_CAP
        end

        if attr == 262 then -- SPA_INCREASE_STAT_CAP
        end

        if attr == 263 then -- SPA_TRADESKILL_MASTERY
        end

        if attr == 264 then -- SPA_REDUCE_AA_TIMER
        end

        if attr == 265 then -- SPA_NO_FIZZLE
        end

        if attr == 266 then -- SPA_ADD_2H_ATTACK_CHANCE
        end

        if attr == 267 then -- SPA_ADD_PET_COMMANDS
        end

        if attr == 268 then -- SPA_ALCHEMY_FAIL_RATE
        end

        if attr == 269 then -- SPA_FIRST_AID
        end

        if attr == 270 then -- SPA_EXTEND_SONG_RANGE
        end

        if attr == 271 then -- SPA_BASE_RUN_MOD
        end

        if attr == 272 then -- SPA_INCREASE_CASTING_LEVEL
        end

        if attr == 273 then -- SPA_DOTCRIT
        end

        if attr == 274 then -- SPA_HEALCRIT
        end

        if attr == 275 then -- SPA_MENDCRIT
        end

        if attr == 276 then -- SPA_DUAL_WIELD_AMT
        end

        if attr == 277 then -- SPA_EXTRA_DI_CHANCE
        end

        if attr == 278 then -- SPA_FINISHING_BLOW
        end

        if attr == 279 then -- SPA_FLURRY
        end

        if attr == 280 then -- SPA_PET_FLURRY
        end

        if attr == 281 then -- SPA_PET_FEIGN
        end

        if attr == 282 then -- SPA_INCREASE_BANDAGE_AMT
        end

        if attr == 283 then -- SPA_WU_ATTACK
        end

        if attr == 284 then -- SPA_IMPROVE_LOH
        end

        if attr == 285 then -- SPA_NIMBLE_EVASION
        end

        if attr == 286 then -- SPA_FOCUS_DAMAGE_AMT
        end

        if attr == 287 then -- SPA_FOCUS_DURATION_AMT
        end

        if attr == 288 then -- SPA_ADD_PROC_HIT
        end

        if attr == 289 then -- SPA_DOOM_EFFECT
        end

        if attr == 290 then -- SPA_INCREASE_RUN_SPEED_CAP
        end

        if attr == 291 then -- SPA_PURIFY
            spellTag.IsCureDisease = true
            spellTag.IsCurePoison = true
        end

        if attr == 292 then -- SPA_STRIKETHROUGH
        end

        if attr == 293 then -- SPA_STUN_RESIST2
        end

        if attr == 294 then -- SPA_SPELL_CRIT_CHANCE
        end

        if attr == 295 then -- SPA_REDUCE_SPECIAL_TIMER
        end

        if attr == 296 then -- SPA_FOCUS_DAMAGE_MOD_DETRIMENTAL
        end

        if attr == 297 then -- SPA_FOCUS_DAMAGE_AMT_DETRIMENTAL
        end

        if attr == 298 then -- SPA_TINY_COMPANION
        end

        if attr == 299 then -- SPA_WAKE_DEAD
        end

        if attr == 300 then -- SPA_DOPPELGANGER
        end

        if attr == 301 then -- SPA_INCREASE_RANGE_DMG
        end

        if attr == 302 then -- SPA_FOCUS_DAMAGE_MOD_CRIT
        end

        if attr == 303 then -- SPA_FOCUS_DAMAGE_AMT_CRIT
        end

        if attr == 304 then -- SPA_SECONDARY_RIPOSTE_MOD
        end

        if attr == 305 then -- SPA_DAMAGE_SHIELD_MOD
        end

        if attr == 306 then -- SPA_WEAK_DEAD_2
        end

        if attr == 307 then -- SPA_APPRAISAL
        end

        if attr == 308 then -- SPA_ZONE_SUSPEND_MINION
        end

        if attr == 309 then -- SPA_TELEPORT_CASTERS_BINDPOINT
        end

        if attr == 310 then -- SPA_FOCUS_REUSE_TIMER
        end

        if attr == 311 then -- SPA_FOCUS_COMBAT_SKILL
        end

        if attr == 312 then -- SPA_OBSERVER
        end

        if attr == 313 then -- SPA_FORAGE_MASTER
        end

        if attr == 314 then -- SPA_IMPROVED_INVIS
        end

        if attr == 315 then -- SPA_IMPROVED_INVIS_UNDEAD
        end

        if attr == 316 then -- SPA_IMPROVED_INVIS_ANIMALS
        end

        if attr == 317 then -- SPA_INCREASE_WORN_HP_REGEN_CAP
        end

        if attr == 318 then -- SPA_INCREASE_WORN_MANA_REGEN_CAP
        end

        if attr == 319 then -- SPA_CRITICAL_HP_REGEN
        end

        if attr == 320 then -- SPA_SHIELD_BLOCK_CHANCE
        end

        if attr == 321 then -- SPA_REDUCE_TARGET_HATE
        end

        if attr == 322 then -- SPA_GATE_STARTING_CITY
        end

        if attr == 323 then -- SPA_DEFENSIVE_PROC
        end

        if attr == 324 then -- SPA_HP_FOR_MANA
        end

        if attr == 325 then -- SPA_NO_BREAK_AE_SNEAK
        end

        if attr == 326 then -- SPA_ADD_SPELL_SLOTS
        end

        if attr == 327 then -- SPA_ADD_BUFF_SLOTS
        end

        if attr == 328 then -- SPA_INCREASE_NEGATIVE_HP_LIMIT
        end

        if attr == 329 then -- SPA_MANA_ABSORB_PCT_DMG
        end

        if attr == 330 then -- SPA_CRIT_ATTACK_MODIFIER
        end

        if attr == 331 then -- SPA_FAIL_ALCHEMY_ITEM_RECOVERY
        end

        if attr == 332 then -- SPA_SUMMON_TO_CORPSE
        end

        if attr == 333 then -- SPA_DOOM_RUNE_EFFECT
        end

        if attr == 334 then -- SPA_NO_MOVE_HP
        end

        if attr == 335 then -- SPA_FOCUSED_IMMUNITY
        end

        if attr == 336 then -- SPA_ILLUSIONARY_TARGET
        end

        if attr == 337 then -- SPA_INCREASE_EXP_MOD
        end

        if attr == 338 then -- SPA_EXPEDIENT_RECOVERY
        end

        if attr == 339 then -- SPA_FOCUS_CASTING_PROC
        end

        if attr == 340 then -- SPA_CHANCE_SPELL
        end

        if attr == 341 then -- SPA_WORN_ATTACK_CAP
        end

        if attr == 342 then -- SPA_NO_PANIC
        end

        if attr == 343 then -- SPA_SPELL_INTERRUPT
        end

        if attr == 344 then -- SPA_ITEM_CHANNELING
        end

        if attr == 345 then -- SPA_ASSASSINATE_MAX_LEVEL
        end

        if attr == 346 then -- SPA_HEADSHOT_MAX_LEVEL
        end

        if attr == 347 then -- SPA_DOUBLE_RANGED_ATTACK
        end

        if attr == 348 then -- SPA_FOCUS_MANA_MIN
        end

        if attr == 349 then -- SPA_INCREASE_SHIELD_DMG
        end

        if attr == 350 then -- SPA_MANABURN
        end

        if attr == 351 then -- SPA_SPAWN_INTERACTIVE_OBJECT
        end

        if attr == 352 then -- SPA_INCREASE_TRAP_COUNT
        end

        if attr == 353 then -- SPA_INCREASE_SOI_COUNT
        end

        if attr == 354 then -- SPA_DEACTIVATE_ALL_TRAPS
        end

        if attr == 355 then -- SPA_LEARN_TRAP
        end

        if attr == 356 then -- SPA_CHANGE_TRIGGER_TYPE
        end

        if attr == 357 then -- SPA_FOCUS_MUTE
        end

        if attr == 358 then -- SPA_INSTANT_MANA
        end

        if attr == 359 then -- SPA_PASSIVE_SENSE_TRAP
        end

        if attr == 360 then -- SPA_PROC_ON_KILL_SHOT
        end

        if attr == 361 then -- SPA_PROC_ON_DEATH
        end

        if attr == 362 then -- SPA_POTION_BELT
        end

        if attr == 363 then -- SPA_BANDOLIER
        end

        if attr == 364 then -- SPA_ADD_TRIPLE_ATTACK_CHANCE
        end

        if attr == 365 then -- SPA_PROC_ON_SPELL_KILL_SHOT
        end

        if attr == 366 then -- SPA_GROUP_SHIELDING
        end

        if attr == 367 then -- SPA_MODIFY_BODY_TYPE
        end

        if attr == 368 then -- SPA_MODIFY_FACTION
        end

        if attr == 369 then -- SPA_CORRUPTION
        end

        if attr == 370 then -- SPA_RESIST_CORRUPTION
        end

        if attr == 371 then -- SPA_SLOW
        end

        if attr == 372 then -- SPA_GRANT_FORAGING
        end

        if attr == 373 then -- SPA_DOOM_ALWAYS
        end

        if attr == 374 then -- SPA_TRIGGER_SPELL
        end

        if attr == 375 then -- SPA_CRIT_DOT_DMG_MOD
        end

        if attr == 376 then -- SPA_FLING
        end

        if attr == 377 then -- SPA_DOOM_ENTITY
        end

        if attr == 378 then -- SPA_RESIST_OTHER_SPA
        end

        if attr == 379 then -- SPA_DIRECTIONAL_TELEPORT
        end

        if attr == 380 then -- SPA_EXPLOSIVE_KNOCKBACK
        end

        if attr == 381 then -- SPA_FLING_TOWARD
        end

        if attr == 382 then -- SPA_SUPPRESSION
        end

        if attr == 383 then -- SPA_FOCUS_CASTING_PROC_NORMALIZED
        end

        if attr == 384 then -- SPA_FLING_AT
        end

        if attr == 385 then -- SPA_FOCUS_WHICH_GROUP
        end

        if attr == 386 then -- SPA_DOOM_DISPELLER
        end

        if attr == 387 then -- SPA_DOOM_DISPELLEE
        end

        if attr == 388 then -- SPA_SUMMON_ALL_CORPSES
        end

        if attr == 389 then -- SPA_REFRESH_SPELL_TIMER
        end

        if attr == 390 then -- SPA_LOCKOUT_SPELL_TIMER
        end

        if attr == 391 then -- SPA_FOCUS_MANA_MAX
        end

        if attr == 392 then -- SPA_FOCUS_HEAL_AMT
        end

        if attr == 393 then -- SPA_FOCUS_HEAL_MOD_BENEFICIAL
        end

        if attr == 394 then -- SPA_FOCUS_HEAL_AMT_BENEFICIAL
        end

        if attr == 395 then -- SPA_FOCUS_HEAL_MOD_CRIT
        end

        if attr == 396 then -- SPA_FOCUS_HEAL_AMT_CRIT
        end

        if attr == 397 then -- SPA_ADD_PET_AC
        end

        if attr == 398 then -- SPA_FOCUS_SWARM_PET_DURATION
        end

        if attr == 399 then -- SPA_FOCUS_TWINCAST_CHANCE
        end

        if attr == 400 then -- SPA_HEALBURN
        end

        if attr == 401 then -- SPA_MANA_IGNITE
        end

        if attr == 402 then -- SPA_ENDURANCE_IGNITE
        end

        if attr == 403 then -- SPA_FOCUS_SPELL_CLASS
        end

        if attr == 404 then -- SPA_FOCUS_SPELL_SUBCLASS
        end

        if attr == 405 then -- SPA_STAFF_BLOCK_CHANCE
        end

        if attr == 406 then -- SPA_DOOM_LIMIT_USE
        end

        if attr == 407 then -- SPA_DOOM_FOCUS_USED
        end

        if attr == 408 then -- SPA_LIMIT_HP
        end

        if attr == 409 then -- SPA_LIMIT_MANA
        end

        if attr == 410 then -- SPA_LIMIT_ENDURANCE
        end

        if attr == 411 then -- SPA_FOCUS_LIMIT_CLASS
        end

        if attr == 412 then -- SPA_FOCUS_LIMIT_RACE
        end

        if attr == 413 then -- SPA_FOCUS_BASE_EFFECTS
        end

        if attr == 414 then -- SPA_FOCUS_LIMIT_SKILL
        end

        if attr == 415 then -- SPA_FOCUS_LIMIT_ITEM_CLASS
        end

        if attr == 416 then -- SPA_AC2
        end

        if attr == 417 then -- SPA_MANA2
        end

        if attr == 418 then -- SPA_FOCUS_INCREASE_SKILL_DMG_2
        end

        if attr == 419 then -- SPA_PROC_EFFECT_2
        end

        if attr == 420 then -- SPA_FOCUS_LIMIT_USE
        end

        if attr == 421 then -- SPA_FOCUS_LIMIT_USE_AMT
        end

        if attr == 422 then -- SPA_FOCUS_LIMIT_USE_MIN
        end

        if attr == 423 then -- SPA_FOCUS_LIMIT_USE_TYPE
        end

        if attr == 424 then -- SPA_GRAVITATE
        end

        if attr == 425 then -- SPA_FLY
        end

        if attr == 426 then -- SPA_ADD_EXTENDED_TARGET_SLOTS
        end

        if attr == 427 then -- SPA_SKILL_PROC
        end

        if attr == 428 then -- SPA_PROC_SKILL_MODIFIER
        end

        if attr == 429 then -- SPA_SKILL_PROC_SUCCESS
        end

        if attr == 430 then -- SPA_POST_EFFECT
        end

        if attr == 431 then -- SPA_POST_EFFECT_DATA
        end

        if attr == 432 then -- SPA_EXPAND_MAX_ACTIVE_TROPHY_BENEFITS
        end

        if attr == 433 then -- SPA_ADD_NORMALIZED_SKILL_MIN_DMG_AMT
        end

        if attr == 434 then -- SPA_ADD_NORMALIZED_SKILL_MIN_DMG_AMT_2
        end

        if attr == 435 then -- SPA_FRAGILE_DEFENSE
        end

        if attr == 436 then -- SPA_FREEZE_BUFF_TIMER
        end

        if attr == 437 then -- SPA_TELEPORT_TO_ANCHOR
        end

        if attr == 438 then -- SPA_TRANSLOCATE_TO_ANCHOR
        end

        if attr == 439 then -- SPA_ASSASSINATE
        end

        if attr == 440 then -- SPA_FINISHING_BLOW_MAX
        end

        if attr == 441 then -- SPA_DISTANCE_REMOVAL
        end

        if attr == 442 then -- SPA_REQUIRE_TARGET_DOOM
        end

        if attr == 443 then -- SPA_REQUIRE_CASTER_DOOM
        end

        if attr == 444 then -- SPA_IMPROVED_TAUNT
        end

        if attr == 445 then -- SPA_ADD_MERC_SLOT
        end

        if attr == 446 then -- SPA_STACKER_A
        end

        if attr == 447 then -- SPA_STACKER_B
        end

        if attr == 448 then -- SPA_STACKER_C
        end

        if attr == 449 then -- SPA_STACKER_D
        end

        if attr == 450 then -- SPA_DOT_GUARD
        end

        if attr == 451 then -- SPA_MELEE_THRESHOLD_GUARD
        end

        if attr == 452 then -- SPA_SPELL_THRESHOLD_GUARD
        end

        if attr == 453 then -- SPA_MELEE_THRESHOLD_DOOM
        end

        if attr == 454 then -- SPA_SPELL_THRESHOLD_DOOM
        end

        if attr == 455 then -- SPA_ADD_HATE_PCT
        end

        if attr == 456 then -- SPA_ADD_HATE_OVER_TIME_PCT
        end

        if attr == 457 then -- SPA_RESOURCE_TAP
        end

        if attr == 458 then -- SPA_FACTION_MOD
        end

        if attr == 459 then -- SPA_SKILL_DAMAGE_MOD_2
        end

        if attr == 460 then -- SPA_OVERRIDE_NOT_FOCUSABLE
        end

        if attr == 461 then -- SPA_FOCUS_DAMAGE_MOD_2
        end

        if attr == 462 then -- SPA_FOCUS_DAMAGE_AMT_2
        end

        if attr == 463 then -- SPA_SHIELD
        end

        if attr == 464 then -- SPA_PC_PET_RAMPAGE
        end

        if attr == 465 then -- SPA_PC_PET_AE_RAMPAGE
        end

        if attr == 466 then -- SPA_PC_PET_FLURRY
        end

        if attr == 467 then -- SPA_DAMAGE_SHIELD_MITIGATION_AMT
        end

        if attr == 468 then -- SPA_DAMAGE_SHIELD_MITIGATION_PCT
        end

        if attr == 469 then -- SPA_CHANCE_BEST_IN_SPELL_GROUP
        end

        if attr == 470 then -- SPA_TRIGGER_BEST_IN_SPELL_GROUP
        end

        if attr == 471 then -- SPA_DOUBLE_MELEE_ATTACKS
        end

        if attr == 472 then -- SPA_AA_BUY_NEXT_RANK
        end

        if attr == 473 then -- SPA_DOUBLE_BACKSTAB_FRONT
        end

        if attr == 474 then -- SPA_PET_MELEE_CRIT_DMG_MOD
        end

        if attr == 475 then -- SPA_TRIGGER_SPELL_NON_ITEM
        end

        if attr == 476 then -- SPA_WEAPON_STANCE
        end

        if attr == 477 then -- SPA_HATELIST_TO_TOP
        end

        if attr == 478 then -- SPA_HATELIST_TO_TAIL
        end

        if attr == 479 then -- SPA_FOCUS_LIMIT_MIN_VALUE
        end

        if attr == 480 then -- SPA_FOCUS_LIMIT_MAX_VALUE
        end

        if attr == 481 then -- SPA_FOCUS_CAST_SPELL_ON_LAND
        end

        if attr == 482 then -- SPA_SKILL_BASE_DAMAGE_MOD
        end

        if attr == 483 then -- SPA_FOCUS_INCOMING_DMG_MOD
        end

        if attr == 484 then -- SPA_FOCUS_INCOMING_DMG_AMT
        end

        if attr == 485 then -- SPA_FOCUS_LIMIT_CASTER_CLASS
        end

        if attr == 486 then -- SPA_FOCUS_LIMIT_SAME_CASTER
        end

        if attr == 487 then -- SPA_EXTEND_TRADESKILL_CAP
        end

        if attr == 488 then -- SPA_DEFENDER_MELEE_FORCE_PCT
        end

        if attr == 489 then -- SPA_WORN_ENDURANCE_REGEN_CAP
        end

        if attr == 490 then -- SPA_FOCUS_MIN_REUSE_TIME
        end

        if attr == 491 then -- SPA_FOCUS_MAX_REUSE_TIME
        end

        if attr == 492 then -- SPA_FOCUS_ENDURANCE_MIN
        end

        if attr == 493 then -- SPA_FOCUS_ENDURANCE_MAX
        end

        if attr == 494 then -- SPA_PET_ADD_ATK
        end

        if attr == 495 then -- SPA_FOCUS_DURATION_MAX
        end

        if attr == 496 then -- SPA_CRIT_MELEE_DMG_MOD_MAX
        end

        if attr == 497 then -- SPA_FOCUS_CAST_PROC_NO_BYPASS
        end

        if attr == 498 then -- SPA_ADD_EXTRA_PRIMARY_ATTACK_PCT
        end

        if attr == 499 then -- SPA_ADD_EXTRA_SECONDARY_ATTACK_PCT
        end

        if attr == 500 then -- SPA_FOCUS_CAST_TIME_MOD2
        end

        if attr == 501 then -- SPA_FOCUS_CAST_TIME_AMT
        end

        if attr == 502 then -- SPA_FEARSTUN
        end

        if attr == 503 then -- SPA_MELEE_DMG_POSITION_MOD
        end

        if attr == 504 then -- SPA_MELEE_DMG_POSITION_AMT
        end

        if attr == 505 then -- SPA_DMG_TAKEN_POSITION_MOD
        end

        if attr == 506 then -- SPA_DMG_TAKEN_POSITION_AMT
        end

        if attr == 507 then -- SPA_AMPLIFY_MOD
        end

        if attr == 508 then -- SPA_AMPLIFY_AMT
        end

        if attr == 509 then -- SPA_HEALTH_TRANSFER
        end

        if attr == 510 then -- SPA_FOCUS_RESIST_INCOMING
        end

        if attr == 511 then -- SPA_FOCUS_TIMER_MIN
        end

        if attr == 512 then -- SPA_PROC_TIMER_MOD
        end

        if attr == 513 then -- SPA_MANA_MAX
        end

        if attr == 514 then -- SPA_ENDURANCE_MAX
        end

        if attr == 515 then -- SPA_AC_AVOIDANCE_MAX
        end

        if attr == 516 then -- SPA_AC_MITIGATION_MAX
        end

        if attr == 517 then -- SPA_ATTACK_OFFENSE_MAX
        end

        if attr == 518 then -- SPA_ATTACK_ACCURACY_MAX
        end

        if attr == 519 then -- SPA_LUCK_AMT
        end

        if attr == 520 then -- SPA_LUCK_PCT
        end

        if attr == 521 then -- SPA_ENDURANCE_ABSORB_PCT_DMG
        end

        if attr == 522 then -- SPA_INSTANT_MANA_PCT
        end

        if attr == 523 then -- SPA_INSTANT_ENDURANCE_PCT
        end

        if attr == 524 then -- SPA_DURATION_HP_PCT
        end

        if attr == 525 then -- SPA_DURATION_MANA_PCT
        end

        if attr == 526 then -- SPA_DURATION_ENDURANCE_PCT
        end

    end

    --- Clean up cases a debuff is dealing damage, turning it into a dot/nuke
    if spellTag.IsDebuff and spellTag.DamageAmount and spellTag.DamageAmount > 0 then
        spellTag.IsDebuff = false
        if currentSpell.Duration.Ticks() > 0 then
            spellTag.IsDoT = true
        else
            spellTag.IsNuke = true
        end
    end

    --- General catch all for healing spells
    if currentSpell.SubcategoryID() == 43 and currentSpell.Duration.Ticks() < 10 then
        spellTag.IsHeal = true
    end

    if currentSpell.CategoryID() == 126 then -- taps
        if currentSpell.SubcategoryID == 43 then -- gives health
            spellTag.IsLifetap = true
        end
    end

    
    if currentSpell.TargetType() == "Group v1" then
        spellTag.IsGroupSpell = true
    end

    if currentSpell.TargetType() == "Group v2" then
        spellTag.IsGroupSpell = true
    end

    if elixir.Config.IsDebugVerboseEnabled then
        local tags = ""
        for property, value in pairs(spellTag) do
            if value then
                if type(value) == "number" then
                    tags = string.format("%s%s=%d, ", tags, property, value)
                else
                    tags = tags .. property .. ", "
                end
            end
            
        end
        if string.len(tags) > 3 then tags = string.sub(tags, 0, -3) end
        elixir:DebugPrintf("initialized new spell %s (%d) tags: %s", currentSpell.Name(), spellID, tags)
    end

    return spellTag
end

---Generate spell tags, using cache for existing generated ones
---@param spellID number
---@returns SpellTag SpellTag # Spell Tag data
function GenerateSpellTag(spellID)
    if not spellID then
        return {}
    end
    local spellTag = spellTagCache[spellID]
    if spellTag then
        return spellTag
    end
    spellTag = initializeSpellTag(spellID)
    spellTagCache[spellID] = spellTag
    return spellTag
end
