class_name WorldPickup
extends Node3D

enum Kind {
	ITEM,
	MAIN_ABILITY,
	MODIFIER_ABILITY,
	CHEST,
}

var kind: int = Kind.ITEM
var item_data: ItemInstance = null
var gem_data: GemInstance = null

var _spin_pivot: Node3D = null
var _vel_y: float = 5.5
var _vel_xz: Vector3 = Vector3.ZERO
var _age: float = 0.0

func setup_item(p_pos: Vector3, item: ItemInstance) -> void:
	kind = Kind.ITEM
	item_data = item
	position = p_pos
	_attach_visual("item", GameEnums.rarity_color(item.rarity), item.rarity)
	_launch_pop(4.0)

func setup_main_ability(p_pos: Vector3, gem: GemInstance) -> void:
	kind = Kind.MAIN_ABILITY
	gem_data = gem
	position = p_pos
	_attach_visual("main_gem", GameEnums.gem_color_value(gem.get_gem_color()), 2)
	_launch_pop(4.0)

func setup_modifier_ability(p_pos: Vector3, gem: GemInstance) -> void:
	kind = Kind.MODIFIER_ABILITY
	gem_data = gem
	position = p_pos
	_attach_visual("mod_gem", GameEnums.gem_color_value(gem.get_gem_color()), 1)
	_launch_pop(4.0)

func setup_chest(p_pos: Vector3) -> void:
	kind = Kind.CHEST
	position = p_pos
	_attach_visual("chest", Color(1.0, 0.85, 0.25), 2)
	_vel_y = 0.0
	_vel_xz = Vector3.ZERO

func _attach_visual(vkind: String, col: Color, rarity: int) -> void:
	var vis: Node3D = ChibiMeshFactory.build_loot_mesh(vkind, col, rarity)
	add_child(vis)
	_spin_pivot = vis.get_node_or_null("SpinPivot")

func _launch_pop(strength: float) -> void:
	var ang: float = randf() * TAU
	_vel_xz = Vector3(cos(ang), 0.0, sin(ang)) * randf_range(1.1, strength)
	_vel_y = randf_range(4.2, 6.0)

func get_label_text() -> String:
	if kind == Kind.ITEM and item_data != null:
		return item_data.item_name
	if kind == Kind.MAIN_ABILITY and gem_data != null:
		return "[Main] %s" % gem_data.get_gem_name()
	if kind == Kind.MODIFIER_ABILITY and gem_data != null:
		return "[Mod] %s" % gem_data.get_gem_name()
	if kind == Kind.CHEST:
		return "Acorn Chest"
	return ""

func get_label_color() -> Color:
	if kind == Kind.ITEM and item_data != null:
		return GameEnums.rarity_color(item_data.rarity)
	if (kind == Kind.MAIN_ABILITY or kind == Kind.MODIFIER_ABILITY) and gem_data != null:
		return GameEnums.gem_color_value(gem_data.get_gem_color())
	return Color(1.0, 0.90, 0.35)

func step(delta: float, player_pos: Vector3) -> bool:
	_age += delta
	if _spin_pivot != null:
		_spin_pivot.rotation.y += delta * 2.5
		_spin_pivot.position.y = sin(_age * 3.5) * 0.09

	if global_position.y > 0.0 or _vel_y > 0.0:
		global_position.x += _vel_xz.x * delta
		global_position.z += _vel_xz.z * delta
		global_position.y += _vel_y * delta
		_vel_y -= 18.0 * delta
		if global_position.y <= 0.0:
			global_position.y = 0.0
			_vel_y = 0.0
			_vel_xz = Vector3.ZERO

	var dx: float = player_pos.x - global_position.x
	var dz: float = player_pos.z - global_position.z
	var dist_sq: float = dx * dx + dz * dz
	var touch_r: float = 2.6 if kind != Kind.CHEST else 2.8
	if dist_sq <= touch_r * touch_r and _age > 0.28:
		return true

	return false
