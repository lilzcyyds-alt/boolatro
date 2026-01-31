# boolatro

Phase 1 prototype for a cruising-style run loop with a simple phase state machine.

## Getting Started

- Install Flutter (stable) and run `flutter pub get`
- Launch the app with `flutter run`

## Phase 1 Notes

- `RunState` is a `ChangeNotifier` that tracks the current phase and the tick loop.
- `GameScreen` owns a Ticker-based loop and renders minimal overlays for Start,
  SelectBlind, Proof, Cashout, and Shop.
- Phase flow: Start -> SelectBlind -> Proof -> Cashout -> Shop -> SelectBlind

## Tests

Run `flutter test`.
