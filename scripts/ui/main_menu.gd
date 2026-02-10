extends Control

## Script del menú principal mejorado
## Maneja la navegación entre las diferentes secciones del juego con transiciones suaves

@onready var buttons_container: VBoxContainer = $VBoxContainer
@onready var title_label: Label = $VBoxContainer/Title
@onready var version_label: Label = $VersionLabel

# Efectos
var button_hover_tween: Tween

func _ready() -> void:
	print("Menú principal cargado")
	_animate_menu_entrance()
	_setup_button_effects()

## Animar entrada del menú
func _animate_menu_entrance() -> void:
	# Empezar con elementos invisibles
	buttons_container.modulate.a = 0
	buttons_container.position.y += 50
	
	# Animar aparición
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(buttons_container, "modulate:a", 1.0, 0.6)
	tween.tween_property(buttons_container, "position:y", buttons_container.position.y - 50, 0.6)

## Configurar efectos de hover en botones
func _setup_button_effects() -> void:
	# Obtener todos los botones del container
	for child in buttons_container.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_button_hover.bind(child))
			child.mouse_exited.connect(_on_button_unhover.bind(child))

## Efecto hover en botones
func _on_button_hover(button: Button) -> void:
	if button_hover_tween:
		button_hover_tween.kill()
	
	button_hover_tween = create_tween()
	button_hover_tween.set_ease(Tween.EASE_OUT)
	button_hover_tween.set_trans(Tween.TRANS_BACK)
	button_hover_tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2)

func _on_button_unhover(button: Button) -> void:
	if button_hover_tween:
		button_hover_tween.kill()
	
	button_hover_tween = create_tween()
	button_hover_tween.set_ease(Tween.EASE_OUT)
	button_hover_tween.set_trans(Tween.TRANS_BACK)
	button_hover_tween.tween_property(button, "scale", Vector2.ONE, 0.15)

## Callbacks de botones
func _on_play_button_pressed() -> void:
	print("Botón Jugar presionado")
	_show_coming_soon("Modo de Juego")

func _on_collection_button_pressed() -> void:
	print("Botón Colección presionado")
	# Usar sistema de transiciones si está disponible
	var scene_transition = get_node_or_null("/root/SceneTransition")
	if scene_transition:
		scene_transition.change_scene("res://scenes/collection/collection_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/collection/collection_screen.tscn")

func _on_deck_builder_button_pressed() -> void:
	print("Botón Constructor de Mazos presionado")
	_show_coming_soon("Constructor de Mazos")

func _on_options_button_pressed() -> void:
	print("Botón Opciones presionado")
	_show_coming_soon("Opciones")

func _on_exit_button_pressed() -> void:
	print("Saliendo del juego...")
	# Animación de salida
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(buttons_container, "modulate:a", 0.0, 0.3)
	tween.tween_property(buttons_container, "position:y", buttons_container.position.y + 30, 0.3)
	await tween.finished
	
	get_tree().quit()

## Método temporal para mostrar mensaje de "próximamente"
func _show_coming_soon(feature_name: String) -> void:
	print("Característica '%s' próximamente..." % feature_name)
	
	# TODO: En el futuro, mostrar un diálogo bonito
	# Por ahora, mostramos un label temporal
	var temp_label = Label.new()
	temp_label.text = "🚧 %s\n\nPróximamente..." % feature_name
	temp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	temp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	temp_label.add_theme_font_size_override("font_size", 32)
	temp_label.modulate = Color(1, 1, 1, 0)
	temp_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(temp_label)
	
	# Animar aparición y desaparición
	var tween = create_tween()
	tween.tween_property(temp_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(temp_label, "modulate:a", 0.0, 0.3)
	await tween.finished
	temp_label.queue_free()
