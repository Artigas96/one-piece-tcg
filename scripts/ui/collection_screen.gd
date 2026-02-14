extends Control

## Pantalla de colección OPTIMIZADA - VERSION DEBUG
## Para diagnosticar problemas de filtrado

@onready var cards_grid:    GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/CardsGrid
@onready var search_bar:    LineEdit      = $MarginContainer/VBoxContainer/SearchAndFilters/SearchBar
@onready var color_filter:  OptionButton  = $MarginContainer/VBoxContainer/SearchAndFilters/ColorFilter
@onready var type_filter:   OptionButton  = $MarginContainer/VBoxContainer/SearchAndFilters/TypeFilter
@onready var rarity_filter: OptionButton  = $MarginContainer/VBoxContainer/SearchAndFilters/RarityFilter
@onready var set_filter:    OptionButton  = $MarginContainer/VBoxContainer/SearchAndFilters/SetFilter if has_node("MarginContainer/VBoxContainer/SearchAndFilters/SetFilter") else null
@onready var stats_label:   Label         = $MarginContainer/VBoxContainer/TopBar/StatsLabel
@onready var loading_label: Label         = $MarginContainer/VBoxContainer/LoadingLabel
@onready var no_cards_label:Label         = $MarginContainer/VBoxContainer/NoCardsLabel
@onready var pagination:    HBoxContainer = $MarginContainer/VBoxContainer/Pagination if has_node("MarginContainer/VBoxContainer/Pagination") else null

@onready var prev_button:   Button        = $MarginContainer/VBoxContainer/Pagination/PrevButton if has_node("MarginContainer/VBoxContainer/Pagination/PrevButton") else null
@onready var page_label:    Label         = $MarginContainer/VBoxContainer/Pagination/PageLabel if has_node("MarginContainer/VBoxContainer/Pagination/PageLabel") else null
@onready var next_button:   Button        = $MarginContainer/VBoxContainer/Pagination/NextButton if has_node("MarginContainer/VBoxContainer/Pagination/NextButton") else null

const CARD_SCENE          = preload("res://scenes/ui/card.tscn")
const PREVIEW_MODAL_SCENE = preload("res://scenes/ui/card_preview_modal.tscn")
const CARDS_PER_PAGE = 50

var preview_modal: CardPreviewModal = null
var current_page: int = 0
var total_pages: int = 0
var total_cards: int = 0
var displayed_cards: Array = []

var current_search: String = ""
var current_color:  String = ""
var current_type:   String = ""
var current_rarity: String = ""
var current_set:    String = ""

var search_timer: Timer = null
const SEARCH_DEBOUNCE_MS = 300

var _card_pool: Array = []
var _card_nodes: Dictionary = {}


func _ready() -> void:
	print("\n=== COLLECTION SCREEN DEBUG ===")
	
	_setup_preview_modal()
	_setup_search_debounce()
	_setup_pagination()
	_connect_signals()
	_populate_set_filter()
	
	# DEBUG: Mostrar estado inicial de filtros
	_debug_print_filter_state()

	if CardDatabase.is_ready():
		_on_database_ready()
	else:
		loading_label.visible = true
		loading_label.text    = "⏳ Cargando base de datos..."


func _debug_print_filter_state() -> void:
	"""DEBUG: Imprime el estado actual de los filtros"""
	print("📊 Estado de filtros al inicio:")
	print("  - SearchBar text: '%s'" % (search_bar.text if search_bar else "null"))
	print("  - ColorFilter selected: %d" % (color_filter.selected if color_filter else -1))
	print("  - TypeFilter selected: %d" % (type_filter.selected if type_filter else -1))
	print("  - RarityFilter selected: %d" % (rarity_filter.selected if rarity_filter else -1))
	print("  - SetFilter selected: %d" % (set_filter.selected if set_filter else -1))


func _setup_search_debounce() -> void:
	search_timer = Timer.new()
	search_timer.one_shot = true
	search_timer.wait_time = SEARCH_DEBOUNCE_MS / 1000.0
	search_timer.timeout.connect(_on_search_debounce_timeout)
	add_child(search_timer)


func _setup_pagination() -> void:
	if prev_button:
		prev_button.pressed.connect(_on_prev_page)
	if next_button:
		next_button.pressed.connect(_on_next_page)
	
	if pagination:
		pagination.visible = false


func _populate_set_filter() -> void:
	if not set_filter:
		print("⚠️  SetFilter no existe en la UI")
		return
	
	set_filter.clear()
	set_filter.add_item("Todos los Sets", 0)
	
	var sets = CardDatabase.get_all_sets()
	sets.sort_custom(func(a, b): return a.get("code", "") < b.get("code", ""))
	
	print("📦 Sets disponibles: %d" % sets.size())
	for i in range(sets.size()):
		var set_data = sets[i]
		var set_code = set_data.get("code", "")
		var set_name = set_data.get("name", "")
		set_filter.add_item("%s - %s" % [set_code, set_name], i + 1)
		print("  - %s: %s" % [set_code, set_name])


func _connect_signals() -> void:
	if not CardDatabase.database_ready.is_connected(_on_database_ready):
		CardDatabase.database_ready.connect(_on_database_ready)
	if not ImageLoader.image_loaded.is_connected(_on_image_loaded):
		ImageLoader.image_loaded.connect(_on_image_loaded)
	
	if search_bar and not search_bar.text_changed.is_connected(_on_search_text_changed):
		search_bar.text_changed.connect(_on_search_text_changed)
	if color_filter and not color_filter.item_selected.is_connected(_on_color_filter_changed):
		color_filter.item_selected.connect(_on_color_filter_changed)
	if type_filter and not type_filter.item_selected.is_connected(_on_type_filter_changed):
		type_filter.item_selected.connect(_on_type_filter_changed)
	if rarity_filter and not rarity_filter.item_selected.is_connected(_on_rarity_filter_changed):
		rarity_filter.item_selected.connect(_on_rarity_filter_changed)
	if set_filter and not set_filter.item_selected.is_connected(_on_set_filter_changed):
		set_filter.item_selected.connect(_on_set_filter_changed)


func _on_database_ready() -> void:
	loading_label.visible = false
	
	var card_count = CardDatabase.get_card_count()
	print("✅ Collection: Base de datos lista con %d cartas" % card_count)
	
	if card_count == 0:
		no_cards_label.visible = true
		no_cards_label.text = "No hay cartas en la base de datos."
		return
	
	var stats = CardDatabase.get_stats()
	print("📊 Stats de base de datos:")
	print("  - Total cartas: %d" % stats.total_cards)
	print("  - Total sets: %d" % stats.total_sets)
	print("  - Por color: %s" % JSON.stringify(stats.cards_by_color))
	print("  - Por tipo: %s" % JSON.stringify(stats.cards_by_type))
	
	# Leer estado INICIAL de los filtros
	_read_initial_filter_state()
	
	# Cargar primera página
	current_page = 0
	_apply_filters()


func _read_initial_filter_state() -> void:
	"""Lee el estado inicial de los filtros del editor"""
	print("\n🔍 Leyendo estado inicial de filtros...")
	
	# Leer texto de búsqueda
	if search_bar:
		current_search = search_bar.text
		print("  - Búsqueda inicial: '%s'" % current_search)
	
	# Leer filtro de color
	if color_filter:
		var colors = ["", "Red", "Blue", "Green", "Purple", "Yellow", "Black"]
		var idx = color_filter.selected
		current_color = colors[idx] if idx >= 0 and idx < colors.size() else ""
		print("  - Color inicial (idx=%d): '%s'" % [idx, current_color])
	
	# Leer filtro de tipo
	if type_filter:
		var types = ["", "Leader", "Character", "Event", "Stage"]
		var idx = type_filter.selected
		current_type = types[idx] if idx >= 0 and idx < types.size() else ""
		print("  - Tipo inicial (idx=%d): '%s'" % [idx, current_type])
	
	# Leer filtro de rareza
	if rarity_filter:
		var rarities = ["", "C", "UC", "R", "SR", "SEC", "L"]
		var idx = rarity_filter.selected
		current_rarity = rarities[idx] if idx >= 0 and idx < rarities.size() else ""
		print("  - Rareza inicial (idx=%d): '%s'" % [idx, current_rarity])
	
	# Leer filtro de set
	if set_filter:
		var idx = set_filter.selected
		if idx == 0:
			current_set = ""
		else:
			var sets = CardDatabase.get_all_sets()
			sets.sort_custom(func(a, b): return a.get("code", "") < b.get("code", ""))
			if idx - 1 < sets.size():
				current_set = sets[idx - 1].get("code", "")
		print("  - Set inicial (idx=%d): '%s'" % [idx, current_set])


func _display_current_page() -> void:
	var start_time = Time.get_ticks_msec()
	
	_clear_grid()
	
	# Construir parámetros de filtro
	var params = _get_filter_params()
	
	print("\n🔎 Aplicando filtros:")
	print("  Params: %s" % JSON.stringify(params))
	
	# Filtrar cartas
	var all_filtered = CardDatabase.filter_cards(params)
	total_cards = all_filtered.size()
	
	print("  ✅ Resultado: %d cartas encontradas" % total_cards)
	
	if total_cards == 0:
		no_cards_label.visible = true
		no_cards_label.text = "No se encontraron cartas con esos filtros."
		if pagination:
			pagination.visible = false
		
		# DEBUG: Intentar sin filtros
		print("\n⚠️  0 cartas encontradas. Probando sin filtros...")
		var all_cards = CardDatabase.filter_cards({})
		print("  Sin filtros: %d cartas disponibles" % all_cards.size())
		
		if all_cards.size() > 0:
			print("  🔍 El problema está en los filtros. Verifica:")
			print("    - Los valores de los OptionButtons")
			print("    - Que los índices correspondan a las opciones correctas")
		
		return
	
	no_cards_label.visible = false
	total_pages = ceili(float(total_cards) / float(CARDS_PER_PAGE))
	
	# Calcular índices de la página
	var start_idx = current_page * CARDS_PER_PAGE
	var end_idx = mini(start_idx + CARDS_PER_PAGE, total_cards)
	
	print("  📄 Mostrando página %d/%d (cartas %d-%d)" % [current_page + 1, total_pages, start_idx + 1, end_idx])
	
	# Crear nodos solo para las cartas visibles
	for i in range(start_idx, end_idx):
		if i >= all_filtered.size():
			break
		
		var card_data = all_filtered[i]
		var card_node = _get_or_create_card_node()
		
		cards_grid.add_child(card_node)
		card_node.set_card_data(card_data)
		
		var card_id = card_data.get("id", "")
		if card_id != "":
			_card_nodes[card_id] = card_node
			
			var image_url = card_data.get("image", "")
			if image_url != "":
				ImageLoader.request_image(card_id, image_url)
	
	_update_pagination_ui()
	
	var elapsed = Time.get_ticks_msec() - start_time
	print("  ⏱️  Tiempo de renderizado: %d ms\n" % elapsed)


func _get_or_create_card_node() -> Card:
	if _card_pool.size() > 0:
		return _card_pool.pop_back()
	
	var card_node = CARD_SCENE.instantiate() as Card
	card_node.card_clicked.connect(_on_card_clicked)
	card_node.card_hovered.connect(_on_card_hovered)
	return card_node


func _clear_grid() -> void:
	for child in cards_grid.get_children():
		cards_grid.remove_child(child)
		if child is Card:
			_card_pool.append(child)
	_card_nodes.clear()


func _update_pagination_ui() -> void:
	if not pagination:
		print("Página %d/%d (mostrando %d-%d de %d cartas)" % [
			current_page + 1, total_pages,
			current_page * CARDS_PER_PAGE + 1,
			mini((current_page + 1) * CARDS_PER_PAGE, total_cards),
			total_cards
		])
		return
	
	if total_cards == 0:
		pagination.visible = false
		return
	
	pagination.visible = true
	
	var showing_start = current_page * CARDS_PER_PAGE + 1
	var showing_end = mini((current_page + 1) * CARDS_PER_PAGE, total_cards)
	
	if page_label:
		page_label.text = "%d-%d de %d | Página %d/%d" % [
			showing_start, showing_end, total_cards, 
			current_page + 1, total_pages
		]
	
	if prev_button:
		prev_button.disabled = (current_page == 0)
	if next_button:
		next_button.disabled = (current_page >= total_pages - 1)


func _on_prev_page() -> void:
	if current_page > 0:
		current_page -= 1
		_display_current_page()
		_update_stats()


func _on_next_page() -> void:
	if current_page < total_pages - 1:
		current_page += 1
		_display_current_page()
		_update_stats()


func _on_search_text_changed(new_text: String) -> void:
	current_search = new_text
	print("🔎 Búsqueda cambiada a: '%s'" % new_text)
	
	if search_timer.is_stopped():
		search_timer.start()
	else:
		search_timer.stop()
		search_timer.start()


func _on_search_debounce_timeout() -> void:
	print("⏰ Debounce timeout - aplicando búsqueda")
	current_page = 0
	_apply_filters()


func _on_color_filter_changed(index: int) -> void:
	var colors = ["", "Red", "Blue", "Green", "Purple", "Yellow", "Black"]
	current_color = colors[index] if index < colors.size() else ""
	print("🎨 Filtro color cambiado a: '%s' (index=%d)" % [current_color, index])
	current_page = 0
	_apply_filters()


func _on_type_filter_changed(index: int) -> void:
	var types = ["", "Leader", "Character", "Event", "Stage"]
	current_type = types[index] if index < types.size() else ""
	print("📋 Filtro tipo cambiado a: '%s' (index=%d)" % [current_type, index])
	current_page = 0
	_apply_filters()


func _on_rarity_filter_changed(index: int) -> void:
	var rarities = ["", "C", "UC", "R", "SR", "SEC", "L"]
	current_rarity = rarities[index] if index < rarities.size() else ""
	print("💎 Filtro rareza cambiado a: '%s' (index=%d)" % [current_rarity, index])
	current_page = 0
	_apply_filters()


func _on_set_filter_changed(index: int) -> void:
	if index == 0:
		current_set = ""
	else:
		var sets = CardDatabase.get_all_sets()
		sets.sort_custom(func(a, b): return a.get("code", "") < b.get("code", ""))
		if index - 1 < sets.size():
			current_set = sets[index - 1].get("code", "")
	
	print("📦 Filtro set cambiado a: '%s' (index=%d)" % [current_set, index])
	current_page = 0
	_apply_filters()


func _get_filter_params() -> Dictionary:
	return {
		"search": current_search,
		"color": current_color,
		"type": current_type,
		"rarity": current_rarity,
		"set": current_set,
	}


func _apply_filters() -> void:
	_display_current_page()
	_update_stats()


func _update_stats() -> void:
	stats_label.text = "%d cartas encontradas" % total_cards


func _on_image_loaded(card_id: String, texture: Texture2D) -> void:
	if card_id in _card_nodes:
		var card_node = _card_nodes[card_id]
		if is_instance_valid(card_node):
			card_node.set_card_texture(texture)


func _on_card_clicked(card: Card) -> void:
	if preview_modal:
		preview_modal.show_card(card.get_card_data())


func _on_card_hovered(_card: Card) -> void:
	pass


func _setup_preview_modal() -> void:
	preview_modal = PREVIEW_MODAL_SCENE.instantiate()
	add_child(preview_modal)
	preview_modal.visible = false
	preview_modal.closed.connect(_on_preview_modal_closed)


func _on_preview_modal_closed() -> void:
	pass


func _on_back_button_pressed() -> void:
	ImageLoader.cancel_all()
	
	for card_node in _card_pool:
		card_node.queue_free()
	_card_pool.clear()
	
	if has_node("/root/SceneTransition"):
		SceneTransition.change_scene("res://scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# F3 para debug stats
		if event.keycode == KEY_F3:
			var stats = CardDatabase.get_stats()
			print("\n=== DATABASE STATS ===")
			print(JSON.stringify(stats, "  "))
			print("\n=== COLLECTION STATS ===")
			print("Current page: %d/%d" % [current_page + 1, total_pages])
			print("Cards in pool: %d" % _card_pool.size())
			print("Cards in scene: %d" % cards_grid.get_child_count())
			_debug_print_filter_state()
		
		# PageDown/PageUp para navegar
		elif event.keycode == KEY_PAGEDOWN:
			_on_next_page()
		elif event.keycode == KEY_PAGEUP:
			_on_prev_page()
