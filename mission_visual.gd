extends Control
const LAB = preload("res://art/water_lab.png")
var chapter := 0
var clock := 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(880, 293)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(size.x / 880.0, size.y / 293.33))
	draw_texture_rect(LAB, Rect2(0, 0, 880, 293.33), false)
	var focus := Rect2(610, 58, 123, 130) if chapter == 0 else Rect2(174, 65, 145, 130)
	var tint := Color("#7cfbd3") if chapter == 0 else Color("#ffcc74")
	draw_rect(focus, Color(tint, 0.07 + 0.03 * sin(clock * 2)))
	draw_rect(focus, tint, false, 2)
	draw_set_transform(Vector2.ZERO)
