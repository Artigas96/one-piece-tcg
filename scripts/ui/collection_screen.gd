extends Control

## Pantalla de colección - Fase 2
## Carga cartas desde CardDatabase (API + caché local)
## Las imágenes se descargan en background vía ImageLoader

@onready var cards_grid:    GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/CardsGrid
@onready var search_bar:    LineEdit      = $MarginContainer/VBoxContainer/SearchAndFilters/SearchBar
@onready var color_filter:  OptionButton  = $MarginContainer/VBoxContainer/SearchAndFilters/ColorFilter
@onready var type_filter:   OptionButton  = $MarginContainer/VBoxContainer/SearchAndFilters/TypeFilter
@onready var rarity_filter: OptionButton  = $MarginContainer/VBoxContainer/SearchAndFilters/RarityFilter
@onready var stats_label:   Label         = $MarginContainer/VBoxContainer/TopBar/StatsLabel
@onready var loading_label: Label         = $MarginContainer/VBoxContainer/LoadingLabel
@onready var no_cards_label:Label         = $MarginContainer/VBoxContainer/NoCardsLabel

const CARD_SCENE          = preload("res://scenes/ui/card.tscn")
const PREVIEW_MODAL_SCENE = preload("res://scenes/ui/card_preview_modal.tscn")

var preview_modal: CardPreviewModal = null

# Todos los datos de cartas (sin filtrar)
var all_cards: Array = []
# Cartas actualmente mostradas
var displayed_cards: Array = []

# Filtros activos
var current_search: String = ""
var current_color:  String = ""
var current_type:   String = ""
var current_rarity: String = ""

# Mapa card_id → nodo Card en escena (para actualizar imagen en caliente)
var _card_nodes: Dictionary = {}


func _ready() -> void:
	_setup_preview_modal()
	_connect_signals()

	if CardDatabase.is_ready():
		_on_database_ready()
	else:
		loading_label.visible = true
		loading_label.text    = "⏳ Conectando con la API..."


func _connect_signals() -> void:
	CardDatabase.database_ready.connect(_on_database_ready)
	CardDatabase.update_progress.connect(_on_load_progress)
	ImageLoader.image_loaded.connect(_on_image_loaded)


# ─────────────────────────────────────────
#  Carga de datos
# ─────────────────────────────────────────

func _on_load_progress(current: int, total: int) -> void:
	if total > 0:
		var pct = int(100.0 * current / total)
		loading_label.text = "⏳ Descargando cartas... %d / %d  (%d%%)" % [current, total, pct]


func _on_database_ready() -> void:
	loading_label.visible = false
	all_cards = CardDatabase.get_all_cards()

	if all_cards.is_empty():
		no_cards_label.visible = true
		no_cards_label.text    = "No se encontraron cartas.\nRevisa tu conexión a internet."
		return

	displayed_cards = all_cards.duplicate()
	_update_stats()
	_display_cards()


# ─────────────────────────────────────────
#  Visualización
# ─────────────────────────────────────────

func _display_cards() -> void:
	# Limpiar grid y mapa de nodos
	for child in cards_grid.get_children():
		child.queue_free()
	_card_nodes.clear()

	if displayed_cards.is_empty():
		no_cards_label.visible = true
		return
	no_cards_label.visible = false

	for card_data in displayed_cards:
		var card_node = CARD_SCENE.instantiate() as Card
		cards_grid.add_child(card_node)
		card_node.set_card_data(card_data)
		card_node.card_clicked.connect(_on_card_clicked)
		card_node.card_hovered.connect(_on_card_hovered)

		# Registrar nodo para actualizar imagen después
		var card_id = card_data.get("id", "")
		if card_id != "":
			_card_nodes[card_id] = card_node

		# Solicitar imagen (si ya está en caché se emitirá image_loaded de inmediato)
		var image_url = card_data.get("image", "")
		if card_id != "" and image_url != "":
			ImageLoader.request_image(card_id, image_url)


# ─────────────────────────────────────────
#  Imágenes en caliente
# ─────────────────────────────────────────

func _on_image_loaded(card_id: String, texture: Texture2D) -> void:
	if card_id in _card_nodes:
		var card_node = _card_nodes[card_id]
		# Verificar que el nodo sigue en escena
		if is_instance_valid(card_node):
			card_node.set_card_texture(texture)


# ─────────────────────────────────────────
#  Filtros
# ─────────────────────────────────────────

func _apply_filters() -> void:
	var params = {
		"search": current_search,
		"color":  current_color,
		"type":   current_type,
		"rarity": current_rarity,
	}
	displayed_cards = CardDatabase.filter_cards(params)
	_display_cards()
	_update_stats()


func _update_stats() -> void:
	stats_label.text = "%d / %d cartas" % [displayed_cards.size(), all_cards.size()]


# Callbacks de filtros
func _on_search_text_changed(new_text: String) -> void:
	current_search = new_text
	_apply_filters()


func _on_color_filter_changed(index: int) -> void:
	var colors = ["", "Red", "Blue", "Green", "Purple", "Yellow", "Black"]
	current_color = colors[index] if index < colors.size() else ""
	_apply_filters()


func _on_type_filter_changed(index: int) -> void:
	var types = ["", "Leader", "Character", "Event", "Stage"]
	current_type = types[index] if index < types.size() else ""
	_apply_filters()


func _on_rarity_filter_changed(index: int) -> void:
	var rarities = ["", "C", "UC", "R", "SR", "SEC", "L"]
	current_rarity = rarities[index] if index < rarities.size() else ""
	_apply_filters()


# ─────────────────────────────────────────
#  Interacción con cartas
# ─────────────────────────────────────────

func _on_card_clicked(card: Card) -> void:
	if preview_modal:
		preview_modal.show_card(card.get_card_data())


func _on_card_hovered(_card: Card) -> void:
	pass


# ─────────────────────────────────────────
#  Modal de preview
# ─────────────────────────────────────────

func _setup_preview_modal() -> void:
	preview_modal = PREVIEW_MODAL_SCENE.instantiate()
	add_child(preview_modal)
	preview_modal.visible = false
	preview_modal.closed.connect(_on_preview_modal_closed)


func _on_preview_modal_closed() -> void:
	pass


# ─────────────────────────────────────────
#  Navegación
# ─────────────────────────────────────────

func _on_back_button_pressed() -> void:
	ImageLoader.cancel_all()   # Parar descargas al salir
	if has_node("/root/SceneTransition"):
		SceneTransition.change_scene("res://scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
