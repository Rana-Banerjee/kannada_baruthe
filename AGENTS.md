# AGENTS.md — Kannada Baruthe

# **Purpose:** Minimum context to act on any task. Read STATUS.md first, this second.

---

## Rules

1. Data / Config / Logic always separate. No hardcoded strings/colors in Dart.
2. One file = one concern. Split if >150 lines.
3. `progress_service.dart` sole owner of `checkpoint.json`. No exceptions.
4. All user-visible text from `app_config.json` or lesson JSON only.
5. Every testable widget needs `Key('kl_<widget>_<role>')`. See Semantic Keys below.
6. To add lessons: use `data-generator` sub-agent. Never touch `lib/` for data changes.

---

## Sub-Agents

| Agent             | File                                   | Needs Dart context? |
| ----------------- | -------------------------------------- | ------------------- |
| Data Generator    | `.opencode/agents/DATA_GENERATOR.md` | ❌                  |
| Playwright Tester | `.opencode/agents/TESTER.md`         | ❌                  |

---

## Folder Map

```
STATUS.md                           ← READ FIRST / WRITE LAST every session
PRD.md                              ← features, ACs, data schemas, config schema
AGENTS.md                           ← this file: structure, rules, recipes
.opencode/agents/DATA-GENERATOR.md         ← sub-agent: content generation
.opencode/agents/TESTER.md      ← sub-agent: E2E tests

config/app_config.json              ← theme, fonts, TTS, exercise rules
data/lessons_index.json             ← lesson list (id, path, enabled)
data/lessons/lesson_01.json         ← words, tiles, images, audio paths
data/progress/checkpoint.json       ← RUNTIME ONLY — .gitignore

assets/images/<category>/           ← tile images + IMAGE_MANIFEST.md
assets/audio/                       ← optional .mp3s + AUDIO_MANIFEST.md
assets/fonts/NotoSansKannada*.ttf

lib/main.dart                       ← runApp() only
lib/app.dart                        ← MaterialApp: theme + routes
lib/config/app_config.dart          ← parses app_config.json → typed object
lib/models/lesson.dart              ← Lesson(id, title, exercises[])
lib/models/exercise.dart            ← Exercise(word, audio, tiles[])
lib/models/tile.dart                ← Tile(label, image, is_correct)
lib/models/checkpoint.dart          ← Checkpoint(lesson_id, exercise_index, score, timestamp)
lib/services/lesson_service.dart    ← JSON → Lesson object
lib/services/audio_service.dart     ← file or TTS decision
lib/services/tts_service.dart       ← TTS plugin wrapper
lib/services/progress_service.dart  ← SOLE owner: save/load/clear checkpoint
lib/screens/home_screen.dart        ← home UI + resume/restart
lib/screens/lesson_screen.dart      ← exercise sequencing, score, checkpoint saves
lib/screens/complete_screen.dart    ← score display, checkpoint clear, home nav
lib/widgets/word_header.dart        ← ಸೇಬು / Sēbu + speaker button
lib/widgets/image_tile.dart         ← tappable tile: image + label + state
lib/widgets/tile_grid.dart          ← 2×2 grid of image_tiles
lib/widgets/feedback_banner.dart    ← Correct/Wrong + Continue

tests/conftest.py                   ← browser fixtures, base_url, lesson loader
tests/test_home.py                  ← F1+F6
tests/test_lesson_flow.py           ← F2
tests/test_exercise.py              ← F3
tests/test_audio.py                 ← F4 (button only)
tests/test_completion.py            ← F5
tests/test_checkpoint.py            ← F6
tests/helpers/lesson_helper.py      ← reads JSON → correct/wrong tile keys
```

---

## Data Flow

```
app_config.json → app_config.dart ─────────────────→ all screens + widgets

home_screen ──→ progress_service.load()
                  checkpoint? → show Resume/Restart
                  [Start/Resume] ↓
lesson_screen ──→ lesson_service → lesson_XX.json → Lesson
                  resume? start at checkpoint.exercise_index
                  each exercise:
                    word_header → audio_service → file | tts_service
                    tile_grid → image_tile ×4
                    feedback_banner → Continue → progress_service.save()
                  last exercise → progress_service.clear() → complete_screen
```

---

## Semantic Keys *(never rename after tests written)*

| Key                                        | File            |
| ------------------------------------------ | --------------- |
| `kl_home_app_name`                       | home_screen     |
| `kl_home_start_btn`                      | home_screen     |
| `kl_home_resume_btn`                     | home_screen     |
| `kl_home_restart_btn`                    | home_screen     |
| `kl_home_resume_label`                   | home_screen     |
| `kl_lesson_progress`                     | lesson_screen   |
| `kl_word_script`                         | word_header     |
| `kl_word_roman`                          | word_header     |
| `kl_word_audio_btn`                      | word_header     |
| `kl_tile_t1`…`kl_tile_t4`             | image_tile      |
| `kl_tile_label_t1`…`kl_tile_label_t4` | image_tile      |
| `kl_banner_message`                      | feedback_banner |
| `kl_banner_continue_btn`                 | feedback_banner |
| `kl_complete_title`                      | complete_screen |
| `kl_complete_score`                      | complete_screen |
| `kl_complete_home_btn`                   | complete_screen |

---

## Recipes *(share ONLY these files per task)*

| Task                | Files                                                                   |
| ------------------- | ----------------------------------------------------------------------- |
| Add lessons/words   | `.opencode/data-generator.md`only                                     |
| Generate/run tests  | `.opencode/playwright-tester.md`only                                  |
| Fix tile grid       | `tile_grid.dart`,`image_tile.dart`,`app_config.json`              |
| Fix audio/TTS       | `audio_service.dart`,`tts_service.dart`,`app_config.json`         |
| Fix lesson loading  | `lesson_service.dart`,`lesson.dart`,`exercise.dart`,`tile.dart` |
| Fix checkpoint      | `progress_service.dart`,`checkpoint.dart`                           |
| Fix Resume/Restart  | `home_screen.dart`,`progress_service.dart`,`checkpoint.dart`      |
| Fix resume position | `lesson_screen.dart`,`progress_service.dart`,`checkpoint.dart`    |
| Change colors/fonts | `app_config.json`only                                                 |
| Add exercise type   | `lesson_screen.dart`+ new model + new widget (see below)              |
| Fix word header     | `word_header.dart`,`exercise.dart`,`app_config.json`              |
| Debug navigation    | `home_screen.dart`,`lesson_screen.dart`,`app.dart`                |
| Failing test        | failing `test_XX.py`+ its target widget only                          |

---

## Adding a New Exercise Type

1. `lib/models/<type>.dart` — model
2. `lib/widgets/<type>_widget.dart` — widget with `kl_` keys
3. `lesson_screen.dart` — add switch case for new `exercise_type`
4. Add keys to Semantic Keys table above
5. `tests/test_<type>.py` — follow `test_exercise.py` pattern
6. Do NOT touch: home, complete, audio, TTS, tile_grid, feedback_banner, progress_service

## Adding a New Lesson

→ `.opencode/data-generator.md`. Tests auto-adapt. No Dart changes.

---

## Conventions

`snake_case.dart` | `PascalCase` classes | `snake_case` JSON keys
Asset paths relative to project root | One widget per file | Config read-only at runtime
`.gitignore`: `data/progress/checkpoint.json`, `build/`

---

## Session Protocol

**Start:** Read `STATUS.md` → read `AGENTS.md` → read only files needed for the task (use Recipes).
**End:** Update `STATUS.md` (done/in-progress/next/last session summary). Confirm no hardcoded values.
