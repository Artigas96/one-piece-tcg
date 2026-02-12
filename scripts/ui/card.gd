extends Control
class_name Card

## Componente de carta individual corregido para la API apitcg.com

signal card_clicked(card: Card)
signal card_hovered(card: Card)
signal card_unhovered(card: Card)

@onready var card_name_label: Label        = $MarginContainer/VBoxContainer/TopBar/CardName
@onready var cost_label:      Label        = $MarginContainer/VBoxContainer/TopBar/Cost
@onready var card_image:      TextureRect  = $MarginContainer/VBoxContainer/CardImage
@onready var image_placeholder: ColorRect  = $MarginContainer/VBoxContainer/CardImage/ImagePlaceholder
@onready var type_label:      Label        = $MarginContainer/VBoxContainer/BottomBar/TypeLabel
@onready var power_label:     Label        = $MarginContainer/VBoxContainer/BottomBar/PowerLabel
@onready var color_indicator: ColorRect    = $MarginContainer/VBoxContainer/ColorIndicator
@onready var rarity_label:    Label        = $MarginContainer/VBoxContainer/RarityLabel
@onready var hover_effect:    Panel        = $HoverEffect
@onready var glow_particles:  CPUParticles2D = $GlowParticles

var card_data: Dictionary = {}
var card_id:   String     = ""
var is_hovered: bool      = false

var hover_tween: Tween

const COLOR_MAP = {
	"Red":    Color(0.9, 0.2, 0.2),
	"Blue":   Color(0.2, 0.4, 0.9),
	"Green":  Color(0.2, 0.8, 0.2),
	"Purple": Color(0.6, 0.2, 0.8),
	"Yellow": Color(0.9, 0.8, 0.2),
	"Black":  Color(0.2, 0.2, 0.2),
}

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	image_placeholder.visible = true
	glow_particles.emitting   = false
	# Importante: Las partículas deben empezar con al menos 1
	glow_particles.amount = 1 

# ─────────────────────────────────────────
#  Datos
# ─────────────────────────────────────────

func set_card_data(data: Dictionary) -> void:
	card_data = data
	card_id   = str(data.get("id", ""))
	_update_visuals()

func set_card_texture(texture: Texture2D) -> void:
	if texture == null: return
	card_image.texture        = texture
	image_placeholder.visible = false

func get_card_data() -> Dictionary:
	return card_data

func get_card_id() -> String:
	return card_id

# ─────────────────────────────────────────
#  Visualización
# ─────────────────────────────────────────

func _update_visuals() -> void:
	if card_data.is_empty():
		return

	card_name_label.text = str(card_data.get("name", "Unknown"))

	# Validar Cost (algunas cartas no tienen o es Nil)
	var cost = card_data.get("cost")
	cost_label.text = str(cost) if cost != null else "-"

	type_label.text = str(card_data.get("card_type", "Character"))

	# SOLUCIÓN ERROR Nil > int: Validar que power exista y sea número
	var power = card_data.get("power")
	if power != null and str(power) != "" and int(power) > 0:
		power_label.text    = str(power)
		power_label.visible = true
	else:
		power_label.visible = false

	var rarity = str(card_data.get("rarity", "C"))
	rarity_label.text = _get_rarity_display(rarity)

	var colors = card_data.get("color", [])
	if colors is Array and colors.size() > 0:
		var c = colors[0]
		if c in COLOR_MAP:
			color_indicator.color = COLOR_MAP[c]
			glow_particles.color  = COLOR_MAP[c]

	_configure_particles_by_rarity(rarity)

func _get_rarity_display(rarity: String) -> String:
	match rarity:
		"C":   return "C"
		"UC":  return "UC"
		"R":   return "R ⭐"
		"SR":  return "SR ⭐⭐"
		"SEC": return "SEC 💎"
		"L":   return "L 👑"
		_:     return rarity

func _configure_particles_by_rarity(rarity: String) -> void:
	# SOLUCIÓN ERROR amount < 1:
	# En Godot, p_amount debe ser >= 1. Si no queremos partículas, 
	# simplemente no las emitimos.
	match rarity:
		"SR", "SEC", "L":
			glow_particles.amount   = 30
			glow_particles.lifetime = 2.0
		"R":
			glow_particles.amount   = 15
			glow_particles.lifetime = 1.5
		_:
			# En lugar de 0, dejamos 1 y controlamos con .emitting
			glow_particles.amount   = 1

# ─────────────────────────────────────────
#  Interacción
# ─────────────────────────────────────────

func _on_mouse_entered() -> void:
	is_hovered = true
	_animate_hover_in()
	card_hovered.emit(self)

func _on_mouse_exited() -> void:
	is_hovered = false
	_animate_hover_out()
	card_unhovered.emit(self)

func _animate_hover_in() -> void:
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	z_index = 10
	hover_effect.visible = true
	hover_tween.tween_property(hover_effect, "modulate:a", 0.2, 0.2)

	# Solo emitir si la rareza lo merece y amount es > 1 (configurado arriba)
	var rarity = str(card_data.get("rarity", "C"))
	if rarity in ["R", "SR", "SEC", "L"]:
		glow_particles.emitting = true

func _animate_hover_out() -> void:
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.15)
	z_index = 0
	hover_tween.tween_property(hover_effect, "modulate:a", 0.0, 0.15)
	
	glow_particles.emitting = false
	
	await hover_tween.finished
	if not is_hovered:
		hover_effect.visible = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_animate_click()
			card_clicked.emit(self)

func _animate_click() -> void:
	var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	t.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	t.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)