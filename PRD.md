# PRD.md — Kannada Baruthe

**Stack:** Flutter | **Platforms:** iOS + Android + Web | **Phase:** 1 MVP
**Rule:** Data/config/assets are external files. Nothing hardcoded in Dart.

---

## Features & Acceptance Criteria

*Each AC maps to a Playwright test. See `.opencode/playwright-tester.md`.*

**F1 Home** — `test_home.py`

* AC1.1 App name (from config) + Start Lesson button
* AC1.2 If checkpoint: show "Resume: Lesson 1 — Ex 4/8" + Resume / Restart buttons
* AC1.3 Responsive web + mobile

**F2 Lesson Flow** — `test_lesson_flow.py`

* AC2.1 Load lesson JSON; resume from checkpoint.exercise_index if match
* AC2.2 One exercise at a time; progress counter "3 / 8"
* AC2.3 Save checkpoint after every answered exercise
* AC2.4 After last exercise → completion screen; clear checkpoint

**F3 Select Correct Image** — `test_exercise.py`

* AC3.1 Show word as: ಸೇಬು / Sēbu (script + romanized)
* AC3.2 2×2 grid, 4 tiles, each with English label
* AC3.3 Correct tap → green; wrong tap → red + correct shown green
* AC3.4 Feedback banner: message + Continue button

**F4 Audio** — `test_audio.py`

* AC4.1 Speaker button visible + clickable
* AC4.2 Play `assets/audio/<file>` if exists; else TTS fallback
* AC4.3 TTS config from `app_config.json`

**F5 Completion** — `test_completion.py`

* AC5.1 "Lesson Complete!" + score (e.g., "7 / 8 correct")
* AC5.2 Back to Home clears checkpoint

**F6 Checkpoint** — `test_checkpoint.py`

* AC6.1 Checkpoint: `{ lesson_id, exercise_index, score, timestamp }`
* AC6.2 Overwrite on each advance; delete on complete/restart
* AC6.3 Restart → exercise 0
* AC6.4 `progress_service.dart` sole reader/writer

---

## Data Schemas

### `data/lessons/lesson_01.json`

```json
{
  "lesson_id": "lesson_01", "lesson_title": "Fruits",
  "exercises": [{
    "exercise_id": "ex_001", "exercise_type": "select_correct_image",
    "word": { "kannada_script": "ಸೇಬು", "kannada_roman": "Sēbu", "english": "Apple" },
    "audio": { "file": "assets/audio/sebu.mp3", "tts_text": "ಸೇಬು" },
    "tiles": [
      { "tile_id": "t1", "english_label": "Apple",  "image": "assets/images/fruits/apple.png",  "is_correct": true },
      { "tile_id": "t2", "english_label": "Banana", "image": "assets/images/fruits/banana.png", "is_correct": false },
      { "tile_id": "t3", "english_label": "Mango",  "image": "assets/images/fruits/mango.png",  "is_correct": false },
      { "tile_id": "t4", "english_label": "Grapes", "image": "assets/images/fruits/grapes.png", "is_correct": false }
    ]
  }]
}
```

*Rules: 1 `is_correct:true` per exercise; `audio.file` optional (TTS if absent); tile count = `app_config.num_tiles`.*

### `data/lessons_index.json`

```json
{ "lessons": [{ "lesson_id": "lesson_01", "title": "Fruits", "file": "data/lessons/lesson_01.json", "enabled": true }] }
```

### `data/progress/checkpoint.json` *(runtime only — .gitignore)*

```json
{ "lesson_id": "lesson_01", "exercise_index": 3, "score": 2, "timestamp": "2026-03-03T10:22:00Z" }
```

### `config/app_config.json`

```json
{
  "app": { "name": "Kannada Baruthe", "version": "1.0.0" },
  "theme": { "primary_color": "#58CC02", "secondary_color": "#1CB0F6", "correct_color": "#58CC02", "wrong_color": "#FF4B4B", "background_color": "#FFFFFF", "text_color_primary": "#3C3C3C" },
  "fonts": { "size_word_script": 32, "size_word_roman": 18, "size_tile_label": 14, "kannada_font": "NotoSansKannada" },
  "exercise": { "num_tiles": 4, "tile_columns": 2, "randomize_tile_order": true, "auto_play_audio": true, "show_roman": true },
  "audio": { "tts_enabled": true, "tts_language_code": "kn-IN", "tts_rate": 0.85 },
  "feedback_banner": { "correct_message": "Correct!", "wrong_message": "Try again!", "continue_label": "Continue" }
}
```

---

## Out of Scope (Phase 1)

Accounts, streaks, gamification, multi-exercise types, analytics, offline caching, mobile-native testing.

## Roadmap

* **P2:** Multi-lesson home, new exercise types, offline caching
* **P3:** Streaks, XP, hearts, lesson gating
* **P4:** Spaced repetition, script writing, leaderboards
