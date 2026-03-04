## Step 1 — Read these two files, in this order, nothing else yet

1. `STATUS.md` — current state, active issue, next steps
2. `AGENTS.md` — rules, folder map, recipes, semantic keys

## Step 2 — Report back in exactly this format, then stop

```
STATUS: <one sentence>
ISSUE:  <one sentence, or "none">
NEXT:   <single next action from STATUS.md>
TASK?   What do you want to work on this session?
```

## Step 3 — After user confirms task

Read ONLY the files listed in the AGENTS.md Recipes table for that task.
Read nothing else. State what you will do. Wait for go-ahead.

## Step 4 — Session close (every session, no exceptions)

* Update STATUS.md: move completed items to Done, update In Progress, update Last Session Summary
* Confirm no hardcoded values were introduced
* Confirm any new widgets have kl_ semantic keys

---

## Never read unless explicitly asked

`PRD.md` · `build/` · `android/` · `ios/` · `linux/` · `macos/` · `windows/` · `pubspec.lock`
