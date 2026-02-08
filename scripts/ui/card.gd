extends Control
class_name Card

## Componente de carta individual
## Muestra la información visual de una carta del juego

signal card_clicked(card: Card)
signal card_hovered(card: Card)
signal card_unhovered(card: Card)

# Referencias a nodos
@onready var card_name_label: Label = $MarginContainer/VBoxContainer/TopBar/CardName
@onready var cost_label: Label = $MarginContainer/VBoxContainer/TopBar/Cost
@onready var card_image: TextureRect = $MarginContainer/VBoxContainer/CardImage
@onready var image_placeholder: ColorRect = $MarginContainer/VBoxContainer/CardImage/ImagePlaceholder
@onready var type_label: Label = $MarginContainer/VBoxContainer/BottomBar/TypeLabel
@onready var power_label: Label = $MarginContainer/VBoxContainer/BottomBar/PowerLabel
@onready var color_indicator: ColorRect = $MarginContainer/VBoxContainer/ColorIndicator
@onready var rarity_label: Label = $MarginContainer/VBoxContainer/RarityLabel
@onready var hover_effect: Panel = $HoverEffect

# Datos de la carta
var card_data: Dictionary = {}
var card_id: String = ""
var is_hovered: bool = false

# Colores por tipo
const COLOR_MAP = {
	"Red": Color(0.9, 0.2, 0.2),
	"Blue": Color(0.2, 0.4, 0.9),
	"Green": Color(0.2, 0.8, 0.2),
	"Purple": Color(0.6, 0.2, 0.8),
	"Yellow": Color(0.9, 0.8, 0.2),
	"Black": Color(0.2, 0.2, 0.2)
}

func _ready() -> void:
	# Conectar señales de hover
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
	# Mostrar placeholder por defecto
	image_placeholder.visible = true

## Cargar datos de una carta
func set_card_data(data: Dictionary) -> void:
	card_data = data
	card_id = data.get("id", "")
	_update_visuals()

## Actualizar elementos visuales con los datos
func _update_visuals() -> void:
	if card_data.is_empty():
		return
	
	# Nombre
	card_name_label.text = card_data.get("name", "Unknown")
	
	# Coste
	var cost = card_data.get("cost", 0)
	cost_label.text = str(cost)
	
	# Tipo
	type_label.text = card_data.get("card_type", "Character")
	
	# Poder
	var power = card_data.get("power", 0)
	if power > 0:
		power_label.text = str(power)
		power_label.visible = true
	else:
		power_label.visible = false
	
	# Rareza
	rarity_label.text = card_data.get("rarity", "C")
	
	# Color (tomar el primero si hay múltiples)
	var colors = card_data.get("color", [])
	if colors.size() > 0:
		var color_name = colors[0]
		if color_name in COLOR_MAP:
			color_indicator.color = COLOR_MAP[color_name]
	
	# TODO: Cargar imagen desde URL o caché
	_load_card_image()

## Cargar la imagen de la carta
func _load_card_image() -> void:
	var image_url = card_data.get("image", "")
	if image_url.is_empty():
		return
	
	# Por ahora, solo mostramos el placeholder
	# En Fase 2 implementaremos la descarga real
	image_placeholder.visible = true

## Efecto hover
func _on_mouse_entered() -> void:
	is_hovered = true
	hover_effect.visible = true
	scale = Vector2(1.05, 1.05)
	z_index = 10
	card_hovered.emit(self)

func _on_mouse_exited() -> void:
	is_hovered = false
	hover_effect.visible = false
	scale = Vector2.ONE
	z_index = 0
	card_unhovered.emit(self)

## Detectar clicks
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(self)
			print("Carta clickeada: ", card_name_label.text)

## Obtener datos de la carta
func get_card_data() -> Dictionary:
	return card_data

## Obtener ID de la carta
func get_card_id() -> String:
	return card_id
