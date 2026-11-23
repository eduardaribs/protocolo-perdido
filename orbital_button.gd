extends Button
var ui_font: Font
var accent := Color("#77e6f3")
var primary := false
var symbol := 0

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		add_theme_color_override(state, Color.TRANSPARENT)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)

func _draw() -> void:
	var highlighted := is_hovered() or has_focus()
	var tint := accent if highlighted or primary else Color("#91b9ca")
	var middle := size.y * 0.5
	var panel := PackedVector2Array([
		Vector2(41, 3), Vector2(size.x - 14, 3), Vector2(size.x - 3, 14),
		Vector2(size.x - 3, size.y - 12), Vector2(size.x - 15, size.y - 3),
		Vector2(41, size.y - 3), Vector2(31, middle)
	])
	draw_colored_polygon(panel, Color(0.03, 0.16, 0.22, 0.85 if highlighted else 0.58))
	panel.append(panel[0])
	draw_polyline(panel, Color(tint, 0.8 if highlighted else 0.4), 1.5, true)
	draw_line(Vector2(57, size.y - 3), Vector2(139 if primary else 100, size.y - 3), tint, 3, true)
	draw_circle(Vector2(23, middle), 20 if primary else 17, Color("#061824"))
	draw_arc(Vector2(23, middle), 20 if primary else 17, 0, TAU, 48, tint, 1.5, true)
	if symbol == 0:
		draw_colored_polygon(PackedVector2Array([Vector2(19, middle - 7), Vector2(19, middle + 7), Vector2(30, middle)]), tint)
	elif symbol == 1:
		draw_circle(Vector2(23, middle - 5), 2, tint)
		draw_line(Vector2(23, middle), Vector2(23, middle + 7), tint, 2, true)
	elif symbol == 2:
		for i in 3:
			draw_line(Vector2(17, middle - 6 + i * 6), Vector2(30, middle - 6 + i * 6), tint, 2)
	else:
		for i in 3:
			draw_circle(Vector2(17 + i * 6, middle), 2, tint)
	draw_string(ui_font, Vector2(61, middle + 7), text, HORIZONTAL_ALIGNMENT_LEFT, size.x - 80, 23 if primary else 19, Color("#edfaff") if highlighted or primary else Color("#b5d0dd"))
