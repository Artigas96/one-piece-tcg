# 🔌 Guía de Integración con OPTCG API

Documentación para trabajar con la API de One Piece TCG.

---

## 📡 Información de la API

**Base URL:** `https://optcgapi.com/api/v1/`  
**Tipo:** RESTful API  
**Autenticación:** No requerida (límite de peticiones por IP)  
**Formato:** JSON  
**Límites:** ~100 peticiones por hora por IP  

---

## 🔍 Endpoints Principales

### 1. Obtener todas las cartas

```http
GET /cards
```

**Parámetros opcionales:**
- `page` (int): Número de página
- `page_size` (int): Cartas por página (máx 100)
- `search` (string): Búsqueda por nombre
- `color` (string): Filtrar por color (Red, Blue, Green, Purple, Black, Yellow)
- `type` (string): Filtrar por tipo (Leader, Character, Event, Stage)
- `rarity` (string): Filtrar por rareza (C, UC, R, SR, SEC, L)
- `set` (string): Filtrar por set (OP01, OP02, etc.)

**Ejemplo de respuesta:**
```json
{
  "count": 1234,
  "next": "https://optcgapi.com/api/v1/cards?page=2",
  "previous": null,
  "results": [
    {
      "id": "OP01-001",
      "name": "Monkey D. Luffy",
      "image": "https://optcgapi.com/media/cards/OP01-001.png",
      "card_type": "Leader",
      "color": ["Red"],
      "cost": 0,
      "power": 5000,
      "counter": 0,
      "attribute": ["Straw Hat Crew"],
      "effect": "[DON!! x1] [When Attacking] ...",
      "rarity": "L",
      "set_name": "Romance Dawn",
      "set_code": "OP01",
      "card_number": "001"
    }
  ]
}
```

### 2. Obtener carta específica

```http
GET /cards/{id}
```

**Ejemplo:**
```http
GET /cards/OP01-001
```

### 3. Obtener todos los sets

```http
GET /sets
```

**Ejemplo de respuesta:**
```json
{
  "results": [
    {
      "id": 1,
      "code": "OP01",
      "name": "Romance Dawn",
      "release_date": "2022-07-08",
      "total_cards": 121
    }
  ]
}
```

### 4. Obtener información de un set

```http
GET /sets/{code}
```

**Ejemplo:**
```http
GET /sets/OP01
```

---

## 💻 Implementación en Godot

### Servicio de API (APIService.gd)

```gdscript
extends Node

const BASE_URL = "https://optcgapi.com/api/v1/"
var http_request: HTTPRequest

func _ready():
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_request_completed)

# Obtener todas las cartas (con paginación)
func fetch_all_cards(page: int = 1, page_size: int = 100) -> void:
    var url = BASE_URL + "cards?page=%d&page_size=%d" % [page, page_size]
    var error = http_request.request(url)
    if error != OK:
        push_error("Error al hacer petición: " + str(error))

# Buscar cartas por nombre
func search_cards(query: String) -> void:
    var url = BASE_URL + "cards?search=" + query.uri_encode()
    http_request.request(url)

# Filtrar por set
func get_cards_by_set(set_code: String) -> void:
    var url = BASE_URL + "cards?set=" + set_code
    http_request.request(url)

# Filtrar por color
func get_cards_by_color(color: String) -> void:
    # color: Red, Blue, Green, Purple, Black, Yellow
    var url = BASE_URL + "cards?color=" + color
    http_request.request(url)

# Obtener carta específica
func get_card_by_id(card_id: String) -> void:
    var url = BASE_URL + "cards/" + card_id
    http_request.request(url)

# Obtener todos los sets
func fetch_all_sets() -> void:
    var url = BASE_URL + "sets"
    http_request.request(url)

func _on_request_completed(result, response_code, headers, body):
    if response_code == 200:
        var json = JSON.parse_string(body.get_string_from_utf8())
        if json:
            emit_signal("data_received", json)
        else:
            push_error("Error al parsear JSON")
    else:
        push_error("Error HTTP: " + str(response_code))

signal data_received(data)
```

### Sistema de Caché

```gdscript
# CardDatabase.gd
extends Node

const CACHE_PATH = "user://cards_cache.json"
var cards_cache: Dictionary = {}
var last_update: int = 0

func load_cache() -> void:
    if FileAccess.file_exists(CACHE_PATH):
        var file = FileAccess.open(CACHE_PATH, FileAccess.READ)
        var json = JSON.parse_string(file.get_as_text())
        if json:
            cards_cache = json.get("cards", {})
            last_update = json.get("timestamp", 0)
        file.close()

func save_cache() -> void:
    var file = FileAccess.open(CACHE_PATH, FileAccess.WRITE)
    var data = {
        "cards": cards_cache,
        "timestamp": Time.get_unix_time_from_system()
    }
    file.store_string(JSON.stringify(data))
    file.close()

func needs_update() -> bool:
    var current_time = Time.get_unix_time_from_system()
    var one_day = 86400  # segundos en un día
    return (current_time - last_update) > one_day

func get_card(card_id: String) -> Dictionary:
    if card_id in cards_cache:
        return cards_cache[card_id]
    return {}

func add_card(card_id: String, card_data: Dictionary) -> void:
    cards_cache[card_id] = card_data
    save_cache()

func search_cards(query: String) -> Array:
    var results = []
    for card_id in cards_cache:
        var card = cards_cache[card_id]
        if query.to_lower() in card.get("name", "").to_lower():
            results.append(card)
    return results

func filter_by_color(color: String) -> Array:
    var results = []
    for card_id in cards_cache:
        var card = cards_cache[card_id]
        if color in card.get("color", []):
            results.append(card)
    return results
```

---

## 🖼️ Descarga de Imágenes

### Image Loader

```gdscript
# image_loader.gd
extends Node

const CARDS_PATH = "user://cards/"

func _ready():
    # Crear directorio si no existe
    DirAccess.make_dir_recursive_absolute(CARDS_PATH)

func download_card_image(card_id: String, image_url: String) -> void:
    var http = HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(_on_image_downloaded.bind(card_id, http))
    http.request(image_url)

func _on_image_downloaded(result, response_code, headers, body, card_id, http):
    if response_code == 200:
        var path = CARDS_PATH + card_id + ".png"
        var file = FileAccess.open(path, FileAccess.WRITE)
        file.store_buffer(body)
        file.close()
        print("Imagen descargada: " + card_id)
    http.queue_free()

func get_card_image(card_id: String) -> Texture2D:
    var path = CARDS_PATH + card_id + ".png"
    if FileAccess.file_exists(path):
        return load(path)
    return null

func has_card_image(card_id: String) -> bool:
    var path = CARDS_PATH + card_id + ".png"
    return FileAccess.file_exists(path)
```

---

## ⚡ Optimización y Buenas Prácticas

### 1. Paginación Inteligente
```gdscript
# Cargar cartas en lotes pequeños
func load_cards_batch(start_page: int, batch_size: int = 5):
    for i in range(batch_size):
        await fetch_all_cards(start_page + i)
        await get_tree().create_timer(0.5).timeout  # Esperar entre peticiones
```

### 2. Rate Limiting
```gdscript
var request_queue = []
var requests_this_hour = 0
var last_request_time = 0

func queue_request(url: String):
    request_queue.append(url)
    process_queue()

func process_queue():
    if request_queue.is_empty():
        return
    
    if requests_this_hour >= 90:  # Límite de seguridad
        await get_tree().create_timer(60).timeout
        requests_this_hour = 0
    
    var url = request_queue.pop_front()
    http_request.request(url)
    requests_this_hour += 1
```

### 3. Caché de Imágenes
- No descargar imágenes que ya existen localmente
- Descargar imágenes bajo demanda (lazy loading)
- Comprimir imágenes si es necesario

### 4. Manejo de Errores
```gdscript
func _on_request_completed(result, response_code, headers, body):
    match response_code:
        200:
            # Éxito
            process_data(body)
        404:
            push_error("Recurso no encontrado")
        429:
            # Too Many Requests - esperar
            await get_tree().create_timer(60).timeout
            retry_request()
        _:
            push_error("Error HTTP: " + str(response_code))
```

---

## 📝 Ejemplos de Uso

### Ejemplo 1: Cargar todas las cartas al inicio
```gdscript
func _ready():
    APIService.fetch_all_cards()
    await APIService.data_received
    CardDatabase.save_cache()
```

### Ejemplo 2: Buscar cartas mientras el usuario escribe
```gdscript
func _on_search_text_changed(new_text: String):
    if new_text.length() >= 3:
        var results = CardDatabase.search_cards(new_text)
        display_results(results)
```

### Ejemplo 3: Filtros combinados
```gdscript
func apply_filters(color: String, type: String, set_code: String):
    var url = BASE_URL + "cards?"
    if color != "":
        url += "color=" + color + "&"
    if type != "":
        url += "type=" + type + "&"
    if set_code != "":
        url += "set=" + set_code
    
    APIService.custom_request(url)
```

---

## 🔗 Enlaces Útiles

- **Documentación oficial:** https://optcgapi.com/docs/
- **GitHub (si disponible):** https://github.com/optcgapi
- **Status de API:** Verificar en la web oficial

---

## ⚠️ Limitaciones Conocidas

1. **Límite de peticiones:** ~100 por hora
2. **Sin autenticación:** No hay API keys
3. **Sin webhooks:** No hay notificaciones de nuevos sets
4. **Datos en inglés:** Principalmente en inglés

---

**Última actualización:** Febrero 2026