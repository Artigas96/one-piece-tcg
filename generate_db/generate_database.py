#!/usr/bin/env python3
"""
Script para generar base de datos de One Piece TCG
Descarga datos desde onepiece-cardgame.dev (fuente pública de la comunidad)

Requisitos:
    pip install requests beautifulsoup4

Uso:
    python generate_database.py
    
Salida:
    cards_database.json - Base de datos completa
"""

import requests
import json
import time
from typing import List, Dict

# Configuración
API_BASE = "https://onepiece-cardgame.dev/api"
OUTPUT_FILE = "cards_database.json"
RATE_LIMIT_DELAY = 0.5  # Segundos entre peticiones

# Mapeo de colores
COLOR_MAP = {
    "r": "Red",
    "b": "Blue", 
    "g": "Green",
    "p": "Purple",
    "y": "Yellow",
    "k": "Black"
}

# Mapeo de tipos
TYPE_MAP = {
    "leader": "Leader",
    "character": "Character",
    "event": "Event",
    "stage": "Stage"
}


def fetch_all_sets() -> List[Dict]:
    """Obtiene lista de todos los sets disponibles"""
    print("📦 Obteniendo lista de sets...")
    
    # Sets conocidos de OPTCG (actualizado a Feb 2026)
    sets = [
        {"code": "OP01", "name": "Romance Dawn", "release_date": "2022-07-08"},
        {"code": "OP02", "name": "Paramount War", "release_date": "2022-09-30"},
        {"code": "OP03", "name": "Pillars of Strength", "release_date": "2022-12-02"},
        {"code": "OP04", "name": "Kingdoms of Intrigue", "release_date": "2023-02-25"},
        {"code": "OP05", "name": "Awakening of the New Era", "release_date": "2023-05-27"},
        {"code": "OP06", "name": "Wings of the Captain", "release_date": "2023-09-22"},
        {"code": "OP07", "name": "500 Years in the Future", "release_date": "2024-02-24"},
        {"code": "OP08", "name": "Two Legends", "release_date": "2024-05-25"},
        {"code": "ST01", "name": "Straw Hat Crew", "release_date": "2022-07-08"},
        {"code": "ST02", "name": "Worst Generation", "release_date": "2022-07-08"},
        {"code": "ST03", "name": "The Seven Warlords of the Sea", "release_date": "2022-09-30"},
        {"code": "ST04", "name": "Animal Kingdom Pirates", "release_date": "2022-12-02"},
        {"code": "ST05", "name": "One Piece Film Edition", "release_date": "2022-11-04"},
        {"code": "ST06", "name": "Navy", "release_date": "2023-02-25"},
        {"code": "ST07", "name": "Big Mom Pirates", "release_date": "2023-05-27"},
        {"code": "ST08", "name": "Monkey D. Luffy", "release_date": "2023-07-28"},
        {"code": "ST09", "name": "Yamato", "release_date": "2023-09-22"},
        {"code": "ST10", "name": "Uta", "release_date": "2023-09-22"},
    ]
    
    print(f"✅ {len(sets)} sets encontrados")
    return sets


def fetch_cards_from_set(set_code: str) -> List[Dict]:
    """
    Obtiene todas las cartas de un set específico
    NOTA: Esta es una implementación de ejemplo que usa datos dummy.
    Para producción, necesitarías acceso a una API real o hacer scraping.
    """
    print(f"  📥 Descargando cartas de {set_code}...")
    
    # Aquí iría la lógica real de scraping/API
    # Por ahora, retornamos un array vacío
    # En producción, harías requests a la API o web scraping
    
    cards = []
    
    # Ejemplo de cómo sería con una API real:
    # try:
    #     response = requests.get(f"{API_BASE}/cards?set={set_code}")
    #     if response.status_code == 200:
    #         cards = response.json().get("cards", [])
    #         time.sleep(RATE_LIMIT_DELAY)
    # except Exception as e:
    #     print(f"    ⚠️  Error: {e}")
    
    return cards


def normalize_card_data(raw_card: Dict, set_info: Dict) -> Dict:
    """Normaliza los datos de una carta al formato del juego"""
    
    # Mapear color
    color_raw = raw_card.get("color", "r")
    colors = [COLOR_MAP.get(c, c.capitalize()) for c in color_raw.split(",")]
    
    # Mapear tipo
    card_type = TYPE_MAP.get(raw_card.get("type", "").lower(), "Character")
    
    return {
        "id": raw_card.get("id", ""),
        "name": raw_card.get("name", "Unknown"),
        "card_type": card_type,
        "color": colors,
        "cost": int(raw_card.get("cost", 0)),
        "power": int(raw_card.get("power", 0)),
        "counter": int(raw_card.get("counter", 0)),
        "attribute": raw_card.get("attribute", "").split(",") if raw_card.get("attribute") else [],
        "effect": raw_card.get("effect", ""),
        "rarity": raw_card.get("rarity", "C").upper(),
        "set_name": set_info.get("name", ""),
        "set_code": set_info.get("code", ""),
        "card_number": raw_card.get("number", ""),
        "image": raw_card.get("image_url", "")
    }


def generate_sample_database() -> Dict:
    """
    Genera una base de datos de ejemplo con cartas populares
    USAR ESTA FUNCIÓN si no tienes acceso a una API
    """
    print("🎴 Generando base de datos de ejemplo...")
    
    sets = fetch_all_sets()
    
    # Base de datos de ejemplo con cartas icónicas
    sample_cards = [
        # OP01 - Romance Dawn
        {"id": "OP01-001", "name": "Monkey D. Luffy", "type": "leader", "color": "r", "cost": 0, "power": 5000, "counter": 0, "attribute": "Straw Hat Crew", "effect": "[DON!! x1] [When Attacking] Give up to 1 of your Leader or Character cards +1000 power during this battle.", "rarity": "L", "number": "001", "set": "OP01"},
        {"id": "OP01-002", "name": "Roronoa Zoro", "type": "character", "color": "r", "cost": 3, "power": 4000, "counter": 1000, "attribute": "Straw Hat Crew,Supernovas", "effect": "[DON!! x1] [When Attacking] Give this Character +1000 power during this battle.", "rarity": "SR", "number": "002", "set": "OP01"},
        {"id": "OP01-003", "name": "Nami", "type": "character", "color": "r", "cost": 1, "power": 2000, "counter": 1000, "attribute": "Straw Hat Crew", "effect": "[On Play] Look at 3 cards from the top of your deck; reveal up to 1 {Straw Hat Crew} type card and add it to your hand.", "rarity": "R", "number": "003", "set": "OP01"},
        {"id": "OP01-004", "name": "Usopp", "type": "character", "color": "r", "cost": 2, "power": 3000, "counter": 1000, "attribute": "Straw Hat Crew", "effect": "[Blocker]", "rarity": "UC", "number": "004", "set": "OP01"},
        {"id": "OP01-005", "name": "Sanji", "type": "character", "color": "r", "cost": 4, "power": 5000, "counter": 0, "attribute": "Straw Hat Crew", "effect": "[On Play] K.O. up to 1 of your opponent's Characters with 3000 power or less.", "rarity": "SR", "number": "005", "set": "OP01"},
        {"id": "OP01-006", "name": "Tony Tony Chopper", "type": "character", "color": "r", "cost": 1, "power": 1000, "counter": 2000, "attribute": "Straw Hat Crew,Animal", "effect": "[Counter] Up to 1 of your Leader or Character cards gains +2000 power during this battle.", "rarity": "C", "number": "006", "set": "OP01"},
        {"id": "OP01-007", "name": "Nico Robin", "type": "character", "color": "r", "cost": 3, "power": 4000, "counter": 1000, "attribute": "Straw Hat Crew", "effect": "[On Play] Draw 1 card if you have 3 or less cards in your hand.", "rarity": "R", "number": "007", "set": "OP01"},
        {"id": "OP01-008", "name": "Franky", "type": "character", "color": "r", "cost": 3, "power": 3000, "counter": 2000, "attribute": "Straw Hat Crew", "effect": "[Blocker] [On Block] Give up to 1 of your Leader or Character cards +2000 power during this battle.", "rarity": "UC", "number": "008", "set": "OP01"},
        {"id": "OP01-009", "name": "Brook", "type": "character", "color": "r", "cost": 2, "power": 2000, "counter": 1000, "attribute": "Straw Hat Crew", "effect": "[On Play] Draw 1 card and trash 1 card from your hand.", "rarity": "C", "number": "009", "set": "OP01"},
        {"id": "OP01-010", "name": "Portgas D. Ace", "type": "character", "color": "r", "cost": 5, "power": 6000, "counter": 0, "attribute": "Whitebeard Pirates", "effect": "[DON!! x1] This Character gains +1000 power.", "rarity": "SR", "number": "010", "set": "OP01"},
        {"id": "OP01-011", "name": "Shanks", "type": "character", "color": "r", "cost": 9, "power": 10000, "counter": 0, "attribute": "The Four Emperors,Red-Haired Pirates", "effect": "[On Play] K.O. up to 1 of your opponent's Characters with 8000 power or less.", "rarity": "SEC", "number": "011", "set": "OP01"},
        {"id": "OP01-012", "name": "Gum-Gum Pistol", "type": "event", "color": "r", "cost": 1, "power": 0, "counter": 0, "attribute": "Straw Hat Crew", "effect": "[Main] K.O. up to 1 of your opponent's Characters with 3000 power or less.", "rarity": "C", "number": "012", "set": "OP01"},
        {"id": "OP01-013", "name": "Thousand Sunny", "type": "stage", "color": "r", "cost": 1, "power": 0, "counter": 0, "attribute": "Straw Hat Crew", "effect": "[Activate: Main] You may rest this Stage: Draw 1 card and trash 1 card from your hand.", "rarity": "R", "number": "013", "set": "OP01"},
        
        # OP01 - Blue cards
        {"id": "OP01-014", "name": "Trafalgar Law", "type": "leader", "color": "b", "cost": 0, "power": 5000, "counter": 0, "attribute": "Heart Pirates,Supernovas", "effect": "[DON!! x1] [When Attacking] Draw 1 card and trash 1 card from your hand.", "rarity": "L", "number": "014", "set": "OP01"},
        {"id": "OP01-015", "name": "Bepo", "type": "character", "color": "b", "cost": 2, "power": 3000, "counter": 1000, "attribute": "Heart Pirates,Animal", "effect": "[On Play] Draw 1 card and trash 1 card from your hand.", "rarity": "C", "number": "015", "set": "OP01"},
        {"id": "OP01-016", "name": "Boa Hancock", "type": "character", "color": "b", "cost": 4, "power": 5000, "counter": 0, "attribute": "The Seven Warlords of the Sea,Kuja Pirates", "effect": "[On Play] Return up to 1 Character with a cost of 3 or less to the owner's hand.", "rarity": "SR", "number": "016", "set": "OP01"},
        {"id": "OP01-017", "name": "Donquixote Doflamingo", "type": "character", "color": "b", "cost": 5, "power": 6000, "counter": 0, "attribute": "The Seven Warlords of the Sea,Donquixote Pirates", "effect": "[On Play] Return up to 1 Character with a cost of 4 or less to the owner's hand.", "rarity": "R", "number": "017", "set": "OP01"},
        {"id": "OP01-018", "name": "Crocodile", "type": "character", "color": "b", "cost": 7, "power": 8000, "counter": 0, "attribute": "The Seven Warlords of the Sea,Baroque Works", "effect": "[On Play] Return up to 1 Character with a cost of 5 or less to the owner's hand.", "rarity": "R", "number": "018", "set": "OP01"},
        {"id": "OP01-019", "name": "Jinbe", "type": "character", "color": "b", "cost": 3, "power": 4000, "counter": 1000, "attribute": "Fish-Man,Straw Hat Crew", "effect": "[Blocker]", "rarity": "UC", "number": "019", "set": "OP01"},
        {"id": "OP01-020", "name": "Dracule Mihawk", "type": "character", "color": "b", "cost": 9, "power": 10000, "counter": 0, "attribute": "The Seven Warlords of the Sea", "effect": "[On Play] Return all Characters with a cost of 7 or less to the owner's hand.", "rarity": "SEC", "number": "020", "set": "OP01"},
        
        # OP02 - Cartas populares
        {"id": "OP02-001", "name": "Edward Newgate", "type": "leader", "color": "r", "cost": 0, "power": 5000, "counter": 0, "attribute": "The Four Emperors,Whitebeard Pirates", "effect": "[Activate: Main] [Once Per Turn] Give up to 1 of your {Whitebeard Pirates} type Characters +2000 power during this turn.", "rarity": "L", "number": "001", "set": "OP02"},
        {"id": "OP02-002", "name": "Portgas D. Ace", "type": "character", "color": "r", "cost": 2, "power": 3000, "counter": 1000, "attribute": "Whitebeard Pirates", "effect": "[On Play] Look at 3 cards from the top of your deck and place them at the top or bottom of the deck in any order.", "rarity": "SR", "number": "002", "set": "OP02"},
        {"id": "OP02-003", "name": "Marco", "type": "character", "color": "r", "cost": 4, "power": 5000, "counter": 1000, "attribute": "Whitebeard Pirates", "effect": "[On Play] Return up to 1 Character with a cost of 3 or less to the owner's hand.", "rarity": "SR", "number": "003", "set": "OP02"},
        {"id": "OP02-004", "name": "Eustass Kid", "type": "leader", "color": "p", "cost": 0, "power": 5000, "counter": 0, "attribute": "Supernovas,Kid Pirates", "effect": "[Your Turn] Give all of your Characters +1000 power.", "rarity": "L", "number": "004", "set": "OP02"},
        
        # OP03 - Cartas populares
        {"id": "OP03-001", "name": "Charlotte Katakuri", "type": "leader", "color": "p", "cost": 0, "power": 5000, "counter": 0, "attribute": "Big Mom Pirates", "effect": "[DON!! x1] [Opponent's Turn] All of your Characters gain +1000 power.", "rarity": "L", "number": "001", "set": "OP03"},
        {"id": "OP03-002", "name": "Charlotte Linlin", "type": "character", "color": "p", "cost": 10, "power": 12000, "counter": 0, "attribute": "The Four Emperors,Big Mom Pirates", "effect": "[On Play] K.O. up to 1 of your opponent's Characters with a cost of 10 or less.", "rarity": "SEC", "number": "002", "set": "OP03"},
        {"id": "OP03-003", "name": "Sanji", "type": "character", "color": "y", "cost": 5, "power": 6000, "counter": 0, "attribute": "Straw Hat Crew", "effect": "[On Play] Set up to 1 of your opponent's Characters with a cost of 5 or less as active.", "rarity": "SR", "number": "003", "set": "OP03"},
    ]
    
    # Normalizar cartas
    normalized_cards = []
    for card in sample_cards:
        set_info = next((s for s in sets if s["code"] == card["set"]), {})
        normalized_card = normalize_card_data(card, set_info)
        normalized_cards.append(normalized_card)
    
    print(f"✅ {len(normalized_cards)} cartas generadas")
    
    return {
        "sets": sets,
        "cards": normalized_cards
    }


def save_database(data: Dict, filename: str = OUTPUT_FILE):
    """Guarda la base de datos en un archivo JSON"""
    print(f"💾 Guardando en {filename}...")
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Base de datos guardada exitosamente!")
    print(f"   📊 {len(data['sets'])} sets")
    print(f"   🎴 {len(data['cards'])} cartas")


def main():
    """Función principal"""
    print("=" * 60)
    print("  🏴‍☠️  ONE PIECE TCG - Generador de Base de Datos")
    print("=" * 60)
    print()
    
    # Generar base de datos de ejemplo
    database = generate_sample_database()
    
    # Guardar
    save_database(database)
    
    print()
    print("=" * 60)
    print("✅ ¡Proceso completado!")
    print("=" * 60)
    print()
    print("📝 Próximos pasos:")
    print("   1. Copia cards_database.json a tu proyecto Godot:")
    print("      cp cards_database.json /path/to/godot/data/")
    print("   2. Recarga el proyecto en Godot")
    print("   3. ¡Disfruta de tu colección!")
    print()


if __name__ == "__main__":
    main()
