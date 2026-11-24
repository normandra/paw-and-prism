class_name TutorialDirector
extends Node

signal objective_changed(step_idx: int, total_steps: int, short_text: String, highlight_bag: bool)
signal satchel_hint_changed(hint_text: String)
signal banner_requested(text: String, color: Color)
signal tutorial_completed()

enum Step {
	INACTIVE,
	LOOT_ITEM,
	EQUIP_ITEM,
	LOOT_MAIN,
	SOCKET_MAIN,
	KILL_WAVE_1,
	LOOT_MOD,
	SOCKET_MOD,
	KILL_WAVE_2,
	DONE,
}

var current_step: int = Step.INACTIVE
var _stats: HeroStats = null
var _loot_manager: LootManager = null
var _wave_director: WaveDirector = null
var _player_ref: PlayerController = null
var _wave_kills: int = 0

func reset() -> void:
	current_step = Step.INACTIVE
	_wave_kills = 0
	_stats = null
	_loot_manager = null
	_wave_director = null
	_player_ref = null

func is_active() -> bool:
	return current_step != Step.INACTIVE and current_step != Step.DONE

func start(p_stats: HeroStats, p_loot: LootManager, p_wave: WaveDirector, p_player: PlayerController) -> void:
	_stats = p_stats
	_loot_manager = p_loot
	_wave_director = p_wave
	_player_ref = p_player
	_wave_kills = 0
	current_step = Step.LOOT_ITEM

	var origin: Vector3 = _player_ref.global_position if _player_ref != null else Vector3.ZERO
	var wand: ItemInstance = ItemDatabase.create_tutorial_wand()
	_loot_manager.spawn_specific_item(origin + Vector3(0.0, 0.0, -4.2), wand)

	satchel_hint_changed.emit("")
	objective_changed.emit(1, 3, "1/3  Walk to Wand", false)
	banner_requested.emit("Tutorial: Pick up your first Relic!", Color(1.0, 0.88, 0.36))

func notify_item_looted(_item: ItemInstance) -> void:
	if current_step != Step.LOOT_ITEM:
		return
	current_step = Step.EQUIP_ITEM
	satchel_hint_changed.emit("Items tab -> Select Meadow Acorn Wand -> Equip")
	objective_changed.emit(1, 3, "1/3  Equip Wand [Tab]", true)

func notify_gem_looted(gem: GemInstance) -> void:
	if current_step == Step.LOOT_MAIN and gem.get_gem_type() == GameEnums.GemType.MAIN:
		current_step = Step.SOCKET_MAIN
		satchel_hint_changed.emit("Main tab -> Select Acorn Barrage -> Click Green Socket")
		objective_changed.emit(2, 3, "2/3  Socket Ability [Tab]", true)
	elif current_step == Step.LOOT_MOD and gem.get_gem_type() == GameEnums.GemType.MODIFIER:
		current_step = Step.SOCKET_MOD
		satchel_hint_changed.emit("Mods tab -> Select Multi-Shot -> Click Linked Socket")
		objective_changed.emit(3, 3, "3/3  Link Modifier [Tab]", true)

func notify_gear_changed() -> void:
	if _stats == null:
		return
	var origin: Vector3 = _player_ref.global_position if _player_ref != null else Vector3.ZERO
	match current_step:
		Step.EQUIP_ITEM:
			if _stats.equipped.get(GameEnums.EquipSlot.WEAPON, null) != null:
				current_step = Step.LOOT_MAIN
				satchel_hint_changed.emit("")
				var main_gem: GemInstance = GemInstance.new("acorn_barrage")
				_loot_manager.spawn_specific_gem(origin + Vector3(3.6, 0.0, -2.6), main_gem)
				objective_changed.emit(2, 3, "2/3  Pick up Acorn Barrage", false)
				banner_requested.emit("Relic Equipped! Grab your Main Ability!", Color(0.55, 0.96, 0.60))
		Step.SOCKET_MAIN:
			if _stats.active_skill_configs.size() >= 1:
				current_step = Step.KILL_WAVE_1
				_wave_kills = 0
				satchel_hint_changed.emit("")
				_spawn_critter_ring(origin, 3, 7.5, 0.55, 0.35)
				objective_changed.emit(2, 3, "2/3  Defeat Critters (0/3)", false)
				banner_requested.emit("Ability Socketed! Watch it Auto-Cast!", Color(0.55, 0.96, 0.60))
		Step.SOCKET_MOD:
			var has_linked_mod: bool = false
			for cfg in _stats.active_skill_configs:
				if (cfg.get("linked_mod_names", []) as Array).size() >= 1:
					has_linked_mod = true
					break
			if has_linked_mod:
				current_step = Step.KILL_WAVE_2
				_wave_kills = 0
				satchel_hint_changed.emit("")
				_spawn_critter_ring(origin, 5, 8.5, 0.60, 0.35)
				objective_changed.emit(3, 3, "3/3  Test Multi-Shot (0/5)", false)
				banner_requested.emit("Combo Linked! Multi-Shot Active!", Color(1.0, 0.85, 0.35))

func notify_enemy_killed(_enemy: EnemyEntity) -> void:
	var origin: Vector3 = _player_ref.global_position if _player_ref != null else Vector3.ZERO
	match current_step:
		Step.KILL_WAVE_1:
			_wave_kills += 1
			if _wave_kills >= 3:
				current_step = Step.LOOT_MOD
				var mod_gem: GemInstance = GemInstance.new("mod_multishot")
				_loot_manager.spawn_specific_gem(origin + Vector3(-3.4, 0.0, -2.8), mod_gem)
				objective_changed.emit(3, 3, "3/3  Pick up Multi-Shot", false)
				banner_requested.emit("Modifier Dropped! Link it to your Ability!", Color(0.52, 0.94, 1.0))
			else:
				objective_changed.emit(2, 3, "2/3  Defeat Critters (%d/3)" % _wave_kills, false)
		Step.KILL_WAVE_2:
			_wave_kills += 1
			if _wave_kills >= 5:
				current_step = Step.DONE
				satchel_hint_changed.emit("")
				objective_changed.emit(3, 3, "Tutorial Complete!", false)
				tutorial_completed.emit()
			else:
				objective_changed.emit(3, 3, "3/3  Test Multi-Shot (%d/5)" % _wave_kills, false)

func _spawn_critter_ring(center: Vector3, count: int, radius: float, hp_scale: float, dmg_scale: float) -> void:
	if _wave_director == null:
		return
	var bound: float = ArenaBuilder.ARENA_HALF_SIZE - 2.5
	for i in range(count):
		var ang: float = -PI * 0.5 + float(i) * (TAU / float(count))
		var pos: Vector3 = Vector3(
			clampf(center.x + cos(ang) * radius, -bound, bound),
			0.0,
			clampf(center.z + sin(ang) * radius, -bound, bound)
		)
		_wave_director.spawn_custom_enemy("slime_frog", pos, hp_scale, dmg_scale)
