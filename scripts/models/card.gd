extends Resource
class_name CardData

## Clase de datos para una carta del juego
## Representa toda la información de una carta de One Piece TCG

@export var id: String = ""
@export var name: String = ""
@export var card_type: String = ""  # Leader, Character, Event, Stage
@export var color: Array[String] = []  # Red, Blue, Green, Purple, Black, Yellow
@export var cost: int = 0
@export var power: int = 0
@export var counter: int = 0
@export var attributes: Array[String] = []
@export var effect_text: String = ""
@export var image_url: String = ""
@export var rarity: String = ""  # C, UC, R, SR, SEC, L
@export var set_name: String = ""
@export var set_code: String = ""
@export var card_number: String = ""

## Constructor desde diccionario (útil para datos de API)
static func from_dict(data: Dictionary) -> CardData:
	var card = CardData.new()
	
	card.id = data.get("id", "")
	card.name = data.get("name", "")
	card.card_type = data.get("card_type", "Character")
	
	# Color puede venir como array o string
	var color_data = data.get("color", [])
	if color_data is Array:
		card.color = color_data
	else:
		card.color = [color_data]
	
	card.cost = data.get("cost", 0)
	card.power = data.get("power", 0)
	card.counter = data.get("counter", 0)
	
	# Attributes
	var attr_data = data.get("attribute", [])
	if attr_data is Array:
		card.attributes = attr_data
	else:
		card.attributes = [attr_data]
	
	card.effect_text = data.get("effect", "")
	card.image_url = data.get("image", "")
	card.rarity = data.get("rarity", "C")
	card.set_name = data.get("set_name", "")
	card.set_code = data.get("set_code", "")
	card.card_number = data.get("card_number", "")
	
	return card

## Convertir a diccionario
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"card_type": card_type,
		"color": color,
		"cost": cost,
		"power": power,
		"counter": counter,
		"attribute": attributes,
		"effect": effect_text,
		"image": image_url,
		"rarity": rarity,
		"set_name": set_name,
		"set_code": set_code,
		"card_number": card_number
	}

## Obtener color principal (el primero)
func get_primary_color() -> String:
	if color.size() > 0:
		return color[0]
	return "Red"

## Es carta de líder?
func is_leader() -> bool:
	return card_type == "Leader"

## Es carta de personaje?
func is_character() -> bool:
	return card_type == "Character"

## Es carta de evento?
func is_event() -> bool:
	return card_type == "Event"

## Es carta de escenario?
func is_stage() -> bool:
	return card_type == "Stage"

## String de información básica
func _to_string() -> String:
	return "[%s] %s (%s) - Cost: %d, Power: %d" % [id, name, card_type, cost, power]
