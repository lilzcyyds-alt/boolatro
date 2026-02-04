import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/material.dart'
    show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';
import 'game_button.dart';
import '../../state/run_state.dart';

class ScoringPanelComponent extends BoolatroComponent {
  late final TextComponent anteValue;
  late final TextComponent moneyText;
  late final TextComponent scoreText;
  late final TextComponent targetText;
  late final TextComponent handsValue;
  late final TextComponent discardValue;

  late final GameButton runInfoButton;
  late final GameButton optionsButton;

  // Score breakdown (Balatro-style): Chips x Multiplier
  late final TextComponent chipsValue;
  late final TextComponent multValue;

  double _displayScore = 0;
  double _displayChips = 0;
  double _displayMult = 0;

  int _targetChips = 0;
  int _targetMult = 0;
  int _targetScore = 0;

  bool _lastShowingPopup = false;
  GamePhase? _lastPhase;

  @override
  Future<void> onLoad() async {
    add(
      anteValue = TextComponent(
        text: '1',
        textRenderer: GameStyles.valueSmall,
        anchor: Anchor.centerRight,
      ),
    );
    add(
      moneyText = TextComponent(
        text: '\$0',
        textRenderer: GameStyles.valueSmall,
        anchor: Anchor.centerRight,
      ),
    );
    add(
      scoreText = TextComponent(
        text: '0',
        textRenderer: GameStyles.valueLarge,
        anchor: Anchor.center,
      ),
    );
    add(
      targetText = TextComponent(
        text: 'Target: 0',
        textRenderer: GameStyles.label,
        anchor: Anchor.center,
      ),
    );
    add(
      handsValue = TextComponent(
        text: '0',
        textRenderer: GameStyles.valueSmall,
        anchor: Anchor.centerRight,
      ),
    );
    add(
      discardValue = TextComponent(
        text: '0',
        textRenderer: GameStyles.valueSmall,
        anchor: Anchor.centerRight,
      ),
    );

    // Breakdown placeholders (wired later when Chips/Mult exist in state)
    add(
      chipsValue = TextComponent(
        text: '0',
        textRenderer: GameStyles.valueSmall,
        anchor: Anchor.centerRight,
      ),
    );
    add(
      multValue = TextComponent(
        text: '1',
        textRenderer: GameStyles.valueSmall,
        anchor: Anchor.centerRight,
      ),
    );

    add(
      runInfoButton = GameButton(
        label: 'RUN INFO',
        color: Colors.blueGrey.shade700,
        onPressed: () => runState.showRunInfo = true,
      )..size = Vector2(210, 48),
    );
    add(
      optionsButton = GameButton(
        label: 'OPTIONS',
        color: Colors.blueGrey.shade700,
        onPressed: () => runState.showOptions = true,
      )..size = Vector2(210, 48),
    );

    onStateChanged();
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;
    if (runState.phase == GamePhase.start) return;

    // Main Panel Background
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.black.withOpacity(0.4));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white10
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Money Pill
    _drawStatPill(canvas, Offset(size.x / 2, 60), 'MONEY', GameStyles.money);

    // Score Box
    final scoreBox = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x / 2, 210), width: 210, height: 110),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      scoreBox,
      Paint()..color = GameStyles.score.withOpacity(0.8),
    );
    canvas.drawRRect(
      scoreBox,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke,
    );

    GameStyles.label.render(
      canvas,
      'SCORE',
      Vector2(size.x / 2, 170),
      anchor: Anchor.center,
    );

    // Score breakdown boxes (Chips x Mult) - side-by-side under the SCORE box
    // Panel width is 230; use two compact boxes with a small gap.
    const boxW = 100.0;
    const boxH = 44.0;
    const gap = 18.0;
    const centerY = 330.0;
    final leftCenterX = size.x / 2 - (boxW / 2) - (gap / 2);
    final rightCenterX = size.x / 2 + (boxW / 2) + (gap / 2);

    // Boxes only (no label text inside). Values are rendered as TextComponents.
    _drawBreakdownBox(
      canvas,
      center: Offset(leftCenterX, centerY),
      color: Colors.teal.shade800,
      width: boxW,
      height: boxH,
    );
    _drawBreakdownBox(
      canvas,
      center: Offset(rightCenterX, centerY),
      color: Colors.purple.shade800,
      width: boxW,
      height: boxH,
    );

    // Multiplication sign between the two boxes (Balatro style: Chips × Mult)
    GameStyles.label.render(
      canvas,
      '×',
      Vector2(size.x / 2, centerY),
      anchor: Anchor.center,
    );

    // Hands Pill
    _drawStatPill(canvas, Offset(size.x / 2, 425), 'HANDS', GameStyles.hands);

    // Discards Pill
    _drawStatPill(
      canvas,
      Offset(size.x / 2, 495),
      'DISCARDS',
      GameStyles.discards,
    );

    // Ante Pill
    _drawStatPill(
      canvas,
      Offset(size.x / 2, 565),
      'ANTE',
      GameStyles.ante,
    );
  }

  void _drawStatPill(Canvas canvas, Offset center, String label, Color color) {
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 210, height: 48),
      const Radius.circular(4),
    );
    canvas.drawRRect(pillRect, Paint()..color = color);
    canvas.drawRRect(
      pillRect,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke,
    );

    final labelPainter = GameStyles.label;
    labelPainter.render(
      canvas,
      label,
      Vector2(center.dx - 90, center.dy),
      anchor: Anchor.centerLeft,
    );
  }

  void _drawBreakdownBox(
    Canvas canvas, {
    required Offset center,
    required Color color,
    required double width,
    required double height,
  }) {
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      const Radius.circular(8),
    );
    canvas.drawRRect(boxRect, Paint()..color = color.withOpacity(0.9));
    canvas.drawRRect(
      boxRect,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke,
    );
  }

  void _jump(PositionComponent component) {
    component.children.whereType<ScaleEffect>().forEach((e) => e.removeFromParent());
    component.scale = Vector2.all(1.0);
    component.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.2),
          EffectController(duration: 0.1, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.1, curve: Curves.easeIn),
        ),
      ]),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isVisible || runState.phase == GamePhase.start) return;

    final proof = runState.proofState;

    bool changed = false;

    // Pause score lerping during validation popup to let user see chips/mult
    if (!proof.showingValidationPopup) {
      if (_displayScore != _targetScore) {
        _displayScore =
            _lerpTo(_displayScore, _targetScore.toDouble(), dt * 4, minStep: 1);
        scoreText.text = _displayScore.toInt().toString();
        changed = true;
      }
    }

    if (_displayChips != _targetChips) {
      _displayChips =
          _lerpTo(_displayChips, _targetChips.toDouble(), dt * 6, minStep: 1);
      chipsValue.text = _displayChips.toInt().toString();
      changed = true;
    }

    if (_displayMult != _targetMult) {
      _displayMult =
          _lerpTo(_displayMult, _targetMult.toDouble(), dt * 6, minStep: 0.1);
      // Show one decimal for small mult values, otherwise integer
      multValue.text =
          (_displayMult < 10 && _displayMult > 0 && _displayMult % 1 != 0)
              ? _displayMult.toStringAsFixed(1)
              : _displayMult.toInt().toString();
      changed = true;
    }

    if (changed) {
      _layout();
    }
  }

  double _lerpTo(double current, double target, double t, {double minStep = 0}) {
    if ((current - target).abs() < (minStep > 0 ? minStep : 0.01)) return target;
    final delta = target - current;
    double step = delta * t;
    if (minStep > 0 && step.abs() < minStep) {
      step = step.sign * minStep;
    }
    if (step.abs() > delta.abs()) return target;
    return current + step;
  }

  void _layout() {
    moneyText.position = Vector2(size.x / 2 + 95, 60);
    scoreText.position = Vector2(size.x / 2, 205);
    targetText.position = Vector2(size.x / 2, 245);
    // Breakdown values sit side-by-side under the SCORE box.
    // Must match render() geometry.
    const boxW = 100.0;
    const gap = 18.0;
    const centerY = 330.0;
    final leftCenterX = size.x / 2 - (boxW / 2) - (gap / 2);
    final rightCenterX = size.x / 2 + (boxW / 2) + (gap / 2);

    // Center the values now that labels are removed.
    chipsValue.anchor = Anchor.center;
    multValue.anchor = Anchor.center;
    chipsValue.position = Vector2(leftCenterX, centerY);
    multValue.position = Vector2(rightCenterX, centerY);

    handsValue.position = Vector2(size.x / 2 + 95, 425);
    discardValue.position = Vector2(size.x / 2 + 95, 495);

    anteValue.position = Vector2(size.x / 2 + 95, 565);

    runInfoButton.position = Vector2(size.x / 2, size.y - 120);
    runInfoButton.anchor = Anchor.center;
    optionsButton.position = Vector2(size.x / 2, size.y - 60);
    optionsButton.anchor = Anchor.center;
  }

  @override
  void onMount() {
    super.onMount();
    runState.addListener(onStateChanged);
    onStateChanged();
  }

  @override
  void onRemove() {
    runState.removeListener(onStateChanged);
    super.onRemove();
  }

  @override
  void onStateChanged() {
    if (!isLoaded || !isVisible || runState.phase == GamePhase.start) return;

    final proof = runState.proofState;
    final shop = runState.shopState;

    final isNewPhase = _lastPhase != runState.phase;
    _lastPhase = runState.phase;

    anteValue.text = runState.currentAnte.toString();
    moneyText.text = '\$${shop.money}';
    // scoreText, chipsValue, multValue are updated in update() for ticking effect
    targetText.text = 'Target: ${proof.blindTargetScore}';
    handsValue.text = proof.handsRemaining.toString();
    discardValue.text = proof.discardsRemaining.toString();

    if (isNewPhase && runState.phase == GamePhase.proof) {
      // Snap values on new blind to prevent unwanted animations/jumps
      _displayScore = proof.blindScore.toDouble();
      _displayChips = proof.currentChips.toDouble();
      _displayMult = proof.currentMult.toDouble();

      scoreText.text = proof.blindScore.toString();
      chipsValue.text = proof.currentChips.toString();
      multValue.text = proof.currentMult.toString();
    }

    _targetChips = proof.currentChips;
    _targetMult = proof.currentMult;
    _targetScore = proof.blindScore;

    // Trigger jump animations on value changes in state (only if not snapped)
    if (!isNewPhase) {
      if (proof.blindScore != _displayScore.toInt() &&
          !proof.showingValidationPopup) {
        // Score only jumps when transfer starts (popup closed)
        if (_lastShowingPopup && !proof.showingValidationPopup) {
          _jump(scoreText);
        }
      }

      if (proof.currentChips != _displayChips.toInt() &&
          proof.currentChips != 0) {
        _jump(chipsValue);
      }
      if (proof.currentMult != _displayMult.toInt() && proof.currentMult != 0) {
        _jump(multValue);
      }
    }

    _lastShowingPopup = proof.showingValidationPopup;

    _layout();
  }
}
