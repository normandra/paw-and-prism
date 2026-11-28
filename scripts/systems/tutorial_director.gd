class_name TutorialDirector
extends Node

signal objective_changed(step_idx: int, total_steps: int, short_text: String, highlight_bag: bool)
signal satchel_hint_changed(hint_text: String)
signal banner_requested(text: String, color: Color)
signal tutorial_completed()

enum Step {
	INACTIVE,
	LOOT_TEMPLATE,
	EQUIP_TEMPLATE,
	KILL_WAVE_1,
	LOOT_ADDON,
	FORGE_ADDON,
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
	current_step = Step.LOOT_TEMPLATE

	var origin: Vector3 = _player_ref.global_position if _player_ref != null else Vector3.ZERO
	var starter_tpl: CardInstance = CardInstance.new("acorn_barrage", GameEnums.Rarity.UNCOMMON)
	_loot_manager.spawn_specific_card(origin + Vector3(0.0, 0.0, -4.2), starter_tpl)

	satchel_hint_changed.emit("")
	objective_changed.emit(1, 3, "1/3  Walk to Acorn Barrage Card", false)
	banner_requested.emit("Tutorial: Pick up your first Template Card!", Color(1.0, 0.88, 0.36))

func notify_card_looted(card: CardInstance) -> void:
	if card == null:
		return
	if current_step == Step.LOOT_TEMPLATE and card.is_template():
		current_step = Step.EQUIP_TEMPLATE
		satchel_hint_changed.emit("Templates tab -> Tap [Equip] on Acorn Barrage")
		objective_changed.emit(1, 3, "1/3  Equip Card in Deck [Tab]", true)
	elif current_step == Step.LOOT_ADDON and card.is_addon():
		current_step = Step.FORGE_ADDON
		satchel_hint_changed.emit("Add-ons tab -> Tap [Forge onto Card] on Multi-Shot -> Forge onto Acorn Barrage")
		objective_changed.emit(3, 3, "3/3  Forge Multi-Shot [Tab]", true)

func notify_deck_changed() -> void:
	if _stats == null:
		return
	var origin: Vector3 = _player_ref.global_position if _player_ref != null else Vector3.ZERO
	match current_step:
		Step.EQUIP_TEMPLATE:
			if _stats.equipped_cards.size() >= 1:
				current_step = Step.KILL_WAVE_1
				_wave_kills = 0
				satchel_hint_changed.emit("")
				_spawn_critter_ring(origin, 3, 7.5, 0.55, 0.35)
				objective_changed.emit(2, 3, "2/3  Defeat Critters (0/3)", false)
				banner_requested.emit("Card Equipped! Watch Acorn Barrage Auto-Cast!", Color(0.55, 0.96, 0.60))
		Step.FORGE_ADDON:
			var has_forged: bool = false
			for card in _stats.equipped_cards:
				if card.get_forge_count() >= 1:
					has_forged = true
					break
			if has_forged:
				current_step = Step.KILL_WAVE_2
				_wave_kills = 0
				satchel_hint_changed.emit("")
				_spawn_critter_ring(origin, 5, 8.5, 0.60, 0.35)
				objective_changed.emit(3, 3, "3/3  Test Forged Combo (0/5)", false)
				banner_requested.emit("Forged! Multi-Shot Permanently Added!", Color(1.0, 0.85, 0.35))

func notify_enemy_killed(_enemy: EnemyEntity) -> void:
	var origin: Vector3 = _player_ref.global_position if _player_ref != null else Vector3.ZERO
	match current_step:
		Step.KILL_WAVE_1:
			_wave_kills += 1
			if _wave_kills >= 3:
				current_step = Step.LOOT_ADDON
				var addon: CardInstance = CardInstance.new("addon_multishot")
				_loot_manager.spawn_specific_card(origin + Vector3(-3.4, 0.0, -2.8), addon)
				objective_changed.emit(2, 3, "2/3  Pick up Multi-Shot Add-on", false)
				banner_requested.emit("Add-on Dropped! Forge it into Acorn Barrage!", Color(0.52, 0.94, 1.0))
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
				objective_changed.emit(3, 3, "3/3  Test Forged Combo (%d/5)" % _wave_kills, false)

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
