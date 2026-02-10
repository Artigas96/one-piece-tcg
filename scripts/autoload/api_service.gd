extends Node

## APIService - Singleton para comunicación con OPTCG API
## Añadir en Project > AutoLoad como "APIService"
##
## Señales disponibles:
##   cards_page_loaded(cards, page, total_count)  → cada página de cartas recibida
##   sets_loaded(sets)                            → lista de sets recibida
##   card_loaded(card)                            → carta individual recibida
##   error_occurred(code, message)               → error HTTP o de red
##   request_queued(pending)                      → cuántas peticiones quedan

signal cards_page_loaded(cards: Array, page: int, total_count: int)
signal sets_loaded(sets: Array)
signal card_loaded(card: Dictionary)
signal error_occurred(code: int, message: String)
signal request_queued(pending_count: int)

const BASE_URL     = "https://optcgapi.com/api/v1/"
const PAGE_SIZE    = 100          # Máximo que permite la API
const RATE_LIMIT   = 90           # Peticiones por hora (dejamos margen de 10)
const RETRY_DELAY  = 65.0         # Segundos a esperar si llegamos al límite
const REQUEST_GAP  = 0.4          # Segundos mínimos entre peticiones

# Cola de peticiones pendientes
var _queue: Array[Dictionary] = []
var _is_processing: bool      = false
var _requests_this_hour: int  = 0
var _hour_reset_timer: float  = 0.0
var _gap_timer: float         = 0.0

# HTTPRequest activo
var _http: HTTPRequest


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)


func _process(delta: float) -> void:
	# Resetear contador cada hora
	_hour_reset_timer += delta
	if _hour_reset_timer >= 3600.0:
		_hour_reset_timer  = 0.0
		_requests_this_hour = 0

	# Temporizador de espacio entre peticiones
	if _gap_timer > 0.0:
		_gap_timer -= delta
		return

	if not _is_processing and not _queue.is_empty():
		_process_next()


# ─────────────────────────────────────────
#  API Pública
# ─────────────────────────────────────────

## Obtiene UNA página de cartas (page empieza en 1)
func fetch_cards_page(page: int = 1) -> void:
	var url = BASE_URL + "cards?page=%d&page_size=%d" % [page, PAGE_SIZE]
	_enqueue(url, "cards_page", {"page": page})


## Descarga TODAS las cartas paginando automáticamente.
## Emite cards_page_loaded por cada página. CardDatabase lo usa internamente.
func fetch_all_cards() -> void:
	fetch_cards_page(1)   # La primera página; al recibirla calculamos cuántas hay


## Filtra cartas por parámetros combinables
func fetch_cards_filtered(params: Dictionary) -> void:
	# params puede tener: color, type, rarity, set, search
	var query = ""
	for key in params:
		if params[key] != "":
			query += "%s=%s&" % [key, str(params[key]).uri_encode()]
	query = query.trim_suffix("&")
	var url = BASE_URL + "cards?" + query
	_enqueue(url, "cards_page", {"page": 1})


## Obtiene una carta por ID (ej: "OP01-001")
func fetch_card(card_id: String) -> void:
	var url = BASE_URL + "cards/" + card_id.uri_encode()
	_enqueue(url, "card", {"id": card_id})


## Obtiene la lista de todos los sets
func fetch_sets() -> void:
	var url = BASE_URL + "sets"
	_enqueue(url, "sets", {})


## Cuántas peticiones quedan disponibles esta hora
func get_remaining_quota() -> int:
	return RATE_LIMIT - _requests_this_hour


# ─────────────────────────────────────────
#  Cola interna
# ─────────────────────────────────────────

func _enqueue(url: String, type: String, meta: Dictionary) -> void:
	_queue.append({"url": url, "type": type, "meta": meta})
	request_queued.emit(_queue.size())


func _process_next() -> void:
	if _queue.is_empty():
		return

	if _requests_this_hour >= RATE_LIMIT:
		push_warning("APIService: Rate limit alcanzado. Esperando %ds..." % RETRY_DELAY)
		await get_tree().create_timer(RETRY_DELAY).timeout
		_requests_this_hour = 0

	var item = _queue.pop_front()
	_is_processing = true
	_requests_this_hour += 1
	_gap_timer = REQUEST_GAP

	var err = _http.request(item.url)
	if err != OK:
		push_error("APIService: Error al lanzar petición (%s)" % item.url)
		_is_processing = false
		error_occurred.emit(-1, "No se pudo iniciar la petición HTTP")

	# Guardamos metadatos para usarlos en el callback
	_http.set_meta("current_item", item)


func _on_request_completed(
		_result: int,
		response_code: int,
		_headers: PackedStringArray,
		body: PackedByteArray) -> void:

	_is_processing = false

	var item: Dictionary = _http.get_meta("current_item", {})

	if response_code == 429:
		# Too Many Requests → reencolar y esperar
		push_warning("APIService: 429 Too Many Requests. Reintentando en %ds..." % RETRY_DELAY)
		_queue.push_front(item)   # Devolver al frente de la cola
		await get_tree().create_timer(RETRY_DELAY).timeout
		_requests_this_hour = 0
		return

	if response_code != 200:
		var msg = "Error HTTP %d en %s" % [response_code, item.get("url", "?")]
		push_error("APIService: " + msg)
		error_occurred.emit(response_code, msg)
		return

	var text = body.get_string_from_utf8()
	var json = JSON.parse_string(text)

	if json == null:
		error_occurred.emit(-2, "Respuesta JSON inválida")
		return

	match item.get("type", ""):
		"cards_page":
			_handle_cards_page(json, item)
		"card":
			card_loaded.emit(json)
		"sets":
			var results = json.get("results", [])
			sets_loaded.emit(results)


func _handle_cards_page(json: Dictionary, item: Dictionary) -> void:
	var results     = json.get("results", [])
	var total_count = json.get("count", 0)
	var page        = item.get("meta", {}).get("page", 1)

	cards_page_loaded.emit(results, page, total_count)

	# Si hay más páginas y esta fue la primera, encolar el resto automáticamente
	# (solo cuando se llamó fetch_all_cards, no fetch_cards_filtered)
	var next_url = json.get("next", "")
	if next_url != "" and item.get("meta", {}).get("page", 1) == 1:
		var total_pages = ceili(float(total_count) / float(PAGE_SIZE))
		for p in range(2, total_pages + 1):
			fetch_cards_page(p)
