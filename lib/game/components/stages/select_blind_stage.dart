import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, Paint, RRect, Radius, PaintingStyle, TextStyle, FontWeight;
import '../../boolatro_component.dart';
import '../../styles.dart';
import '../../systems/blind_system.dart';

class SelectBlindStageComponent extends BoolatroComponent {
  final List<BlindCardComponent> blindCards = [];

  @override
  Future<void> onLoad() async {
    final blinds = BlindSystem.blinds;
    for (var i = 0; i < blinds.length; i++) {
      final card = BlindCardComponent(
        config: blinds[i],
        onSelect: () => runState.advancePhase(),
        onSkip: () => runState.skipBlind(),
      )
        ..size = Vector2(300, 450)
        ..anchor = Anchor.center;
      
      blindCards.add(card);
      add(card);
    }

    _layout(animate: false);
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
    if (!isLoaded) return;
    _layout(animate: true);
  }

  void _layout({bool animate = true}) {
    final currentIndex = runState.currentBlindIndex;
    final cardWidth = 300.0;
    final spacing = 40.0;
    final totalWidth = (blindCards.length * cardWidth) + ((blindCards.length - 1) * spacing);
    var startX = (size.x - totalWidth) / 2 + (cardWidth / 2);

    for (var i = 0; i < blindCards.length; i++) {
      final card = blindCards[i];
      double targetY;
      double targetOpacity;
      bool targetActive;
      
      if (i < currentIndex) {
        // Skipped
        targetY = size.y / 2 + 150;
        targetOpacity = 0.5;
        targetActive = false;
      } else if (i == currentIndex) {
        // Current
        targetY = size.y / 2 - 40;
        targetOpacity = 1.0;
        targetActive = true;
      } else {
        // Pending
        targetY = size.y / 2 + 100;
        targetOpacity = 0.7;
        targetActive = false;
      }

      final targetPos = Vector2(startX + i * (cardWidth + spacing), targetY);
      
      if (animate && isMounted) {
        card.flyTo(targetPos, duration: 0.4);
        card.fadeTo(targetOpacity, duration: 0.4);
        card.isActive = targetActive;
      } else {
        card.position = targetPos;
        card.opacity = targetOpacity;
        card.isActive = targetActive;
      }
    }
  }
}

class BlindCardComponent extends BoolatroComponent {
  final BlindConfig config;
  final VoidCallback onSelect;
  final VoidCallback onSkip;
  
  bool _isActive = false;
  
  set isActive(bool value) {
    if (_isActive == value) return;
    _isActive = value;
    _updateButtonVisibility();
  }
  
  bool get isActive => _isActive;

  late final BlindActionButton selectButton;
  late final BlindActionButton skipButton;

  BlindCardComponent({
    required this.config, 
    required this.onSelect,
    required this.onSkip,
  });

  @override
  Future<void> onLoad() async {
    add(selectButton = BlindActionButton(
      label: 'SELECT',
      color: Colors.white,
      textColor: Colors.black,
      onPressed: () {
        runState.selectBlind(config);
        onSelect();
      },
    )
      ..size = Vector2(220, 60)
      ..anchor = Anchor.center
      ..isVisible = isActive);

    add(skipButton = BlindActionButton(
      label: 'SKIP BLIND',
      color: Colors.orange.shade900,
      textColor: Colors.white,
      onPressed: () {
        print('[BlindCardComponent] Skip button pressed for: ${config.name}');
        onSkip();
      },
    )
      ..size = Vector2(220, 60)
      ..anchor = Anchor.center
      ..isVisible = isActive && config.category != 'boss blind');

    _layoutButtons();
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (!isEffectivelyVisible) return false;
    
    // Check buttons first
    if (isActive) {
      if (selectButton.isVisible && selectButton.containsLocalPoint(point - selectButton.position)) {
        return true;
      }
      if (skipButton.isVisible && skipButton.containsLocalPoint(point - skipButton.position)) {
        return true;
      }
      
      // Expand hit area to include buttons
      final expandedRect = Rect.fromLTWH(0, 0, size.x, size.y + 180);
      return expandedRect.contains(point.toOffset());
    }
    
    return super.containsLocalPoint(point);
  }

  void _updateButtonVisibility() {
    try {
      selectButton.isVisible = isActive;
      skipButton.isVisible = isActive && config.category != 'boss blind';
    } catch (_) {
      // Buttons might not be initialized yet
    }
  }

  void _layoutButtons() {
    selectButton.position = Vector2(size.x / 2, size.y + 60);
    skipButton.position = Vector2(size.x / 2, size.y + 130);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (opacity < 1.0) {
      // Use a larger rect to include buttons that are outside the card's local size
      final layerRect = Rect.fromLTWH(-50, -50, size.x + 100, size.y + 250);
      canvas.saveLayer(layerRect, Paint()..color = Colors.white.withOpacity(opacity));
    }

    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(16),
    );
    
    // Outer glow/shadow
    canvas.drawRRect(
      rect.shift(const Offset(4, 4)),
      Paint()..color = Colors.black.withOpacity(0.5),
    );

    // Card background - change color based on blind category
    Color bgColor;
    switch (config.category) {
      case 'boss blind':
        bgColor = Colors.red.shade900;
        break;
      case 'big blind':
        bgColor = Colors.orange.shade900;
        break;
      default:
        bgColor = Colors.blue.shade900;
    }
    
    if (!isActive) {
      bgColor = Color.alphaBlend(Colors.black.withOpacity(0.3), bgColor);
    }

    canvas.drawRRect(rect, Paint()..color = bgColor);
    
    // Border
    canvas.drawRRect(rect, Paint()
      ..color = isActive ? Colors.white : Colors.white60
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4);
    
    // Category Name (Small/Big/Boss)
    GameStyles.label.render(
      canvas,
      config.category.toUpperCase(),
      Vector2(size.x / 2, 40),
      anchor: Anchor.center,
    );

    // Title
    GameStyles.valueSmall.render(
      canvas,
      config.name.toUpperCase(),
      Vector2(size.x / 2, size.y / 2 - 60),
      anchor: Anchor.center,
    );

    // Calculate scaled target score for display
    final scaledScore = (config.targetScore * pow(1.5, runState.currentAnte - 1)).round();

    // Target Score
    GameStyles.title.render(
      canvas,
      '$scaledScore',
      Vector2(size.x / 2, size.y / 2 + 10),
      anchor: Anchor.center,
    );

    GameStyles.label.render(
      canvas,
      'SCORE TO BEAT',
      Vector2(size.x / 2, size.y / 2 + 60),
      anchor: Anchor.center,
    );

    // Reward
    GameStyles.valueSmall.render(
      canvas,
      'Reward: \$${config.reward}',
      Vector2(size.x / 2, size.y / 2 + 110),
      anchor: Anchor.center,
    );

    if (opacity < 1.0) {
      canvas.restore();
    }
    canvas.restore();
  }
}

class BlindActionButton extends BoolatroComponent with TapCallbacks {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  BlindActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;

    final rect = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8));
    
    // Shadow
    canvas.drawRRect(rect.shift(const Offset(2, 2)), Paint()..color = Colors.black45);
    
    canvas.drawRRect(rect, Paint()..color = color);
    canvas.drawRRect(rect, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    final textPaint = TextPaint(style: TextStyle(
      color: textColor, 
      fontWeight: FontWeight.bold, 
      fontSize: 20,
    ));
    
    textPaint.render(
      canvas,
      label,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isEffectivelyVisible) return;
    print('[BlindActionButton] Tapped: $label');
    onPressed();
  }
}
