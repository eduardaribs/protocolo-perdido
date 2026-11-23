extends Control
signal step_changed
const COLORS := [Color("#68caff"), Color("#7cfbd3"), Color("#b4a0ff")]
const NAMES := ["Terminal", "Serviço", "Banco"]
const STEPS := [
	[
		[0, 1, "Pedido de reserva · 14h", "O Terminal envia o horário ao Serviço.", "UML · A mensagem parte de quem solicita. A seta Terminal → Serviço representa o pedido."],
	],
	[
		[1, 2, "Consultar horário · 14h", "O Serviço pergunta se o horário está livre.", "UML · A consulta vem antes da decisão. A barra no Banco indica que ele está processando a consulta."],
		[2, 1, "Resposta · horário livre", "O Banco responde à consulta.", "UML · A resposta tracejada vem depois da consulta. A barra mostra o período de execução no Banco."],
		[1, 2, "Gravar reserva · 14h", "Com o horário livre, o Serviço solicita a gravação.", "UML · Leia as três mensagens de cima para baixo: consultar, receber a resposta e só então gravar."],
	],
	[
		[1, 2, "Consulta recebida · 14h", "O Banco verifica os horários registrados.", "UML · Cada participante tem sua linha de vida. O Banco recebe a consulta do Serviço."],
		[2, 1, "Resposta · horário ocupado", "O Banco informa que já existe uma reserva.", "UML · O Banco informa o estado. Ao receber [horário ocupado], o Serviço deve recusar o pedido."],
	],
]

var station := 0
var body_font: Font = ThemeDB.fallback_font
var step := 0
var progress := 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(880, 212)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	progress = minf(progress + delta / 1.8, 1.0)
	queue_redraw()

func current_step() -> int:
	return step

func is_last() -> bool:
	return step == STEPS[station].size() - 1

func advance() -> void:
	if not is_last():
		step += 1
		replay()
		step_changed.emit()

func back() -> void:
	if step > 0:
		step -= 1
		replay()
		step_changed.emit()

func replay() -> void:
	progress = 0.0
	queue_redraw()

func line(text: String, x: float, y: float, width: float, font_size: int, color: Color) -> void:
	draw_string(body_font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(size.x / 880.0, size.y / 212.0))
	draw_rect(Rect2(0, 0, 880, 212), Color("#07131f"))
	draw_rect(Rect2(0, 0, 880, 212), Color("#365465"), false, 1)
	var examples: Array = STEPS[station]
	var ids := [mini(examples[0][0], examples[0][1]), maxi(examples[0][0], examples[0][1])]
	var positions := [170.0, 710.0]
	for i in 2:
		var color: Color = COLORS[ids[i]]
		draw_rect(Rect2(positions[i] - 99, 12, 198, 42), color.darkened(0.88))
		draw_rect(Rect2(positions[i] - 99, 12, 198, 42), color.darkened(0.25), false, 1.5)
		line(NAMES[ids[i]], positions[i] - 99, 42, 198, 25, color)
		draw_dashed_line(Vector2(positions[i], 58), Vector2(positions[i], 191), color.darkened(0.4), 2, 6)
	# Calls activate their receiver until the visible return, or a short
	# execution segment while that participant is still processing.
	for row in step + 1:
		var item: Array = examples[row]
		var receiver: int = item[1]
		var y := 91.0 + row * 41
		var end_y := y + 22.0
		for later in range(row + 1, step + 1):
			if examples[later][0] == receiver and examples[later][1] == item[0]:
				end_y = 91.0 + later * 41
				break
		var x: float = positions[ids.find(receiver)]
		var tint: Color = COLORS[receiver]
		draw_rect(Rect2(x - 6, y, 12, end_y - y), tint.darkened(0.65))
		draw_rect(Rect2(x - 6, y, 12, end_y - y), tint, false, 1)
	for row in step + 1:
		var item: Array = examples[row]
		var sender: int = item[0]
		var receiver: int = item[1]
		var y := 91.0 + row * 41
		var start := Vector2(positions[ids.find(sender)], y)
		var end := Vector2(positions[ids.find(receiver)], y)
		var tint: Color = COLORS[sender]
		if sender == 2:
			draw_dashed_line(start, end, tint, 2, 7)
		else:
			draw_line(start, end, tint, 2.5, true)
		var direction := signf(end.x - start.x)
		draw_line(end, end + Vector2(-10 * direction, -6), tint, 2, true)
		draw_line(end, end + Vector2(-10 * direction, 6), tint, 2, true)
		line(item[2], 245, y - 8, 390, 18, tint)
		line("%02d" % (row + 1), 26, y + 5, 65, 17, Color("#9bb7d0"))
		if row == step:
			var packet := start.lerp(end, smoothstep(0.0, 1.0, progress))
			draw_circle(packet, 12, Color(tint, 0.17))
			draw_circle(packet, 5, tint)
	line("Leia de cima para baixo. As barras indicam períodos de execução.", 80, 205, 720, 14, Color("#a9becb"))
	draw_set_transform(Vector2.ZERO)
