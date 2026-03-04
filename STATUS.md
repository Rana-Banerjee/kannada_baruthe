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

- **Lesson Selection Screen** - Adding ability to select between multiple lessons
  - Created `LessonIndexService` to load available lessons
  - Created `LessonSelectScreen` to display lesson cards
  - Modified `app.dart` to add `/select` route
  - Modified `home_screen.dart` to navigate to selection screen
  - Modified `lesson_screen.dart` to handle lessonId argument

---

## Next Up ⏭️

1. Fix app bug: Resume not showing when navigating back to home
2. Clear checkpoint between test runs for proper test isolation
3. Run full test suite and fix any remaining issues

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
  - Added Numbers lesson (lesson_02) with 10 exercises
  - Created lesson JSON, updated index, added manifest files
  - Added asset declarations to pubspec.yaml
  - Created placeholder audio files for numbers
  - Added lesson selection screen (lesson_select_screen.dart)
  - Created LessonIndexService to load available lessons
  - Modified app routes and navigation flow
* Files created:
  - `data/lessons/lesson_02.json` - new lesson
  - `data/lessons_index.json` - added lesson_02 entry
  - `assets/images/numbers/IMAGE_MANIFEST.md` - image list
  - `assets/audio/AUDIO_MANIFEST.md` - added numbers section
  - `pubspec.yaml` - added new assets
  - 10 placeholder audio files in `assets/audio/`
  - `lib/models/lesson_index.dart` - new model
  - `lib/services/lesson_index_service.dart` - new service
  - `lib/screens/lesson_select_screen.dart` - new screen
* Modified:
  - `lib/app.dart` - added /select route
  - `lib/screens/home_screen.dart` - navigate to select
  - `lib/screens/lesson_screen.dart` - handle lessonId argument

---

## How to Update This File

At the end of every coding session, ask the agent:

> "Update STATUS.md: move completed items to Done, update In Progress, update Last Session Summary."

Only share STATUS.md + the files you worked on. Do not share the full codebase.
