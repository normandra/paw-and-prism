extends SceneTree

# Automated Paw & Prism v2.3 Balance Audit System
# Usage: godot --headless --path . --script res://tests/balance_audit.gd

var _failures: Array[String] = []

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)
		push_error("BALANCE FAIL: " + msg)
	else:
		print("OK: " + msg)

func _initialize() -> void:
	call_deferred("_run_audit")

func _single_skill_dps(cfg: Dictionary, cd_rate: float = 1.0, extra_target_hits: int = 1) -> float:
	var dmg: float = float(cfg.get("damage", 20.0)) * BalanceConfig.expected_crit_mult()
	var cd: float = maxf(0.18, float(cfg.get("cooldown", 1.0))) / cd_rate
	var casts: float = 2.0 if bool(cfg.get("echo", false)) else 1.0
	var proj_n: int = maxi(1, int(cfg.get("projectiles", 1)))
	var hit_weight: float = 1.0
	var gid: String = String(cfg.get("gem_id", ""))
	if gid == "starlight_orb":
		var orb_n: int = proj_n + (1 if bool(cfg.get("echo", false)) else 0)
		hit_weight = 1.0 + float(maxi(0, orb_n - 1)) * BalanceConfig.VOLLEY_REPEAT_MULT
		casts = 1.0
	elif gid == "spirit_bees" or gid == "acorn_barrage" or gid == "fireball_berry" or gid == "petal_cyclone" or gid == "frost_nova":
		var hits_on_boss: int = mini(proj_n, maxi(1, extra_target_hits))
		hit_weight = 1.0 + float(maxi(0, hits_on_boss - 1)) * BalanceConfig.VOLLEY_REPEAT_MULT
	var direct_dps: float = (dmg * hit_weight * casts) / cd
	var burn_dps: float = dmg * BalanceConfig.BURN_DPS_RATIO if bool(cfg.get("ignite", false)) else 0.0
	return direct_dps + burn_dps

func _build_single_skill_stats(main_id: String, mod_ids: Array[String], effects: Array[String]) -> Dictionary:
	var st: HeroStats = HeroStats.new("shiba")
	st.init_bare_for_tutorial("shiba")
	var wep: ItemInstance = ItemInstance.new()
	wep.equip_slot = GameEnums.EquipSlot.WEAPON
	wep.effects = effects.duplicate()
	var cols: Array[int] = [GameEnums.GemColor.WHITE, GameEnums.GemColor.WHITE, GameEnums.GemColor.WHITE, GameEnums.GemColor.WHITE]
	var lnks: Array[bool] = [true, true, true]
	wep.setup_sockets(cols, lnks)
	wep.insert_gem(0, GemInstance.new(main_id))
	for i in range(mini(mod_ids.size(), 3)):
		wep.insert_gem(i + 1, GemInstance.new(mod_ids[i]))
	st.equipped[GameEnums.EquipSlot.WEAPON] = wep
	st.recompute()
	return st.active_skill_configs[0]

func _run_audit() -> void:
	print("=== Paw & Prism v2.3 Automated Balance Audit ===")
	print("--- 1. T0 Single-Ability Baseline DPS (crit=x%.3f) ---" % BalanceConfig.expected_crit_mult())

	for gid in GemDatabase.get_ids_by_type(GameEnums.GemType.MAIN):
		var cfg: Dictionary = _build_single_skill_stats(gid, [], [])
		var st_hits: int = 2 if gid == "spirit_bees" else 1
		var dps: float = _single_skill_dps(cfg, 1.0, st_hits)
		print("  %-18s dmg=%4.1f  cd=%.2fs  ST_DPS=%5.1f" % [String(cfg["gem_name"]), float(cfg["damage"]), float(cfg["cooldown"]), dps])
		_check(dps >= 10.0 and dps <= 40.0, "T0 %s ST DPS within [10, 40] (got %.1f)" % [gid, dps])

	print("--- 2. Progression & Maxed Single-Ability Ceiling ---")
	var t1_acorn: Dictionary = _build_single_skill_stats("acorn_barrage", ["mod_pierce"], ["sniper_focus"])
	var t1_dps: float = _single_skill_dps(t1_acorn, 1.0, 1)

	var t2_acorn: Dictionary = _build_single_skill_stats("acorn_barrage", ["mod_pierce", "mod_homing"], ["sniper_focus", "prism_echo"])
	var t2_dps: float = _single_skill_dps(t2_acorn, 1.0, 1)

	var t3_solid: Dictionary = _build_single_skill_stats("acorn_barrage", ["mod_pierce", "mod_homing", "mod_ignite"], ["sniper_focus", "prism_echo"])
	var t3_solid_dps: float = _single_skill_dps(t3_solid, 1.0, 1)

	var max_sniper: Dictionary = _build_single_skill_stats("acorn_barrage", ["mod_pierce", "mod_homing", "mod_ignite"], ["sniper_focus", "glass_spark", "prism_echo", "turret_stance"])
	var max_sniper_still: float = _single_skill_dps(max_sniper, BalanceConfig.TURRET_STILL_RATE, 1)
	var max_sniper_move: float = _single_skill_dps(max_sniper, BalanceConfig.TURRET_MOVE_RATE, 1)

	var max_bees: Dictionary = _build_single_skill_stats("spirit_bees", ["mod_multishot", "mod_homing", "mod_ignite"], ["glass_spark", "prism_echo", "turret_stance"])
	var max_bees_still: float = _single_skill_dps(max_bees, BalanceConfig.TURRET_STILL_RATE, int(max_bees["projectiles"]))
	var max_bees_move: float = _single_skill_dps(max_bees, BalanceConfig.TURRET_MOVE_RATE, int(max_bees["projectiles"]))

	var max_meteor: Dictionary = _build_single_skill_stats("meteor_pine", ["mod_nova_area", "mod_chill", "mod_leech"], ["glass_spark", "prism_echo", "turret_stance"])
	var max_meteor_still: float = _single_skill_dps(max_meteor, BalanceConfig.TURRET_STILL_RATE, 1)

	# Unlinked 5-Main random spam comparison
	var spam_st: HeroStats = HeroStats.new("shiba")
	spam_st.init_bare_for_tutorial("shiba")
	var spam_mains: Array[String] = ["acorn_barrage", "whisker_lightning", "fireball_berry", "honey_slam", "spirit_bees"]
	var slots: Array[int] = [GameEnums.EquipSlot.WEAPON, GameEnums.EquipSlot.HELMET, GameEnums.EquipSlot.ARMOR, GameEnums.EquipSlot.BOOTS, GameEnums.EquipSlot.AMULET]
	for idx in range(5):
		var it: ItemInstance = ItemInstance.new()
		it.equip_slot = slots[idx]
		it.setup_sockets([GameEnums.GemColor.WHITE], [])
		it.insert_gem(0, GemInstance.new(spam_mains[idx]))
		spam_st.equipped[slots[idx]] = it
	spam_st.recompute()
	var spam_total_dps: float = 0.0
	for scfg in spam_st.active_skill_configs:
		var hits_est: int = 2 if String(scfg["gem_id"]) == "spirit_bees" else 1
		spam_total_dps += _single_skill_dps(scfg, 1.0, hits_est)

	print("  T1 Early Acorn Sniper:        ST_DPS=%.1f" % t1_dps)
	print("  T2 Mid Acorn + Crown:         ST_DPS=%.1f" % t2_dps)
	print("  T3 Solid Acorn + Crown:       ST_DPS=%.1f" % t3_solid_dps)
	print("  T3 Max Acorn Sniper:          Still=%.1f  Move=%.1f" % [max_sniper_still, max_sniper_move])
	print("  T3 Max Spirit Bees (%d bees): Still=%.1f  Move=%.1f" % [int(max_bees["projectiles"]), max_bees_still, max_bees_move])
	print("  T3 Max Meteor Pinecone:       Still=%.1f" % max_meteor_still)
	print("  Random 5-Main Unlinked Spam:  Total=%.1f (Focus CD=x%.2f)" % [spam_total_dps, spam_st.multi_skill_cd_mult])

	_check(max_sniper_still > spam_total_dps * 1.4, "Focused Max Acorn beats 5-Main unlinked spam by >1.4x (%.1f vs %.1f)" % [max_sniper_still, spam_total_dps])
	_check(max_bees_still <= 260.0, "Shotgun-dampened Max Bees stays <= 260 DPS (got %.1f)" % max_bees_still)

	print("--- 3. Boss & Elite TTK ---")
	var b1_hp: float = float(EnemyDatabase.get_def("boss_grizzle")["hp"])
	var b2_hp: float = float(EnemyDatabase.get_def("boss_whiskers")["hp"])
	var b3_hp: float = float(EnemyDatabase.get_def("boss_bramblehorn")["hp"])
	var t_b1: float = b1_hp / maxf(1.0, t1_dps)
	var t_b2: float = b2_hp / maxf(1.0, t2_dps)
	var t_b3_max: float = b3_hp / maxf(1.0, max_sniper_still)
	var t_b3_solid: float = b3_hp / maxf(1.0, t3_solid_dps)
	var late_prof: Dictionary = EnemyDatabase.get_wave_profile(1170.0)
	var bandit_hp: float = float(EnemyDatabase.get_def("raccoon_bandit")["hp"]) * float(late_prof["hp_scale"])
	var elite_bandit_hp: float = bandit_hp * BalanceConfig.ELITE_HP_MULT
	var bandit_ttk_solid: float = bandit_hp / maxf(1.0, t3_solid_dps)
	print("  06:30 Grizzle (%.0f HP) @ T1:        %.1fs" % [b1_hp, t_b1])
	print("  13:00 Whiskers (%.0f HP) @ T2:       %.1fs" % [b2_hp, t_b2])
	print("  19:30 Bramblehorn (%.0f HP) @ Max: %.1fs (Solid: %.1fs)" % [b3_hp, t_b3_max, t_b3_solid])
	print("  19:30 Bandit (%.0f HP) / Elite (%.0f HP) @ Solid: %.1fs / %.1fs" % [bandit_hp, elite_bandit_hp, bandit_ttk_solid, elite_bandit_hp / t3_solid_dps])

	_check(t_b1 >= 25.0 and t_b1 <= 55.0, "Boss 1 TTK at T1 within [25s, 55s] (got %.1fs)" % t_b1)
	_check(t_b2 >= 30.0 and t_b2 <= 75.0, "Boss 2 TTK at T2 within [30s, 75s] (got %.1fs)" % t_b2)
	_check(t_b3_max >= 32.0 and t_b3_max <= 65.0, "Boss 3 TTK at Max within [32s, 65s] (got %.1fs)" % t_b3_max)
	_check(bandit_ttk_solid <= 9.0, "Late Bandit TTK at Solid <= 9.0s (got %.1fs)" % bandit_ttk_solid)

	print("--- 4. Lethality (Hits-to-Die) & Sustain Caps ---")
	var m_hp: float = float(HeroDatabase.get_hero("shiba")["base_hp"])
	var late_dmg_scale: float = float(late_prof["dmg_scale"])
	var bandit_dmg: float = float(EnemyDatabase.get_def("raccoon_bandit")["damage"]) * late_dmg_scale
	var boss3_tele: float = float(EnemyDatabase.get_def("boss_bramblehorn")["damage"]) * late_dmg_scale * 1.65
	var hits_bandit: int = int(ceil(m_hp / bandit_dmg))
	var hits_boss3_tele: int = int(ceil(m_hp / boss3_tele))
	var hits_glass_tele: int = int(ceil(m_hp / (boss3_tele * BalanceConfig.GLASS_TAKEN_MULT)))
	var max_sustain_hps: float = BalanceConfig.BASE_HP_REGEN + (BalanceConfig.KILL_SIPHON_HEAL / BalanceConfig.KILL_SIPHON_ICD_SEC) + (BalanceConfig.LEECH_MAX_PER_PROC / BalanceConfig.LEECH_ICD_SEC)
	print("  Mochi HP=%.0f | 19:30 Bandit=%.1f dmg (%d hits) | Boss3 Cross=%.1f (%d hits, Glass %d hit)" % [m_hp, bandit_dmg, hits_bandit, boss3_tele, hits_boss3_tele, hits_glass_tele])
	print("  Max Capped Sustain HP/s: %.2f HP/s (Regen=%.2f + Siphon=%.2f + Leech=%.2f)" % [max_sustain_hps, BalanceConfig.BASE_HP_REGEN, BalanceConfig.KILL_SIPHON_HEAL / BalanceConfig.KILL_SIPHON_ICD_SEC, BalanceConfig.LEECH_MAX_PER_PROC / BalanceConfig.LEECH_ICD_SEC])
	_check(hits_bandit >= 2 and hits_bandit <= 5, "Late regular Bandit kills Mochi in 2-5 hits (got %d)" % hits_bandit)
	_check(hits_boss3_tele == 2 and hits_glass_tele == 1, "Boss 3 telegraph 2-shots standard Mochi and 1-shots Glass (got %d, Glass %d)" % [hits_boss3_tele, hits_glass_tele])

	print("--- 5. Late-Game Speed & 20-Min Drop Budget ---")
	var bear_spd: float = float(HeroDatabase.get_hero("bear")["base_speed"])
	var late_bandit_spd: float = float(EnemyDatabase.get_def("raccoon_bandit")["speed"]) * float(late_prof["speed_scale"])
	print("  Bear Speed=%.1f | 19:30 Bandit Speed=%.2f (%.0f%% of Bear)" % [bear_spd, late_bandit_spd, (late_bandit_spd / bear_spd) * 100.0])
	_check(late_bandit_spd >= bear_spd * 0.90, "Late Bandit >= 90%% of slowest hero speed (%.2f vs %.1f)" % [late_bandit_spd, bear_spd])
	print("  Drop Gates: Item=%.1fs (%.1fs Lucky)  Gem=%.1fs (%.1fs Lucky) | Base=%.2f%% / %.2f%%" % [
		BalanceConfig.ITEM_MIN_INTERVAL, BalanceConfig.ITEM_MIN_INTERVAL_LUCKY,
		BalanceConfig.GEM_MIN_INTERVAL, BalanceConfig.GEM_MIN_INTERVAL_LUCKY,
		BalanceConfig.BASE_ITEM_DROP * 100.0, BalanceConfig.BASE_GEM_DROP * 100.0,
	])

	if _failures.is_empty():
		print("=== BALANCE AUDIT PASSED ===")
		quit(0)
	else:
		print("=== BALANCE AUDIT FAILED (%d checks) ===" % _failures.size())
		quit(1)
