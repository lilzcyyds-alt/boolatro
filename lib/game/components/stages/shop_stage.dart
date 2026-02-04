import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../game_button.dart';
import '../../boolatro_game.dart';
import '../../utils/logger.dart';
// import '../../../state/run_state.dart';

class ShopStageComponent extends BoolatroComponent {
  final List<ShopItemComponent> _items = [];
  late final BoolatroTextComponent soldOutText;
  late final GameButton backButton;

  @override
  Future<void> onLoad() async {
    add(soldOutText = BoolatroTextComponent(
      text: 'SOLD OUT',
      textRenderer: GameStyles.valueLarge,
      anchor: Anchor.center,
    )..isVisible = false);

    add(backButton = GameButton(
      label: 'BACK TO BLINDS',
      color: GameStyles.discards,
      onPressed: () => runState.advancePhase(),
    )
      ..size = Vector2(240, 60)
      ..anchor = Anchor.center);

    onStateChanged();
  }

  @override
  void onStateChanged() {
    if (!isLoaded) return;
    _layout();
    _refreshInventory();
  }

  void _layout() {
    soldOutText.position = size / 2;
    backButton.position = Vector2(size.x / 2, size.y - 70);
  }

  void _refreshInventory() {
    for (final item in _items) {
      remove(item);
    }
    _items.clear();

    final shop = runState.shopState;
    final inventory = shop.inventory;

    if (inventory.isEmpty) {
      soldOutText.isVisible = true;
    } else {
      soldOutText.isVisible = false;
      final itemWidth = 120.0;
      final itemHeight = 170.0;
      final spacing = 30.0;

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
  }
}

class ShopItemComponent extends PositionComponent with HasGameRef<BoolatroGame> {
  final dynamic card;
  final VoidCallback onBuy;
  final bool canAfford;
  Sprite? _sprite;

  ShopItemComponent({
    required this.card,
    required this.onBuy,
    required this.canAfford,
  });

  @override
  Future<void> onLoad() async {
    if (card.imagePath != null) {
      String path = card.imagePath!;
      if (path.startsWith('assets/images/')) {
        path = path.replaceFirst('assets/images/', '');
      }
      try {
        _sprite = await game.loadSprite(path);
      } catch (e) {
        Log.e('Error loading shop item sprite: $path', error: e);
      }
    }

    final nameComp = BoolatroTextComponent(
      text: card.name,
      textRenderer: TextPaint(style: GameStyles.label.style.copyWith(fontSize: 12)),
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.center,
    );
    add(nameComp);
    
    if (_sprite != null) {
      nameComp.isVisible = false;
    }

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

    if (_sprite != null) {
      // Draw a small background for the sprite
      canvas.drawRRect(rect, Paint()..color = Colors.white.withOpacity(0.05));
      _sprite!.render(canvas, 
        position: Vector2(size.x / 2, size.y / 2 - 10),
        size: Vector2(84, 112), // Standard card size in shop
        anchor: Anchor.center,
      );
    } else {
      canvas.drawRRect(rect, Paint()..color = Colors.white.withOpacity(0.1));
    }

    canvas.drawRRect(rect, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }
}
