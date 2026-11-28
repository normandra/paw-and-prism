class_name WorldPickup
extends Node3D

enum Kind {
	TEMPLATE_CARD,
	ADDON_CARD,
	CHEST,
}

var kind: int = Kind.TEMPLATE_CARD
var card_data: CardInstance = null

var _spin_pivot: Node3D = null
var _vel_y: float = 5.5
var _vel_xz: Vector3 = Vector3.ZERO
var _age: float = 0.0

func setup_card(p_pos: Vector3, card: CardInstance) -> void:
	card_data = card
	position = p_pos
	if card.is_template():
		kind = Kind.TEMPLATE_CARD
		_attach_visual("template_card", GameEnums.rarity_color(card.rarity), card.rarity)
	else:
		kind = Kind.ADDON_CARD
		_attach_visual("addon_card", GameEnums.rarity_color(card.rarity), card.rarity)
	_launch_pop(4.0)

func setup_chest(p_pos: Vector3) -> void:
	kind = Kind.CHEST
	position = p_pos
	_attach_visual("chest", Color(1.0, 0.85, 0.25), GameEnums.Rarity.RARE)
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
	if card_data != null:
		if kind == Kind.TEMPLATE_CARD:
			return "[%s Card] %s" % [GameEnums.rarity_label(card_data.rarity), card_data.get_card_name()]
		return "[Add-on] %s" % card_data.get_card_name()
	if kind == Kind.CHEST:
		return "Acorn Chest"
	return ""

func get_label_color() -> Color:
	if card_data != null:
		return GameEnums.rarity_color(card_data.rarity)
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
