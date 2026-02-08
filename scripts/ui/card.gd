extends Control
class_name Card

## Componente de carta individual mejorado
## Muestra la información visual de una carta con efectos y animaciones

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
@onready var glow_particles: CPUParticles2D = $GlowParticles

# Datos de la carta
var card_data: Dictionary = {}
var card_id: String = ""
var is_hovered: bool = false

# Tweens para animaciones suaves
var hover_tween: Tween
var particle_tween: Tween

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
	
	# Configurar partículas según rareza (se actualizará con los datos)
	glow_particles.emitting = false

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
	var card_type = card_data.get("card_type", "Character")
	type_label.text = card_type
	
	# Poder
	var power = card_data.get("power", 0)
	if power > 0:
		power_label.text = str(power)
		power_label.visible = true
	else:
		power_label.visible = false
	
	# Rareza
	var rarity = card_data.get("rarity", "C")
	rarity_label.text = _get_rarity_display(rarity)
	
	# Color (tomar el primero si hay múltiples)
	var colors = card_data.get("color", [])
	if colors.size() > 0:
		var color_name = colors[0]
		if color_name in COLOR_MAP:
			color_indicator.color = COLOR_MAP[color_name]
			# Configurar color de partículas según el color de la carta
			glow_particles.color = COLOR_MAP[color_name]
	
	# Configurar partículas según rareza
	_configure_particles_by_rarity(rarity)
	
	# TODO: Cargar imagen desde URL o caché
	_load_card_image()

## Obtener texto de rareza más amigable
func _get_rarity_display(rarity: String) -> String:
	match rarity:
		"C": return "C"
		"UC": return "UC"
		"R": return "R ⭐"
		"SR": return "SR ⭐⭐"
		"SEC": return "SEC 💎"
		"L": return "L 👑"
		_: return rarity

## Configurar partículas según la rareza
func _configure_particles_by_rarity(rarity: String) -> void:
	match rarity:
		"SR", "SEC", "L":
			glow_particles.amount = 30
			glow_particles.lifetime = 2.0
		"R":
			glow_particles.amount = 15
			glow_particles.lifetime = 1.5
		_:
			glow_particles.amount = 10
			glow_particles.lifetime = 1.0

## Cargar la imagen de la carta
func _load_card_image() -> void:
	var image_url = card_data.get("image", "")
	if image_url.is_empty():
		return
	
	# Por ahora, solo mostramos el placeholder
	# En Fase 2 implementaremos la descarga real
	image_placeholder.visible = true

## Efecto hover con animación suave
func _on_mouse_entered() -> void:
	is_hovered = true
	_animate_hover_in()
	card_hovered.emit(self)

func _on_mouse_exited() -> void:
	is_hovered = false
	_animate_hover_out()
	card_unhovered.emit(self)

## Animación de entrada del hover
func _animate_hover_in() -> void:
	# Cancelar tween anterior si existe
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Escalar
	hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	
	# Elevar z-index
	z_index = 10
	
	# Mostrar efecto de hover
	hover_effect.visible = true
	hover_tween.tween_property(hover_effect, "modulate:a", 0.2, 0.2)
	
	# Activar partículas para cartas raras
	var rarity = card_data.get("rarity", "C")
	if rarity in ["R", "SR", "SEC", "L"]:
		glow_particles.emitting = true

## Animación de salida del hover
func _animate_hover_out() -> void:
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Volver a escala normal
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.15)
	
	# Resetear z-index
	z_index = 0
	
	# Ocultar efecto
	hover_tween.tween_property(hover_effect, "modulate:a", 0.0, 0.15)
	await hover_tween.finished
	hover_effect.visible = false
	
	# Desactivar partículas
	glow_particles.emitting = false

## Detectar clicks con feedback visual
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_animate_click()
			card_clicked.emit(self)
			print("Carta clickeada: ", card_name_label.text)

## Animación de click
func _animate_click() -> void:
	var click_tween = create_tween()
	click_tween.set_ease(Tween.EASE_OUT)
	click_tween.set_trans(Tween.TRANS_ELASTIC)
	
	# Efecto de "presión"
	click_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	click_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)

## Obtener datos de la carta
func get_card_data() -> Dictionary:
	return card_data

## Obtener ID de la carta
func get_card_id() -> String:
	return card_id
