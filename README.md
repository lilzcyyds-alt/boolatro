# boolatro

A Flutter port (in progress) of the **Boolatro** core loop (Balatro-like run structure), with the key twist:
- **Each Blind is a logic proof puzzle** (proof construction + validation + scoring).

This repo currently contains **Phase 1**: a cruising-style run loop + phase state machine + minimal UI overlays.

---

## Status

- ✅ Phase 0: Flutter project skeleton
- ✅ Phase 1: RunState + Ticker loop + phase flow (minimal UI)
- ⏳ Next: ProofCore port (task generator / validator / scoring) + proper Proof UI

---

## Run Loop (Phase Flow)

Current phase flow matches the Unity prototype at a high level:

Start → SelectBlind → Proof → Cashout → Shop → SelectBlind → …

---

## Project Structure

```text
lib/
  main.dart
  screens/
    game_screen.dart          # Ticker loop + scene root
  state/
    run_state.dart            # ChangeNotifier (single source of truth)

# Planned (next phases)
lib/boolatro/
  phases/
  proof_core/
  ui/
```

---

## Getting Started

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Run tests

```bash
flutter test
```

### 3) Run the app

> Note: macOS desktop requires Xcode (`xcodebuild`). If you see `unable to find utility "xcodebuild"`, install Xcode first.

```bash
# macOS desktop
flutter run -d macos

# web (if Chrome is installed)
flutter run -d chrome
```

---

## Docs

- `design_doc/1. Overview.md`
- `design_doc/2. Architecture.md`
- `design_doc/2.1_phase_flow.md`
- `design_doc/2.2_proof_core.md`

(We keep the doc naming style aligned with the existing `cruising` repo.)
