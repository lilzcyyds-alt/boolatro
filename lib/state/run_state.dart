import 'package:flutter/foundation.dart';

enum GamePhase {
  start,
  selectBlind,
  proof,
  cashout,
  shop,
}

class RunState extends ChangeNotifier {
  GamePhase _phase = GamePhase.start;
  double _elapsedSeconds = 0;
  double _lastDtSeconds = 0;

  GamePhase get phase => _phase;
  double get elapsedSeconds => _elapsedSeconds;
  double get lastDtSeconds => _lastDtSeconds;

  void tick(double dtSeconds) {
    _lastDtSeconds = dtSeconds;
    _elapsedSeconds += dtSeconds;
    notifyListeners();
  }

  void advancePhase() {
    _phase = _nextPhase(_phase);
    notifyListeners();
  }

  void reset() {
    _phase = GamePhase.start;
    _elapsedSeconds = 0;
    _lastDtSeconds = 0;
    notifyListeners();
  }

  GamePhase _nextPhase(GamePhase phase) {
    switch (phase) {
      case GamePhase.start:
        return GamePhase.selectBlind;
      case GamePhase.selectBlind:
        return GamePhase.proof;
      case GamePhase.proof:
        return GamePhase.cashout;
      case GamePhase.cashout:
        return GamePhase.shop;
      case GamePhase.shop:
        return GamePhase.selectBlind;
    }
  }
}
