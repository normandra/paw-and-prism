class_name BalanceConfig

# Single source of truth for combat, sustain, enemy, item-effect, and drop-rate tuning.
# Edit values here, then run: godot --headless --path . --script res://tests/balance_audit.gd

# === Player & Core Combat ===
const BASE_HP_REGEN: float = 0.25
const BASE_CRIT_CHANCE: float = 8.0
const BASE_CRIT_MULT: float = 165.0
const HIT_INVULN_SEC: float = 0.30
const CONTACT_CHECK_RADIUS: float = 0.68
const MULTI_SKILL_CD_TAX: float = 0.28 # CD(N) = 1.0 + 0.28 * (N - 1)
const VOLLEY_REPEAT_MULT: float = 0.30 # Same-volley repeat projectile multiplier

# === Enemy Status & Knockback Scaling ===
const ENEMY_CHILL_SPEED_MULT: float = 0.74
const ENEMY_KNOCKBACK_REGULAR: float = 0.38
const ENEMY_KNOCKBACK_ELITE: float = 0.15
const ELITE_HP_MULT: float = 3.8
const ELITE_DMG_MULT: float = 1.45
const ELITE_SPEED_MULT: float = 1.16

# === Sustain Caps ===
const LEECH_PCT: float = 2.2
const LEECH_MAX_PER_PROC: float = 2.5
const LEECH_ICD_SEC: float = 0.35
const KILL_SIPHON_HEAL: float = 1.2
const KILL_SIPHON_ICD_SEC: float = 0.80
const ELITE_HEAL: float = 12.0
const CHEST_HEAL: float = 20.0
const BOSS_HEAL: float = 35.0

# === Global Behavioral Effects & Tradeoffs ===
const GLASS_DMG_MULT: float = 1.62
const GLASS_TAKEN_MULT: float = 1.65
const SNIPER_DMG_MULT: float = 1.42
const SNIPER_SPEED_MULT: float = 1.50
const SNIPER_EXTRA_PIERCE: int = 2
const SHORT_BARRAGE_PROJ: int = 2
const SHORT_BARRAGE_LIFE_MULT: float = 0.52
const GIANT_AOE_RADIUS_MULT: float = 1.55
const GIANT_AOE_CD_MULT: float = 1.35
const TURRET_STILL_RATE: float = 1.75
const TURRET_MOVE_RATE: float = 0.78
const CADENCE_EVERY_N: int = 4
const CADENCE_DMG: float = 24.0
const CADENCE_RADIUS: float = 4.0
const CADENCE_CD_MULT: float = 1.20
const ZOOMIES_SPEED_MULT: float = 1.18
const ZOOMIES_CAST_RATE: float = 1.15
const ZOOMIES_DURATION: float = 1.8
const FLEET_PAWS_MAX_BONUS: float = 0.16
const FLEET_PAWS_RAMP_SEC: float = 2.2
const PRISM_ECHO_DMG_MULT: float = 0.80
const STATIC_SPRINT_DIST: float = 7.5
const STATIC_SPRINT_DMG: float = 14.0
const STRIDE_HONEY_DIST: float = 9.0
const STRIDE_HONEY_DMG: float = 16.0
const STRIDE_HONEY_RADIUS: float = 3.6
const COMET_STRIDE_DIST: float = 13.5
const COMET_STRIDE_DMG_MULT: float = 0.65
const EMBER_CORPSE_DMG: float = 16.0
const EMBER_CORPSE_RADIUS: float = 3.0
const KILL_PROC_ICD_SEC: float = 0.25
const FROST_SHATTER_DMG: float = 16.0
const FROST_SHATTER_RADIUS: float = 3.6
const THORNS_DMG: float = 18.0
const THORNS_RADIUS: float = 3.8
const THORNS_CD: float = 2.0
const AEGIS_DMG: float = 22.0
const AEGIS_RADIUS: float = 4.4
const AEGIS_CD: float = 3.0
const ORBIT_SHIELD_DMG: float = 14.0
const ORBIT_SHIELD_DUR: float = 3.8
const ORBIT_SHIELD_CD: float = 8.5
const CHEAT_DEATH_HEAL_PCT: float = 0.45
const CHEAT_DEATH_INVULN: float = 1.4
const CHEAT_DEATH_CD: float = 105.0
const BURN_DPS_RATIO: float = 0.22
const BURN_DURATION: float = 3.0
const CHILL_DURATION: float = 2.2

# === Loot Drop Formula Constants ===
const BASE_ITEM_DROP: float = 0.018
const BASE_GEM_DROP: float = 0.011
const PITY_GRACE_ITEM: int = 65
const PITY_STEP_ITEM: float = 0.0015
const PITY_GRACE_GEM: int = 95
const PITY_STEP_GEM: float = 0.0012
const ITEM_MIN_INTERVAL: float = 16.0
const ITEM_MIN_INTERVAL_LUCKY: float = 12.5
const GEM_MIN_INTERVAL: float = 24.0
const GEM_MIN_INTERVAL_LUCKY: float = 19.0

static func expected_crit_mult() -> float:
	return 1.0 + (BASE_CRIT_CHANCE * 0.01) * ((BASE_CRIT_MULT * 0.01) - 1.0)
