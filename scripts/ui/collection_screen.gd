extends Control

## Pantalla de colección
## Muestra todas las cartas disponibles en un grid

# Referencias a nodos
@onready var cards_grid: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/CardsGrid
@onready var search_bar: LineEdit = $MarginContainer/VBoxContainer/SearchAndFilters/SearchBar
@onready var color_filter: OptionButton = $MarginContainer/VBoxContainer/SearchAndFilters/ColorFilter
@onready var type_filter: OptionButton = $MarginContainer/VBoxContainer/SearchAndFilters/TypeFilter
@onready var rarity_filter: OptionButton = $MarginContainer/VBoxContainer/SearchAndFilters/RarityFilter
@onready var stats_label: Label = $MarginContainer/VBoxContainer/TopBar/StatsLabel
@onready var loading_label: Label = $MarginContainer/VBoxContainer/LoadingLabel
@onready var no_cards_label: Label = $MarginContainer/VBoxContainer/NoCardsLabel

# Escena de carta
const CARD_SCENE = preload("res://scenes/ui/card.tscn")

# Datos
var all_cards: Array[Dictionary] = []
var displayed_cards: Array[Dictionary] = []

# Filtros actuales
var current_search: String = ""
var current_color_filter: String = ""
var current_type_filter: String = ""
var current_rarity_filter: String = ""

func _ready() -> void:
	print("Pantalla de colección cargada")
	_load_sample_cards()
	_display_cards()

## Cargar cartas de ejemplo (temporalmente hasta tener API)
func _load_sample_cards() -> void:
	loading_label.visible = true
	
	# Crear algunas cartas de ejemplo
	var sample_cards = [
		{
			"id": "OP01-001",
			"name": "Monkey D. Luffy",
			"card_type": "Leader",
			"color": ["Red"],
			"cost": 0,
			"power": 5000,
			"rarity": "L",
			"set_code": "OP01"
		},
		{
			"id": "OP01-002",
			"name": "Roronoa Zoro",
			"card_type": "Character",
			"color": ["Green"],
			"cost": 3,
			"power": 4000,
			"rarity": "SR",
			"set_code": "OP01"
		},
		{
			"id": "OP01-003",
			"name": "Nami",
			"card_type": "Character",
			"color": ["Blue"],
			"cost": 2,
			"power": 3000,
			"rarity": "R",
			"set_code": "OP01"
		},
		{
			"id": "OP01-004",
			"name": "Usopp",
			"card_type": "Character",
			"color": ["Yellow"],
			"cost": 2,
			"power": 2000,
			"rarity": "UC",
			"set_code": "OP01"
		},
		{
			"id": "OP01-005",
			"name": "Sanji",
			"card_type": "Character",
			"color": ["Blue"],
			"cost": 4,
			"power": 5000,
			"rarity": "SR",
			"set_code": "OP01"
		},
		{
			"id": "OP01-006",
			"name": "Gum-Gum Pistol",
			"card_type": "Event",
			"color": ["Red"],
			"cost": 1,
			"power": 0,
			"rarity": "C",
			"set_code": "OP01"
		},
	]
	
	# Duplicar para tener más cartas de prueba
	for i in range(3):
		all_cards.append_array(sample_cards.duplicate(true))
	
	displayed_cards = all_cards.duplicate()
	_update_stats()
	loading_label.visible = false

## Mostrar las cartas en el grid
func _display_cards() -> void:
	# Limpiar grid actual
	for child in cards_grid.get_children():
		child.queue_free()
	
	# Verificar si hay cartas
	if displayed_cards.is_empty():
		no_cards_label.visible = true
		return
	
	no_cards_label.visible = false
	
	# Crear instancias de cartas
	for card_data in displayed_cards:
		var card_instance = CARD_SCENE.instantiate()
		cards_grid.add_child(card_instance)
		card_instance.set_card_data(card_data)
		
		# Conectar señales
		card_instance.card_clicked.connect(_on_card_clicked)
		card_instance.card_hovered.connect(_on_card_hovered)

## Aplicar filtros
func _apply_filters() -> void:
	displayed_cards.clear()
	
	for card in all_cards:
		# Filtro de búsqueda por nombre
		if current_search != "":
			if not current_search.to_lower() in card.get("name", "").to_lower():
				continue
		
		# Filtro de color
		if current_color_filter != "":
			var card_colors = card.get("color", [])
			if not current_color_filter in card_colors:
				continue
		
		# Filtro de tipo
		if current_type_filter != "":
			if card.get("card_type", "") != current_type_filter:
				continue
		
		# Filtro de rareza
		if current_rarity_filter != "":
			if card.get("rarity", "") != current_rarity_filter:
				continue
		
		displayed_cards.append(card)
	
	_display_cards()
	_update_stats()

## Actualizar estadísticas
func _update_stats() -> void:
	stats_label.text = "%d / %d cartas" % [displayed_cards.size(), all_cards.size()]

## Callbacks de filtros
func _on_search_text_changed(new_text: String) -> void:
	current_search = new_text
	_apply_filters()

func _on_color_filter_changed(index: int) -> void:
	var colors = ["", "Red", "Blue", "Green", "Purple", "Yellow", "Black"]
	current_color_filter = colors[index]
	_apply_filters()

func _on_type_filter_changed(index: int) -> void:
	var types = ["", "Leader", "Character", "Event", "Stage"]
	current_type_filter = types[index]
	_apply_filters()

func _on_rarity_filter_changed(index: int) -> void:
	var rarities = ["", "C", "UC", "R", "SR", "SEC", "L"]
	current_rarity_filter = rarities[index]
	_apply_filters()

## Callbacks de cartas
func _on_card_clicked(card: Card) -> void:
	print("Carta clickeada: ", card.get_card_data())
	# TODO: Mostrar preview grande de la carta

func _on_card_hovered(card: Card) -> void:
	# TODO: Mostrar tooltip o info adicional
	pass

## Volver al menú principal
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")