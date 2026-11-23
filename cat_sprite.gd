extends RefCounted
const ATLAS = preload("res://art/cat_astronaut.png")
const FRAMES := [
	Rect2(135, 16, 279, 570),
	Rect2(767, 20, 313, 562),
	Rect2(128, 653, 336, 559),
	Rect2(766, 647, 350, 571),
]

static func paint(canvas: CanvasItem, feet: Vector2, height: float, pose: int, flip := false) -> void:
	var frame: Rect2 = FRAMES[clampi(pose, 0, 3)]
	var width := frame.size.x * height / frame.size.y
	var shadow := PackedVector2Array()
	for i in 24:
		shadow.append(feet + Vector2.from_angle(i * TAU / 24.0) * Vector2(width * 0.42, height * 0.05))
	canvas.draw_colored_polygon(shadow, Color(0.015, 0.03, 0.05, 0.65))
	var destination := Rect2(feet - Vector2(width * 0.5, height), Vector2(width, height))
	if flip:
		destination.position.x += width
		destination.size.x = -width
	canvas.draw_texture_rect_region(ATLAS, destination, frame)
