extends Node2D
signal arrived
const SHIP = preload("res://art/research_ship.png")
var clock := 0.0
var zoom := 0.0
var blackout := 0.0
var entering := false
var flight: Tween
var font: Font = ThemeDB.fallback_font

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func begin() -> void:
	if entering:
		return
	entering = true
	flight = create_tween()
	flight.tween_property(self, "zoom", 1.0, 3.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	flight.tween_property(self, "blackout", 1.0, 0.45)
	flight.tween_callback(func(): arrived.emit())

func skip() -> void:
	if not entering:
		return
	flight.kill()
	blackout = 1.0
	arrived.emit()

func reset() -> void:
	if is_instance_valid(flight):
		flight.kill()
	zoom = 0.0
	blackout = 0.0
	entering = false

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1024, 640), Color("#040a19"))
	for i in 110:
		var star := Vector2(fposmod(i * 127.7 + clock * (3 + i % 3), 1024), fposmod(i * 83.3, 640))
		var alpha := 0.45 + 0.3 * sin(clock * 1.3 + i)
		draw_circle(star, 1.1 if i % 4 else 1.8, Color(0.65, 0.83, 1, alpha))
	draw_circle(Vector2(980, 647), 240, Color("#173a58"))
	draw_arc(Vector2(980, 647), 242, PI, TAU, 80, Color("#397d9b"), 5, true)
	draw_arc(Vector2(980, 647), 248, PI, TAU, 80, Color(0.3, 0.8, 1, 0.12), 9, true)
	var origin := Vector2(741, 307 + sin(clock * 0.8) * 5 * (1.0 - zoom))
	var focus := origin.lerp(Vector2(512, 320), zoom)
	var scale_factor := lerpf(1.0, 8.0, zoom)
	draw_set_transform(focus, 0, Vector2.ONE * scale_factor)
	var ship_size := Vector2(SHIP.get_size()) * (512.0 / float(SHIP.get_height()))
	draw_texture_rect(SHIP, Rect2(-ship_size * 0.5, ship_size), false)
	draw_set_transform(Vector2.ZERO)
	if not entering:
		var ring_center := Vector2(741, 313)
		draw_arc(ring_center, 263, -1.4, 1.1, 80, Color(0.25, 0.67, 0.78, 0.15), 1, true)
		draw_arc(ring_center, 252, 1.6, 2.3, 32, Color(0.25, 0.67, 0.78, 0.3), 1, true)
		var beacon := ring_center + Vector2.from_angle(clock * 0.12) * 263
		draw_circle(beacon, 2, Color("#7cfbd3"))
		draw_string(font, Vector2(607, 592), "NAVE DE PESQUISA  /  LABORATÓRIO", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#8bbad1"))
	else:
		draw_rect(Rect2(0, 545, 1024, 95), Color(0.02, 0.04, 0.09, 0.88))
		var caption := "Aproximando da nave…" if zoom < 0.6 else "Entrando na sala de operações…"
		draw_string(font, Vector2(70, 582), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#7cfbd3"))
		draw_rect(Rect2(70, 603, 660, 4), Color("#263f57"))
		draw_rect(Rect2(70, 603, 660 * zoom, 4), Color("#7cfbd3"))
	if blackout > 0:
		draw_rect(Rect2(0, 0, 1024, 640), Color(0.01, 0.025, 0.05, blackout))
