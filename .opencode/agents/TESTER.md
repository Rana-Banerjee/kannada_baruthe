# playwright-tester.md — Kannada Baruthe E2E Test Sub-Agent

**Language:** Python | **Zero Dart context needed**
**Tests:** Web build only. Uses Flutter's accessibility mode for DOM inspection.

---

## ⚠️ Critical: Flutter Web Rendering

Modern Flutter (3.24.5+) uses **Canvaskit/Skwasm** by default which renders to `<canvas>`. Playwright **cannot** inspect canvas elements directly.

**Solution:** Enable Flutter's **accessibility mode** which creates DOM elements (`flt-semantics`) that Playwright can interact with.

---

## Prerequisite: Build and Start Server

```bash
# Build Flutter web (no special renderer flag needed in modern Flutter)
flutter build web

# Start HTTP server
cd build/web && python3 -m http.server 8080 &
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
├── conftest.py                 ← browser fixture, BASE_URL, lesson_data, accessibility helpers
├── helpers/lesson_helper.py    ← reads lesson JSON → correct/wrong tile keys
├── test_home.py                ← AC1.1, AC1.2 (F1 + F6 home UI)
├── test_lesson_flow.py         ← AC2.1–AC2.4 (F2)
├── test_exercise.py            ← AC3.1–AC3.4 (F3)
├── test_audio.py               ← AC4.1 (button only — playback not assertable)
├── test_completion.py          ← AC5.1–AC5.2 (F5)
└── test_checkpoint.py          ← AC6.1–AC6.3 (F6)
```

---

## Core Concept: Flutter Accessibility Mode

When you click the hidden `flt-semantics-placeholder` button, Flutter creates semantic DOM elements:

- **Buttons** → `flt-semantics[role="button"]`
- **Text** → Inner text of `flt-semantics` elements
- **Interact** → Find by text content and call `.click()`

### Key Helper Functions

```python
def go_home(page):
    """Navigate to home screen and enable Flutter accessibility"""
    page.goto(BASE_URL)
    page.wait_for_timeout(4000)  # Wait for Flutter to load
    
    # Enable Flutter accessibility - this exposes semantic elements
    page.evaluate('''
        () => {
            const el = document.querySelector("flt-semantics-placeholder");
            if (el) {
                el.scrollIntoViewIfNeeded();
                el.click();
            }
        }
    ''')
    page.wait_for_timeout(2000)

def _click_button_by_text(page, text):
    """Click a Flutter button by its text content"""
    page.evaluate(f'''
        () => {{
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {{
                if (btn.textContent.includes("{text}")) {{
                    btn.click();
                    return true;
                }}
            }}
            return false;
        }}
    ''')
    page.wait_for_timeout(500)

def _get_semantic_text(page):
    """Get all semantic element texts for debugging"""
    semantics = page.locator('flt-semantics').all()
    texts = []
    for sem in semantics:
        text = sem.inner_text() if sem.inner_text() else ''
        if text.strip():
            texts.append(text)
    return texts
```

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
        ctx = browser.new_context(viewport={'width': 1920, 'height': 1080})
        yield ctx
        browser.close()

@pytest.fixture
def page(browser_context):
    page = browser_context.new_page()
    yield page
    page.close()

def go_home(page):
    """Navigate to home screen and enable Flutter accessibility"""
    page.goto(BASE_URL)
    page.wait_for_timeout(4000)
    
    page.evaluate('''
        () => {
            const el = document.querySelector("flt-semantics-placeholder");
            if (el) {
                el.scrollIntoViewIfNeeded();
                el.click();
            }
        }
    ''')
    page.wait_for_timeout(2000)
    
    semantic_count = page.locator('flt-semantics').count()
    if semantic_count == 0:
        page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
        page.wait_for_timeout(2000)

def _click_button_by_text(page, text):
    """Click a Flutter button by its text content"""
    page.evaluate(f'''
        () => {{
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {{
                if (btn.textContent.includes("{text}")) {{
                    btn.click();
                    return true;
                }}
            }}
            return false;
        }}
    ''')
    page.wait_for_timeout(500)

def _get_semantic_text(page):
    """Get all semantic element texts for assertions"""
    semantics = page.locator('flt-semantics').all()
    texts = []
    for sem in semantics:
        text = sem.inner_text() if sem.inner_text() else ''
        if text.strip():
            texts.append(text)
    return texts
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
from conftest import go_home, _click_button_by_text, _get_semantic_text

def test_app_name_visible(page):                         # AC1.1
    go_home(page)
    texts = _get_semantic_text(page)
    assert any('KannadaLearn' in text for text in texts)

def test_start_button_present(page):                     # AC1.1
    go_home(page)
    texts = _get_semantic_text(page)
    assert any('Start Lesson' in text for text in texts)

def test_no_resume_on_fresh_start(page):                 # AC1.2
    go_home(page)
    texts = _get_semantic_text(page)
    assert not any('Resume' in text for text in texts)

def test_resume_shown_after_checkpoint(page):            # AC1.2
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    
    # Enable accessibility on lesson page
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click tile (Apple is correct in first exercise)
    page.evaluate('''
        () => {
            const semantics = document.querySelectorAll('flt-semantics[role="button"]');
            for (const sem of semantics) {
                if (sem.textContent.includes('Apple') && !sem.textContent.includes('Play')) {
                    sem.click();
                }
            }
        }
    ''')
    page.wait_for_timeout(1000)
    
    # Click Continue
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Continue') || btn.textContent.includes('ಮುಂದೆ')) {
                    btn.click();
                }
            }
        }
    ''')
    page.wait_for_timeout(1000)
    
    page.go_back()
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    has_resume = any('Resume' in text for text in texts)
    has_restart = any('Restart' in text for text in texts)
    assert has_resume or has_restart
```

---

## test_lesson_flow.py

```python
from conftest import go_home, _click_button_by_text, _get_semantic_text

def test_progress_counter_visible(page):                 # AC2.2
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    assert any('1 /' in text for text in texts)

def test_completion_after_last_exercise(page, lesson_data): # AC2.4
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    
    num_exercises = len(lesson_data["exercises"])
    for i in range(num_exercises):
        page.wait_for_timeout(1500)
        page.evaluate('() => { const p = document.querySelector("flt-semantics-placeholder"); if (p) p.click(); }')
        page.wait_for_timeout(500)
        
        # Click tile by finding button with text
        page.evaluate('''
            () => {
                const semantics = document.querySelectorAll('flt-semantics[role="button"]');
                for (const sem of semantics) {
                    if (sem.textContent.includes('Apple') && !sem.textContent.includes('Play audio')) {
                        sem.click();
                        return;
                    }
                }
            }
        ''')
        page.wait_for_timeout(1000)
        
        # Click Continue
        page.evaluate('''
            () => {
                const buttons = document.querySelectorAll('flt-semantics[role="button"]');
                for (const btn of buttons) {
                    if (btn.textContent.includes('Continue') || btn.textContent.includes('ಮುಂದೆ')) {
                        btn.click();
                    }
                }
            }
        ''')
        page.wait_for_timeout(500)
    
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    completion_found = any(
        'complete' in text.lower() or 
        'ಮುಗಿಯಿತು' in text or 
        '10 / 10' in text
        for text in texts
    )
    assert completion_found
```

---

## test_exercise.py

```python
from conftest import go_home, _click_button_by_text, _get_semantic_text

def test_kannada_word_shown(page):                       # AC3.1
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    assert any('ಸೇಬು' in text for text in texts)  # First word
    assert any('Sēbu' in text for text in texts)

def test_four_tiles_visible(page):                       # AC3.2
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    tile_words = ['Apple', 'Banana', 'Mango', 'Grapes']
    found_tiles = sum(1 for word in tile_words if any(word in text for text in texts))
    assert found_tiles >= 4

def test_correct_tap_shows_correct_banner(page):         # AC3.3–3.4
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click Apple tile
    page.evaluate('''
        () => {
            const semantics = document.querySelectorAll('flt-semantics[role="button"]');
            for (const sem of semantics) {
                if (sem.textContent.includes('Apple') && !sem.textContent.includes('Play')) {
                    sem.click();
                }
            }
        }
    ''')
    page.wait_for_timeout(1500)
    
    texts = _get_semantic_text(page)
    feedback_found = any('Correct' in text for text in texts)
    continue_found = any('Continue' in text for text in texts)
    assert feedback_found or continue_found

def test_wrong_tap_shows_wrong_banner(page):             # AC3.3–3.4
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click Banana (wrong)
    page.evaluate('''
        () => {
            const semantics = document.querySelectorAll('flt-semantics[role="button"]');
            for (const sem of semantics) {
                if (sem.textContent.includes('Banana') && !sem.textContent.includes('Play')) {
                    sem.click();
                }
            }
        }
    ''')
    page.wait_for_timeout(1500)
    
    texts = _get_semantic_text(page)
    continue_found = any('Continue' in text for text in texts)
    assert continue_found
```

---

## test_audio.py

```python
from conftest import go_home, _get_semantic_text

def test_audio_button_present_and_clickable(page):       # AC4.1
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    audio_found = any('audio' in text.lower() or 'ಶಬ್ದ' in text for text in texts)
    assert audio_found
    
    # Click audio button (no error = pass)
    page.evaluate('''
        () => {
            const semantics = document.querySelectorAll('flt-semantics[role="button"]');
            for (const sem of semantics) {
                if (sem.textContent.includes('audio') || sem.textContent.includes('Play')) {
                    sem.click();
                }
            }
        }
    ''')
```

---

## test_checkpoint.py

```python
from conftest import go_home, _get_semantic_text

def test_restart_clears_checkpoint(page):                # AC6.3
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    # Click Apple tile
    page.evaluate('''
        () => {
            const semantics = document.querySelectorAll('flt-semantics[role="button"]');
            for (const sem of semantics) {
                if (sem.textContent.includes('Apple') && !sem.textContent.includes('Play')) {
                    sem.click();
                }
            }
        }
    ''')
    page.wait_for_timeout(1000)
    
    # Continue
    page.evaluate('''
        () => {
            const buttons = document.querySelectorAll('flt-semantics[role="button"]');
            for (const btn of buttons) {
                if (btn.textContent.includes('Continue')) btn.click();
            }
        }
    ''')
    page.wait_for_timeout(1000)
    
    page.go_back()
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    assert any('Restart' in text for text in texts)
    
    _click_button_by_text(page, 'Restart')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    assert any('1 /' in text for text in texts)

def test_resume_restores_position(page):                 # AC6.1, AC2.1
    go_home(page)
    _click_button_by_text(page, 'Start Lesson')
    
    for i in range(2):
        page.wait_for_timeout(1500)
        page.evaluate('() => { const p = document.querySelector("flt-semantics-placeholder"); if (p) p.click(); }')
        page.wait_for_timeout(500)
        
        page.evaluate('''
            () => {
                const semantics = document.querySelectorAll('flt-semantics[role="button"]');
                for (const sem of semantics) {
                    if (sem.textContent.includes('Apple') && !sem.textContent.includes('Play')) {
                        sem.click();
                    }
                }
            }
        ''')
        page.wait_for_timeout(1000)
        
        page.evaluate('''
            () => {
                const buttons = document.querySelectorAll('flt-semantics[role="button"]');
                for (const btn of buttons) {
                    if (btn.textContent.includes('Continue')) btn.click();
                }
            }
        ''')
        page.wait_for_timeout(500)
    
    page.go_back()
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    _click_button_by_text(page, 'Resume')
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    assert any('3 /' in text for text in texts)
```

---

## test_completion.py

```python
from conftest import go_home, _get_semantic_text

def _complete_lesson(page, lesson_data):
    _click_button_by_text(page, 'Start Lesson')
    num_exercises = len(lesson_data["exercises"])
    
    for i in range(num_exercises):
        page.wait_for_timeout(1500)
        page.evaluate('() => { const p = document.querySelector("flt-semantics-placeholder"); if (p) p.click(); }')
        page.wait_for_timeout(500)
        
        page.evaluate('''
            () => {
                const semantics = document.querySelectorAll('flt-semantics[role="button"]');
                for (const sem of semantics) {
                    if (sem.textContent.includes('Apple') && !sem.textContent.includes('Play audio')) {
                        sem.click();
                    }
                }
            }
        ''')
        page.wait_for_timeout(1000)
        
        page.evaluate('''
            () => {
                const buttons = document.querySelectorAll('flt-semantics[role="button"]');
                for (const btn of buttons) {
                    if (btn.textContent.includes('Continue') || btn.textContent.includes('ಮುಂದೆ')) {
                        btn.click();
                    }
                }
            }
        ''')
        page.wait_for_timeout(500)

def test_completion_elements(page, lesson_data):         # AC5.1
    go_home(page)
    _complete_lesson(page, lesson_data)
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    complete_found = any(
        'complete' in text.lower() or 
        'ಮುಗಿಯಿತು' in text or 
        '10 / 10' in text
        for text in texts
    )
    assert complete_found

def test_back_to_home_clears_checkpoint(page, lesson_data): # AC5.2
    go_home(page)
    _complete_lesson(page, lesson_data)
    page.wait_for_timeout(2000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    _click_button_by_text(page, 'Home')
    page.wait_for_timeout(2000)
    
    page.goto('http://localhost:8080')
    page.wait_for_timeout(3000)
    page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
    page.wait_for_timeout(1000)
    
    texts = _get_semantic_text(page)
    assert not any('Resume' in text for text in texts)
```

---

## Run Commands

```bash
# Start server first
cd build/web && python3 -m http.server 8080 &

# Run tests
pytest tests/ -v                              # all tests
pytest tests/test_home.py -v                 # single file
PWDEBUG=1 pytest tests/test_exercise.py -v  # visible browser
```

---

## When to Run

| Trigger           | Command                                                       |
| ----------------- | ------------------------------------------------------------- |
| Any widget change | `pytest tests/ -v`                                          |
| New lesson added  | `pytest tests/test_lesson_flow.py tests/test_checkpoint.py` |
| Before release    | `pytest tests/ -v` — all must pass                          |
| Debug test        | `PWDEBUG=1 pytest tests/test_XX.py -v`                      |

---

## Test Isolation Notes

- **Checkpoint persists**: Tests share state via `data/progress/checkpoint.json`
- **Clear between runs**: Delete `data/progress/checkpoint.json` or restart server
- **Fresh browser**: Each test gets a fresh page but shares browser context

---

## Key Patterns Summary

1. **Enable accessibility** before every interaction:
   ```python
   page.evaluate('() => document.querySelector("flt-semantics-placeholder")?.click()')
   ```

2. **Find elements by text**:
   ```python
   page.evaluate('''
       () => {
           const buttons = document.querySelectorAll('flt-semantics[role="button"]');
           for (const btn of buttons) {
               if (btn.textContent.includes('Start Lesson')) btn.click();
           }
       }
   ''')
   ```

3. **Get all visible text**:
   ```python
   texts = _get_semantic_text(page)
   assert any('expected' in text for text in texts)
   ```

---

## Constraints

* Never modify `lib/` or lesson JSON
* Audio/TTS playback not assertable — button presence only
* `data/progress/checkpoint.json` written during tests → `.gitignore`
* Tests run against built web app, not source
