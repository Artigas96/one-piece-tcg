extends Node

## CardDatabase - Caché local de cartas y sets
## Añadir en Project > AutoLoad como "CardDatabase" (después de APIService)
##
## Señales disponibles:
##   database_ready                          → caché listo para consultar
##   update_progress(current, total)         → progreso de descarga inicial
##   card_added(card_id)                     → nueva carta añadida al caché

signal database_ready()
signal update_progress(current: int, total: int)
signal card_added(card_id: String)

const CACHE_PATH    = "user://cards_cache.json"
const SETS_PATH     = "user://sets_cache.json"
const CACHE_MAX_AGE = 86400   # 1 día en segundos

# Almacenamiento en memoria
var _cards: Dictionary   = {}   # { "OP01-001": {...} }
var _sets: Dictionary    = {}   # { "OP01": {...} }
var _is_ready: bool      = false
var _total_expected: int = 0
var _total_loaded: int   = 0


func _ready() -> void:
	_load_cache()
	_connect_api_signals()


# ─────────────────────────────────────────
#  Inicialización
# ─────────────────────────────────────────

func _connect_api_signals() -> void:
	APIService.cards_page_loaded.connect(_on_cards_page_loaded)
	APIService.sets_loaded.connect(_on_sets_loaded)
	APIService.error_occurred.connect(_on_api_error)


func _load_cache() -> void:
	var loaded_cards = _read_json(CACHE_PATH)
	var loaded_sets  = _read_json(SETS_PATH)

	if loaded_cards != null:
		_cards     = loaded_cards.get("cards", {})
		var ts     = loaded_cards.get("timestamp", 0)

		if _needs_update(ts):
			print("CardDatabase: Caché antiguo, actualizando desde API...")
			_refresh_from_api()
		else:
			print("CardDatabase: Caché válido con %d cartas." % _cards.size())
			_is_ready = true
			database_ready.emit()
	else:
		print("CardDatabase: Sin caché. Descargando desde API...")
		_refresh_from_api()

	if loaded_sets != null:
		_sets = loaded_sets.get("sets", {})


func _refresh_from_api() -> void:
	_total_loaded   = 0
	_total_expected = 0
	_is_ready       = false
	APIService.fetch_all_cards()
	APIService.fetch_sets()


func _needs_update(timestamp: int) -> bool:
	var now = int(Time.get_unix_time_from_system())
	return (now - timestamp) > CACHE_MAX_AGE


# ─────────────────────────────────────────
#  API Pública - Consultas
# ─────────────────────────────────────────

## ¿Está el caché listo?
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


## Cuántas cartas hay en caché
func get_card_count() -> int:
	return _cards.size()


## Fuerza una actualización desde la API ignorando el caché
func force_refresh() -> void:
	print("CardDatabase: Forzando actualización...")
	_cards.clear()
	_refresh_from_api()


# ─────────────────────────────────────────
#  Callbacks de APIService
# ─────────────────────────────────────────

func _on_cards_page_loaded(cards: Array, page: int, total_count: int) -> void:
	if _total_expected == 0:
		_total_expected = total_count
		print("CardDatabase: Esperando %d cartas en total..." % total_count)

	for card_data in cards:
		var id = card_data.get("id", "")
		if id != "":
			_cards[id] = card_data
			card_added.emit(id)

	_total_loaded += cards.size()
	update_progress.emit(_total_loaded, _total_expected)

	print("CardDatabase: Cargadas %d / %d cartas (página %d)" % [
		_total_loaded, _total_expected, page
	])

	# ¿Hemos recibido todo?
	if _total_loaded >= _total_expected and _total_expected > 0:
		_save_cards_cache()
		_is_ready = true
		database_ready.emit()
		print("CardDatabase: ¡Base de datos lista! %d cartas en caché." % _cards.size())


func _on_sets_loaded(sets: Array) -> void:
	for s in sets:
		var code = s.get("code", "")
		if code != "":
			_sets[code] = s
	_save_sets_cache()
	print("CardDatabase: %d sets guardados." % _sets.size())


func _on_api_error(code: int, message: String) -> void:
	push_error("CardDatabase: Error de API (%d) — %s" % [code, message])
	# Si teníamos caché parcial, lo marcamos como listo igualmente
	if not _is_ready and _cards.size() > 0:
		push_warning("CardDatabase: Usando caché parcial con %d cartas." % _cards.size())
		_is_ready = true
		database_ready.emit()


# ─────────────────────────────────────────
#  Persistencia
# ─────────────────────────────────────────

func _save_cards_cache() -> void:
	var data = {
		"timestamp": int(Time.get_unix_time_from_system()),
		"cards": _cards
	}
	_write_json(CACHE_PATH, data)
	print("CardDatabase: Caché de cartas guardado (%d cartas)." % _cards.size())


func _save_sets_cache() -> void:
	var data = {"sets": _sets}
	_write_json(SETS_PATH, data)


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
