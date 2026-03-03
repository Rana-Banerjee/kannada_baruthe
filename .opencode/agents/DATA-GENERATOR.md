# data-generator.md — Kannada Baruthe Data Generator

**Zero app/Dart context needed.** Reads: `data/`, `pubspec.yaml`. Writes: data + assets only.

---

## Inputs

```
CATEGORY:     <e.g., fruits>
LESSON_TITLE: <e.g., Fruits>
LESSON_ID:    <e.g., lesson_02>  # omit to auto-assign next lesson_NN
WORDS:        <comma list, min 4, recommended 6–10>
AUDIO_MODE:   tts_only | files_needed
```

---

## Execution

### 1 — Translate

For each word produce: `kannada_script` (Unicode), `kannada_roman` (ISO 15919), `tts_text` (= script).

ISO 15919 key rules: ā=long a, ī=long i, ū=long u, ḷ=retroflex l.
Prefer Karnataka school textbook forms for ambiguous words.

Output translation table → **pause for user confirmation before continuing.**

```
| English | Kannada Script | Romanized |
|---------|---------------|-----------|
| Apple   | ಸೇಬು           | Sēbu      |
```

### 2 — Build Exercises

For each word: select 3 distractors from WORDS list. If <3 available, ask user for more words.

* `exercise_id`: `ex_001` … `ex_NNN`
* `exercise_type`: `select_correct_image`
* Image path: `assets/images/<category>/<english_lowercase>.png`
* Audio path (files_needed only): `assets/audio/<roman_lowercase_nospaces>.mp3`
* Vary correct tile position (t1–t4) across exercises
* Schema: see `PRD.md → Data Schemas`

### 3 — Write Lesson JSON

`data/lessons/<lesson_id>.json` — full lesson per PRD.md schema.

### 4 — Update Index

Append to `data/lessons_index.json`:

```json
{ "lesson_id": "<id>", "title": "<TITLE>", "file": "data/lessons/<id>.json", "enabled": true }
```

### 5 — Image Manifest

Create `assets/images/<category>/IMAGE_MANIFEST.md`:

```markdown
# Images — <CATEGORY>
Format: PNG, square, min 200×200px, white/transparent bg.
| Filename   | Description                          | Status |
|------------|--------------------------------------|--------|
| apple.png  | Realistic illustration of a red apple | NEEDED |
```

### 6 — Audio Manifest *(files_needed only)*

Append to `assets/audio/AUDIO_MANIFEST.md`:

```markdown
| Filename  | Speak this | Script | Status |
|-----------|-----------|--------|--------|
| sebu.mp3  | ಸೇಬು       | Sēbu   | NEEDED |
```

### 7 — Update pubspec.yaml

Add under `flutter: assets:` if not present:

```yaml
    - assets/images/<category>/
    - assets/audio/
```

### 8 — Summary

```
✅ <LESSON_TITLE> complete
Lesson: data/lessons/<id>.json  ✅
Index:  data/lessons_index.json ✅
pubspec: assets/images/<category>/ ✅
📷 <N> images needed → assets/images/<category>/IMAGE_MANIFEST.md
🔊 TTS only | <N> audio files needed → assets/audio/AUDIO_MANIFEST.md
```

---

## Constraints

* Never read/modify `lib/`, `config/app_config.json`, `data/progress/`
* Always pause after Step 1 for translation confirmation
* Min 4 words (tiles need 4 per exercise)
