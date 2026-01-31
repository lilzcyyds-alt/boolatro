import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../action_panel.dart';
// import '../../../state/run_state.dart';

class ShopStageComponent extends BoolatroComponent {
  final List<ShopItemComponent> _items = [];

  @override
  Future<void> onLoad() async {
    add(TextComponent(
      text: 'SHOP',
      textRenderer: GameStyles.title,
      position: Vector2(size.x / 2, 40),
      anchor: Anchor.center,
    ));

    onStateChanged();
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _refreshInventory();
  }

  void _refreshInventory() {
    for (final item in _items) {
      remove(item);
    }
    _items.clear();

    final shop = runState.shopState;
    final inventory = shop.inventory;

    if (inventory.isEmpty) {
      add(TextComponent(
        text: 'SOLD OUT',
        textRenderer: GameStyles.valueLarge,
        position: size / 2,
        anchor: Anchor.center,
      ));
    } else {
      final itemWidth = 110.0;
      final itemHeight = 150.0;
      final spacing = 20.0;

      double startX = (size.x - (inventory.length * (itemWidth + spacing) - spacing)) / 2;

      for (int i = 0; i < inventory.length; i++) {
        final card = inventory[i];
        final itemComp = ShopItemComponent(
          card: card,
          onBuy: () => runState.buyCard(card),
          canAfford: shop.canBuy(card),
        )
          ..size = Vector2(itemWidth, itemHeight)
          ..position = Vector2(startX + i * (itemWidth + spacing), size.y / 2 - 20);
        
        add(itemComp);
        _items.add(itemComp);
      }
    }

    add(GameButton(
      label: 'BACK TO BLINDS',
      color: Colors.red.shade900,
      onPressed: () => runState.advancePhase(),
    )
      ..size = Vector2(160, 50)
      ..position = Vector2(size.x / 2, size.y - 60)
      ..anchor = Anchor.center);
  }
}

class ShopItemComponent extends PositionComponent {
  final dynamic card;
  final VoidCallback onBuy;
  final bool canAfford;

  ShopItemComponent({
    required this.card,
    required this.onBuy,
    required this.canAfford,
  });

  @override
  Future<void> onLoad() async {
    add(TextComponent(
      text: card.name,
      textRenderer: TextPaint(style: GameStyles.label.style.copyWith(fontSize: 12)),
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.center,
    ));

    add(GameButton(
      label: '\$${card.cost}',
      color: Colors.orange.shade800,
      onPressed: onBuy,
    )
      ..size = Vector2(size.x - 20, 36)
      ..position = Vector2(size.x / 2, size.y - 25)
      ..anchor = Anchor.center
      ..isEnabled = canAfford);
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white.withOpacity(0.1));
    canvas.drawRRect(rect, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }
}
