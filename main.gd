extends Node2D

const MISSION_VISUAL = preload("res://mission_visual.gd")
const LAB_FINALE = preload("res://lab_finale.gd")
const DIAGRAM = preload("res://sequence_view.gd")
const ORBITAL_MENU = preload("res://orbital_menu.gd")
const GAME_FONT = preload("res://fonts/Oxanium.ttf")
const BODY_FONT = preload("res://fonts/OpenSans-Regular.ttf")
const CAT_SPRITE = preload("res://cat_sprite.gd")
const TERMINAL_LESSON = preload("res://terminal_lesson.gd")
const BRIDGE_ART = preload("res://art/ship_bridge.png")
const SPACE_ARRIVAL = preload("res://space_arrival.gd")
const COMPUTER_SCENE = preload("res://computer_scene.gd")
const HINT_ANIMATION = preload("res://hint_animation.gd")
const READING_CUES := [
	"Linhas de vida: cada coluna representa um participante.",
	"Leia de cima para baixo: a próxima mensagem vem abaixo do pedido.",
	"A seta tracejada representa a resposta à consulta.",
	"A condição [horário livre] autoriza a gravação.",
	"A ponta da seta indica quem recebe o resultado.",
]
const QUESTIONS := [
	"Você escolheu um horário para analisar a água. Para onde o Terminal envia o pedido?",
	"O Serviço recebeu o pedido. O que precisa fazer antes de reservar?",
	"O Banco recebeu a consulta. O que ele deve responder?",
	"O Serviço já sabe se o horário está livre. Quando ele pode gravar?",
	"Como o astronauta descobre o resultado da solicitação?",
]
const ANSWERS := [
	["Enviar o pedido ao Serviço", "Gravar direto no Banco"],
	["Consultar o horário no Banco", "Confirmar sem consultar"],
	["Informar se o horário está livre", "Pedir ao Terminal para consultar"],
	["Gravar apenas se estiver livre", "Gravar mesmo se estiver ocupado"],
	["Enviar o resultado ao Terminal", "Guardar o resultado só no Banco"],
]
const MINT := Color("#7cfbd3")
const AMBER := Color("#ffcc74")
const RED := Color("#ff818c")
const TEXT := Color("#e4f2ff")
const MUTED := Color("#9bb7d0")
const FLOOR := Rect2(49, 116, 926, 425)
const SPEED := 205.0
const STATIONS := [
	{"name": "TERMINAL", "center": Vector2(225, 267), "color": Color("#68caff"),
	 "hint": "Ao solicitar uma reserva, o Terminal envia o horário ao Serviço. A resposta ao usuário vem do Serviço."},
	{"name": "SERVIÇO", "center": Vector2(512, 267), "color": Color("#7cfbd3"),
	 "hint": "O Serviço consulta o Banco e espera a resposta. Só deve gravar uma reserva se o horário estiver livre."},
	{"name": "BANCO DE DADOS", "center": Vector2(803, 267), "color": Color("#b4a0ff"),
	 "hint": "O Banco informa a disponibilidade. Se receber uma ordem de gravação, registra a reserva. O Serviço precisa proteger horários ocupados."},
	{"name": "SIMULADOR", "center": Vector2(512, 451), "color": Color("#ffcc74"),
	 "hint": ""},
]
const MESSAGES := [
	{"sender": 1, "receiver": 2, "text": "Gravar reserva [se livre]"},
	{"sender": 2, "receiver": 1, "text": "Informar disponibilidade"},
	{"sender": 0, "receiver": 1, "text": "Solicitar reserva"},
	{"sender": 1, "receiver": 0, "text": "Responder: confirmada ou recusada"},
	{"sender": 1, "receiver": 2, "text": "Consultar horário"},
	{"sender": 0, "receiver": 2, "text": "Gravar direto no Banco"},
	{"sender": 1, "receiver": 0, "text": "Confirmar sem consultar"},
	{"sender": 2, "receiver": 0, "text": "Pedir ao Terminal para consultar"},
	{"sender": 1, "receiver": 2, "text": "Gravar mesmo se estiver ocupado"},
	{"sender": 1, "receiver": 2, "text": "Guardar o resultado só no Banco"},
]
const EXPECTED := [2, 4, 1, 0, 3]

var menu_ui: Control
var space_view: Node2D
var boarding_ui: Control
var entry_fade: ColorRect
var arrival_action: Callable

var player := Vector2(176, 501)
var visited: Array[int] = []
var sequence: Array[int] = []
var scene_mode := "intro"
var result_color := MUTED
var attempts := 0
var free_pass := false
var occupied_pass := false
var busy := false
var panel: PanelContainer
var content: VBoxContainer
var body_font: Font = BODY_FONT
var display_font := FontVariation.new()
var hint_text := ""
var hearts := 3
var fault_step := -1
var review_passed := false
var prediction_correct := true
var elapsed := 0.0
var walking := false
var direction := 1.0
var tutorial := false
var tutorial_step := 0
var tutorial_done := false
var best_medals := 0
var failed_tests := 0
var reward_text := ""
var reward_until := 0.0
const SAVE_PATH := "user://protocolo_progress.cfg"

func _ready() -> void:
	display_font.base_font = GAME_FONT
	display_font.variation_embolden = 0.0
	space_view = SPACE_ARRIVAL.new()
	add_child(space_view)
	space_view.arrived.connect(finish_arrival)
	space_view.font = GAME_FONT
	var layer := CanvasLayer.new()
	add_child(layer)
	panel = PanelContainer.new()
	panel.position = Vector2(152, 104)
	panel.size = Vector2(720, 432)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0d192b")
	style.border_color = Color("#528fa6")
	style.shadow_color = Color(0, 0, 0, 0.65)
	style.shadow_size = 12
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 26
	style.content_margin_right = 26
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	menu_ui = ORBITAL_MENU.new()
	menu_ui.title_font = GAME_FONT
	menu_ui.body_font = body_font
	menu_ui.play_requested.connect(start_play)
	menu_ui.briefing_requested.connect(show_flight_briefing)
	menu_ui.phases_requested.connect(show_phases)
	menu_ui.rewards_requested.connect(show_rewards)
	layer.add_child(menu_ui)
	menu_ui.hide()
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	panel.add_child(content)
	boarding_ui = Control.new()
	boarding_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(boarding_ui)
	var skip_entry := button("Pular entrada", finish_arrival, boarding_ui)
	skip_entry.position = Vector2(806, 572)
	skip_entry.size.x = 182
	boarding_ui.hide()
	entry_fade = ColorRect.new()
	entry_fade.size = Vector2(1024, 640)
	entry_fade.color = Color("#040a19")
	entry_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry_fade.hide()
	layer.add_child(entry_fade)
	load_progress()
	show_intro()

func _process(delta: float) -> void:
	space_view.visible = scene_mode in ["intro", "boarding", "phases", "rewards"]
	elapsed += delta
	walking = false
	if scene_mode == "room":
		var move := Vector2(
			float(Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right")) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left")),
			float(Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down")) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"))
		)
		walking = not move.is_zero_approx()
		if move.x != 0:
			direction = signf(move.x)
		var next := player + move.normalized() * SPEED * delta
		next = next.clamp(Vector2(78, 228), Vector2(953, 543))
		if not blocked(Vector2(next.x, player.y)):
			player.x = next.x
		if not blocked(Vector2(player.x, next.y)):
			player.y = next.y
	queue_redraw()

var walkable := PackedVector2Array([
	Vector2(111, 224), Vector2(913, 224), Vector2(956, 531),
	Vector2(900, 548), Vector2(128, 548), Vector2(78, 522)
])
const CONSOLE_BOUNDS := [
	Rect2(130, 210, 184, 117),
	Rect2(417, 210, 189, 117),
	Rect2(712, 203, 179, 124),
	Rect2(402, 398, 215, 107),
]

func blocked(position_on_floor: Vector2) -> bool:
	if not Geometry2D.is_point_in_polygon(position_on_floor, walkable):
		return true
	for bounds in CONSOLE_BOUNDS:
		if bounds.has_point(position_on_floor):
			return true
	return false

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_E and scene_mode == "room":
		interact()
	elif event.physical_keycode == KEY_ESCAPE:
		if scene_mode in ["hint", "terminal", "builder", "test_result", "lesson"]:
			show_room()
		elif scene_mode == "room":
			show_pause()

func closest_station() -> int:
	var index := -1
	var distance := 112.0
	for i in STATIONS.size():
		var current := player.distance_to(STATIONS[i].center)
		if current < distance:
			distance = current
			index = i
	return index

func interact() -> void:
	var index := closest_station()
	if index < 0:
		return
	if tutorial:
		handle_tutorial(index)
		return
	if index == 3:
		show_builder()
		return
	show_terminal(index)

func show_terminal(index: int) -> void:
	reset_panel("terminal")
	var accent: Color = STATIONS[index].color
	var style := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color = Color("#0b1726")
	style.border_color = accent
	panel.add_theme_stylebox_override("panel", style)
	paragraph("PISTA %d DE 3  /  %s" % [index + 1, STATIONS[index].name], accent)
	content.get_child(-1).add_theme_font_size_override("font_size", 17)
	heading(["É aqui que o pedido começa", "Consulte antes de reservar", "O Banco informa a disponibilidade"][index])
	var title := content.get_child(-1) as Label
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", accent)
	paragraph([
		"O Terminal recebe o horário escolhido para a análise da água e envia o pedido ao Serviço.",
		"O Serviço consulta o Banco, espera a resposta e decide o que fazer.",
		"O Banco consulta os registros e responde se o horário está livre ou ocupado."
	][index])
	content.get_child(-1).add_theme_font_size_override("font_size", 20)
	var step_label := Label.new()
	step_label.add_theme_font_override("font", body_font)
	step_label.add_theme_font_size_override("font_size", 17)
	step_label.add_theme_color_override("font_color", AMBER)
	content.add_child(step_label)
	var lesson := TERMINAL_LESSON.new()
	lesson.station = index
	lesson.body_font = body_font
	content.add_child(lesson)
	paragraph("", TEXT)
	var cue := content.get_child(-1) as Label
	cue.add_theme_font_size_override("font_size", 20)
	cue.custom_minimum_size.y = 55
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	content.add_child(controls)
	var previous := button("Anterior", lesson.back, controls)
	button("Repetir esta seta", lesson.replay, controls)
	var space := Control.new()
	space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_child(space)
	button("Sair da pista", show_room, controls)
	var next := button("Próxima mensagem →", func():
		if lesson.is_last():
			complete_terminal(index)
		else:
			lesson.advance()
	, controls)
	for state in ["normal", "hover", "pressed"]:
		var primary_style := next.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		primary_style.bg_color = accent.darkened(0.7 if state == "normal" else 0.5)
		primary_style.border_color = accent
		next.add_theme_stylebox_override(state, primary_style)
	next.add_theme_color_override("font_color", TEXT)
	next.custom_minimum_size.x = 245
	var update := func():
		var item: Array = lesson.STEPS[index][lesson.step]
		step_label.text = "ETAPA %d DE %d  ·  %s" % [lesson.step + 1, lesson.STEPS[index].size(), item[3]]
		cue.text = item[4].replace("UML · ", "UML — ")
		previous.disabled = lesson.step == 0
		next.text = "Concluir pista e voltar" if lesson.is_last() else "Próxima mensagem →"
	lesson.step_changed.connect(update)
	update.call()

func complete_terminal(index: int) -> void:
	if index not in visited:
		visited.append(index)
		reward("Pista concluída  %d / 3" % visited.size())
	show_room()

func add_hint_animation(index: int) -> Control:
	var animation := HINT_ANIMATION.new()
	animation.station = index
	animation.body_font = body_font
	animation.title_font = display_font
	animation.custom_minimum_size.y = 158
	content.add_child(animation)
	return animation

func reset_panel(mode: String) -> void:
	scene_mode = mode
	menu_ui.hide()
	var panel_style := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	panel_style.bg_color = Color("#0b1726") if mode == "computer" else Color("#0d192b")
	panel_style.border_color = Color("#58899d") if mode == "computer" else Color("#528fa6")
	panel.add_theme_stylebox_override("panel", panel_style)
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	panel.show()
	if mode == "recap":
		panel.position = Vector2(29, 10)
		panel.size = Vector2(966, 620)
		return
	if mode == "briefing":
		panel.position = Vector2(29, 24)
		panel.size = Vector2(966, 580)
		return
	if mode == "victory":
		panel.position = Vector2(29, 36)
		panel.size = Vector2(966, 568)
		return
	if mode == "terminal":
		panel.position = Vector2(29, 30)
		panel.size = Vector2(966, 560)
		return
	if mode in ["hint", "intro"]:
		panel.position = Vector2(113, 42)
	else:
		panel.position = Vector2(29, 48) if mode in ["builder", "prediction", "simulation", "computer", "briefing", "finale"] else Vector2(148, 125)
	panel.size = Vector2(798, 544) if mode in ["hint", "intro"] else (Vector2(966, 544) if mode in ["builder", "prediction", "simulation", "computer", "briefing", "finale"] else Vector2(728, 390))

func heading(value: String) -> void:
	var label := Label.new()
	label.text = value
	label.add_theme_color_override("font_color", MINT)
	label.add_theme_font_override("font", display_font)
	label.add_theme_font_size_override("font_size", 40)
	content.add_child(label)

func paragraph(value: String, color: Color = TEXT) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_override("font", body_font)
	label.add_theme_font_size_override("font_size", 22)
	content.add_child(label)

func button(value: String, action: Callable, target: Control = content) -> Button:
	var item := Button.new()
	item.text = value
	item.custom_minimum_size.y = 43
	item.add_theme_font_override("font", display_font)
	item.add_theme_font_size_override("font_size", 18)
	item.add_theme_color_override("font_color", TEXT)
	item.add_theme_color_override("font_hover_color", MINT)
	for variant in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#244a60") if variant in ["hover", "pressed"] else Color("#142d40")
		style.border_color = Color("#79e4f3") if variant == "hover" else Color("#456b82")
		style.set_border_width_all(1)
		style.set_corner_radius_all(6)
		style.content_margin_left = 10
		style.content_margin_right = 10
		item.add_theme_stylebox_override(variant, style)
	item.pressed.connect(action)
	target.add_child(item)
	return item

func show_intro() -> void:
	space_view.reset()
	space_view.show()
	scene_mode = "intro"
	panel.hide()
	menu_ui.show()

func show_flight_briefing() -> void:
	reset_panel("hint")
	paragraph("ANTES DE EMBARCAR", AMBER)
	heading("Como jogar")
	paragraph("Sua missão é recuperar o agendamento da câmara que analisa a água da nave. Investigue os terminais, monte as mensagens e teste dois horários.")
	var preview := add_hint_animation(3)
	button("Rever prévia", preview.replay)
	button("Entrar na nave", start_play)
	button("Voltar ao menu", show_intro)

func start_play() -> void:
	begin_arrival(show_mission_story.bind(0))

func show_mission_story(chapter: int = 0) -> void:
	reset_panel("briefing")
	paragraph("TRANSMISSÃO DE BORDO  /  %d DE 3" % (chapter + 1), AMBER)
	var titles := ["A água mantém a nave em operação", "Uma câmara. Um experimento por vez.", "Você cuida dos sistemas de bordo"]
	var descriptions := [
		"A tripulação depende da água reciclada. Antes de liberar um lote, o laboratório precisa analisar uma amostra.",
		"O agendamento parou de responder. Dois pedidos no mesmo horário podem comprometer os experimentos da única câmara de análise.",
		"Investigue os consoles e reconstrua as mensagens do sistema. Confirme horários livres e recuse os ocupados para agendar sua amostra."
	]
	heading(titles[chapter])
	content.get_child(-1).add_theme_font_size_override("font_size", 32)
	paragraph(descriptions[chapter])
	content.get_child(-1).add_theme_font_size_override("font_size", 21)
	var visual := MISSION_VISUAL.new()
	visual.chapter = chapter
	content.add_child(visual)
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 12)
	content.add_child(controls)
	if chapter > 0:
		button("Anterior", show_mission_story.bind(chapter - 1), controls)
	button("Ver objetivos do reparo" if chapter == 2 else "Continuar →", show_learning_briefing if chapter == 2 else show_mission_story.bind(chapter + 1), controls)
	if chapter < 2:
		button("Pular história", show_learning_briefing, controls)
	button("Voltar ao menu", show_intro, controls)
	panel.set_size.call_deferred(Vector2(966, 0))

func show_learning_briefing() -> void:
	reset_panel("briefing")
	paragraph("OBJETIVO EDUCATIVO  /  UML", AMBER)
	heading("Aprenda a ler um diagrama de sequência")
	content.get_child(-1).add_theme_font_size_override("font_size", 29)
	paragraph("Durante o reparo da nave, você vai praticar:")
	paragraph("1. Identificar os participantes, suas linhas de vida e barras de ativação.", MINT)
	paragraph("2. Ler as mensagens e as respostas na ordem em que acontecem.", TEXT)
	paragraph("3. Escolher o caminho do alt conforme o horário esteja livre ou ocupado.", TEXT)
	paragraph("Ao final, você vai explicar uma decisão do protocolo antes de concluir a missão.", MUTED)
	content.get_child(-1).add_theme_font_size_override("font_size", 19)
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 12)
	content.add_child(controls)
	button("Iniciar reparo", start_after_story, controls)
	button("Rever a história", show_mission_story.bind(2), controls)
	panel.set_size.call_deferred(Vector2(966, 0))

func start_after_story() -> void:
	if tutorial_done:
		start_mission()
	else:
		start_tutorial()

func begin_arrival(action: Callable) -> void:
	if scene_mode == "boarding":
		return
	arrival_action = action
	scene_mode = "boarding"
	menu_ui.hide()
	panel.hide()
	boarding_ui.show()
	space_view.show()
	space_view.begin()

func finish_arrival() -> void:
	if scene_mode != "boarding":
		return
	boarding_ui.hide()
	space_view.reset()
	space_view.hide()
	entry_fade.color.a = 1.0
	entry_fade.show()
	arrival_action.call()
	var fade := create_tween()
	fade.tween_property(entry_fade, "color:a", 0.0, 0.55)
	fade.tween_callback(entry_fade.hide)

func show_phases() -> void:
	reset_panel("phases")
	heading("Selecionar fase")
	paragraph("Treinamento  /  Aprenda os controles e envie seu primeiro sinal.", MUTED)
	button("Jogar treinamento" + ("  ✓" if tutorial_done else ""), begin_arrival.bind(start_tutorial))
	paragraph("Fase 01  /  A amostra à espera", AMBER)
	button("Iniciar Fase 01  •  %d / 3 estrelas" % best_medals, begin_arrival.bind(show_mission_story.bind(0)))
	button("Voltar ao menu", show_intro)

func show_rewards() -> void:
	reset_panel("rewards")
	heading("Recompensas")
	paragraph("Treinamento  •  " + ("concluído" if tutorial_done else "pendente"), MINT)
	paragraph("Melhor resultado na Fase 01  •  %d / 3 estrelas" % best_medals, AMBER)
	paragraph("1. Restabelecer o sistema e passar nos dois testes.")
	paragraph("2. Concluir sem falhas na simulação nem erros de previsão.")
	paragraph("3. Concluir sem usar o botão Pedir dica.")
	button("Voltar ao menu", show_intro)

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		tutorial_done = config.get_value("progresso", "tutorial", false)
		best_medals = clampi(int(config.get_value("progresso", "medalhas", 0)), 0, 3)

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progresso", "tutorial", tutorial_done)
	config.set_value("progresso", "medalhas", best_medals)
	config.save(SAVE_PATH)

func start_tutorial() -> void:
	reset_run()
	tutorial = true
	tutorial_step = 0
	show_room()

func handle_tutorial(index: int) -> void:
	if tutorial_step == 0 and index == 0:
		tutorial_step = 1
		reset_panel("lesson")
		heading("Sinal recebido")
		paragraph("Você encontrou o Terminal. É daqui que parte o pedido de reserva. Agora leve o sinal de teste até o Simulador, na parte de baixo da sala.")
		button("Continuar treinamento", show_room)
	elif tutorial_step == 1 and index == 3:
		reset_panel("lesson")
		heading("Envie o sinal de teste")
		paragraph("O Terminal inicia o pedido. Qual direção envia o sinal ao Serviço?")
		button("Terminal → Serviço", finish_tutorial)
		button("Serviço → Terminal", retry_tutorial_signal)
	else:
		reward("Siga a seta amarela até o objetivo do treinamento.")

func retry_tutorial_signal() -> void:
	reset_panel("lesson")
	heading("Direção invertida")
	paragraph("O Terminal inicia o pedido. O Serviço recebe a mensagem e só responde depois.", RED)
	button("Tentar novamente", handle_tutorial.bind(3))

func finish_tutorial() -> void:
	tutorial_done = true
	save_progress()
	reset_panel("tutorial_done")
	paragraph("RECOMPENSA DESBLOQUEADA", AMBER)
	heading("Treinamento concluído")
	paragraph("Você se moveu, interagiu com o Terminal e enviou o sinal na direção certa. Agora o laboratório precisa da sua ajuda.")
	button("Iniciar Fase 01", start_mission)
	button("Selecionar fase", show_phases)

func start_mission() -> void:
	reset_run()
	show_room()

func show_pause() -> void:
	reset_panel("pause")
	heading("Jogo pausado")
	button("Continuar", show_room)
	if tutorial:
		button("Reiniciar treinamento", start_tutorial)
	else:
		button("Reiniciar fase", start_mission)
	button("Selecionar fase", show_phases)
	button("Menu principal", show_intro)

func reward(value: String) -> void:
	reward_text = value
	reward_until = elapsed + 4.0

func show_room() -> void:
	menu_ui.hide()
	space_view.hide()
	scene_mode = "room"
	panel.hide()

func show_builder() -> void:
	reset_panel("builder")
	var step := sequence.size()
	paragraph("SIMULADOR  /  " + ("ETAPA %d DE 5" % (step + 1) if step < 5 else "VALIDAÇÃO"), AMBER)
	heading("Monte o diagrama de sequência" if step < 5 else "Agora teste a reserva")
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	content.add_child(layout)
	add_diagram(layout, free_pass or occupied_pass)
	var choices := VBoxContainer.new()
	choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choices.add_theme_constant_override("separation", 10)
	layout.add_child(choices)
	if step < EXPECTED.size():
		builder_prompt(QUESTIONS[step], choices, TEXT)
		for i in 2:
			var correct := i == step % 2
			var id: int = EXPECTED[step] if correct else EXPECTED.size() + step
			var answer: String = ANSWERS[step][0 if correct else 1]
			var option := button(("A   " if i == 0 else "B   ") + answer, choose_message.bind(id), choices)
			option.custom_minimum_size.y = 52
		builder_prompt(READING_CUES[step] if hint_text.is_empty() else hint_text, choices, MUTED if hint_text.is_empty() else AMBER)
	else:
		builder_prompt("Execute os dois cenários para validar o seu diagrama.", choices, TEXT)
		button("✓ Horário livre aprovado" if free_pass else "Testar horário livre", show_prediction.bind(false), choices).disabled = free_pass
		button("✓ Horário ocupado aprovado" if occupied_pass else "Testar horário ocupado", show_prediction.bind(true), choices).disabled = occupied_pass
		builder_prompt("Antes de cada teste, preveja se o Serviço deve confirmar ou recusar a reserva.", choices, MUTED)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	content.add_child(actions)
	button("Desfazer", undo_message, actions).disabled = sequence.is_empty()
	if step < EXPECTED.size():
		button("Pedir dica  ·  ♥ %d/3" % hearts, request_hint, actions).disabled = hearts == 0 or not hint_text.is_empty()
	button("Reiniciar fase", start_mission, actions)
	button("Voltar à sala", show_room, actions)

func builder_prompt(value: String, target: Control, color: Color) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", body_font)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	target.add_child(label)

func request_hint() -> void:
	var step := sequence.size()
	if hearts == 0 or step >= EXPECTED.size() or not hint_text.is_empty():
		return
	hearts -= 1
	var expected: int = EXPECTED[step]
	if expected in sequence:
		hint_text = "Uma mensagem já foi usada cedo demais. Simule para localizar o erro."
	else:
		hint_text = "Próxima mensagem: " + MESSAGES[expected].text + "."
	show_builder()

func add_diagram(target: Control, branches: bool, focus: int = -1) -> Control:
	var diagram := DIAGRAM.new()
	diagram.custom_minimum_size = Vector2(432, 347)
	diagram.messages.assign(sequence)
	diagram.show_branches = branches
	diagram.branch_focus = focus
	diagram.occupied_path = focus == 1
	diagram.fault_step = fault_step
	diagram.body_font = body_font
	diagram.display_font = display_font
	target.add_child(diagram)
	return diagram

func scenario_layout(mode: String, occupied: bool) -> HBoxContainer:
	reset_panel(mode)
	paragraph("CENÁRIO  /  " + ("HORÁRIO OCUPADO" if occupied else "HORÁRIO LIVRE"), AMBER)
	heading("Preveja a próxima mensagem" if mode == "prediction" else "Acompanhe a simulação")
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	content.add_child(layout)
	return layout

func show_prediction(occupied: bool) -> void:
	var layout := scenario_layout("prediction", occupied)
	add_diagram(layout, evaluate(sequence, occupied).is_empty(), 1 if occupied else 0)
	var options := VBoxContainer.new()
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options.add_theme_constant_override("separation", 10)
	layout.add_child(options)
	builder_prompt("Leia o diagrama a partir da resposta do Banco. Qual mensagem deve aparecer neste cenário?", options, TEXT)
	button("Serviço → Banco  ·  Gravar reserva", run_prediction.bind(occupied, false), options)
	button("Serviço → Terminal  ·  Recusar reserva", run_prediction.bind(occupied, true), options)
	button("Voltar ao simulador", show_builder, options)

func run_prediction(occupied: bool, predicts_rejection: bool) -> void:
	prediction_correct = occupied == predicts_rejection
	simulate(occupied)

func choose_message(id: int) -> void:
	if id in sequence:
		return
	sequence.append(id)
	hint_text = ""
	fault_step = -1
	free_pass = false
	occupied_pass = false
	show_builder()

func undo_message() -> void:
	hint_text = ""
	fault_step = -1
	sequence.pop_back()
	free_pass = false
	occupied_pass = false
	show_builder()

func evaluate(order: Array[int], occupied := false) -> String:
	for i in EXPECTED.size():
		if order[i] == EXPECTED[i]:
			continue
		match order[i]:
			5:
				return "O pedido pulou o Serviço. Sem a verificação, um horário ocupado pode ser reservado duas vezes."
			6:
				return "O Terminal recebeu uma confirmação sem saber se o horário estava livre."
			7:
				return "O Serviço ficou sem a resposta do Banco. Sem ela, não consegue decidir se deve gravar."
			8:
				return "O horário já estava reservado. Gravar de novo criaria uma duplicata." if occupied else "A gravação funcionaria neste horário livre, mas a regra também permitiria gravar em um horário ocupado."
			9:
				return "O resultado ficou no Banco. O Terminal não recebeu confirmação nem recusa."
			0:
				return "O Serviço tentou gravar antes de receber a disponibilidade. A disponibilidade ainda era desconhecida."
			1:
				return "O Banco respondeu antes de receber a consulta correspondente."
			2:
				return "O pedido do Terminal precisa chegar antes das operações do Serviço."
			3:
				return "O Terminal recebeu o resultado antes de o Serviço concluir a decisão."
			4:
				return "O Serviço enviou a consulta sem receber um pedido válido na ordem esperada."
	return ""

func simulate(occupied: bool) -> void:
	if busy or sequence.size() != EXPECTED.size():
		return
	busy = true
	attempts += 1
	result_color = AMBER
	var problem := evaluate(sequence, occupied)
	fault_step = -1
	var layout := scenario_layout("simulation", occupied)
	var diagram := add_diagram(layout, problem.is_empty(), 1 if occupied else 0)
	var status := VBoxContainer.new()
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(status)
	builder_prompt("A seta iluminada mostra a mensagem em execução.", status, TEXT)
	var caption := Label.new()
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_override("font", body_font)
	caption.add_theme_font_size_override("font_size", 22)
	caption.add_theme_color_override("font_color", MINT)
	status.add_child(caption)
	for i in sequence.size():
		var id := sequence[i]
		if occupied and id == 0 and i == 3 and problem.is_empty():
			continue
		var message: Dictionary = MESSAGES[id]
		var pulse_message: String = message.text
		if id == 1:
			pulse_message = "Banco responde: horário ocupado" if occupied else "Banco responde: horário livre"
		elif id == 3 and problem.is_empty():
			pulse_message = "Reserva recusada" if occupied else "Reserva confirmada"
		caption.text = pulse_message
		diagram.active_step = i
		diagram.occupied_path = occupied
		diagram.progress = 0.0
		var tween := create_tween()
		tween.tween_property(diagram, "progress", 1.0, 0.75)
		await tween.finished
		if id != EXPECTED[i]:
			fault_step = i
			break
	await show_computer_sequence(occupied, problem)
	busy = false
	if problem.is_empty() and prediction_correct:
		if occupied:
			occupied_pass = true
		else:
			free_pass = true
	if not problem.is_empty() or not prediction_correct:
		failed_tests += 1
	result_color = MINT if problem.is_empty() else RED
	show_test_result(occupied, problem)

func show_computer_sequence(occupied: bool, problem: String) -> void:
	reset_panel("computer")
	paragraph("TESTE NO COMPUTADOR  /  " + ("HORÁRIO OCUPADO" if occupied else "HORÁRIO LIVRE"), AMBER)
	heading("Executando sua sequência")
	var test_heading := content.get_child(-1) as Label
	test_heading.add_theme_font_size_override("font_size", 42)
	var animation := COMPUTER_SCENE.new()
	animation.body_font = body_font
	animation.failed = not problem.is_empty() or not prediction_correct
	if not problem.is_empty():
		var titles := ["PEDIDO BLOQUEADO", "CONFIRMAÇÃO BLOQUEADA", "RESPOSTA AUSENTE", "RESERVA BLOQUEADA", "RESULTADO NÃO ENTREGUE"]
		var details := ["O pedido precisa passar pelo Serviço.", "Consulte a disponibilidade primeiro.", "O Serviço precisa da resposta do Banco.", "Verifique a condição de gravação.", "Envie o resultado ao Terminal."]
		var index := clampi(fault_step, 0, 4)
		animation.screen_title = titles[index]
		animation.screen_detail = details[index]
	elif not prediction_correct:
		animation.screen_title = "PREVISÃO INCORRETA"
		animation.screen_detail = "O horário ocupado exige recusa." if occupied else "O horário livre permite gravar."
	else:
		animation.screen_title = "RESERVA RECUSADA" if occupied else "RESERVA CONFIRMADA"
		animation.screen_detail = "Horário ocupado. Nenhum registro novo." if occupied else "Horário livre. Reserva gravada."
	var actions := HBoxContainer.new()
	# Connect before adding the animation, because _ready starts the tween.
	var continue_button := button("Aguarde o computador…", func(): pass, actions)
	continue_button.disabled = true
	animation.finished.connect(func():
		continue_button.text = "Ver resultado e corrigir" if animation.failed else "Ver resultado do teste"
		continue_button.disabled = false
	)
	content.add_child(animation)
	content.add_child(actions)
	var skip := button("Pular animação", animation.skip_to_result, actions)
	animation.finished.connect(func(): skip.disabled = true)
	var explanation := Label.new()
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_theme_font_override("font", body_font)
	explanation.add_theme_font_size_override("font_size", 20)
	explanation.add_theme_color_override("font_color", RED if animation.failed else MINT)
	explanation.text = problem if not problem.is_empty() else ("O alt executou [horário ocupado]: recusar." if occupied else "O alt executou [horário livre]: gravar e confirmar.")
	if problem.is_empty() and not prediction_correct:
		explanation.text = "A sequência está montada, mas a previsão seguiu a condição errada do alt. Reveja [horário ocupado]." if occupied else "A sequência está montada, mas a previsão seguiu a condição errada do alt. Reveja [horário livre]."
	explanation.hide()
	content.add_child(explanation)
	animation.finished.connect(func():
		explanation.show()
		test_heading.text = ("Revise sua previsão" if problem.is_empty() else "Revise sua sequência") if animation.failed else "Teste executado"
	)
	# Return when the player explicitly opens the result. No state changes occur
	# during the animation, so skipping it cannot alter scores or scenario passes.
	await continue_button.pressed

func show_test_result(occupied: bool, problem: String) -> void:
	if problem.is_empty() and not prediction_correct:
		reset_panel("test_result")
		heading("Reveja sua previsão")
		paragraph("O horário está ocupado. O Serviço deve recusar a reserva." if occupied else "O horário está livre. O Serviço pode pedir a gravação ao Banco.", AMBER)
		paragraph("No fragmento alt, a condição do horário determina qual mensagem será executada. Faça uma nova previsão para aprovar este cenário.")
		button("Tentar a previsão novamente", show_prediction.bind(occupied))
		button("Ver diagrama", show_builder)
		return
	if free_pass and occupied_pass:
		show_review_question()
		return
	reset_panel("test_result")
	heading("1 de 2 testes aprovados" if problem.is_empty() else "Falha na simulação")
	if problem.is_empty():
		paragraph("Reserva duplicada recusada. Nenhuma gravação foi enviada." if occupied else "Horário disponível. A reserva da câmara foi gravada e confirmada.", MINT)
	else:
		paragraph("Passo %d  ·  %s" % [fault_step + 1, MESSAGES[sequence[fault_step]].text], AMBER)
		paragraph(problem, RED)
		paragraph("Resultado: a simulação parou antes de validar a reserva.", MUTED)
	if problem.is_empty():
		var pending := "horário livre" if occupied else "horário ocupado"
		paragraph("Falta testar o " + pending + " para concluir a fase.", AMBER)
		if not prediction_correct:
			paragraph("Sua previsão foi diferente do que o sistema fez.", AMBER)
		button("Testar " + pending, show_prediction.bind(not occupied))
	else:
		button("Corrigir a partir do erro", repair_sequence)
		button("Ver diagrama com erro", show_builder)
	button("Voltar para a sala", show_room)

func show_review_question() -> void:
	if not (free_pass and occupied_pass):
		return
	if review_passed:
		show_lab_finale()
		return
	reset_panel("briefing")
	paragraph("DESAFIO DE COMPREENSÃO  /  DIAGRAMA DE SEQUÊNCIA", AMBER)
	heading("Por que esperar a resposta do Banco?")
	content.get_child(-1).add_theme_font_size_override("font_size", 30)
	paragraph("O Serviço enviou uma consulta sobre o horário da câmara. Por que precisa receber a resposta antes de decidir?")
	button("A · Para gravar somente depois de saber que o horário está livre.", answer_review.bind(true))
	button("B · Porque o Banco escolhe qual horário o astronauta deve solicitar.", answer_review.bind(false))
	button("C · Para confirmar a reserva antes de verificar a disponibilidade.", answer_review.bind(false))
	paragraph("Explique a lógica do protocolo. Esta pergunta não gasta corações.", MUTED)
	content.get_child(-1).add_theme_font_size_override("font_size", 18)
	panel.set_size.call_deferred(Vector2(966, 0))

func answer_review(correct: bool) -> void:
	if not (free_pass and occupied_pass):
		return
	review_passed = correct
	reset_panel("briefing")
	paragraph("COMPREENSÃO DO PROTOCOLO", AMBER)
	heading("Você entendeu a decisão" if correct else "Vamos olhar essa decisão")
	content.get_child(-1).add_theme_font_size_override("font_size", 32)
	paragraph("O Serviço só sabe se pode gravar depois de receber a disponibilidade do Banco. Essa resposta determina qual condição do alt é verdadeira.", MINT if correct else AMBER)
	paragraph("Se o horário estiver livre, grava e confirma. Se estiver ocupado, recusa o pedido. Confirmar antes da resposta pode criar uma reserva indevida.")
	button("Acompanhar a análise da amostra" if correct else "Tentar a pergunta novamente", show_lab_finale if correct else show_review_question)
	panel.set_size.call_deferred(Vector2(966, 0))

func show_learning_recap() -> void:
	if not (free_pass and occupied_pass and review_passed):
		return
	reset_panel("recap")
	paragraph("O QUE VOCÊ PRATICOU  /  UML", AMBER)
	content.get_child(-1).add_theme_font_size_override("font_size", 17)
	heading("Você construiu um diagrama de sequência")
	content.get_child(-1).add_theme_font_size_override("font_size", 28)
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	content.add_child(layout)
	var diagram := add_diagram(layout, true, 0)
	var concepts := VBoxContainer.new()
	concepts.add_theme_constant_override("separation", 7)
	concepts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(concepts)
	for item in [
		["Linhas de vida", "Identificam Terminal, Serviço e Banco."],
		["Mensagens e respostas", "Leia de cima para baixo. A resposta usa seta tracejada."],
		["Barras de ativação", "Mostram períodos de execução nos participantes."],
		["Fragmento alt", "A condição seleciona apenas um dos caminhos."]
	]:
		builder_prompt(item[0], concepts, MINT)
		builder_prompt(item[1], concepts, TEXT)
		concepts.get_child(-1).add_theme_font_size_override("font_size", 17)
	var paths := HBoxContainer.new()
	paths.add_theme_constant_override("separation", 8)
	concepts.add_child(paths)
	button("Ver horário livre", func(): diagram.branch_focus = 0, paths)
	button("Ver ocupado", func(): diagram.branch_focus = 1, paths)
	button("Concluir missão e ver estrelas", show_victory)
	panel.set_size.call_deferred(Vector2(966, 0))

func show_lab_finale() -> void:
	if not (free_pass and occupied_pass):
		return
	if not review_passed:
		show_review_question()
		return
	reset_panel("finale")
	paragraph("MISSÃO  /  ANÁLISE DA ÁGUA", AMBER)
	heading("A câmara voltou a funcionar")
	content.get_child(-1).add_theme_font_size_override("font_size", 33)
	paragraph("Os dois testes passaram. Agora acompanhe a análise no horário que você reservou.")
	content.get_child(-1).add_theme_font_size_override("font_size", 20)
	var finale := LAB_FINALE.new()
	finale.body_font = body_font
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 12)
	var finish := button("Aguarde a análise…", show_learning_recap, controls)
	finish.disabled = true
	finale.finished.connect(func():
		finish.text = "Rever o que aprendeu"
		finish.disabled = false
	)
	content.add_child(finale)
	content.add_child(controls)
	var skip := button("Pular animação", finale.skip_to_end, controls)
	finale.finished.connect(func(): skip.disabled = true)

func show_victory() -> void:
	if not (free_pass and occupied_pass and review_passed):
		return
	var flawless := failed_tests == 0
	var no_hints := hearts == 3
	var medals := 1 + int(flawless) + int(no_hints)
	best_medals = maxi(best_medals, medals)
	save_progress()
	reset_panel("victory")
	paragraph("FASE CONCLUÍDA  •  %d / 3 ESTRELAS" % medals, AMBER)
	heading("Água liberada para a tripulação")
	content.get_child(-1).add_theme_font_size_override("font_size", 31)
	var stars := Control.new()
	stars.custom_minimum_size.y = 74
	stars.draw.connect(draw_stars.bind(stars, medals))
	content.add_child(stars)
	paragraph("Você recuperou o agendamento, analisou a amostra e liberou o lote de água da missão.", MINT)
	if not prediction_correct:
		paragraph("A última previsão diferiu do resultado exibido.", AMBER)
	paragraph("★  Dois cenários aprovados", MINT)
	paragraph(("★" if flawless else "☆") + "  Sem falhas ou erros de previsão", MUTED)
	paragraph(("★" if no_hints else "☆") + "  Sem usar o botão Pedir dica", MUTED)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	content.add_child(actions)
	button("Reiniciar fase", start_mission, actions)
	button("Selecionar fase", show_phases, actions)
	button("Menu principal", show_intro, actions)
	panel.set_size.call_deferred(Vector2(966, 0))

func repair_sequence() -> void:
	if fault_step >= 0:
		sequence.resize(fault_step)
	fault_step = -1
	hint_text = ""
	free_pass = false
	occupied_pass = false
	show_builder()

func draw_stars(canvas: Control, count: int) -> void:
	for index in 3:
		var center := Vector2(canvas.size.x / 2 + (index - 1) * 88, 37)
		var points := PackedVector2Array()
		for point in 10:
			var radius := 32.0 if point % 2 == 0 else 15.0
			points.append(center + Vector2.from_angle(-PI / 2 + point * TAU / 10) * radius)
		canvas.draw_colored_polygon(points, Color("#ffc966") if index < count else Color("#292440"))
		points.append(points[0])
		canvas.draw_polyline(points, Color("#ffe9a4") if index < count else Color("#786795"), 2.5, true)

func reset_run() -> void:
	player = Vector2(176, 501)
	visited.clear()
	sequence.clear()
	attempts = 0
	free_pass = false
	occupied_pass = false
	result_color = MUTED
	tutorial = false
	failed_tests = 0
	hint_text = ""
	hearts = 3
	fault_step = -1
	prediction_correct = true
	review_passed = false
	reward_until = 0.0

func _draw() -> void:
	if scene_mode in ["intro", "boarding", "phases", "rewards"]:
		return
	draw_ship_room()
	for i in STATIONS.size():
		draw_station(i)
	draw_character()
	draw_string(display_font, Vector2(47, 49), "PROTOCOLO PERDIDO", HORIZONTAL_ALIGNMENT_LEFT, -1, 33, TEXT)
	draw_string(body_font, Vector2(47, 77), "Nave de pesquisa  /  Sala de operações", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MUTED)
	var status := "TREINAMENTO" if tutorial else "FASE 01   •   PISTAS %d/3" % visited.size()
	var status_width := body_font.get_string_size(status, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	draw_string(body_font, Vector2(976 - status_width, 52), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MINT)
	var instruction := "WASD / setas  ·  Mover      E  ·  Interagir"
	if scene_mode == "room":
		var near := closest_station()
		if near >= 0:
			instruction = "E  ·  Acessar " + STATIONS[near].name
	var objective := "Recupere o agendamento da câmara. Investigue os três consoles."
	if tutorial:
		objective = "Vá até o Terminal e aperte E." if tutorial_step == 0 else "Vá até o Simulador e aperte E."
	elif visited.size() == 3:
		objective = "Monte o protocolo no Simulador e valide os dois horários."
	if scene_mode == "room":
		draw_string(body_font, Vector2(48, 574), objective, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, AMBER)
		if elapsed < reward_until:
			draw_string(body_font, Vector2(48, 621), reward_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MINT)
	draw_string(body_font, Vector2(48, 601), instruction, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, TEXT)

func draw_ship_room() -> void:
	draw_rect(Rect2(0, 0, 1024, 640), Color("#050c19"))
	draw_texture_rect(BRIDGE_ART, Rect2(0, 64, 1024, 576), false)
	# Keep the HUD on a dark surface while the illustrated bridge fills the scene.
	draw_rect(Rect2(0, 0, 1024, 89), Color("#08111e"))
	draw_line(Vector2(0, 89), Vector2(1024, 89), Color("#365565"), 1)
	draw_rect(Rect2(0, 558, 1024, 82), Color(0.02, 0.045, 0.08, 0.95))
	# Subtle motion in the observation window.
	for i in 12:
		var star := Vector2(174 + fposmod(i * 63.7 + elapsed * 1.7, 670), 101 + fposmod(i * 13.7, 61))
		draw_circle(star, 1, Color(0.55, 0.88, 1.0, 0.35 + 0.25 * sin(elapsed + i)))
	if free_pass and occupied_pass:
		draw_rect(Rect2(48, 480, 5, 61), MINT)
		draw_rect(Rect2(106, 480, 5, 61), MINT)
		draw_circle(Vector2(82, 474), 4, MINT)

func draw_station(index: int) -> void:
	var station: Dictionary = STATIONS[index]
	var center: Vector2 = station.center
	var color: Color = station.color
	if index == 3 and result_color != MUTED:
		color = result_color
	var nearby := index == closest_station() and scene_mode == "room"
	var bounds: Rect2 = CONSOLE_BOUNDS[index]
	# Labels identify the painted consoles without drawing replacement computers.
	var label: String = station.name + ("  ✓" if index in visited else "")
	var label_width := body_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	var label_y := bounds.position.y - 11
	if index == 3:
		label_y = bounds.end.y + 21
	draw_rect(Rect2(center.x - label_width / 2 - 9, label_y - 20, label_width + 18, 26), Color(0.025, 0.05, 0.09, 0.94))
	draw_string(body_font, Vector2(center.x - label_width / 2, label_y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
	if scene_mode != "room":
		return
	var target := index == (0 if tutorial_step == 0 else 3) if tutorial else (index < 3 and index not in visited) or (index == 3 and visited.size() == 3)
	if target:
		var arrow := Vector2(center.x, label_y - 29 + sin(elapsed * 3) * 3)
		draw_colored_polygon(PackedVector2Array([arrow + Vector2(-6, -7), arrow + Vector2(6, -7), arrow]), AMBER)
	if nearby:
		var focus := bounds.grow(4)
		var length := 12.0
		for corner in [focus.position, Vector2(focus.end.x, focus.position.y), focus.end, Vector2(focus.position.x, focus.end.y)]:
			var dx := 1.0 if corner.x == focus.position.x else -1.0
			var dy := 1.0 if corner.y == focus.position.y else -1.0
			draw_line(corner, corner + Vector2(length * dx, 0), color, 2, true)
			draw_line(corner, corner + Vector2(0, length * dy), color, 2, true)

func draw_character() -> void:
	var pose := 1 + int(elapsed * 7) % 2 if walking else 0
	var bob := sin(elapsed * 14) * 1.2 if walking else sin(elapsed * 2) * 0.5
	CAT_SPRITE.paint(self, player + Vector2(0, 12 + bob), 71, pose, direction < 0)
