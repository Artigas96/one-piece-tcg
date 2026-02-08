# Game Design Document (GDD)
## One Piece TCG - Digital Edition

---

## 📋 Información General

**Título:** One Piece TCG  
**Género:** Trading Card Game (TCG) Digital  
**Plataforma objetivo:** PC (Windows, Linux, macOS), Web  
**Motor:** Godot 4  
**Público objetivo:** Fans de One Piece y jugadores de TCG (12+ años)  
**Modo de juego:** Single Player (vs IA), Multijugador Online (Fase 8)  

---

## 🎯 Concepto Principal

Recreación digital del One Piece Card Game oficial, permitiendo a los jugadores:
- Coleccionar cartas del universo One Piece
- Construir mazos estratégicos
- Jugar partidas siguiendo las reglas oficiales
- Competir contra IA o jugadores reales

### Propuesta de Valor
- **Gratuito y accesible:** Sin necesidad de comprar cartas físicas
- **Fiel al juego original:** Reglas oficiales del OPTCG
- **Visualmente atractivo:** Animaciones y efectos inspirados en el anime
- **Actualizado:** Integración con API para nuevos sets

---

## 🎮 Mecánicas de Juego

### Reglas Básicas (OPTCG Official)

#### Componentes del Mazo
- **50 cartas totales** en el mazo principal
- **1 carta de Líder** (fuera del mazo)
- **Máximo 4 copias** de cada carta (excepto líder)
- **Cartas de colores compatibles** con el líder

#### Tipos de Cartas
1. **Leader (Líder)**
   - Define el color del mazo
   - Tiene vida (normalmente 4-5)
   - Puede atacar y tener efectos

2. **Character (Personaje)**
   - Cartas que se juegan en el campo
   - Tienen coste, poder y efectos
   - Pueden atacar y bloquear

3. **Event (Evento)**
   - Efectos de un solo uso
   - Se juegan y van al cementerio
   - No permanecen en el campo

4. **Stage (Escenario)**
   - Efectos permanentes
   - Permanecen en el campo
   - Máximo 1 Stage activo

#### Fases del Turno
1. **Refresh Phase:** Enderezar cartas y DON!!
2. **Draw Phase:** Robar 1 carta
3. **DON!! Phase:** Añadir 2 DON!! al mazo
4. **Main Phase:** Jugar cartas y atacar
5. **End Phase:** Fin del turno

#### Sistema DON!!
- Recurso principal del juego
- Se añaden 2 por turno al "mazo DON!!"
- Se pueden asignar a cartas para:
  - Pagar costes
  - Aumentar poder (+1000 por DON!!)

#### Combate
- Los personajes pueden atacar al líder enemigo
- El oponente puede bloquear con personajes
- Daño = Poder del atacante - Poder del bloqueador
- Si no hay bloqueo, el líder pierde vida

### Sistema de Efectos

#### Palabras Clave
- **[On Play]:** Al jugar la carta
- **[When Attacking]:** Al declarar ataque
- **[Blocker]:** Puede bloquear aunque esté descansada
- **[Rush]:** Puede atacar el turno que entra
- **[Banish]:** Remueve del juego
- **[Counter]:** Puede jugarse desde la mano en respuesta

---

## 🎨 Diseño Visual

### Estilo Artístico
- **Inspiración:** Anime de One Piece
- **Colores:** Vibrantes y saturados
- **UI:** Moderna pero con elementos náuticos/piratas
- **Efectos:** Partículas, brillos, animaciones fluidas

### Paleta de Colores por Tipo
- **Rojo:** Fuego, pasión, agresividad
- **Verde:** Naturaleza, crecimiento, vida
- **Azul:** Agua, control, inteligencia
- **Morado:** Poder, misterio
- **Amarillo:** Velocidad, luz
- **Negro:** Oscuridad, prohibido

### Elementos de UI

#### Menú Principal
- Fondo animado del mar/barco
- Botones principales:
  - Jugar
  - Colección
  - Constructor de Mazos
  - Opciones
  - Salir

#### Pantalla de Juego
- **Zona Superior:** Campo del oponente
- **Zona Central:** Tablero de juego
- **Zona Inferior:** Campo del jugador
- **Panel Lateral:** Log de acciones, info de carta
- **HUD:** Vida, DON!!, cartas en mano/mazo

---

## 🔧 Arquitectura Técnica

### Estructura de Datos

#### Card (Carta)
```gdscript
class_name Card extends Resource

var id: String
var name: String
var card_type: String  # Leader, Character, Event, Stage
var color: Array[String]  # Red, Blue, Green, etc.
var cost: int
var power: int
var counter: int
var attributes: Array[String]
var effect_text: String
var image_url: String
var rarity: String
var set_id: String
var card_number: String
```

#### Deck (Mazo)
```gdscript
class_name Deck extends Resource

var deck_name: String
var leader: Card
var cards: Array[Card]  # 50 cartas
var total_cards: int
var color_distribution: Dictionary
var cost_curve: Array[int]
```

#### GameState (Estado del Juego)
```gdscript
class_name GameState extends Node

var current_turn: int
var active_player: int  # 0 o 1
var phase: String
var player1: Player
var player2: Player
var effect_stack: Array
```

### Arquitectura de Escenas

```
Main
├── MainMenu
├── CollectionScreen
├── DeckBuilder
└── GameScene
    ├── Board
    │   ├── PlayerArea
    │   │   ├── LeaderZone
    │   │   ├── CharacterZone
    │   │   ├── DONZone
    │   │   ├── HandZone
    │   │   └── DeckZone
    │   └── OpponentArea
    │       └── [mismas zonas]
    ├── UI
    │   ├── HUD
    │   ├── ActionLog
    │   └── CardPreview
    └── GameManager
```

### Sistemas Principales

1. **APIService:** Gestión de peticiones HTTP a OPTCG API
2. **CardDatabase:** Caché local de cartas
3. **DeckManager:** CRUD de mazos
4. **GameEngine:** Lógica del juego
5. **EffectResolver:** Resolución de efectos
6. **AIController:** Inteligencia artificial
7. **SaveSystem:** Persistencia de datos

---

## 📊 Progresión del Jugador

### Sistema de Colección
- **Cartas iniciales:** Set básico al empezar
- **Obtención de cartas:** 
  - Packs gratis diarios
  - Recompensas por victorias
  - Sistema de crafteo (opcional)

### Logros y Desafíos
- Completar sets
- Ganar X partidas con cada color
- Derrotar IA en máxima dificultad
- Construir X mazos diferentes

---

## 🎵 Audio

### Música
- **Menú:** Tema relajado de One Piece
- **Combate:** Música épica/batalla
- **Victoria:** Fanfarria triunfal
- **Derrota:** Música melancólica

### Efectos de Sonido
- Barajar cartas
- Jugar carta
- Ataque
- Efecto especial
- Click UI
- Notificaciones

---

## 🚀 Características Únicas

### Diferenciadores
1. **Integración API:** Siempre actualizado con nuevos sets
2. **Modo Tutorial Interactivo:** Aprende jugando
3. **Análisis de Mazo:** Estadísticas detalladas
4. **Replay System:** Revive tus mejores partidas
5. **Temática Fiel:** Ambientación One Piece auténtica

---

## 📈 Métricas de Éxito

### KPIs Técnicos
- Tiempo de carga < 3 segundos
- FPS estable a 60
- Tamaño de build < 500MB
- 0 bugs críticos en release

### KPIs de Usuario
- Retención día 1 > 60%
- Tiempo promedio de sesión > 20 min
- Partidas completadas/iniciadas > 80%
- Rating > 4.5/5

---

## 🛠️ Herramientas de Desarrollo

- **Motor:** Godot 4.3+
- **Control de versiones:** Git + GitHub
- **Gestión de proyecto:** GitHub Projects
- **Testing:** GDScript Test Framework
- **CI/CD:** GitHub Actions (futuro)

---

## 📝 Riesgos y Mitigación

### Riesgos Identificados

1. **Legal - Uso de propiedad intelectual**
   - Mitigación: Proyecto no comercial, fan-made, dar créditos

2. **Técnico - Complejidad del motor de efectos**
   - Mitigación: Implementación iterativa, efectos básicos primero

3. **Diseño - Balance de IA**
   - Mitigación: Múltiples niveles de dificultad, testing extensivo

4. **Alcance - Feature creep**
   - Mitigación: Roadmap estricto, MVP bien definido

---

## 🎯 Definición de Completado (MVP)

### Versión 1.0 debe incluir:
- ✅ Colección de al menos 3 sets completos
- ✅ Constructor de mazos funcional
- ✅ Partidas contra IA (3 niveles)
- ✅ Reglas oficiales implementadas
- ✅ UI pulida y responsiva
- ✅ Tutorial interactivo
- ✅ Sistema de guardado

---

## 📚 Referencias

- [One Piece Card Game Official Rules](https://en.onepiece-cardgame.com/rule/)
- [OPTCG API Documentation](https://optcgapi.com/)
- [Godot Documentation](https://docs.godotengine.org/)
- [One Piece TCG Community Resources](https://onepiece.gg/)

---

**Versión del documento:** 1.0  
**Última actualización:** Febrero 2026  
**Autor:** Artigas96