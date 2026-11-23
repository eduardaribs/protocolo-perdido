extends Control

const COLORS := [Color("#53d5ff"), Color("#90f9ad"), Color("#d1a8ff")]
const TITLES := ["Terminal", "Serviço", "Banco"]
const EXAMPLES := [
	[[0, 1, "Pedido de reserva · 14h", "O Serviço recebe o horário escolhido."]],
	[[1, 2, "O horário das 14h está livre?", "O Serviço consulta o Banco."],
	 [2, 1, "14h está livre", "O Serviço recebe a disponibilidade."],
	 [1, 2, "Gravar reserva das 14h", "Como o horário está livre, o Serviço pede a gravação."]],
	[[1, 2, "Consultar horário das 14h", "O Banco verifica as reservas já registradas."],
	 [2, 1, "14h está ocupado", "O Serviço recebe o aviso e recusa o pedido."]],
	[[0, 1, "1. Investigue os terminais", "Ande pela sala e aperte E para abrir uma pista."],
	 [1, 2, "2. Monte o diagrama", "Escolha a próxima mensagem e veja a seta aparecer."],
	 [2, 1, "3. Teste a reserva", "Compare o resultado para um horário livre e um ocupado."]],
]
const STEP_TIME := 2.9
var station := 0
var playhead := 0.0
var body_font: Font
var title_font: Font

func _process(delta: float) -> void:
	var duration: float = EXAMPLES[station].size() * STEP_TIME
	if playhead >= duration:
		return
	playhead = minf(playhead + delta, duration)
	queue_redraw()

func replay() -> void:
	playhead = 0.0
	queue_redraw()

func _draw() -> void:
	var example: Array = EXAMPLES[station]
	var index := mini(int(playhead / STEP_TIME), example.size() - 1)
	var item: Array = example[index]
	var ratio := clampf((playhead - index * STEP_TIME - 0.3) / 1.0, 0, 1)
	var sender: int = item[0]
	var receiver: int = item[1]
	var tint: Color = COLORS[sender]
	var left := Vector2(139, 67)
	var right := Vector2(size.x - 139, 67)
	var forward := sender < receiver
	var start := left + Vector2(84, 0) if forward else right - Vector2(84, 0)
	var end := right - Vector2(84, 0) if forward else left + Vector2(84, 0)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#10182c"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#564879"), false, 2)
	draw_string(title_font, Vector2(14, 26), "EM AÇÃO  ·  %d/%d" % [index + 1, example.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#ffcc74"))
	draw_node(left, mini(sender, receiver))
	draw_node(right, maxi(sender, receiver))
	draw_line(start, end, tint.darkened(0.45), 3, true)
	var direction := signf(end.x - start.x)
	draw_line(end, end + Vector2(-9 * direction, -6), tint, 2, true)
	draw_line(end, end + Vector2(-9 * direction, 6), tint, 2, true)
	var packet := start.lerp(end, smoothstep(0.0, 1.0, ratio))
	draw_circle(packet, 14, Color(tint, 0.24))
	draw_circle(packet, 7, tint)
	draw_string(body_font, Vector2(14, 114), item[2], HORIZONTAL_ALIGNMENT_CENTER, size.x - 28, 21, tint)
	draw_string(body_font, Vector2(14, 143), item[3], HORIZONTAL_ALIGNMENT_CENTER, size.x - 28, 18, Color("#e4f2ff"))

func draw_node(center: Vector2, id: int) -> void:
	var color: Color = COLORS[id]
	var box := Rect2(center - Vector2(74, 21), Vector2(148, 42))
	draw_rect(box, color.darkened(0.76))
	draw_rect(box, color, false, 2)
	draw_string(title_font, center + Vector2(-74, 8), TITLES[id], HORIZONTAL_ALIGNMENT_CENTER, 148, 25, color)
