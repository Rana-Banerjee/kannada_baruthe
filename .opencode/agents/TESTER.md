# playwright-tester.md — Kannada Baruthe E2E Test Sub-Agent

**Language:** Python | **Zero Dart context needed**
**Tests:** Web build only. Semantic keys defined in `AGENTS.md`.

---

## Prerequisite: HTML Renderer

Flutter's default `canvaskit` renders to `<canvas>` — Playwright cannot inspect it.
Always build and test with:

```bash
flutter build web --web-renderer html
cd build/web && python -m http.server 8080 &
```

---

## Setup (one-time)

```bash
pip install pytest playwright
playwright install chromium
```

---

## Test Files

```
tests/
├── conftest.py                 ← browser fixture, BASE_URL, lesson_data fixture
├── helpers/lesson_helper.py    ← reads lesson JSON → correct/wrong tile keys
├── test_home.py                ← AC1.1, AC1.2 (F1 + F6 home UI)
├── test_lesson_flow.py         ← AC2.1–AC2.4 (F2)
├── test_exercise.py            ← AC3.1–AC3.4 (F3)
├── test_audio.py               ← AC4.1 (button only — playback not assertable)
├── test_completion.py          ← AC5.1–AC5.2 (F5)
└── test_checkpoint.py          ← AC6.1–AC6.3 (F6)
```

Locator pattern: `page.locator('[key="kl_<name>"]')` — keys from AGENTS.md Semantic Keys table.

---

## conftest.py

```python
import pytest, json
from playwright.sync_api import sync_playwright

BASE_URL = "http://localhost:8080"
LESSON_FILE = "data/lessons/lesson_01.json"

@pytest.fixture(scope="session")
def lesson_data():
    with open(LESSON_FILE) as f: return json.load(f)

@pytest.fixture(scope="session")
def browser_context():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        ctx = browser.new_context()
        yield ctx
        browser.close()

@pytest.fixture
def page(browser_context):
    page = browser_context.new_page()
    yield page
    page.close()

def go_home(page):
    page.goto(BASE_URL)
    page.wait_for_selector('[key="kl_home_start_btn"]', timeout=5000)
```

---

## helpers/lesson_helper.py

```python
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
```

---

## test_home.py

```python
from conftest import go_home
from helpers.lesson_helper import get_correct_tile_key

def test_app_name_visible(page):                         # AC1.1
    go_home(page)
    assert page.locator('[key="kl_home_app_name"]').is_visible()

def test_start_button_present(page):                     # AC1.1
    go_home(page)
    assert page.locator('[key="kl_home_start_btn"]').is_visible()

def test_no_resume_on_fresh_start(page):                 # AC1.2
    go_home(page)
    assert not page.locator('[key="kl_home_resume_btn"]').is_visible()

def test_resume_shown_after_checkpoint(page):            # AC1.2
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    page.wait_for_selector('[key="kl_word_script"]', timeout=5000)
    page.locator(f'[key="{get_correct_tile_key(0)}"]').click()
    page.wait_for_selector('[key="kl_banner_continue_btn"]', timeout=3000)
    page.locator('[key="kl_banner_continue_btn"]').click()
    page.go_back()
    page.wait_for_selector('[key="kl_home_resume_btn"]', timeout=5000)
    assert page.locator('[key="kl_home_resume_btn"]').is_visible()
    assert page.locator('[key="kl_home_restart_btn"]').is_visible()
```

---

## test_lesson_flow.py

```python
from conftest import go_home
from helpers.lesson_helper import get_correct_tile_key

def test_progress_counter_visible(page):                 # AC2.2
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    page.wait_for_selector('[key="kl_lesson_progress"]', timeout=5000)
    assert page.locator('[key="kl_lesson_progress"]').is_visible()

def test_completion_after_last_exercise(page, lesson_data): # AC2.4
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    for i in range(len(lesson_data["exercises"])):
        page.wait_for_selector('[key="kl_word_script"]', timeout=5000)
        page.locator(f'[key="{get_correct_tile_key(i)}"]').click()
        page.locator('[key="kl_banner_continue_btn"]').click()
    page.wait_for_selector('[key="kl_complete_title"]', timeout=5000)
    assert page.locator('[key="kl_complete_title"]').is_visible()
```

---

## test_exercise.py

```python
from conftest import go_home
from helpers.lesson_helper import get_correct_tile_key, get_wrong_tile_key

def test_kannada_word_shown(page):                       # AC3.1
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    page.wait_for_selector('[key="kl_word_script"]', timeout=5000)
    assert page.locator('[key="kl_word_script"]').is_visible()
    assert page.locator('[key="kl_word_roman"]').is_visible()

def test_four_tiles_visible(page):                       # AC3.2
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    page.wait_for_selector('[key="kl_tile_t1"]', timeout=5000)
    for t in ["t1","t2","t3","t4"]:
        assert page.locator(f'[key="kl_tile_{t}"]').is_visible()

def test_correct_tap_shows_correct_banner(page):         # AC3.3–3.4
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    page.wait_for_selector('[key="kl_word_script"]', timeout=5000)
    page.locator(f'[key="{get_correct_tile_key(0)}"]').click()
    page.wait_for_selector('[key="kl_banner_message"]', timeout=3000)
    assert "Correct" in page.locator('[key="kl_banner_message"]').inner_text()

def test_wrong_tap_shows_wrong_banner(page):             # AC3.3–3.4
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    page.wait_for_selector('[key="kl_word_script"]', timeout=5000)
    page.locator(f'[key="{get_wrong_tile_key(0)}"]').click()
    page.wait_for_selector('[key="kl_banner_message"]', timeout=3000)
    msg = page.locator('[key="kl_banner_message"]').inner_text()
    assert "Wrong" in msg or "Try" in msg
    assert page.locator('[key="kl_banner_continue_btn"]').is_visible()
```

---

## test_checkpoint.py

```python
from conftest import go_home
from helpers.lesson_helper import get_correct_tile_key

def test_restart_clears_checkpoint(page):                # AC6.3
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    page.wait_for_selector('[key="kl_word_script"]', timeout=5000)
    page.locator(f'[key="{get_correct_tile_key(0)}"]').click()
    page.locator('[key="kl_banner_continue_btn"]').click()
    page.go_back()
    page.wait_for_selector('[key="kl_home_restart_btn"]', timeout=5000)
    page.locator('[key="kl_home_restart_btn"]').click()
    page.wait_for_selector('[key="kl_lesson_progress"]', timeout=5000)
    assert page.locator('[key="kl_lesson_progress"]').inner_text().startswith("1")

def test_resume_restores_position(page):                 # AC6.1, AC2.1
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    for i in range(2):
        page.wait_for_selector('[key="kl_word_script"]', timeout=5000)
        page.locator(f'[key="{get_correct_tile_key(i)}"]').click()
        page.locator('[key="kl_banner_continue_btn"]').click()
    page.go_back()
    page.wait_for_selector('[key="kl_home_resume_btn"]', timeout=5000)
    page.locator('[key="kl_home_resume_btn"]').click()
    page.wait_for_selector('[key="kl_lesson_progress"]', timeout=5000)
    assert page.locator('[key="kl_lesson_progress"]').inner_text().startswith("3")
```

---

## test_completion.py

```python
from conftest import go_home
from helpers.lesson_helper import get_correct_tile_key

def _complete_lesson(page, lesson_data):
    page.locator('[key="kl_home_start_btn"]').click()
    for i in range(len(lesson_data["exercises"])):
        page.wait_for_selector('[key="kl_word_script"]', timeout=5000)
        page.locator(f'[key="{get_correct_tile_key(i)}"]').click()
        page.locator('[key="kl_banner_continue_btn"]').click()

def test_completion_elements(page, lesson_data):         # AC5.1
    go_home(page)
    _complete_lesson(page, lesson_data)
    page.wait_for_selector('[key="kl_complete_title"]', timeout=5000)
    assert page.locator('[key="kl_complete_score"]').is_visible()

def test_back_to_home_clears_checkpoint(page, lesson_data): # AC5.2
    go_home(page)
    _complete_lesson(page, lesson_data)
    page.locator('[key="kl_complete_home_btn"]').click()
    page.wait_for_selector('[key="kl_home_start_btn"]', timeout=5000)
    assert not page.locator('[key="kl_home_resume_btn"]').is_visible()
```

---

## test_audio.py

```python
from conftest import go_home

def test_audio_button_present_and_clickable(page):       # AC4.1
    go_home(page)
    page.locator('[key="kl_home_start_btn"]').click()
    page.wait_for_selector('[key="kl_word_audio_btn"]', timeout=5000)
    assert page.locator('[key="kl_word_audio_btn"]').is_visible()
    page.locator('[key="kl_word_audio_btn"]').click()  # no error = pass
```

---

## Run Commands

```bash
pytest tests/ -v                              # all tests
pytest tests/test_checkpoint.py -v           # single file
PWDEBUG=1 pytest tests/test_exercise.py -v   # visible browser
```

## When to Run

| Trigger           | Command                                                       |
| ----------------- | ------------------------------------------------------------- |
| Any widget change | `pytest tests/ -v`                                          |
| New lesson added  | `pytest tests/test_lesson_flow.py tests/test_checkpoint.py` |
| Before release    | `pytest tests/ -v`— all must pass                          |
| New exercise type | Create `tests/test_<type>.py`, then `pytest tests/`       |

## Adding Tests for a New Exercise Type

1. Get new widget keys from AGENTS.md Semantic Keys table
2. Create `tests/test_<type>.py` following `test_exercise.py` pattern
3. Add helpers to `lesson_helper.py` if new answer logic needed
4. Never modify existing test files unless a key was renamed

## Constraints

* Never modify `lib/` or lesson JSON
* Audio/TTS playback not assertable — button presence only
* `data/progress/checkpoint.json` written during tests → `.gitignore`
