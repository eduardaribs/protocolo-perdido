extends Control
signal finished
const LAB = preload("res://art/water_lab.png")
const CAT = preload("res://cat_sprite.gd")
const MINT := Color("#7cfbd3")
const CYAN := Color("#68caff")
const CAPTIONS := [
	"14h · No horário confirmado, a astronauta leva a amostra à câmara.",
	"A amostra entra no equipamento. A câmara atende um experimento por vez.",
	"A análise está em andamento. O próximo pedido deve aguardar outro horário.",
	"Análise concluída · Amostra aprovada nos parâmetros desta missão.",
	"Lote de água liberado para a tripulação. Missão cumprida!",
]
var body_font: Font = ThemeDB.fallback_font
var playhead := 0.0
var completed := false

func _ready() -> void:
	custom_minimum_size = Vector2(880, 310)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if not completed:
		playhead = minf(playhead + delta, 9.0)
		if playhead >= 9.0:
			completed = true
			finished.emit()
	queue_redraw()

func phase() -> int:
	if playhead < 1.5:
		return 0
	if playhead < 2.8:
		return 1
	if playhead < 5.8:
		return 2
	if playhead < 7.3:
		return 3
	return 4

func skip_to_end() -> void:
	if completed:
		return
	playhead = 9.0
	completed = true
	finished.emit()
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(size.x / 880.0, size.y / 310.0))
	draw_texture_rect(LAB, Rect2(0, 0, 880, 293.33), false)
	var stage := phase()
	var approach := clampf(playhead / 1.5, 0, 1)
	var feet := Vector2(lerpf(62, 151, smoothstep(0, 1, approach)), 260)
	var pose := 1 + int(playhead * 7) % 2 if stage == 0 else 3
	CAT.paint(self, feet, 103, pose)
	var vial_position := Vector2(175, 219)
	if stage >= 1:
		var insertion := clampf((playhead - 1.5) / 1.3, 0, 1)
		vial_position = vial_position.lerp(Vector2(247, 164), smoothstep(0, 1, insertion))
	# The sample is an animated item, separate from the laboratory artwork.
	draw_rect(Rect2(vial_position - Vector2(6, 23), Vector2(12, 25)), Color("#ccefff"))
	draw_rect(Rect2(vial_position - Vector2(4, 12), Vector2(8, 12)), CYAN)
	draw_rect(Rect2(vial_position - Vector2(7, 27), Vector2(14, 5)), Color("#ffcc74"))
	var chamber := Rect2(178, 67, 138, 125)
	if stage == 2:
		var scanning := clampf((playhead - 2.8) / 3.0, 0, 1)
		var scan_y := chamber.position.y + scanning * chamber.size.y
		draw_rect(chamber, Color(0.2, 0.8, 1, 0.08))
		draw_rect(Rect2(chamber.position.x, scan_y, chamber.size.x, 5), Color(0.4, 0.9, 1, 0.25))
		draw_line(Vector2(chamber.position.x, scan_y), Vector2(chamber.end.x, scan_y), CYAN, 2)
	if stage >= 3:
		draw_rect(chamber, Color(MINT, 0.06))
		draw_rect(chamber, MINT, false, 2)
		var result := Rect2(435, 119, 73, 21)
		draw_rect(result, Color("#082d29"))
		draw_string(body_font, result.position + Vector2(6, 15), "APROVADA", HORIZONTAL_ALIGNMENT_CENTER, 61, 11, MINT)
	if stage == 4:
		draw_rect(Rect2(615, 66, 114, 118), Color(MINT, 0.08))
		draw_rect(Rect2(615, 66, 114, 118), MINT, false, 2)
		for i in 7:
			var signal_x := 366 + fposmod(playhead * 80 + i * 34, 217)
			draw_circle(Vector2(signal_x, 92), 3, MINT)
	draw_rect(Rect2(0, 282, 880, 28), Color("#0a1827"))
	draw_string(body_font, Vector2(8, 302), CAPTIONS[stage], HORIZONTAL_ALIGNMENT_CENTER, 864, 16, Color("#e4f2ff"))
	draw_set_transform(Vector2.ZERO)
