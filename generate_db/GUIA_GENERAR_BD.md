# 🗄️ Guía Completa: Generar Base de Datos de Cartas

## 📋 Índice de Opciones

1. **Script Python Automático** (RECOMENDADO) ⭐
2. **Importar desde CSV/Excel**
3. **Usar bases de datos de la comunidad**
4. **Editor visual en Godot**
5. **Scraping de sitios web**

---

## ⭐ Opción 1: Script Python Automático (RECOMENDADO)

### Instalación

```bash
# Instalar dependencias
pip install requests beautifulsoup4

# O con requirements.txt
pip install -r requirements.txt
```

### Uso Básico

```bash
# Ejecutar el script
python generate_database.py

# Salida: cards_database.json con ~30 cartas de ejemplo
```

### Expandir con Más Cartas

Edita `generate_database.py` y añade más cartas en `sample_cards`:

```python
sample_cards = [
    {
        "id": "OP04-001",
        "name": "Kaido",
        "type": "leader",
        "color": "p",
        "cost": 0,
        "power": 5000,
        "counter": 0,
        "attribute": "The Four Emperors,Animal Kingdom Pirates",
        "effect": "[DON!! x2] [When Attacking] This Leader gains +1000 power.",
        "rarity": "L",
        "number": "001",
        "set": "OP04"
    },
    # ... más cartas
]
```

---

## 📊 Opción 2: Importar desde CSV/Excel

### 2A. Desde CSV

**Paso 1:** Crea un archivo `cards.csv`:

```csv
id,name,type,color,cost,power,counter,attribute,effect,rarity,number,set
OP01-001,Monkey D. Luffy,leader,r,0,5000,0,Straw Hat Crew,[DON!! x1] When Attacking...,L,001,OP01
OP01-002,Roronoa Zoro,character,r,3,4000,1000,Straw Hat Crew,[DON!! x1] When Attacking...,SR,002,OP01
```

**Paso 2:** Script de conversión:

```python
import csv
import json

def csv_to_json(csv_file, json_file):
    cards = []
    
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            card = {
                "id": row['id'],
                "name": row['name'],
                "card_type": row['type'].capitalize(),
                "color": [row['color'].upper()],
                "cost": int(row['cost']),
                "power": int(row['power']),
                "counter": int(row['counter']),
                "attribute": row['attribute'].split(','),
                "effect": row['effect'],
                "rarity": row['rarity'],
                "set_code": row['set'],
                "card_number": row['number'],
                "image": ""
            }
            cards.append(card)
    
    data = {
        "sets": [...],  # Añadir sets manualmente
        "cards": cards
    }
    
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

# Usar
csv_to_json('cards.csv', 'cards_database.json')
```

### 2B. Desde Excel

```bash
pip install openpyxl pandas
```

```python
import pandas as pd
import json

def excel_to_json(excel_file, json_file):
    df = pd.read_excel(excel_file)
    
    cards = []
    for _, row in df.iterrows():
        card = {
            "id": row['ID'],
            "name": row['Name'],
            "card_type": row['Type'],
            "color": [row['Color']],
            "cost": int(row['Cost']),
            "power": int(row['Power']),
            "counter": int(row['Counter']),
            "attribute": row['Attribute'].split(','),
            "effect": row['Effect'],
            "rarity": row['Rarity'],
            "set_code": row['Set'],
            "card_number": row['Number'],
            "image": ""
        }
        cards.append(card)
    
    data = {
        "sets": [...],
        "cards": cards
    }
    
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

excel_to_json('cards.xlsx', 'cards_database.json')
```

---

## 🌐 Opción 3: Bases de Datos de la Comunidad

### Fuentes Recomendadas

1. **One Piece Card Game Database (GitHub)**
   ```bash
   git clone https://github.com/OnePieceTCG/card-database
   # Buscar en GitHub: "one piece tcg json"
   ```

2. **Sitios de la Comunidad**
   - https://onepiece-cardgame.dev (API pública)
   - https://onepiece.gg (base de datos visual)
   - https://limitless.gg/one-piece (decks y cartas)

3. **Reddit Community Resources**
   - r/OnePieceTCG - Sidebar con recursos
   - Búsqueda: "database json download"

### Ejemplo: Descargar desde onepiece-cardgame.dev

```python
import requests
import json

def download_from_opcg_dev():
    """
    Intenta descargar desde onepiece-cardgame.dev
    NOTA: Verifica primero que la API esté disponible
    """
    base_url = "https://onepiece-cardgame.dev/api/cards"
    
    all_cards = []
    page = 1
    
    while True:
        print(f"Descargando página {page}...")
        response = requests.get(f"{base_url}?page={page}")
        
        if response.status_code != 200:
            break
        
        data = response.json()
        cards = data.get('cards', [])
        
        if not cards:
            break
        
        all_cards.extend(cards)
        page += 1
    
    return all_cards
```

---

## 🎨 Opción 4: Editor Visual en Godot

Crear una herramienta dentro de Godot para añadir cartas:

```gdscript
# tools/card_editor.gd
@tool
extends Control

@onready var name_input: LineEdit = $VBox/NameInput
@onready var type_option: OptionButton = $VBox/TypeOption
@onready var save_button: Button = $VBox/SaveButton

var current_database: Dictionary = {}

func _ready():
    load_database()
    save_button.pressed.connect(_on_save_pressed)

func load_database():
    if FileAccess.file_exists("res://data/cards_database.json"):
        var file = FileAccess.open("res://data/cards_database.json", FileAccess.READ)
        current_database = JSON.parse_string(file.get_as_text())
        file.close()

func _on_save_pressed():
    var new_card = {
        "id": generate_id(),
        "name": name_input.text,
        "card_type": type_option.get_item_text(type_option.selected),
        # ... resto de campos
    }
    
    current_database["cards"].append(new_card)
    save_database()

func save_database():
    var file = FileAccess.open("res://data/cards_database.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(current_database, "\t"))
    file.close()
```

---

## 🕷️ Opción 5: Web Scraping

### Scraping de onepiece.gg

```python
import requests
from bs4 import BeautifulSoup
import json
import time

def scrape_onepiece_gg():
    """
    Scraping de ejemplo de onepiece.gg
    IMPORTANTE: Respetar robots.txt y rate limiting
    """
    base_url = "https://onepiece.gg/cards"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Educational Project)'
    }
    
    cards = []
    
    for set_code in ['OP01', 'OP02', 'OP03']:
        print(f"Scraping {set_code}...")
        url = f"{base_url}?set={set_code}"
        
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Encontrar elementos de carta
        card_elements = soup.find_all('div', class_='card-item')
        
        for card_elem in card_elements:
            card = {
                "id": card_elem.get('data-id'),
                "name": card_elem.find('h3').text.strip(),
                "card_type": card_elem.get('data-type'),
                # ... extraer más datos
            }
            cards.append(card)
        
        time.sleep(2)  # Rate limiting
    
    return cards

# IMPORTANTE: Siempre verificar robots.txt
# IMPORTANTE: Usar rate limiting (2+ segundos entre peticiones)
# IMPORTANTE: No sobrecargar servidores
```

---

## 🚀 Método RÁPIDO: Base de Datos Pre-generada

### Descargar Base de Datos Completa (Comunidad)

```bash
# Buscar en GitHub
gh repo search "one piece tcg database" --json name,url

# O descargar manualmente desde:
# https://github.com/search?q=one+piece+tcg+database+json
```

### Template de Base de Datos Vacía

```json
{
  "sets": [
    {
      "code": "OP01",
      "name": "Romance Dawn",
      "release_date": "2022-07-08",
      "total_cards": 121
    }
  ],
  "cards": [
    {
      "id": "",
      "name": "",
      "card_type": "Character",
      "color": ["Red"],
      "cost": 0,
      "power": 0,
      "counter": 0,
      "attribute": [],
      "effect": "",
      "rarity": "C",
      "set_name": "",
      "set_code": "",
      "card_number": "",
      "image": ""
    }
  ]
}
```

---

## 📝 Formato de Datos Requerido

### Campos Obligatorios

```json
{
  "id": "OP01-001",           // Único, formato: SET-NUMBER
  "name": "Monkey D. Luffy",  // Nombre de la carta
  "card_type": "Leader",      // Leader | Character | Event | Stage
  "color": ["Red"],           // Array: Red, Blue, Green, Purple, Yellow, Black
  "cost": 0,                  // 0-10 (Leader = 0)
  "power": 5000,              // 0-12000
  "counter": 0,               // 0, 1000, 2000
  "attribute": ["Straw Hat Crew"],  // Array de strings
  "effect": "...",            // Texto del efecto
  "rarity": "L",              // C, UC, R, SR, SEC, L
  "set_name": "Romance Dawn", // Nombre del set
  "set_code": "OP01",         // Código del set
  "card_number": "001",       // Número en el set
  "image": ""                 // URL o vacío
}
```

---

## 🎯 Estrategia Recomendada

### Para Empezar AHORA (10 minutos)

1. **Usa el script Python incluido**
   ```bash
   python generate_database.py
   ```
   → Genera 30 cartas de ejemplo

2. **Copia al proyecto**
   ```bash
   cp cards_database.json /path/to/godot/data/
   ```

3. **¡Juega y prueba!**

### Para Base de Datos COMPLETA (1-2 horas)

1. **Busca en GitHub**
   - "one piece tcg database json"
   - Descarga un repositorio completo

2. **O Scraping Manual**
   - Visita onepiece.gg
   - Copia datos manualmente a CSV
   - Convierte CSV → JSON

3. **O Scraping Automatizado**
   - Usa el script de scraping
   - Respeta rate limits
   - Verifica robots.txt

---

## ⚖️ Consideraciones Legales

### ✅ Permitido
- Bases de datos de fans para uso personal
- Proyectos no comerciales
- Educación y aprendizaje

### ⚠️ Ten Cuidado
- No redistribuir imágenes oficiales sin permiso
- No vender bases de datos
- Respetar términos de servicio de sitios web

### 📜 Recomendaciones
- Dar crédito a fuentes
- Incluir disclaimer: "Fan project, no affiliation with Bandai"
- No usar para fines comerciales

---

## 🐛 Solución de Problemas

### "Encoding error" al guardar JSON

```python
# Siempre usar encoding='utf-8'
with open(file, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False)
```

### "Caracteres extraños" en nombres japoneses

```python
# ensure_ascii=False preserva Unicode
json.dump(data, f, ensure_ascii=False)
```

### "JSON inválido" en Godot

Valida tu JSON en: https://jsonlint.com/

---

## 📚 Recursos Adicionales

### Comunidad
- Discord: One Piece Card Game Official
- Reddit: r/OnePieceTCG
- Twitter: #OPTCG

### Herramientas
- JSONLint: Validar JSON
- CSV to JSON converters (online)
- Postman: Probar APIs

### Bases de Datos Conocidas
- GitHub: "OnePieceTCG/card-database"
- onepiece-cardgame.dev
- onepiece.gg

---

## ✅ Checklist de Completado

- [ ] Decidí mi método preferido
- [ ] Instalé dependencias necesarias
- [ ] Generé o descargué la base de datos
- [ ] Validé el JSON
- [ ] Copié a `/data/cards_database.json`
- [ ] Probé en Godot
- [ ] ¡Funciona!

---

**¡Buena suerte generando tu base de datos! 🏴‍☠️**
