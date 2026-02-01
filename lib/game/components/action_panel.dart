import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../boolatro_component.dart';
import '../styles.dart';
import '../../state/run_state.dart';

class ActionPanelComponent extends BoolatroComponent {
  late final GameButton editButton;
  late final GameButton discardButton;
  late final GameButton backspaceButton;
  late final GameButton clearButton;

  @override
  Future<void> onLoad() async {
    const buttonWidth = 180.0;
    const buttonHeight = 60.0;
    const spacing = 16.0;

    add(editButton = GameButton(
      label: 'EDIT PROOF',
      color: GameStyles.money, 
      onPressed: () => runState.openProofEditor(),
    )
      ..size = Vector2(buttonWidth, buttonHeight)
      ..position = Vector2(size.x / 2, size.y / 2 - buttonHeight * 1.5 - spacing * 1.5)
      ..anchor = Anchor.center);

    add(discardButton = GameButton(
      label: 'DISCARD',
      color: GameStyles.discards,
      onPressed: () => runState.discardHand(),
    )
      ..size = Vector2(buttonWidth, buttonHeight)
      ..position = Vector2(size.x / 2, size.y / 2 - buttonHeight * 0.5 - spacing * 0.5)
      ..anchor = Anchor.center);

    add(backspaceButton = GameButton(
      label: 'BACKSPACE',
      color: Colors.grey.shade800,
      onPressed: () => runState.removeLastConclusionCard(),
    )
      ..size = Vector2(buttonWidth, buttonHeight)
      ..position = Vector2(size.x / 2, size.y / 2 + buttonHeight * 0.5 + spacing * 0.5)
      ..anchor = Anchor.center);

    add(clearButton = GameButton(
      label: 'CLEAR',
      color: GameStyles.discards.withOpacity(0.5),
      onPressed: () => runState.clearConclusion(),
    )
      ..size = Vector2(buttonWidth, buttonHeight)
      ..position = Vector2(size.x / 2, size.y / 2 + buttonHeight * 1.5 + spacing * 1.5)
      ..anchor = Anchor.center);

    onStateChanged();
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;
    if (runState.phase == GamePhase.start) return;
    super.render(canvas);
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
    
    final isProofPhase = runState.phase == GamePhase.proof;
    final proof = runState.proofState;

    editButton.isEnabled = isProofPhase && proof.hasConclusion && proof.handsRemaining > 0;
    discardButton.isEnabled = isProofPhase && proof.discardsRemaining > 0;
    backspaceButton.isEnabled = isProofPhase && proof.hasConclusion;
    clearButton.isEnabled = isProofPhase && proof.hasConclusion;
    
    editButton.isVisible = isProofPhase;
    discardButton.isVisible = isProofPhase;
    backspaceButton.isVisible = isProofPhase;
    clearButton.isVisible = isProofPhase;
  }
}

class GameButton extends BoolatroComponent with TapCallbacks {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final TextPaint? textRenderer;
  bool isEnabled = true;

  GameButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.textRenderer,
  });

  double _lastTapTime = 0;

  @override
  void onTapDown(TapDownEvent event) {
    if (isEnabled && isVisible) {
      final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
      if (now - _lastTapTime < 0.5) return; // Debounce 0.5s
      _lastTapTime = now;
      onPressed();
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(4),
    );
    
    // Shadow
    canvas.drawRRect(rect.shift(const Offset(2, 2)), Paint()..color = Colors.black.withOpacity(0.3));

    final paint = Paint()..color = isEnabled ? color : color.withOpacity(0.2);
    canvas.drawRRect(rect, paint);
    
    if (isEnabled) {
      canvas.drawRRect(rect, Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke);
    }

    final effectiveTextRenderer = textRenderer ?? (isEnabled ? GameStyles.label : TextPaint(style: GameStyles.label.style.copyWith(color: Colors.white24)));
    effectiveTextRenderer.render(
      canvas,
      label,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}
