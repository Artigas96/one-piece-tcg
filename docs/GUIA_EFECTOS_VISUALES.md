# 🎨 Guía de Efectos Visuales - Mejores Prácticas

## 📐 Principios de Diseño Implementados

### 1. Feedback Visual Inmediato
✅ **Qué se implementó:**
- Hover sobre cartas → Escala y brillo
- Click en carta → Efecto de presión
- Hover sobre botones → Crecimiento suave

💡 **Por qué es importante:**
- El usuario necesita saber que su acción fue detectada
- Mejora la sensación de "tangibilidad" de la UI
- Hace que la aplicación se sienta responsiva

### 2. Animaciones con Propósito
✅ **Qué se implementó:**
- Transiciones fade entre escenas (evita cambios abruptos)
- Entrada animada del menú (crea impacto)
- Partículas solo en cartas raras (jerarquía visual)

💡 **Por qué es importante:**
- Las animaciones guían la atención del usuario
- Diferencian elementos importantes de los comunes
- Crean una experiencia más "premium"

### 3. Timing Apropiado
✅ **Duración de animaciones implementadas:**
```gdscript
Hover in:       0.2s (rápido, responsivo)
Hover out:      0.15s (más rápido para no molestar)
Modal fade in:  0.3s (medio, elegante)
Scene transition: 0.5s (lento, suave)
```

💡 **Regla general:**
- Interacciones frecuentes → Rápido (0.1-0.2s)
- Efectos secundarios → Medio (0.3-0.5s)
- Transiciones grandes → Lento (0.5-1s)

---

## 🎯 Anatomía de un Buen Efecto Visual

### Ejemplo: Hover de Carta

```gdscript
func _animate_hover_in() -> void:
    # 1. Cancelar animación anterior (importante!)
    if hover_tween:
        hover_tween.kill()
    
    # 2. Crear nueva animación
    hover_tween = create_tween()
    
    # 3. Configurar curvas (facilidad de movimiento)
    hover_tween.set_parallel(true)        # Múltiples propiedades a la vez
    hover_tween.set_ease(Tween.EASE_OUT)  # Decelera al final
    hover_tween.set_trans(Tween.TRANS_CUBIC)  # Curva suave
    
    # 4. Animar propiedades
    hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
    
    # 5. Efectos adicionales
    z_index = 10  # Traer al frente
    hover_effect.visible = true
    glow_particles.emitting = true  # Solo para raras
```

### Componentes Clave:
1. **Kill anterior** → Previene conflictos
2. **Parallel** → Múltiples animaciones sincronizadas
3. **Ease/Trans** → Movimiento natural
4. **Duración corta** → Responsivo
5. **Efectos complementarios** → Refuerza la acción

---

## ✨ Tipos de Efectos Implementados

### 1. Tweens (Interpolación)
**Qué hace:** Anima valores de propiedades suavemente  
**Casos de uso:** Escala, posición, color, transparencia  
**Ejemplo:**
```gdscript
var tween = create_tween()
tween.tween_property(node, "modulate:a", 1.0, 0.5)
```

### 2. Partículas (CPUParticles2D)
**Qué hace:** Emite pequeñas imágenes que simulan efectos  
**Casos de uso:** Brillo, magia, impacto, polvo  
**Ejemplo:**
```gdscript
glow_particles.emitting = true
glow_particles.color = Color(1, 1, 0.5, 1)
glow_particles.amount = 30
```

### 3. Signals (Eventos)
**Qué hace:** Comunica acciones entre nodos  
**Casos de uso:** Click, hover, completar animación  
**Ejemplo:**
```gdscript
signal card_clicked(card: Card)
# ...
card_clicked.emit(self)
```

---

## 📊 Curvas de Animación (Easing)

### EASE_IN
```
Lento → Rápido
^
|     ___/
|   _/
| _/
+---------> t
```
**Uso:** Objetos acelerando (caída, lanzamiento)

### EASE_OUT
```
Rápido → Lento
^
|\___
|    \___
|        \___
+---------> t
```
**Uso:** Objetos frenando (hover, aparecer)  
✅ **El más usado en la Fase 1**

### EASE_IN_OUT
```
Lento → Rápido → Lento
^
|   ___
| _/   \_
|/       \__
+---------> t
```
**Uso:** Movimientos naturales (ida y vuelta)

---

## 🎨 Paleta de Colores por Tipo de Carta

```gdscript
const COLOR_MAP = {
    "Red":    Color(0.9, 0.2, 0.2),  # Rojo intenso
    "Blue":   Color(0.2, 0.4, 0.9),  # Azul profundo
    "Green":  Color(0.2, 0.8, 0.2),  # Verde vibrante
    "Purple": Color(0.6, 0.2, 0.8),  # Morado mágico
    "Yellow": Color(0.9, 0.8, 0.2),  # Amarillo dorado
    "Black":  Color(0.2, 0.2, 0.2),  # Negro oscuro
}
```

### Aplicaciones:
- **Indicador de color** en la carta
- **Color de partículas** según elemento
- **Tinte del modal** de preview (futuro)
- **Tema del mazo** en deck builder (futuro)

---

## 🔊 Audio (Fase 7 - Futuro)

### Preparación para Audio
Cuando llegues a la Fase 7, aquí tienes sugerencias:

```gdscript
# Ejemplo futuro
func _on_card_clicked(card: Card) -> void:
    AudioManager.play_sfx("card_select")  # SFX corto
    preview_modal.show_card(card.get_card_data())

func _animate_hover_in() -> void:
    # ...
    AudioManager.play_sfx("card_hover", 0.3)  # Volumen bajo
```

### SFX Recomendados:
- `card_hover.wav` → Sonido sutil (papel rozando)
- `card_select.wav` → Click satisfactorio
- `card_draw.wav` → Deslizar carta
- `button_click.wav` → Click de botón
- `transition_whoosh.wav` → Cambio de escena

---

## ⚡ Optimización de Rendimiento

### Problema: Muchas Cartas = Lag

**Solución 1: Limit Particles**
```gdscript
# Solo activar partículas si la carta es visible
func _on_mouse_entered() -> void:
    if is_visible_in_tree() and rarity in ["R", "SR", "SEC", "L"]:
        glow_particles.emitting = true
```

**Solución 2: Pool de Objetos**
```gdscript
# Reutilizar cartas en lugar de crear/destruir
var card_pool: Array[Card] = []

func get_card_from_pool() -> Card:
    if card_pool.is_empty():
        return CARD_SCENE.instantiate()
    return card_pool.pop_back()

func return_card_to_pool(card: Card) -> void:
    card.visible = false
    card_pool.append(card)
```

**Solución 3: Culling**
```gdscript
# Desactivar efectos de cartas fuera de pantalla
func _process(delta: float) -> void:
    if not get_viewport_rect().has_point(global_position):
        glow_particles.emitting = false
```

---

## 🎭 Patrones de Animación Comunes

### Patrón 1: Bounce (Rebote)
```gdscript
var tween = create_tween()
tween.set_trans(Tween.TRANS_ELASTIC)  # ← La clave
tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.3)
tween.tween_property(button, "scale", Vector2.ONE, 0.2)
```

### Patrón 2: Shake (Sacudida)
```gdscript
func shake(duration: float = 0.3, intensity: float = 5.0) -> void:
    var original_pos = position
    var tween = create_tween()
    var steps = 10
    for i in steps:
        var offset = Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_property(self, "position", original_pos + offset, duration / steps)
    tween.tween_property(self, "position", original_pos, duration / steps)
```

### Patrón 3: Pulse (Pulso)
```gdscript
func pulse() -> void:
    var tween = create_tween()
    tween.set_loops()  # Infinito
    tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.5)
    tween.tween_property(self, "scale", Vector2.ONE, 0.5)
```

---

## 🎪 Efectos Especiales Avanzados (Futuro)

### Efecto: Card Flip (Voltear Carta)
```gdscript
func flip_card() -> void:
    var tween = create_tween()
    # Escalar en X hasta 0 (cara oculta)
    tween.tween_property(self, "scale:x", 0.0, 0.2)
    # Cambiar imagen
    tween.tween_callback(func(): change_image())
    # Escalar de vuelta a 1
    tween.tween_property(self, "scale:x", 1.0, 0.2)
```

### Efecto: Glow Pulse (Brillo Pulsante)
```gdscript
func glow_pulse() -> void:
    var shader_material = material as ShaderMaterial
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(shader_material, "shader_parameter/glow_intensity", 1.5, 1.0)
    tween.tween_property(shader_material, "shader_parameter/glow_intensity", 0.5, 1.0)
```

### Efecto: Trail (Estela)
```gdscript
# Usar Line2D para crear estela de movimiento
var trail: Line2D = Line2D.new()
trail.width = 3.0
trail.default_color = Color(1, 1, 1, 0.5)

func _process(delta: float) -> void:
    trail.add_point(global_position)
    if trail.get_point_count() > 20:
        trail.remove_point(0)
```

---

## 📚 Recursos de Aprendizaje

### Documentación Oficial
- [Godot Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html)
- [CPUParticles2D](https://docs.godotengine.org/en/stable/classes/class_cpuparticles2d.html)
- [Easing Cheat Sheet](https://easings.net/)

### Herramientas Útiles
- **Cubic Bezier Tool:** https://cubic-bezier.com/
- **Color Picker:** https://coolors.co/
- **Particle Designer:** (Buscar en Godot Asset Library)

---

## ✅ Checklist de Calidad de Efectos

Antes de considerar un efecto "terminado", verifica:

- [ ] ¿La animación tiene una duración apropiada? (no muy lenta ni muy rápida)
- [ ] ¿Se puede cancelar/interrumpir sin bugs?
- [ ] ¿Funciona bien a 30 FPS? (no solo a 60)
- [ ] ¿El efecto tiene un propósito claro?
- [ ] ¿No marea al usuario con movimiento excesivo?
- [ ] ¿Escala bien con muchos objetos en pantalla?
- [ ] ¿Usa el easing correcto? (EASE_OUT para la mayoría)

---

## 🎓 Ejercicios Opcionales

### Ejercicio 1: Efecto de Rareza
Añade un brillo dorado a las cartas Secret Rare:
```gdscript
if rarity == "SEC":
    var pulse_tween = create_tween()
    pulse_tween.set_loops()
    pulse_tween.tween_property(color_indicator, "modulate", Color(2, 2, 1, 1), 1.0)
    pulse_tween.tween_property(color_indicator, "modulate", Color(1, 1, 1, 1), 1.0)
```

### Ejercicio 2: Efecto de Entrada
Añade un efecto de caída a las cartas cuando aparecen:
```gdscript
func appear_with_drop() -> void:
    position.y -= 100
    modulate.a = 0
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position:y", position.y + 100, 0.5)
    tween.tween_property(self, "modulate:a", 1.0, 0.3)
```

### Ejercicio 3: Contador Animado
Anima números al cambiar (útil para stats):
```gdscript
func animate_number(from: int, to: int, duration: float = 0.5) -> void:
    var tween = create_tween()
    tween.tween_method(
        func(value: float): 
            power_label.text = str(int(value)),
        float(from),
        float(to),
        duration
    )
```

---

## 🏆 Mejores Prácticas - Resumen

### DO ✅
- Usa `EASE_OUT` para la mayoría de interacciones
- Mantén las animaciones cortas (0.1-0.5s)
- Cancela tweens anteriores con `.kill()`
- Usa `set_parallel(true)` para múltiples propiedades
- Añade feedback inmediato (hover, click)

### DON'T ❌
- No uses animaciones > 1 segundo sin razón
- No olvides limpiar tweens (memory leaks)
- No uses partículas para todo (performance)
- No animes sin propósito (distrae)
- No uses `EASE_LINEAR` (se ve robótico)

---

## 🎉 Conclusión

Has implementado un sistema de efectos visuales profesional que:
- ✅ Da feedback inmediato al usuario
- ✅ Crea jerarquía visual (cartas raras brillan)
- ✅ Usa timing apropiado
- ✅ Es optimizado y escalable

**Siguiente nivel:** En la Fase 7, añadirás:
- Shaders personalizados
- Efectos de audio sincronizados
- Animaciones de combate
- Efectos de habilidades especiales

---

**¡Sigue así, tu proyecto se ve increíble! 🚀**

