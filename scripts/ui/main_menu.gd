extends Control

## Script del menú principal
## Maneja la navegación entre las diferentes secciones del juego

func _ready() -> void:
	print("Menú principal cargado")
	# Aquí podríamos cargar configuraciones, música de fondo, etc.

func _on_play_button_pressed() -> void:
	print("Botón Jugar presionado")
	# TODO: Cargar escena de juego
	# get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")
	_show_coming_soon("Modo de Juego")

func _on_collection_button_pressed() -> void:
	print("Botón Colección presionado")
	# TODO: Cargar escena de colección
	get_tree().change_scene_to_file("res://scenes/collection/collection_screen.tscn")

func _on_deck_builder_button_pressed() -> void:
	print("Botón Constructor de Mazos presionado")
	# TODO: Cargar escena de constructor de mazos
	# get_tree().change_scene_to_file("res://scenes/deck_builder/deck_builder.tscn")
	_show_coming_soon("Constructor de Mazos")

func _on_options_button_pressed() -> void:
	print("Botón Opciones presionado")
	# TODO: Abrir panel de opciones
	_show_coming_soon("Opciones")

func _on_exit_button_pressed() -> void:
	print("Saliendo del juego...")
	get_tree().quit()

## Método temporal para mostrar mensaje de "próximamente"
func _show_coming_soon(feature_name: String) -> void:
	print("Característica '%s' próximamente..." % feature_name)
	# TODO: Mostrar un diálogo bonito en lugar de solo un print
