import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../hand.dart';

class ProofStageComponent extends BoolatroComponent {
  late final TextComponent premiseLabel;
  late final TextComponent premiseText;
  late final TextComponent conclusionLabel;
  final Map<int, LogicCardComponent> _conclusionCardMap = {};

  @override
  Future<void> onLoad() async {
    add(premiseLabel = TextComponent(
      text: 'PREMISE',
      textRenderer: GameStyles.label,
      anchor: Anchor.center,
    ));

    add(premiseText = TextComponent(
      text: '',
      textRenderer: GameStyles.valueSmall,
      anchor: Anchor.center,
    ));

    add(conclusionLabel = TextComponent(
      text: 'CONCLUSION',
      textRenderer: GameStyles.label,
      anchor: Anchor.center,
    ));

    onStateChanged();
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    
    _layout();

    final proof = runState.proofState;
    premiseText.text = proof.premise ?? '...';

    final tokens = proof.conclusionTokens;
    
    // Manage components
    final currentIds = tokens.map((t) => t.hashCode).toSet();
    _conclusionCardMap.removeWhere((id, comp) {
      if (!currentIds.contains(id)) {
        remove(comp);
        return true;
      }
      return false;
    });

    if (tokens.isEmpty) return;

    final cardWidth = 70.0;
    final cardHeight = 100.0;
    final spacing = 8.0;

    double startX = (size.x - (tokens.length * (cardWidth + spacing) - spacing)) / 2;

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final id = token.hashCode;
      final targetPos = Vector2(startX + i * (cardWidth + spacing), 200);

      var cardComp = _conclusionCardMap[id];
      if (cardComp == null) {
        cardComp = LogicCardComponent(
          card: token,
          onPressed: () {},
        )
          ..size = Vector2(cardWidth, cardHeight)
          ..position = targetPos;
        add(cardComp);
        _conclusionCardMap[id] = cardComp;
      } else {
        cardComp.flyTo(targetPos);
      }
    }
  }

  void _layout() {
    premiseLabel.position = Vector2(size.x / 2, 40);
    premiseText.position = Vector2(size.x / 2, 75);
    conclusionLabel.position = Vector2(size.x / 2, 160);
  }

  @override
  void render(Canvas canvas) {
    final conclusionBox = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.x / 2, 250), width: size.x - 40, height: 120),
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
        Vector2(size.x / 2, 250),
        anchor: Anchor.center,
      );
    }
  }
}
