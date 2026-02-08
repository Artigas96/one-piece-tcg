extends Control
class_name CardPreviewModal

## Modal para mostrar una carta en detalle
## Se muestra al hacer click en una carta

signal closed()

# Referencias a nodos
@onready var card_name_label: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/TopBar/CardName
@onready var card_image: TextureRect = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/LeftPanel/CardImageContainer/MarginContainer/CardImage
@onready var image_placeholder: ColorRect = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/LeftPanel/CardImageContainer/MarginContainer/CardImage/ImagePlaceholder
@onready var color_indicator: ColorRect = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/LeftPanel/CardImageContainer/MarginContainer/CardImage/ColorIndicator
@onready var set_info_label: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/LeftPanel/SetInfo

# Stats
@onready var type_value: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/RightPanel/StatsGrid/TypeValue
@onready var color_value: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/RightPanel/StatsGrid/ColorValue
@onready var cost_value: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/RightPanel/StatsGrid/CostValue
@onready var power_value: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/RightPanel/StatsGrid/PowerValue
@onready var counter_value: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/RightPanel/StatsGrid/CounterValue
@onready var rarity_value: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/RightPanel/StatsGrid/RarityValue

# Attributes and Effect
@onready var attributes_value: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/RightPanel/AttributesValue
@onready var effect_text: Label = $CenterContainer/PreviewPanel/MarginContainer/VBoxContainer/ContentHBox/RightPanel/EffectScrollContainer/EffectText

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var preview_panel: PanelContainer = $CenterContainer/PreviewPanel

# Colores por tipo
const COLOR_MAP = {
	"Red": Color(0.9, 0.2, 0.2),
	"Blue": Color(0.2, 0.4, 0.9),
	"Green": Color(0.2, 0.8, 0.2),
	"Purple": Color(0.6, 0.2, 0.8),
	"Yellow": Color(0.9, 0.8, 0.2),
	"Black": Color(0.2, 0.2, 0.2)
}

var card_data: Dictionary = {}

func _ready() -> void:
	# Empezar invisible
	modulate.a = 0
	preview_panel.scale = Vector2(0.8, 0.8)
	
	# Crear animación de entrada
	_create_animations()

## Mostrar el modal con datos de una carta
func show_card(data: Dictionary) -> void:
	card_data = data
	visible = true
	_update_content()
	_animate_in()

## Actualizar todo el contenido del modal
func _update_content() -> void:
	if card_data.is_empty():
		return
	
	# Nombre
	card_name_label.text = card_data.get("name", "Unknown Card")
	
	# Tipo
	type_value.text = card_data.get("card_type", "Character")
	
	# Colores
	var colors = card_data.get("color", [])
	if colors.size() > 0:
		color_value.text = ", ".join(colors)
		var primary_color = colors[0]
		if primary_color in COLOR_MAP:
			color_indicator.color = COLOR_MAP[primary_color]
	else:
		color_value.text = "Sin color"
	
	# Stats
	cost_value.text = str(card_data.get("cost", 0))
	
	var power = card_data.get("power", 0)
	power_value.text = str(power) if power > 0 else "—"
	
	var counter = card_data.get("counter", 0)
	counter_value.text = str(counter) if counter > 0 else "—"
	
	# Rareza con emoji
	var rarity = card_data.get("rarity", "C")
	rarity_value.text = _get_rarity_text(rarity)
	
	# Atributos
	var attributes = card_data.get("attribute", [])
	if attributes.size() > 0:
		if attributes is Array:
			attributes_value.text = ", ".join(attributes)
		else:
			attributes_value.text = str(attributes)
	else:
		attributes_value.text = "Sin atributos"
	
	# Efecto
	var effect = card_data.get("effect", "")
	if effect != "":
		effect_text.text = effect
	else:
		effect_text.text = "Esta carta no tiene efecto especial."
	
	# Set info
	var set_name = card_data.get("set_name", "Unknown Set")
	var set_code = card_data.get("set_code", "???")
	set_info_label.text = "Set: %s - %s" % [set_code, set_name]
	
	# Placeholder de imagen
	image_placeholder.visible = true

## Obtener texto de rareza con emoji
func _get_rarity_text(rarity: String) -> String:
	match rarity:
		"C": return "⭐ Common"
		"UC": return "⭐⭐ Uncommon"
		"R": return "⭐⭐⭐ Rare"
		"SR": return "⭐⭐⭐⭐ Super Rare"
		"SEC": return "💎 Secret Rare"
		"L": return "👑 Leader"
		_: return rarity

## Crear animaciones
func _create_animations() -> void:
	var anim_lib = AnimationLibrary.new()
	
	# Animación de entrada
	var anim_in = Animation.new()
	anim_in.length = 0.3
	
	# Track para modulate.a
	var track_fade = anim_in.add_track(Animation.TYPE_VALUE)
	anim_in.track_set_path(track_fade, ".:modulate:a")
	anim_in.track_insert_key(track_fade, 0.0, 0.0)
	anim_in.track_insert_key(track_fade, 0.3, 1.0)
	anim_in.track_set_interpolation_type(track_fade, Animation.INTERPOLATION_CUBIC)
	
	# Track para escala del panel
	var track_scale = anim_in.add_track(Animation.TYPE_VALUE)
	anim_in.track_set_path(track_scale, "CenterContainer/PreviewPanel:scale")
	anim_in.track_insert_key(track_scale, 0.0, Vector2(0.8, 0.8))
	anim_in.track_insert_key(track_scale, 0.3, Vector2.ONE)
	anim_in.track_set_interpolation_type(track_scale, Animation.INTERPOLATION_CUBIC)
	
	anim_lib.add_animation("fade_in", anim_in)
	
	# Animación de salida
	var anim_out = Animation.new()
	anim_out.length = 0.2
	
	var track_fade_out = anim_out.add_track(Animation.TYPE_VALUE)
	anim_out.track_set_path(track_fade_out, ".:modulate:a")
	anim_out.track_insert_key(track_fade_out, 0.0, 1.0)
	anim_out.track_insert_key(track_fade_out, 0.2, 0.0)
	
	var track_scale_out = anim_out.add_track(Animation.TYPE_VALUE)
	anim_out.track_set_path(track_scale_out, "CenterContainer/PreviewPanel:scale")
	anim_out.track_insert_key(track_scale_out, 0.0, Vector2.ONE)
	anim_out.track_insert_key(track_scale_out, 0.2, Vector2(0.9, 0.9))
	
	anim_lib.add_animation("fade_out", anim_out)
	
	animation_player.add_animation_library("", anim_lib)

## Animar entrada
func _animate_in() -> void:
	animation_player.play("fade_in")

## Animar salida y cerrar
func _animate_out() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	visible = false
	closed.emit()

## Cerrar modal
func close() -> void:
	_animate_out()

## Botón de cerrar
func _on_close_button_pressed() -> void:
	close()

## Click en overlay para cerrar
func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			close()

## Cerrar con ESC
func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
