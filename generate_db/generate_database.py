#!/usr/bin/env python3
"""
Script para generar base de datos de One Piece TCG
Fuente: api.apitcg.com
"""

import requests
import json
import time
import os
from typing import List, Dict

# ==========================================
# CONFIGURACIÓN
# = :D =====================================
API_KEY = os.getenv("APITCG_KEY", "PATATA")
# URL corregida según tu feedback
API_URL = "https://apitcg.com/api/one-piece/cards"
OUTPUT_FILE = "cards_database.json"
RATE_LIMIT_DELAY = 0.3 # Un poco más de margen para evitar bloqueos

def fetch_all_cards() -> List[Dict]:
    all_cards = []
    current_page = 1
    total_pages = 1 # Empezamos asumiendo 1, se actualizará en la primera petición
    
    headers = {
        "x-api-key": API_KEY,
        "Accept": "application/json"
    }
    
    print("=" * 60)
    print("🏴‍☠️ Iniciando descarga desde apitcg.com...")
    print("=" * 60)
    
    try:
        while current_page <= total_pages:
            print(f"  📥 Solicitando página {current_page} de {total_pages}...", end="\r")
            
            response = requests.get(
                API_URL, 
                params={"page": current_page}, 
                headers=headers
            )
            
            if response.status_code != 200:
                print(f"\n⚠️ Error {response.status_code} en página {current_page}")
                break
                
            data = response.json()
            
            # Extraer las cartas
            cards_batch = data.get("data", [])
            if not cards_batch:
                print(f"\n⚠️ No se encontraron más cartas en la página {current_page}")
                break
                
            all_cards.extend(cards_batch)
            
            # --- LÓGICA DE PAGINACIÓN DINÁMICA ---
            # Intentamos detectar el total de páginas de varias formas posibles
            meta = data.get("meta", {})
            
            # Actualizamos total_pages solo en la primera petición o si cambia
            if current_page == 1:
                # Intenta obtener de meta.last_page o meta.totalPages o similar
                total_pages = meta.get("last_page") or meta.get("lastPage") or meta.get("total_pages") or 1
                
                # Si total_pages sigue siendo 1 pero sabemos que hay 128, 
                # forzamos una comprobación (esto es para depuración)
                if total_pages == 1:
                    # Si la API no lo dice claro, pero hay datos, seguimos intentando
                    # hasta que cards_batch venga vacío
                    total_pages = 999 

            # Si llegamos a una página que devuelve menos cartas de las habituales 
            # o está vacía, es el final (seguridad extra)
            if len(cards_batch) == 0:
                break
                
            current_page += 1
            time.sleep(RATE_LIMIT_DELAY)
            
        print(f"\n✅ Proceso de red finalizado. Total acumulado: {len(all_cards)}")
        return all_cards

    except Exception as e:
        print(f"\n❌ Error crítico: {e}")
        return []

def normalize_card_data(raw_card: Dict) -> Dict:
    set_info = raw_card.get("set", {})
    images = raw_card.get("images", {})
    
    return {
        "id": raw_card.get("id", ""),
        "name": raw_card.get("name", "Unknown"),
        "card_type": raw_card.get("type", "Character"),
        "color": raw_card.get("colors", []),
        "cost": raw_card.get("cost"),
        "power": raw_card.get("power"),
        "counter": raw_card.get("counter"),
        "attribute": raw_card.get("attributes", []),
        "effect": raw_card.get("description", ""),
        "rarity": raw_card.get("rarity", ""),
        "set_name": set_info.get("name", ""),
        "set_code": set_info.get("id", ""),
        "card_number": raw_card.get("number", ""),
        "image": images.get("png") or images.get("jpg") or ""
    }

def main():
    raw_cards = fetch_all_cards()
    
    if not raw_cards:
        print("❌ No se pudo generar la base de datos.")
        return

    print("🔧 Normalizando y organizando sets...")
    normalized_cards = [normalize_card_data(c) for c in raw_cards]
    
    sets_found = {}
    for c in raw_cards:
        s = c.get("set", {})
        if s.get("id") and s["id"] not in sets_found:
            sets_found[s["id"]] = {
                "code": s.get("id"),
                "name": s.get("name")
            }

    final_db = {
        "metadata": {
            "last_updated": time.strftime("%Y-%m-%d %H:%M:%S"),
            "total_cards": len(normalized_cards)
        },
        "sets": list(sets_found.values()),
        "cards": normalized_cards
    }

    print(f"💾 Guardando en {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(final_db, f, indent=2, ensure_ascii=False)
    
    print("=" * 60)
    print("✅ ¡BASE DE DATOS GENERADA!")
    print(f"📊 Cartas totales: {len(final_db['cards'])}")
    print("=" * 60)

if __name__ == "__main__":
    main()