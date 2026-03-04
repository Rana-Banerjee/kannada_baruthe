import json
LESSON_FILE = "data/lessons/lesson_01.json"

def _load():
    with open(LESSON_FILE) as f: return json.load(f)

def get_correct_tile_key(exercise_index: int) -> str:
    tiles = _load()["exercises"][exercise_index]["tiles"]
    return f'kl_tile_{next(t for t in tiles if t["is_correct"])["tile_id"]}'

def get_wrong_tile_key(exercise_index: int) -> str:
    tiles = _load()["exercises"][exercise_index]["tiles"]
    return f'kl_tile_{next(t for t in tiles if not t["is_correct"])["tile_id"]}'
