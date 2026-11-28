class_name BalanceConfig

# Single source of truth for v3.0 Card-Forging combat, sustain, enemy, add-on, and drop-rate tuning.
# Edit values here, then run: godot --headless --path . --script res://tests/balance_audit.gd

# === Player & Core Combat ===
const BASE_HP_REGEN: float = 0.25
const BASE_CRIT_CHANCE: float = 8.0
const BASE_CRIT_MULT: float = 165.0
const HIT_INVULN_SEC: float = 0.30
const CONTACT_CHECK_RADIUS: float = 0.68
const VOLLEY_REPEAT_MULT: float = 0.30 # Same-volley repeat projectile multiplier

# === Unlimited Deck Focus Cooldown Scaling (sweet spot around 3 well-forged cards) ===
static func compute_deck_cd_mult(active_count: int) -> float:
	if active_count <= 1:
		return 1.00
	if active_count == 2:
		return 1.12
	if active_count == 3:
		return 1.25
	return 1.25 + 0.35 * float(active_count - 3)

# === Enemy Status & Knockback Scaling ===
const ENEMY_CHILL_SPEED_MULT: float = 0.74
const ENEMY_KNOCKBACK_REGULAR: float = 0.38
const ENEMY_KNOCKBACK_ELITE: float = 0.15
const ELITE_HP_MULT: float = 3.8
const ELITE_DMG_MULT: float = 1.45
const ELITE_SPEED_MULT: float = 1.16

# === Sustain Caps ===
const LEECH_PCT_FIRST: float = 2.2
const LEECH_PCT_STACK: float = 1.2
const LEECH_MAX_PER_PROC: float = 2.5
const LEECH_ICD_SEC: float = 0.35
const ELITE_HEAL: float = 12.0
const CHEST_HEAL: float = 20.0
const BOSS_HEAL: float = 35.0

# === Add-on Card Stacking & Tradeoff Constants ===
const MAX_FORK_GENERATIONS: int = 2
const GLASS_CARD_DMG_BONUS: float = 0.52 # Per stack on card: dmg *= (1.0 + 0.52 * k)
const GLASS_TAKEN_BONUS: float = 0.35    # Per total stack in deck: taken *= min(2.40, 1.0 + 0.35 * total)
const GLASS_TAKEN_CAP: float = 2.40
const SNIPER_DMG_FIRST: float = 1.42
const SNIPER_DMG_STACK: float = 1.25
const SNIPER_SPEED_MULT: float = 1.50
const SNIPER_EXTRA_PIERCE: int = 2
const SHORT_BARRAGE_PROJ: int = 2
const SHORT_BARRAGE_LIFE_MULT: float = 0.52
const GIANT_AOE_RADIUS_STEP: float = 0.45
const TURRET_STILL_FIRST: float = 1.65
const TURRET_STILL_STACK: float = 0.25
const TURRET_MOVE_RATE: float = 0.80
const CADENCE_EVERY_N: int = 4
const CADENCE_DMG: float = 24.0
const CADENCE_DMG_STACK: float = 10.0
const CADENCE_RADIUS: float = 4.0
const CADENCE_CD_MULT: float = 1.20
const ZOOMIES_SPEED_MULT: float = 1.18
const ZOOMIES_SPEED_STACK: float = 0.06
const ZOOMIES_CAST_RATE: float = 1.15
const ZOOMIES_CAST_STACK: float = 0.05
const ZOOMIES_DURATION: float = 1.8
const EMBER_CORPSE_DMG: float = 16.0
const EMBER_CORPSE_STACK: float = 6.0
const EMBER_CORPSE_RADIUS: float = 3.0
const KILL_PROC_ICD_SEC: float = 0.25
const FROST_SHATTER_DMG: float = 16.0
const FROST_SHATTER_STACK: float = 6.0
const FROST_SHATTER_RADIUS: float = 3.6
const THORNS_DMG: float = 18.0
const THORNS_STACK: float = 8.0
const THORNS_RADIUS: float = 3.8
const THORNS_CD: float = 2.0
const ORBIT_SHIELD_DMG: float = 14.0
const ORBIT_SHIELD_STACK: float = 5.0
const ORBIT_SHIELD_DUR: float = 3.8
const ORBIT_SHIELD_CD: float = 8.5
const CHEAT_DEATH_HEAL_PCT: float = 0.45
const CHEAT_DEATH_INVULN: float = 1.4
const CHEAT_DEATH_CD: float = 105.0
const CHEAT_DEATH_CD_REDUCTION: float = 20.0
const BURN_DPS_RATIO: float = 0.22
const BURN_DURATION: float = 3.0
const CHILL_DURATION: float = 2.2

# === Card Drop Formula Constants (targets ~3 forged cards + spare inventory by 20m) ===
const BASE_TEMPLATE_DROP: float = 0.016
const BASE_ADDON_DROP: float = 0.020
const PITY_GRACE_TEMPLATE: int = 75
const PITY_STEP_TEMPLATE: float = 0.0014
const PITY_GRACE_ADDON: int = 60
const PITY_STEP_ADDON: float = 0.0016
const TEMPLATE_MIN_INTERVAL: float = 22.0
const ADDON_MIN_INTERVAL: float = 18.0

static func expected_crit_mult() -> float:
	return 1.0 + (BASE_CRIT_CHANCE * 0.01) * ((BASE_CRIT_MULT * 0.01) - 1.0)
