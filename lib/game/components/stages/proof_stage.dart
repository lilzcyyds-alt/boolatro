import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../hand.dart';
import '../../../state/run_state.dart';

class ProofStageComponent extends BoolatroComponent {
  late final TextComponent premiseText;
  final List<LogicCardComponent> _conclusionCards = [];

  @override
  Future<void> onLoad() async {
    add(TextComponent(
      text: 'PREMISE',
      textRenderer: GameStyles.label,
      position: Vector2(size.x / 2, 40),
      anchor: Anchor.center,
    ));

    add(premiseText = TextComponent(
      text: '',
      textRenderer: GameStyles.valueSmall,
      position: Vector2(size.x / 2, 75),
      anchor: Anchor.center,
    ));

    add(TextComponent(
      text: 'CONCLUSION',
      textRenderer: GameStyles.label,
      position: Vector2(size.x / 2, 140),
      anchor: Anchor.center,
    ));

    onStateChanged();
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    
    final proof = runState.proofState;
    premiseText.text = proof.premise ?? '...';

    for (final card in _conclusionCards) {
      remove(card);
    }
    _conclusionCards.clear();

    final tokens = proof.conclusionTokens;
    if (tokens.isEmpty) return;

    final cardWidth = 70.0;
    final cardHeight = 100.0;
    final spacing = 8.0;

    double startX = (size.x - (tokens.length * (cardWidth + spacing) - spacing)) / 2;

    for (int i = 0; i < tokens.length; i++) {
      final cardComp = LogicCardComponent(
        card: tokens[i],
        onPressed: () {},
      )
        ..size = Vector2(cardWidth, cardHeight)
        ..position = Vector2(startX + i * (cardWidth + spacing), 180);
      
      add(cardComp);
      _conclusionCards.add(cardComp);
    }
  }

  @override
  void render(Canvas canvas) {
    final conclusionBox = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x / 2, 230), width: size.x - 40, height: 120),
      const Radius.circular(12),
    );
    canvas.drawRRect(conclusionBox, Paint()..color = Colors.white.withOpacity(0.05));
    canvas.drawRRect(conclusionBox, Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    if (runState.proofState.conclusionTokens.isEmpty) {
      GameStyles.label.render(
        canvas,
        'PLAY CARDS TO BUILD CONCLUSION',
        Vector2(size.x / 2, 230),
        anchor: Anchor.center,
      );
    }
  }
}
