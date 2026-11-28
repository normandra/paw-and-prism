class_name UiLayoutGuard
extends RefCounted

const BOUND_EPS: float = 2.0

static func audit_screen(
	root_ctrl: Control,
	vp_rect: Rect2,
	screen_name: String,
	sibling_overlap_nodes: Array[Control] = []
) -> Array[String]:
	var violations: Array[String] = []
	if root_ctrl == null or not is_instance_valid(root_ctrl):
		return violations
	if not root_ctrl.visible:
		return violations

	var scroll_stack: Array[ScrollContainer] = []
	_walk(root_ctrl, vp_rect, screen_name, scroll_stack, violations)

	# Optional explicit sibling overlap check (e.g., HUD bars, minimap, boss bar, toast feed)
	var active_nodes: Array[Control] = []
	for n in sibling_overlap_nodes:
		if n != null and is_instance_valid(n) and n.visible and n.is_visible_in_tree():
			active_nodes.append(n)
	for i in range(active_nodes.size()):
		var a: Control = active_nodes[i]
		var ar: Rect2 = a.get_global_rect().grow(-2.0)
		if ar.size.x <= 0.0 or ar.size.y <= 0.0:
			continue
		for j in range(i + 1, active_nodes.size()):
			var b: Control = active_nodes[j]
			var br: Rect2 = b.get_global_rect().grow(-2.0)
			if br.size.x <= 0.0 or br.size.y <= 0.0:
				continue
			if ar.intersects(br):
				violations.append("[%s] Sibling overlap: '%s' %s intersects '%s' %s" % [
					screen_name, a.name, _fmt_rect(a.get_global_rect()), b.name, _fmt_rect(b.get_global_rect())
				])

	return violations

static func _walk(
	node: Node,
	vp_rect: Rect2,
	screen_name: String,
	scroll_stack: Array[ScrollContainer],
	violations: Array[String]
) -> void:
	if not (node is Control):
		for ch in node.get_children():
			_walk(ch, vp_rect, screen_name, scroll_stack, violations)
		return

	var ctrl: Control = node as Control
	if not ctrl.visible:
		return
	if ctrl is TouchControls:
		return

	var in_scroll: ScrollContainer = scroll_stack.back() if not scroll_stack.is_empty() else null

	# Skip native internal scrollbars inside ScrollContainer unless testing outer bounds
	var is_internal_sb: bool = (ctrl is VScrollBar or ctrl is HScrollBar) and in_scroll != null
	if not is_internal_sb:
		var gr: Rect2 = ctrl.get_global_rect()
		var cms: Vector2 = ctrl.get_combined_minimum_size()

		if in_scroll == null:
			# Top-level chrome or modal container must fit completely inside viewport
			if gr.position.x < vp_rect.position.x - BOUND_EPS or gr.position.y < vp_rect.position.y - BOUND_EPS or gr.end.x > vp_rect.end.x + BOUND_EPS or gr.end.y > vp_rect.end.y + BOUND_EPS:
				violations.append("[%s] Out of viewport %s: '%s' (%s) rect=%s" % [
					screen_name, _fmt_rect(vp_rect), ctrl.name, _describe(ctrl), _fmt_rect(gr)
				])
			if (ctrl is Container or ctrl is BaseButton or ctrl is Label) and (cms.x > vp_rect.size.x + BOUND_EPS or cms.y > vp_rect.size.y + BOUND_EPS):
				violations.append("[%s] MinSize exceeds viewport %s: '%s' (%s) min=%s" % [
					screen_name, _fmt_rect(vp_rect), ctrl.name, _describe(ctrl), _fmt_vec(cms)
				])
		else:
			# Inside vertical-only ScrollContainer: horizontal overflow is forbidden
			var sr: Rect2 = in_scroll.get_global_rect()
			if cms.x > sr.size.x + BOUND_EPS:
				violations.append("[%s] Scroll content wider than container (%s): '%s' (%s) min_x=%.1f > scroll_w=%.1f" % [
					screen_name, in_scroll.name, ctrl.name, _describe(ctrl), cms.x, sr.size.x
				])
			if gr.size.x > 0.5 and (gr.position.x < sr.position.x - BOUND_EPS or gr.end.x > sr.end.x + BOUND_EPS):
				violations.append("[%s] Scroll child clipped horizontally (%s): '%s' (%s) rect=%s scroll=%s" % [
					screen_name, in_scroll.name, ctrl.name, _describe(ctrl), _fmt_rect(gr), _fmt_rect(sr)
				])

		if ctrl is BaseButton:
			var btn_r: Rect2 = gr
			if btn_r.size.x < 24.0 or btn_r.size.y < 24.0:
				violations.append("[%s] Button too small: '%s' (%s) size=%s" % [
					screen_name, ctrl.name, _describe(ctrl), _fmt_vec(btn_r.size)
				])

	var next_stack: Array[ScrollContainer] = scroll_stack.duplicate()
	if ctrl is ScrollContainer:
		next_stack.append(ctrl as ScrollContainer)

	for ch in ctrl.get_children():
		_walk(ch, vp_rect, screen_name, next_stack, violations)

static func _describe(ctrl: Control) -> String:
	if ctrl is Label:
		return "Label('%s')" % (ctrl as Label).text.left(28)
	if ctrl is Button:
		return "Button('%s')" % (ctrl as Button).text.left(28)
	return ctrl.get_class()

static func _fmt_rect(r: Rect2) -> String:
	return "(%.1f,%.1f %.1fx%.1f)" % [r.position.x, r.position.y, r.size.x, r.size.y]

static func _fmt_vec(v: Vector2) -> String:
	return "(%.1fx%.1f)" % [v.x, v.y]
