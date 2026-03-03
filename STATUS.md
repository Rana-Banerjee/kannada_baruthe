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

---

## In Progress 🔧

- Lesson screen implementation complete
  - Loads lesson JSON with 10 exercises
  - Displays word header with Kannada + Roman + audio button
  - 2x2 tile grid with images and labels
  - Feedback banner after selection (green/red)
  - Progress counter "1 / 10"
  - Checkpoint save after each exercise
  - Completion screen with score

---

## Next Up ⏭️

1. Test the app: Run `flutter run` and verify lesson flow
2. Set up Playwright: `pip install pytest playwright && playwright install chromium`
3. Generate + run tests via playwright-tester sub-agent
4. Debug any UI/UX issues from screenshots

---

## Blocked / Decisions Pending ⚠️

*(none)*

---

## Known Issues 🐛

*(none)*

---

## Last Session Summary

* Date: Mar 3, 2026
* What was done: Built complete lesson flow - models, services, widgets, and screens. Now clicking "Start Lesson" loads the 10 fruit exercises with full UI.
* Files changed: lesson_screen.dart, complete_screen.dart, lesson_service.dart, audio_service.dart, tts_service.dart, lesson.dart, exercise.dart, tile.dart, word_header.dart, image_tile.dart, tile_grid.dart, feedback_banner.dart
* Tests passing: N/A (manual testing)
* Left off at: Need to test the full lesson flow

---

## How to Update This File

At the end of every coding session, ask the agent:

> "Update STATUS.md: move completed items to Done, update In Progress, update Last Session Summary."

Only share STATUS.md + the files you worked on. Do not share the full codebase.
