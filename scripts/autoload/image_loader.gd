extends Node

## ImageLoader - Descarga y caché de imágenes de cartas
## Añadir en Project > AutoLoad como "ImageLoader" (último de los tres)
##
## Señales disponibles:
##   image_loaded(card_id, texture)   → imagen lista para mostrar
##   image_failed(card_id)            → no se pudo descargar

signal image_loaded(card_id: String, texture: Texture2D)
signal image_failed(card_id: String)

const IMAGES_DIR   = "user://cards/"
const MAX_PARALLEL = 3     # Descargas simultáneas máximas

# Cola de descargas pendientes: [ {id, url} ]
var _queue: Array[Dictionary]       = []
var _active: Dictionary             = {}   # { card_id: HTTPRequest }
var _memory_cache: Dictionary       = {}   # { card_id: Texture2D }


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(IMAGES_DIR)


# ─────────────────────────────────────────
#  API Pública
# ─────────────────────────────────────────

## Solicita la imagen de una carta. Si ya está en disco/memoria la devuelve
## inmediatamente vía señal; si no, la descarga en background.
func request_image(card_id: String, image_url: String) -> void:
	# 1. Caché en memoria
	if card_id in _memory_cache:
		image_loaded.emit(card_id, _memory_cache[card_id])
		return

	# 2. Caché en disco
	if _has_on_disk(card_id):
		var tex = _load_from_disk(card_id)
		if tex != null:
			_memory_cache[card_id] = tex
			image_loaded.emit(card_id, tex)
			return

	# 3. Ya está descargando
	if card_id in _active:
		return

	# 4. Ya está en cola
	for item in _queue:
		if item.id == card_id:
			return

	# 5. Encolar descarga
	_queue.append({"id": card_id, "url": image_url})
	_process_queue()


## ¿Está la imagen ya disponible (disco o memoria)?
func has_image(card_id: String) -> bool:
	return card_id in _memory_cache or _has_on_disk(card_id)


## Obtiene la textura si ya está en caché, o null si no
func get_cached_texture(card_id: String) -> Texture2D:
	if card_id in _memory_cache:
		return _memory_cache[card_id]
	if _has_on_disk(card_id):
		var tex = _load_from_disk(card_id)
		if tex != null:
			_memory_cache[card_id] = tex
			return tex
	return null


## Cancela todas las descargas pendientes (útil al cambiar de pantalla)
func cancel_all() -> void:
	_queue.clear()
	for card_id in _active.keys():
		var http = _active[card_id]
		http.cancel_request()
		http.queue_free()
	_active.clear()


## Borra el caché en disco (para forzar re-descarga)
func clear_disk_cache() -> void:
	var dir = DirAccess.open(IMAGES_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	_memory_cache.clear()
	print("ImageLoader: Caché en disco borrado.")


# ─────────────────────────────────────────
#  Descarga interna
# ─────────────────────────────────────────

func _process_queue() -> void:
	while _active.size() < MAX_PARALLEL and not _queue.is_empty():
		var item = _queue.pop_front()
		_start_download(item.id, item.url)


func _start_download(card_id: String, url: String) -> void:
	if url.strip_edges() == "":
		image_failed.emit(card_id)
		return

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(
		_on_download_completed.bind(card_id, http)
	)
	_active[card_id] = http

	var err = http.request(url)
	if err != OK:
		push_error("ImageLoader: Error al iniciar descarga de %s" % card_id)
		_cleanup(card_id, http)
		image_failed.emit(card_id)


func _on_download_completed(
		_result: int,
		response_code: int,
		_headers: PackedStringArray,
		body: PackedByteArray,
		card_id: String,
		http: HTTPRequest) -> void:

	_cleanup(card_id, http)

	if response_code != 200:
		push_warning("ImageLoader: Error %d al descargar imagen de %s" % [response_code, card_id])
		image_failed.emit(card_id)
		_process_queue()
		return

	# Guardar en disco
	var path = _get_disk_path(card_id)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("ImageLoader: No se pudo escribir %s" % path)
		image_failed.emit(card_id)
		_process_queue()
		return

	file.store_buffer(body)
	file.close()

	# Cargar como textura
	var tex = _load_from_disk(card_id)
	if tex != null:
		_memory_cache[card_id] = tex
		image_loaded.emit(card_id, tex)
	else:
		image_failed.emit(card_id)

	_process_queue()


func _cleanup(card_id: String, http: HTTPRequest) -> void:
	_active.erase(card_id)
	http.queue_free()


# ─────────────────────────────────────────
#  Disco
# ─────────────────────────────────────────

func _get_disk_path(card_id: String) -> String:
	# Sustituir caracteres inválidos para nombre de archivo
	var safe_id = card_id.replace("/", "_").replace("\\", "_")
	return IMAGES_DIR + safe_id + ".png"


func _has_on_disk(card_id: String) -> bool:
	return FileAccess.file_exists(_get_disk_path(card_id))


func _load_from_disk(card_id: String) -> Texture2D:
	var path = _get_disk_path(card_id)
	if not FileAccess.file_exists(path):
		return null

	var image = Image.new()
	var err   = image.load(path)
	if err != OK:
		push_warning("ImageLoader: No se pudo leer imagen en disco: %s" % path)
		return null

	return ImageTexture.create_from_image(image)
