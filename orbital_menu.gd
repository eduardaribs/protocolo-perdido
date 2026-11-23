extends Control
signal play_requested
signal briefing_requested
signal phases_requested
signal rewards_requested
const MENU_BUTTON = preload("res://orbital_button.gd")
var title_font: Font
var body_font: Font

func _ready() -> void:
	size = Vector2(1024, 640)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The menu lives directly on the space scene. Only actions have small HUD frames.
	label("ENGENHARIA DE SOFTWARE  /  UML", Vector2(64, 47), Vector2(480, 27), 14, Color("#84acbf"), body_font)
	var title := label("PROTOCOLO\nPERDIDO", Vector2(58, 91), Vector2(510, 137), 57, Color("#dbf8ff"), title_font)
	title.add_theme_color_override("font_shadow_color", Color("#0b5570"))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 3)
	label("Ajude a tripulação.\nReative a análise da água.", Vector2(65, 244), Vector2(450, 58), 20, Color("#b4cfde"), body_font)
	var options := [
		["JOGAR", play_requested, 0],
		["COMO JOGAR", briefing_requested, 1],
		["SELECIONAR FASE", phases_requested, 2],
		["RECOMPENSAS", rewards_requested, 3],
	]
	for i in options.size():
		var action := MENU_BUTTON.new()
		action.text = options[i][0]
		action.ui_font = title_font
		action.add_theme_font_override("font", title_font)
		action.primary = i == 0
		action.symbol = options[i][2]
		action.position = Vector2(64, 319 + i * 59)
		action.size = Vector2(415 if i == 0 else 374, 53 if i == 0 else 45)
		action.pressed.connect(func(): options[i][1].emit())
		add_child(action)
	label("WASD / SETAS  ·  MOVER     E  ·  INTERAGIR", Vector2(65, 589), Vector2(540, 25), 13, Color("#7fa4b9"), title_font)

func label(text: String, at: Vector2, dimensions: Vector2, font_size: int, color: Color, font: Font) -> Label:
	var item := Label.new()
	item.text = text
	item.position = at
	item.size = dimensions
	item.add_theme_font_override("font", font)
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	add_child(item)
	return item
