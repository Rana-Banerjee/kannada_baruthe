# STATUS.md — Kannada Baruthe

> **READ THIS FIRST every session. UPDATE THIS LAST before ending.**
> Single source of truth for current development state.

---

## Current Phase

`Phase 1 — MVP` | Status: `IN PROGRESS`

---

## Done ✅

1. ✅ Scaffold Flutter project structure (directories created)
2. ✅ Add `pubspec.yaml` deps: `flutter_tts`, `audioplayers`, `shared_preferences`
3. ✅ Declare assets in `pubspec.yaml` (fonts, images/, audio/)
4. ✅ Build models: `checkpoint.dart`, `lesson.dart`, `exercise.dart`, `tile.dart`
5. ✅ Build services: `app_config.dart`, `lesson_service.dart`, `progress_service.dart`
6. ✅ Build services: `audio_service.dart`, `tts_service.dart`
7. ✅ Build screens: `home_screen.dart` (F1 - Home feature)
8. ✅ Build screens: `lesson_screen.dart` (F2 - Lesson flow with exercises)
9. ✅ Build screens: `complete_screen.dart` (F5 - Completion)
10. ✅ Build widgets: `word_header.dart`, `image_tile.dart`, `tile_grid.dart`, `feedback_banner.dart`
11. ✅ Add `kl_` semantic keys to all widgets
12. ✅ Generate lesson_01 (Fruits) with 10 exercises
13. ✅ Create image/audio placeholder files
14. ✅ Create IMAGE_MANIFEST.md and AUDIO_MANIFEST.md
15. ✅ **Set up Playwright E2E tests** (with Flutter accessibility mode)
16. ✅ **Discover Flutter accessibility testing pattern** (flt-semantics)

---

## In Progress 🔧

- **Playwright Testing** - Working E2E tests:
  - Test files created: `conftest.py`, `helpers/lesson_helper.py`, `test_home.py`, `test_lesson_flow.py`, `test_exercise.py`, `test_audio.py`, `test_completion.py`, `test_checkpoint.py`
  - Uses Flutter's accessibility mode to expose DOM elements for Playwright
  - Tests verified working: home screen, progress counter, audio button

---

## Next Up ⏭️

1. Fix app bug: Resume not showing when navigating back to home
2. Clear checkpoint between test runs for proper test isolation
3. Run full test suite and fix any remaining issues

---

## Blocked / Decisions Pending ⚠️

*(none)*

---

## Known Issues 🐛

1. **Resume button not appearing** - After completing an exercise and going back to home, Resume doesn't show (app bug in home_screen.dart - not reloading checkpoint)
2. **Test state persistence** - Checkpoint persists between tests; delete `data/progress/checkpoint.json` between runs

---

## Last Session Summary

* Date: Mar 4, 2026
* What was done: 
  - Set up Playwright E2E tests for Flutter Web
  - Discovered Flutter accessibility mode pattern: click `flt-semantics-placeholder` to enable DOM inspection
  - Created all test files with proper selectors using semantic elements
  - Verified tests work: app_name, start_button, no_resume, progress_counter, audio_button
* Tests passing: ~60% (6 passing, 4 failing due to app bug + state)
* Files created: 
  - `tests/conftest.py` - browser fixtures + accessibility helpers
  - `tests/helpers/lesson_helper.py` - lesson data helpers
  - `tests/test_home.py`, `test_lesson_flow.py`, `test_exercise.py`, `test_audio.py`, `test_completion.py`, `test_checkpoint.py`
  - `.opencode/agents/TESTER.md` - Updated with Flutter accessibility testing pattern
* Left off at: Need to fix app bug where Resume doesn't show after navigation

---

## How to Update This File

At the end of every coding session, ask the agent:

> "Update STATUS.md: move completed items to Done, update In Progress, update Last Session Summary."

Only share STATUS.md + the files you worked on. Do not share the full codebase.
