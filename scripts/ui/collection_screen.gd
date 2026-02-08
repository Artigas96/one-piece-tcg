extends Control

## Pantalla de colección mejorada
## Muestra todas las cartas disponibles en un grid con preview modal

# Referencias a nodos
@onready var cards_grid: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/CardsGrid
@onready var search_bar: LineEdit = $MarginContainer/VBoxContainer/SearchAndFilters/SearchBar
@onready var color_filter: OptionButton = $MarginContainer/VBoxContainer/SearchAndFilters/ColorFilter
@onready var type_filter: OptionButton = $MarginContainer/VBoxContainer/SearchAndFilters/TypeFilter
@onready var rarity_filter: OptionButton = $MarginContainer/VBoxContainer/SearchAndFilters/RarityFilter
@onready var stats_label: Label = $MarginContainer/VBoxContainer/TopBar/StatsLabel
@onready var loading_label: Label = $MarginContainer/VBoxContainer/LoadingLabel
@onready var no_cards_label: Label = $MarginContainer/VBoxContainer/NoCardsLabel

# Escenas
const CARD_SCENE = preload("res://scenes/ui/card.tscn")
const PREVIEW_MODAL_SCENE = preload("res://scenes/ui/card_preview_modal.tscn")

# Modal de preview
var preview_modal: CardPreviewModal = null

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
	_setup_preview_modal()
	_load_sample_cards()
	_display_cards()

## Configurar modal de preview
func _setup_preview_modal() -> void:
	preview_modal = PREVIEW_MODAL_SCENE.instantiate()
	add_child(preview_modal)
	preview_modal.visible = false
	preview_modal.closed.connect(_on_preview_modal_closed)

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
			"counter": 0,
			"attribute": ["Straw Hat Crew", "Supernova"],
			"effect": "[DON!! x1] [When Attacking] Give this Leader or 1 of your Characters +1000 power during this battle.",
			"rarity": "L",
			"set_name": "Romance Dawn",
			"set_code": "OP01",
			"card_number": "001"
		},
		{
			"id": "OP01-002",
			"name": "Roronoa Zoro",
			"card_type": "Character",
			"color": ["Green"],
			"cost": 3,
			"power": 4000,
			"counter": 1000,
			"attribute": ["Straw Hat Crew", "Swordsman"],
			"effect": "[DON!! x1] [When Attacking] If your Leader has the {Straw Hat Crew} type, this Character gains +1000 power during this battle.",
			"rarity": "SR",
			"set_name": "Romance Dawn",
			"set_code": "OP01",
			"card_number": "002"
		},
		{
			"id": "OP01-003",
			"name": "Nami",
			"card_type": "Character",
			"color": ["Blue"],
			"cost": 2,
			"power": 3000,
			"counter": 1000,
			"attribute": ["Straw Hat Crew"],
			"effect": "[On Play] Look at 3 cards from the top of your deck; reveal up to 1 {Straw Hat Crew} type card and add it to your hand. Then, place the rest at the bottom of your deck in any order.",
			"rarity": "R",
			"set_name": "Romance Dawn",
			"set_code": "OP01",
			"card_number": "003"
		},
		{
			"id": "OP01-004",
			"name": "Usopp",
			"card_type": "Character",
			"color": ["Yellow"],
			"cost": 2,
			"power": 2000,
			"counter": 2000,
			"attribute": ["Straw Hat Crew", "Sniper"],
			"effect": "[Blocker] (After your opponent declares an attack, you may rest this card to make it the new target of the attack.)",
			"rarity": "UC",
			"set_name": "Romance Dawn",
			"set_code": "OP01",
			"card_number": "004"
		},
		{
			"id": "OP01-005",
			"name": "Sanji",
			"card_type": "Character",
			"color": ["Blue"],
			"cost": 4,
			"power": 5000,
			"counter": 1000,
			"attribute": ["Straw Hat Crew"],
			"effect": "[DON!! x1] [Your Turn] This Character gains +1000 power.",
			"rarity": "SR",
			"set_name": "Romance Dawn",
			"set_code": "OP01",
			"card_number": "005"
		},
		{
			"id": "OP01-006",
			"name": "Gum-Gum Pistol",
			"card_type": "Event",
			"color": ["Red"],
			"cost": 1,
			"power": 0,
			"counter": 0,
			"attribute": ["Straw Hat Crew"],
			"effect": "[Main] Give up to 1 of your Leader or Character cards +3000 power during this turn.",
			"rarity": "C",
			"set_name": "Romance Dawn",
			"set_code": "OP01",
			"card_number": "006"
		},
		{
			"id": "OP01-007",
			"name": "Going Merry",
			"card_type": "Stage",
			"color": ["Red"],
			"cost": 2,
			"power": 0,
			"counter": 0,
			"attribute": ["Straw Hat Crew"],
			"effect": "[Activate: Main] You may rest this Stage: Add 1 card from the top of your Life cards to your hand.",
			"rarity": "C",
			"set_name": "Romance Dawn",
			"set_code": "OP01",
			"card_number": "007"
		},
		{
			"id": "OP01-008",
			"name": "Nico Robin",
			"card_type": "Character",
			"color": ["Purple"],
			"cost": 4,
			"power": 5000,
			"counter": 1000,
			"attribute": ["Straw Hat Crew"],
			"effect": "[On Play] Draw 1 card.",
			"rarity": "R",
			"set_name": "Romance Dawn",
			"set_code": "OP01",
			"card_number": "008"
		},
	]
	
	# Duplicar para tener más cartas de prueba
	for i in range(4):
		for card in sample_cards:
			var duplicated_card = card.duplicate(true)
			duplicated_card["id"] = card["id"] + "_copy" + str(i)
			all_cards.append(duplicated_card)
	
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
	print("Carta clickeada: ", card.get_card_data().get("name", "Unknown"))
	# Mostrar modal de preview
	if preview_modal:
		preview_modal.show_card(card.get_card_data())

func _on_card_hovered(card: Card) -> void:
	# TODO: Mostrar tooltip o info adicional en el futuro
	pass

## Modal cerrado
func _on_preview_modal_closed() -> void:
	print("Preview modal cerrado")

## Volver al menú principal
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
