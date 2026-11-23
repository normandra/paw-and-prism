class_name WorldPickup
extends Node3D

enum Kind {
	XP,
	HEART,
	DUST,
	ITEM,
	GEM,
	CHEST,
}

var kind: int = Kind.XP
var xp_value: float = 10.0
var heal_value: float = 28.0
var dust_value: int = 8
var item_data: ItemInstance = null
var gem_data: GemInstance = null

var _spin_pivot: Node3D = null
var _vel_y: float = 5.5
var _vel_xz: Vector3 = Vector3.ZERO
var _age: float = 0.0
var _magnetized: bool = false

func setup_xp(p_pos: Vector3, amount: float) -> void:
	kind = Kind.XP
	xp_value = amount
	position = p_pos
	var col: Color = Color(0.32, 0.90, 1.0) if amount < 24.0 else (Color(0.50, 1.0, 0.56) if amount < 80.0 else Color(1.0, 0.78, 0.25))
	_attach_visual("xp", col, 0)
	_launch_pop(2.5)

func setup_heart(p_pos: Vector3, heal: float) -> void:
	kind = Kind.HEART
	heal_value = heal
	position = p_pos
	_attach_visual("heart", Color(1.0, 0.30, 0.45), 0)
	_launch_pop(3.0)

func setup_dust(p_pos: Vector3, amount: int) -> void:
	kind = Kind.DUST
	dust_value = amount
	position = p_pos
	_attach_visual("dust", Color(0.55, 0.92, 1.0), 0)
	_launch_pop(3.2)

func setup_item(p_pos: Vector3, item: ItemInstance) -> void:
	kind = Kind.ITEM
	item_data = item
	position = p_pos
	_attach_visual("item", GameEnums.rarity_color(item.rarity), item.rarity)
	_launch_pop(4.4)

func setup_gem(p_pos: Vector3, gem: GemInstance) -> void:
	kind = Kind.GEM
	gem_data = gem
	position = p_pos
	_attach_visual("gem", GameEnums.gem_color_value(gem.get_gem_color()), 1)
	_launch_pop(4.4)

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
	_vel_xz = Vector3(cos(ang), 0.0, sin(ang)) * randf_range(1.2, strength)
	_vel_y = randf_range(4.2, 6.2)

func get_label_text() -> String:
	if kind == Kind.ITEM and item_data != null:
		return item_data.item_name
	if kind == Kind.GEM and gem_data != null:
		return "%s Gem" % gem_data.get_gem_name()
	if kind == Kind.CHEST:
		return "Acorn Treasure Chest!"
	return ""

func get_label_color() -> Color:
	if kind == Kind.ITEM and item_data != null:
		return GameEnums.rarity_color(item_data.rarity)
	if kind == Kind.GEM and gem_data != null:
		return GameEnums.gem_color_value(gem_data.get_gem_color())
	return Color(1.0, 0.90, 0.35)

func step(delta: float, player_pos: Vector3, pickup_radius: float) -> bool:
	_age += delta
	if _spin_pivot != null:
		_spin_pivot.rotation.y += delta * (2.6 if kind >= Kind.ITEM else 1.8)
		_spin_pivot.position.y = sin(_age * 3.5) * 0.09

	# Bouncy drop arc
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

	# Auto-magnet for XP, Hearts, and Prism Dust
	if kind == Kind.XP or kind == Kind.HEART or kind == Kind.DUST:
		if dist_sq <= pickup_radius * pickup_radius:
			_magnetized = true
		if _magnetized:
			var dist: float = sqrt(maxf(0.0001, dist_sq))
			var dir: Vector3 = Vector3(dx / dist, 0.0, dz / dist)
			global_position += dir * 18.5 * delta
			if dist < 1.05:
				return true
	else:
		# Items, Gems, and Chests collect cleanly when stepped near
		var touch_r: float = 2.0 if kind == Kind.CHEST else 1.75
		if dist_sq <= touch_r * touch_r and _age > 0.28:
			return true

	return false
