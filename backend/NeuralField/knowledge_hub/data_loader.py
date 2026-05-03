import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent  # points to knowledge_hub/

def load_json(file_name):
    file_path = BASE_DIR / "data" / file_name   # ✅ correct

    with open(file_path, "r", encoding="utf-8") as file:
        return json.load(file)