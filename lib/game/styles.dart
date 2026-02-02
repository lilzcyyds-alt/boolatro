import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class GameStyles {
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.white70;
  static const Color background = Color(0xFF0B0B0B);

  // Status Colors
  static Color money = Colors.orange.shade700;
  static Color ante = Colors.indigo.shade700;
  static Color score = Colors.red.shade900;
  static Color hands = Colors.blue.shade700;
  static Color discards = Colors.red.shade700;
  
  static final TextPaint title = TextPaint(
    style: const TextStyle(
      color: primaryText,
      fontSize: 32,
      fontWeight: FontWeight.w900,
    ),
  );

  static final TextPaint label = TextPaint(
    style: const TextStyle(
      color: secondaryText,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  );

  static final TextPaint valueLarge = TextPaint(
    style: const TextStyle(
      color: primaryText,
      fontSize: 40,
      fontWeight: FontWeight.w900,
    ),
  );

  static final TextPaint valueSmall = TextPaint(
    style: const TextStyle(
      color: primaryText,
      fontSize: 28,
      fontWeight: FontWeight.w900,
    ),
  );

  static final TextPaint cardAtom = TextPaint(
    style: const TextStyle(
      color: Colors.black,
      fontSize: 40,
      fontWeight: FontWeight.w900,
    ),
  );

  static final TextPaint cardConnective = TextPaint(
    style: TextStyle(
      color: Colors.blue.shade900,
      fontSize: 40,
      fontWeight: FontWeight.w900,
    ),
  );
}

class UIConfig {
  static const double screenWidth = 1920.0;
  static const double screenHeight = 1080.0;

  static const double margin = 10.0;
  static const double gap = 10.0;

  // Region Dimensions
  static const double phaseInfoWidth = 230.0;
  static const double phaseInfoHeight = 100.0;

  static const double jokerRowWidth = 1420.0;
  static const double jokerRowHeight = 120.0; // Increased from 100 to fit 112 height cards

  static const double scoringPanelWidth = 230.0;
  static const double scoringPanelHeight = 860.0;

  static const double stageWidth = 1420.0;
  static const double stageHeight = 730.0; // Adjusted from 750 to accommodate taller JokerRow

  static const double actionPanelWidth = 220.0;
  static const double actionPanelHeight = 730.0; // Adjusted from 750

  static const double handWidth = 1420.0;
  static const double handHeight = 190.0;

  // Safe Off-screen Offsets
  static const double safeOffX = 2200.0;
  static const double safeOffY = 1200.0;

  // Static Anchors (Layer 1 Positions in 1080p space)
  static final Vector2 phaseInfoPos = Vector2(10, 10);
  static final Vector2 jokerRowPos = Vector2(250, 10);
  static final Vector2 scoringPanelPos = Vector2(10, 210);
  static final Vector2 stagePos = Vector2(250, 140); // Adjusted from 120 (10 + 120 + 10 gap)
  static final Vector2 actionPanelPos = Vector2(1690, 140); // Adjusted from 120
  static final Vector2 handPos = Vector2(250, 880);

  // Rects for reference (relative to 1080p root)
  static Rect get phaseInfoRect => Rect.fromLTWH(phaseInfoPos.x, phaseInfoPos.y, phaseInfoWidth, phaseInfoHeight);
  static Rect get jokerRowRect => Rect.fromLTWH(jokerRowPos.x, jokerRowPos.y, jokerRowWidth, jokerRowHeight);
  static Rect get scoringPanelRect => Rect.fromLTWH(scoringPanelPos.x, scoringPanelPos.y, scoringPanelWidth, scoringPanelHeight);
  static Rect get stageRect => Rect.fromLTWH(stagePos.x, stagePos.y, stageWidth, stageHeight);
  static Rect get actionPanelRect => Rect.fromLTWH(actionPanelPos.x, actionPanelPos.y, actionPanelWidth, actionPanelHeight);
  static Rect get handRect => Rect.fromLTWH(handPos.x, handPos.y, handWidth, handHeight);

  /// Returns a random position far outside the 1920x1080 screen.
  static Vector2 getRandomOffscreenPosition() {
    final rand = math.Random();
    // Use an angle to determine direction
    final double angle = rand.nextDouble() * 2 * math.pi;
    // Radius should be large enough to be completely off-screen.
    // Screen diagonal is sqrt(1920^2 + 1080^2) approx 2200.
    // 2000-2500 is a safe range for the center of the container.
    final double radius = 2000.0 + rand.nextDouble() * 500.0;
    
    return Vector2(
      screenWidth / 2 + math.cos(angle) * radius,
      screenHeight / 2 + math.sin(angle) * radius,
    );
  }
}
