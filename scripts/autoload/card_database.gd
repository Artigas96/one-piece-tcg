extends Node

## CardDatabase - Base de datos local de cartas
## Carga cartas desde archivo JSON local (sin dependencia de API)
##
## Señales disponibles:
##   database_ready                          → base de datos lista
##   card_added(card_id)                     → carta añadida

signal database_ready()
signal card_added(card_id: String)

const DATABASE_PATH = "res://data/cards_database.json"  # Base de datos local
const BACKUP_PATH   = "user://cards_backup.json"        # Backup de usuario

# Almacenamiento en memoria
var _cards: Dictionary = {}   # { "OP01-001": {...} }
var _sets: Dictionary  = {}   # { "OP01": {...} }
var _is_ready: bool    = false


func _ready() -> void:
	_load_local_database()


# ─────────────────────────────────────────
#  Inicialización
# ─────────────────────────────────────────

func _load_local_database() -> void:
	print("CardDatabase: Cargando base de datos local...")
	
	# Intentar cargar desde res:// (incluido en el juego)
	var db_data = _read_json_from_res(DATABASE_PATH)
	
	if db_data == null:
		# Si falla, intentar backup en user://
		print("CardDatabase: No se encontró BD local, intentando backup...")
		db_data = _read_json(BACKUP_PATH)
	
	if db_data != null:
		# Cargar cartas
		var cards_array = db_data.get("cards", [])
		for card_data in cards_array:
			var card_id = card_data.get("id", "")
			if card_id != "":
				_cards[card_id] = card_data
				card_added.emit(card_id)
		
		# Cargar sets
		var sets_array = db_data.get("sets", [])
		for set_data in sets_array:
			var set_code = set_data.get("code", "")
			if set_code != "":
				_sets[set_code] = set_data
		
		print("CardDatabase: ✅ Cargadas %d cartas y %d sets." % [_cards.size(), _sets.size()])
		_is_ready = true
		database_ready.emit()
		
		# Guardar backup
		_save_backup(db_data)
	else:
		push_error("CardDatabase: ❌ No se pudo cargar la base de datos local!")
		_is_ready = false


# ─────────────────────────────────────────
#  API Pública - Consultas
# ─────────────────────────────────────────

## ¿Está la base de datos lista?
func is_ready() -> bool:
	return _is_ready


## Devuelve todas las cartas como Array[Dictionary]
func get_all_cards() -> Array:
	return _cards.values()


## Devuelve una carta por ID, o {} si no existe
func get_card(card_id: String) -> Dictionary:
	return _cards.get(card_id, {})


## Búsqueda por nombre (parcial, insensible a mayúsculas)
func search_by_name(query: String) -> Array:
	if query.strip_edges() == "":
		return get_all_cards()
	var q = query.to_lower()
	var results: Array = []
	for card in _cards.values():
		if q in card.get("name", "").to_lower():
			results.append(card)
	return results


## Filtrado combinable. Todos los parámetros son opcionales ("" = sin filtro).
##   color   → "Red", "Blue", etc.
##   type    → "Leader", "Character", "Event", "Stage"
##   rarity  → "C", "UC", "R", "SR", "SEC", "L"
##   set     → "OP01", "OP02", etc.
##   search  → búsqueda por nombre
func filter_cards(params: Dictionary) -> Array:
	var color   = params.get("color", "")
	var type_f  = params.get("type", "")
	var rarity  = params.get("rarity", "")
	var set_f   = params.get("set", "")
	var search  = params.get("search", "").to_lower()

	var results: Array = []

	for card in _cards.values():
		# Nombre
		if search != "" and search not in card.get("name", "").to_lower():
			continue
		# Color
		if color != "" and color not in card.get("color", []):
			continue
		# Tipo
		if type_f != "" and card.get("card_type", "") != type_f:
			continue
		# Rareza
		if rarity != "" and card.get("rarity", "") != rarity:
			continue
		# Set
		if set_f != "" and card.get("set_code", "") != set_f:
			continue

		results.append(card)

	return results


## Devuelve todos los sets como Array[Dictionary]
func get_all_sets() -> Array:
	return _sets.values()


## Devuelve un set por código, o {} si no existe
func get_set(set_code: String) -> Dictionary:
	return _sets.get(set_code, {})


## Cuántas cartas hay en la base de datos
func get_card_count() -> int:
	return _cards.size()


## Añadir una carta manualmente (útil para expansiones futuras)
func add_card(card_data: Dictionary) -> void:
	var card_id = card_data.get("id", "")
	if card_id != "":
		_cards[card_id] = card_data
		card_added.emit(card_id)
		print("CardDatabase: Carta añadida: %s" % card_id)


## Añadir un set manualmente
func add_set(set_data: Dictionary) -> void:
	var set_code = set_data.get("code", "")
	if set_code != "":
		_sets[set_code] = set_data
		print("CardDatabase: Set añadido: %s" % set_code)


## Exportar la base de datos actual a JSON
func export_database() -> String:
	var data = {
		"sets": _sets.values(),
		"cards": _cards.values()
	}
	return JSON.stringify(data, "\t")


# ─────────────────────────────────────────
#  Persistencia
# ─────────────────────────────────────────

func _save_backup(data: Dictionary) -> void:
	_write_json(BACKUP_PATH, data)
	print("CardDatabase: Backup guardado en user://")


func _read_json_from_res(path: String):
	if not FileAccess.file_exists(path):
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("CardDatabase: No se pudo abrir " + path)
		return null
	var text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_error("CardDatabase: Error al parsear JSON en " + path)
	return parsed


func _read_json(path: String):
	if not FileAccess.file_exists(path):
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed


func _write_json(path: String, data: Dictionary) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("CardDatabase: No se pudo abrir %s para escritura." % path)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
