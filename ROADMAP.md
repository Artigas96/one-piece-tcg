# 🗺️ Roadmap de Desarrollo - One Piece TCG

Documento que detalla las fases de desarrollo del proyecto One Piece TCG.

---

## 📋 Fase 0: Configuración Inicial
**Estado:** 🟢 En progreso  
**Duración estimada:** 1 semana

### Tareas
- [x] Crear repositorio en GitHub
- [x] Documentar README inicial
- [x] Investigar APIs disponibles
- [ ] Configurar proyecto Godot 4
- [ ] Configurar .gitignore para Godot
- [ ] Establecer estructura de carpetas base
- [ ] Crear documento de diseño técnico (GDD)

---

## 🎨 Fase 1: Prototipo Visual
**Estado:** ⚪ Pendiente  
**Duración estimada:** 2-3 semanas

### Objetivos
Crear la interfaz base y sistema de visualización de cartas.

### Tareas
- [ ] Diseñar mockups de UI principal
- [ ] Implementar escena de menú principal
- [ ] Crear componente de carta (Card.tscn)
  - [ ] Diseño visual de carta
  - [ ] Mostrar imagen, nombre, coste, poder
  - [ ] Animaciones básicas (hover, selección)
- [ ] Implementar sistema de grid para mostrar colección
- [ ] Crear sistema de zoom/preview de carta
- [ ] Añadir efectos visuales básicos (transiciones, partículas)

### Entregables
- Menú navegable
- Visualización de cartas con datos dummy
- Preview interactivo de cartas

---

## 🔌 Fase 2: Integración con API
**Estado:** ⚪ Pendiente  
**Duración estimada:** 2 semanas

### Objetivos
Conectar el juego con OPTCG API y cargar datos reales.

### Tareas
- [ ] Crear servicio HTTPRequest para API
- [ ] Implementar sistema de caché local de datos
- [ ] Crear modelos de datos (Card, Set, Deck)
- [ ] Descargar y cachear imágenes de cartas
- [ ] Implementar sistema de actualización de datos
- [ ] Crear gestor de errores de red
- [ ] Implementar loading screens
- [ ] Sistema de búsqueda y filtros
  - [ ] Por nombre
  - [ ] Por color
  - [ ] Por tipo (Leader, Character, Event, Stage)
  - [ ] Por rareza
  - [ ] Por set

### Entregables
- Sistema funcional de carga de cartas reales
- Buscador con filtros múltiples
- Caché de datos para modo offline

---

## 📚 Fase 3: Sistema de Colección
**Estado:** ⚪ Pendiente  
**Duración estimada:** 2-3 semanas

### Objetivos
Permitir al jugador gestionar su colección personal.

### Tareas
- [ ] Implementar sistema de guardado local
- [ ] Crear base de datos de colección del jugador
- [ ] UI de galería de colección
  - [ ] Vista de lista
  - [ ] Vista de grid
  - [ ] Ordenación y filtros
- [ ] Sistema de "cartas obtenidas/faltantes"
- [ ] Estadísticas de colección
  - [ ] Porcentaje completado por set
  - [ ] Total de cartas únicas
  - [ ] Rareza de colección
- [ ] Sistema de favoritos/marcadores
- [ ] Importar/exportar colección (JSON)

### Entregables
- Gestión completa de colección personal
- Persistencia de datos
- Sistema de estadísticas

---

## 🃏 Fase 4: Constructor de Mazos
**Estado:** ⚪ Pendiente  
**Duración estimada:** 3-4 semanas

### Objetivos
Crear herramienta para construir y gestionar mazos.

### Tareas
- [ ] UI de constructor de mazos
  - [ ] Panel de colección disponible
  - [ ] Panel de mazo en construcción
  - [ ] Drag & drop de cartas
- [ ] Sistema de validación de mazos
  - [ ] Exactamente 50 cartas
  - [ ] 1 líder obligatorio
  - [ ] Máximo 4 copias por carta
  - [ ] Validación de colores según líder
- [ ] Gestión de múltiples mazos
  - [ ] Crear, editar, eliminar
  - [ ] Nombrar y categorizar mazos
- [ ] Estadísticas de mazo
  - [ ] Curva de coste
  - [ ] Distribución de tipos
  - [ ] Análisis de colores
- [ ] Importar/exportar mazos (formato estándar)
- [ ] Sistema de arquetipos/templates

### Entregables
- Constructor funcional con validación
- Gestión de múltiples mazos
- Herramientas de análisis de mazo

---

## 🎲 Fase 5: Motor de Juego (Core)
**Estado:** ⚪ Pendiente  
**Duración estimada:** 6-8 semanas

### Objetivos
Implementar las mecánicas básicas del juego.

### Tareas
- [ ] Sistema de tablero de juego
  - [ ] Zona de líder
  - [ ] Zona de personajes
  - [ ] Zona de mano
  - [ ] Mazo y cementerio
  - [ ] Zona de DON!!
- [ ] Sistema de turnos
  - [ ] Refresh phase
  - [ ] Draw phase
  - [ ] DON!! phase
  - [ ] Main phase
  - [ ] End phase
- [ ] Mecánicas básicas
  - [ ] Jugar cartas desde la mano
  - [ ] Sistema de costes y DON!!
  - [ ] Atacar con personajes
  - [ ] Bloques y contra-ataques
  - [ ] Gestión de vida del líder
- [ ] Sistema de efectos de cartas
  - [ ] Parser de efectos
  - [ ] Sistema de triggers
  - [ ] Resolución de efectos en pila
- [ ] Detección de victoria/derrota
- [ ] Sistema de log de juego

### Entregables
- Motor de juego funcional
- Mecánicas core implementadas
- Sistema de efectos básico

---

## 🤖 Fase 6: Inteligencia Artificial
**Estado:** ⚪ Pendiente  
**Duración estimada:** 4-5 semanas

### Objetivos
Crear IA para jugar contra la máquina.

### Tareas
- [ ] IA nivel Fácil
  - [ ] Decisiones aleatorias válidas
  - [ ] Priorización básica
- [ ] IA nivel Normal
  - [ ] Sistema de evaluación de tablero
  - [ ] Estrategias básicas de ataque/defensa
- [ ] IA nivel Difícil
  - [ ] Árbol de decisión complejo
  - [ ] Predicción de jugadas del oponente
  - [ ] Optimización de recursos
- [ ] Sistema de personalidades de IA
  - [ ] Agresiva
  - [ ] Defensiva
  - [ ] Control
  - [ ] Tempo

### Entregables
- 3 niveles de dificultad
- IA capaz de jugar partidas completas
- Diferentes estilos de juego

---

## ✨ Fase 7: Pulido Visual y UX
**Estado:** ⚪ Pendiente  
**Duración estimada:** 3-4 semanas

### Objetivos
Mejorar la experiencia visual y de usuario.

### Tareas
- [ ] Animaciones avanzadas
  - [ ] Efectos de cartas especiales
  - [ ] Animaciones de ataque
  - [ ] Transiciones fluidas
  - [ ] Partículas y shaders
- [ ] Efectos de sonido
  - [ ] SFX para acciones
  - [ ] Música de fondo
  - [ ] Voces de personajes (opcional)
- [ ] Feedback visual
  - [ ] Indicadores de acciones válidas
  - [ ] Highlights y glow effects
  - [ ] Tooltips informativos
- [ ] Optimización de rendimiento
- [ ] Responsive UI para diferentes resoluciones
- [ ] Tema visual One Piece
  - [ ] Fondos temáticos
  - [ ] Iconografía personalizada
  - [ ] Fuentes custom

### Entregables
- Experiencia visual pulida
- Audio implementado
- UI/UX optimizada

---

## 🌐 Fase 8: Funcionalidades Online (Opcional)
**Estado:** ⚪ Futuro  
**Duración estimada:** 6-8 semanas

### Objetivos
Añadir capacidades multijugador y online.

### Tareas
- [ ] Sistema de cuentas de usuario
- [ ] Matchmaking
- [ ] Partidas online 1v1
- [ ] Sistema de chat
- [ ] Rankings y leaderboards
- [ ] Sistema de torneos
- [ ] Replay de partidas
- [ ] Integración con Discord

### Entregables
- Multijugador funcional
- Sistema competitivo
- Comunidad online

---

## 📦 Fase 9: Lanzamiento y Post-Lanzamiento
**Estado:** ⚪ Futuro  
**Duración estimada:** 2-3 semanas

### Tareas
- [ ] Testing exhaustivo
- [ ] Corrección de bugs críticos
- [ ] Documentación de usuario
- [ ] Preparar builds para distribución
  - [ ] Windows
  - [ ] Linux
  - [ ] macOS
  - [ ] Web (HTML5)
- [ ] Crear página de itch.io o similar
- [ ] Marketing y promoción
- [ ] Recopilar feedback de usuarios
- [ ] Plan de actualizaciones futuras

### Entregables
- Versión 1.0 estable
- Distribución multiplataforma
- Documentación completa

---

## 📊 Métricas de Éxito

### Por Fase
- **Fase 1-2:** Prototipo jugable mostrando cartas reales
- **Fase 3-4:** Sistema de gestión completo funcional
- **Fase 5-6:** Partida completa jugable contra IA
- **Fase 7:** Experiencia pulida y profesional
- **Fase 8:** Comunidad activa de jugadores
- **Fase 9:** 1000+ descargas en primer mes

---

## 🔄 Metodología

- **Sprints:** Iteraciones de 1-2 semanas
- **Testing:** Continuo durante todo el desarrollo
- **Code Reviews:** Antes de merge a main
- **Documentación:** Actualizada con cada feature

---

## 📝 Notas

- Las fases pueden solaparse si hay múltiples desarrolladores
- Las estimaciones son aproximadas y pueden variar
- Priorizar funcionalidad sobre perfección en primeras fases
- Mantener el proyecto modular para facilitar cambios

---

**Última actualización:** Febrero 2026  
**Versión del roadmap:** 1.0
