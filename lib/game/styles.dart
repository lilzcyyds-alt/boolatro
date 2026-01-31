import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class GameStyles {
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.white70;
  static const Color background = Color(0xFF0B0B0B);
  
  static final TextPaint title = TextPaint(
    style: const TextStyle(
      color: primaryText,
      fontSize: 24,
      fontWeight: FontWeight.w900,
    ),
  );

  static final TextPaint label = TextPaint(
    style: const TextStyle(
      color: secondaryText,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  );

  static final TextPaint valueLarge = TextPaint(
    style: const TextStyle(
      color: primaryText,
      fontSize: 24,
      fontWeight: FontWeight.w900,
    ),
  );

  static final TextPaint valueSmall = TextPaint(
    style: const TextStyle(
      color: primaryText,
      fontSize: 18,
      fontWeight: FontWeight.w900,
    ),
  );
}
