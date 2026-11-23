extends Control
## A short, in-game consequence of the protocol executed by the player.
signal finished
const CAT = preload("res://cat_sprite.gd")
const BAY_ART = preload("res://art/computer_bay.png")

var body_font: Font = ThemeDB.fallback_font
var screen_title := ""
var screen_detail := ""
var failed := false
var phase := 0
var clock := 0.0
var character_x := 160.0
var walking := true
var motion: Tween
const CYAN := Color("#68caff")
const MINT := Color("#7cfbd3")
const RED := Color("#ff818c")

func _ready() -> void:
	custom_minimum_size = Vector2(880, 310)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	motion = create_tween()
	motion.tween_property(self, "character_x", 430.0, 1.5)
	motion.tween_callback(_open_computer)
	motion.tween_interval(0.8)
	motion.tween_callback(_show_result)
	motion.tween_interval(1.2)
	motion.tween_callback(func(): finished.emit())

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _open_computer() -> void:
	walking = false
	phase = 1

func _show_result() -> void:
	phase = 2

func skip_to_result() -> void:
	if phase == 2:
		return
	motion.kill()
	character_x = 430.0
	walking = false
	phase = 2
	finished.emit()

func write(text: String, at: Vector2, width: float, font_size: int, color: Color) -> void:
	draw_string(body_font, at, text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(size.x / 880.0, size.y / 310.0))
	draw_texture_rect(BAY_ART, Rect2(0, 0, 880, 293.33), false)
	var accent := CYAN
	if phase == 2:
		accent = RED if failed else MINT
	var monitor := Rect2(486, 30, 361, 140)
	var pulse := 0.06 + (sin(clock * 4.0) + 1.0) * 0.025
	draw_rect(monitor, Color(accent.r, accent.g, accent.b, pulse))
	draw_rect(monitor, accent.darkened(0.3), false, 1.5)
	# Slow scanline, progress and signal lights are animated over the painted bay.
	var scan_y := 32.0 + fposmod(clock * 20.0, 135.0)
	draw_line(Vector2(488, scan_y), Vector2(845, scan_y), Color(accent.r, accent.g, accent.b, 0.12), 1)
	for y in [45, 145]:
		draw_line(Vector2(477, y), Vector2(477, y + 14), accent, 3)
		draw_line(Vector2(854, y), Vector2(854, y + 14), accent, 3)
	if phase == 0:
		write("CONEXÃO EM ESPERA", Vector2(498, 89), 337, 22, CYAN)
		write("Aproxime-se do console", Vector2(498, 120), 337, 17, Color("#bdcedb"))
	elif phase == 1:
		write("EXECUTANDO PROTOCOLO", Vector2(498, 77), 337, 21, CYAN)
		write("Validando mensagens" + ".".repeat(int(clock * 4) % 4), Vector2(498, 109), 337, 17, Color("#e4f2ff"))
		draw_rect(Rect2(524, 135, 287, 5), Color("#25394b"))
		var signal_x := 524 + fposmod(clock * 220, 249)
		draw_rect(Rect2(signal_x, 135, 38, 5), CYAN)
	else:
		var symbol := Vector2(666, 58)
		draw_circle(symbol, 15, accent.darkened(0.82))
		draw_arc(symbol, 15, 0, TAU, 40, accent, 1.5, true)
		if failed:
			draw_line(symbol - Vector2(5, 5), symbol + Vector2(5, 5), accent, 2, true)
			draw_line(symbol + Vector2(-5, 5), symbol + Vector2(5, -5), accent, 2, true)
		else:
			draw_polyline(PackedVector2Array([symbol + Vector2(-7, 0), symbol + Vector2(-2, 5), symbol + Vector2(7, -5)]), accent, 2, true)
		write(screen_title, Vector2(498, 99), 337, 21, accent)
		write(screen_detail, Vector2(498, 128), 337, 16, Color("#e4f2ff"))
		write("REVISAR SEQUÊNCIA" if failed else "OPERAÇÃO CONCLUÍDA", Vector2(498, 153), 337, 13, accent)
	draw_cat(Vector2(character_x, 235))
	draw_set_transform(Vector2.ZERO, 0, Vector2(size.x / 880.0, size.y / 310.0))
	draw_rect(Rect2(0, 282, 880, 28), Color("#0a1827"))
	var caption := "A astronauta se aproxima do console para testar sua sequência."
	if phase == 1:
		caption = "O computador executa as mensagens do seu diagrama."
	elif phase == 2:
		caption = "O console detectou uma divergência. Confira a explicação abaixo." if failed else "O console concluiu a operação. Confira o resultado abaixo."
	write(caption, Vector2(9, 302), 862, 17, Color("#b8cede"))
	draw_set_transform(Vector2.ZERO)

func draw_cat(at: Vector2) -> void:
	var pose := 1 + int(clock * 7) % 2 if walking else 3
	var bob := sin(clock * 14) * 1.5 if walking else 0.0
	CAT.paint(self, at + Vector2(0, 30 + bob), 106, pose)
