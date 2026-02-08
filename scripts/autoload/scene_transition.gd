extends CanvasLayer

## SceneTransition - Sistema de transiciones suaves entre escenas
## Autoload singleton para gestionar cambios de escena con efectos visuales

signal transition_started()
signal transition_finished()

# Referencias
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

# Estado
var is_transitioning: bool = false
var next_scene_path: String = ""

func _ready() -> void:
	# Asegurar que el color rect esté arriba de todo
	color_rect.color = Color(0, 0, 0, 0)
	_create_animations()

## Cambiar de escena con transición fade
func change_scene(scene_path: String, duration: float = 0.5) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	next_scene_path = scene_path
	transition_started.emit()
	
	# Fade out
	await _fade_out(duration / 2.0)
	
	# Cambiar escena
	get_tree().change_scene_to_file(scene_path)
	
	# Esperar un frame para que la escena se cargue
	await get_tree().process_frame
	
	# Fade in
	await _fade_in(duration / 2.0)
	
	is_transitioning = false
	transition_finished.emit()

## Fade out (negro)
func _fade_out(duration: float) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished

## Fade in (transparente)
func _fade_in(duration: float) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	await tween.finished

## Transición rápida (para loading screens)
func quick_fade(duration: float = 0.2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	tween.tween_property(color_rect, "color:a", 0.0, duration)

## Crear animaciones predefinidas
func _create_animations() -> void:
	var anim_lib = AnimationLibrary.new()
	
	# Animación fade out
	var fade_out_anim = Animation.new()
	fade_out_anim.length = 0.5
	var track_out = fade_out_anim.add_track(Animation.TYPE_VALUE)
	fade_out_anim.track_set_path(track_out, "ColorRect:color:a")
	fade_out_anim.track_insert_key(track_out, 0.0, 0.0)
	fade_out_anim.track_insert_key(track_out, 0.5, 1.0)
	anim_lib.add_animation("fade_out", fade_out_anim)
	
	# Animación fade in
	var fade_in_anim = Animation.new()
	fade_in_anim.length = 0.5
	var track_in = fade_in_anim.add_track(Animation.TYPE_VALUE)
	fade_in_anim.track_set_path(track_in, "ColorRect:color:a")
	fade_in_anim.track_insert_key(track_in, 0.0, 1.0)
	fade_in_anim.track_insert_key(track_in, 0.5, 0.0)
	anim_lib.add_animation("fade_in", fade_in_anim)
	
	animation_player.add_animation_library("", anim_lib)

## Obtener si está en transición
func is_in_transition() -> bool:
	return is_transitioning
