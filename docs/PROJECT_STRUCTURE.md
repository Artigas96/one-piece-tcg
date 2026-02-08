# 📁 Estructura del Proyecto

Documentación de la organización de carpetas y archivos del proyecto One Piece TCG.

```
one-piece-tcg/
│
├── .git/                       # Control de versiones
├── .godot/                     # Archivos internos de Godot (ignorado)
│
├── scenes/                     # Escenas de Godot (.tscn)
│   ├── main_menu.tscn         # Menú principal
│   ├── collection/            # Pantallas de colección
│   │   ├── collection_screen.tscn
│   │   └── card_preview.tscn
│   ├── deck_builder/          # Constructor de mazos
│   │   ├── deck_builder.tscn
│   │   └── deck_list.tscn
│   ├── game/                  # Escenas de juego
│   │   ├── game_scene.tscn
│   │   ├── board.tscn
│   │   ├── player_area.tscn
│   │   └── card_zones/
│   │       ├── leader_zone.tscn
│   │       ├── character_zone.tscn
│   │       ├── hand_zone.tscn
│   │       └── don_zone.tscn
│   └── ui/                    # Componentes de UI reutilizables
│       ├── card.tscn          # Carta individual
│       ├── button_custom.tscn
│       └── dialog_box.tscn
│
├── scripts/                   # Scripts GDScript (.gd)
│   ├── autoload/             # Singletons (AutoLoad)
│   │   ├── game_manager.gd
│   │   ├── api_service.gd
│   │   ├── card_database.gd
│   │   └── save_system.gd
│   ├── models/               # Clases de datos
│   │   ├── card.gd
│   │   ├── deck.gd
│   │   ├── player.gd
│   │   └── game_state.gd
│   ├── ui/                   # Lógica de UI
│   │   ├── main_menu.gd
│   │   ├── collection_screen.gd
│   │   └── deck_builder.gd
│   ├── game/                 # Lógica del juego
│   │   ├── board_controller.gd
│   │   ├── turn_manager.gd
│   │   ├── effect_resolver.gd
│   │   └── combat_system.gd
│   ├── ai/                   # Inteligencia artificial
│   │   ├── ai_controller.gd
│   │   ├── ai_easy.gd
│   │   ├── ai_normal.gd
│   │   └── ai_hard.gd
│   └── utils/                # Utilidades
│       ├── constants.gd
│       ├── signals.gd
│       └── helpers.gd
│
├── assets/                   # Recursos del juego
│   ├── images/              # Imágenes y texturas
│   │   ├── cards/          # Imágenes de cartas (cacheadas desde API)
│   │   ├── ui/             # Elementos de interfaz
│   │   ├── backgrounds/    # Fondos de pantalla
│   │   └── icons/          # Iconografía
│   ├── fonts/              # Fuentes tipográficas
│   │   ├── main_font.ttf
│   │   └── title_font.ttf
│   ├── audio/              # Audio del juego
│   │   ├── music/          # Música de fondo
│   │   └── sfx/            # Efectos de sonido
│   └── shaders/            # Shaders personalizados
│       ├── card_glow.gdshader
│       └── holographic.gdshader
│
├── data/                    # Datos del juego
│   ├── cards/              # Caché local de cartas
│   │   ├── cards_cache.json
│   │   └── sets_info.json
│   ├── decks/              # Mazos guardados
│   │   └── [player_decks].json
│   └── collections/        # Colección del jugador
│       └── player_collection.json
│
├── docs/                    # Documentación
│   ├── GDD.md              # Game Design Document
│   ├── API_GUIDE.md        # Guía de uso de la API
│   └── CONTRIBUTING.md     # Guía de contribución
│
├── tests/                   # Tests unitarios (futuro)
│   ├── test_card.gd
│   ├── test_deck.gd
│   └── test_game_logic.gd
│
├── .gitignore              # Archivos ignorados por Git
├── project.godot           # Configuración del proyecto Godot
├── README.md               # Documentación principal
├── ROADMAP.md              # Fases de desarrollo
└── LICENSE                 # Licencia del proyecto

```

## 📝 Convenciones de Nombres

### Archivos
- **Escenas:** `snake_case.tscn` (ej: `main_menu.tscn`)
- **Scripts:** `snake_case.gd` (ej: `card_database.gd`)
- **Clases:** `PascalCase` dentro del código (ej: `class_name CardDatabase`)
- **Assets:** `snake_case` con prefijos descriptivos (ej: `bg_ocean.png`)

### Carpetas
- Siempre en `snake_case`
- Nombres descriptivos y concisos
- Agrupación lógica por funcionalidad

## 🔧 AutoLoad (Singletons)

Scripts configurados como AutoLoad en `Project Settings > AutoLoad`:

1. **GameManager** (`scripts/autoload/game_manager.gd`)
   - Gestor global del estado del juego
   - Transiciones entre escenas

2. **APIService** (`scripts/autoload/api_service.gd`)
   - Comunicación con OPTCG API
   - Gestión de peticiones HTTP

3. **CardDatabase** (`scripts/autoload/card_database.gd`)
   - Caché local de todas las cartas
   - Búsqueda y filtrado

4. **SaveSystem** (`scripts/autoload/save_system.gd`)
   - Guardado y carga de datos
   - Persistencia de colección y mazos

## 📦 Recursos y Assets

### Imágenes de Cartas
- **Ubicación:** `assets/images/cards/`
- **Formato:** PNG o WebP
- **Resolución:** 421x614 (tamaño oficial OPTCG)
- **Nomenclatura:** `{set_id}_{card_number}.png` (ej: `OP01_001.png`)

### Caché de Datos
- **Ubicación:** `data/cards/`
- **Formato:** JSON
- **Actualización:** Automática desde API
- **Backup:** Incluir datos base en el repositorio

## 🚀 Orden de Implementación

1. **Fase 0:** Crear estructura base (actual)
2. **Fase 1:** Implementar escenas de UI y componente de carta
3. **Fase 2:** Integrar APIService y CardDatabase
4. **Fase 3:** Desarrollar sistema de colección
5. **Fase 4:** Constructor de mazos
6. **Fase 5+:** Motor de juego y IA

## 📚 Referencias Rápidas

- **Escena principal:** `scenes/main_menu.tscn`
- **Script principal:** `scripts/autoload/game_manager.gd`
- **Modelo de carta:** `scripts/models/card.gd`
- **Documentación:** `docs/GDD.md`

---

**Nota:** Esta estructura es flexible y puede evolucionar según las necesidades del proyecto.