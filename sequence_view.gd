extends Control

var messages: Array[int] = []
var show_branches := false
var fault_step := -1
var active_step := -1
var occupied_path := false
var branch_focus := -1:
	set(value):
		branch_focus = value
		queue_redraw()
var progress := 0.0:
	set(value):
		progress = value
		queue_redraw()
var body_font: Font
var display_font: Font
const COLORS := [Color("#53d5ff"), Color("#90f9ad"), Color("#d1a8ff")]
const LABELS := ["Terminal", "Serviço", "Banco"]
const LINKS := [[1, 2], [2, 1], [0, 1], [1, 0], [1, 2], [0, 2], [1, 0], [2, 0], [1, 2], [1, 2]]
const ACTIONS := ["Grava se livre", "Informa status", "Pede reserva", "Envia resultado", "Consulta horário", "Grava direto", "Confirma sem checar", "Pede nova consulta", "Grava sem condição", "Guarda no Banco"]
const FRAME := Color("#ffcc74")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#10182c"))
	var positions := [68.0, size.x * 0.5, size.x - 68.0]
	for i in 3:
		var at := Vector2(positions[i], 14)
		draw_rect(Rect2(at - Vector2(52, 0), Vector2(104, 40)), COLORS[i].darkened(0.78))
		draw_rect(Rect2(at - Vector2(52, 0), Vector2(104, 40)), COLORS[i], false, 1.0)
		draw_string(display_font, at + Vector2(-52, 29), LABELS[i], HORIZONTAL_ALIGNMENT_CENTER, 104, 23, COLORS[i])
		draw_dashed_line(Vector2(positions[i], 58), Vector2(positions[i], 337 if show_branches else 309), COLORS[i].darkened(0.48), 2, 6)
	var complete := show_branches
	if complete:
		activation(positions[1], 85, 163, COLORS[1])
		activation(positions[2], 118, 151, COLORS[2])
		if branch_focus != 1:
			activation(positions[2], 221, 237, COLORS[2])
	else:
		for row in messages.size():
			var id := messages[row]
			var receiver: int = LINKS[id][1]
			var y := 101.0 + row * 49
			activation(positions[receiver], y, minf(y + 24, 325), COLORS[receiver])
	for row in (3 if complete else 5):
		var y := 77.0 + row * 33.0 if complete else 93.0 + row * 49.0
		draw_string(body_font, Vector2(13, y + 6), "%02d" % (row + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#acb9d0"))
		if row == fault_step:
			draw_rect(Rect2(6, y - 25, size.x - 12, 43), Color("#673547"))
		if row < messages.size():
			var id := messages[row]
			draw_message(positions, LINKS[id][0], LINKS[id][1], y, ACTIONS[id], id == 1, row == active_step)
	if complete:
		draw_alternatives(positions)
	else:
		draw_string(body_font, Vector2(12, 334), "Linhas de vida representam os participantes.", HORIZONTAL_ALIGNMENT_CENTER, size.x - 24, 15, Color("#acb9d0"))

func activation(x: float, top: float, bottom: float, color: Color) -> void:
	draw_rect(Rect2(x - 5, top, 10, bottom - top), color.darkened(0.68))
	draw_rect(Rect2(x - 5, top, 10, bottom - top), color, false, 1)

func draw_alternatives(positions: Array) -> void:
	if branch_focus >= 0:
		var band := Rect2(11, 270, size.x - 22, 66) if branch_focus == 1 else Rect2(11, 192, size.x - 22, 76)
		draw_rect(band, Color("#203e43"))
	if branch_focus != 1:
		activation(positions[1], 192, 253, COLORS[1])
		activation(positions[2], 221, 237, COLORS[2])
	if branch_focus != 0:
		activation(positions[1], 270, 323, COLORS[1])
	draw_rect(Rect2(10, 166, size.x - 20, 171), FRAME, false, 1.5)
	draw_rect(Rect2(10, 166, 42, 25), FRAME)
	draw_string(display_font, Vector2(20, 185), "alt", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#10182c"))
	var free_opacity := 0.22 if branch_focus == 1 else 1.0
	var occupied_opacity := 0.22 if branch_focus == 0 else 1.0
	draw_string(body_font, Vector2(61, 185), "[horário livre]", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(FRAME, free_opacity))
	draw_message(positions, 1, 2, 213, "Grava reserva", false, active_step == 3 and not occupied_path, free_opacity)
	draw_message(positions, 1, 0, 245, "Confirma reserva", true, active_step == 4 and not occupied_path, free_opacity)
	draw_dashed_line(Vector2(10, 269), Vector2(size.x - 10, 269), FRAME, 1, 5)
	draw_string(body_font, Vector2(26, 291), "[horário ocupado]", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(FRAME, occupied_opacity))
	draw_message(positions, 1, 0, 315, "Recusa reserva", true, active_step == 4 and occupied_path, occupied_opacity)

func draw_message(positions: Array, sender: int, receiver: int, y: float, label: String, reply := false, active := false, opacity := 1.0) -> void:
	var color := Color(COLORS[sender], opacity)
	var start := Vector2(positions[sender], y + 8)
	var end := Vector2(positions[receiver], y + 8)
	var direction := signf(end.x - start.x)
	if reply:
		draw_dashed_line(start, end, color, 2, 6)
	else:
		draw_line(start, end, color, 3, true)
	draw_line(end, end + Vector2(-9 * direction, -6), color, 2, true)
	draw_line(end, end + Vector2(-9 * direction, 6), color, 2, true)
	draw_string(body_font, Vector2(minf(start.x, end.x) + 4, y - 3), label, HORIZONTAL_ALIGNMENT_CENTER, absf(end.x - start.x) - 8, 16, color)
	if active:
		var packet := start.lerp(end, progress)
		draw_circle(packet, 10, Color(color, 0.35))
		draw_circle(packet, 5, Color("#fff4c5"))
