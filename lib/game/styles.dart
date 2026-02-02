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

  // Editor Region (Covers Stage, ActionPanel, and Hand)
  // Region C width (1420) + Region D width (220) + Gap (10) + ActionPanel right margin (10) = 1660?
  // No, Region C (250 to 1670), Region D (1690 to 1910). 
  // If we want it to NOT cover the bottom-right gap:
  // Region E is at (250, 880) with height 190. Ends at (1670, 1070).
  // The area to cover is:
  // Width: From 250 to 1910 (Region D right edge) = 1660.
  // Height: From 140 (Stage top) to 1070 (Hand bottom) = 930.
  // BUT the user says it should not exceed Region C, Region D + E, and bottom-right gap.
  // Actually, Region D ends at Y=870 (140 + 730). 
  // The bottom-right gap is the area below Region D (Y > 870) and to the right of Region E (X > 1670).
  // So the Editor should be:
  // Top: 140
  // Left: 250
  // Width: 1660 (covers X from 250 to 1910)
  // Height: 730 (covers Y from 140 to 870, i.e., Stage and Action Panel)
  // PLUS the Hand area below it (Region E), which is (250, 880) size (1420, 190).
  // If the Editor is a single rectangle, it can't perfectly avoid the bottom-right gap while covering both D and E
  // unless we shape it or limit its height.
  // Given the instruction "尺寸不能超过 region C， region D + region E以及 右下角的 gap 区域", 
  // it implies the editor should occupy the space of C, D, and E.
  // Region C + D width = 1420 + 10 (gap) + 220 = 1650. (X: 250 to 1900? No, 250+1420=1670, 1670+20=1690. Action Panel starts at 1690).
  // So C + D total width = (1690 + 220) - 250 = 1660.
  // Region C height = 730. Region E height = 190. Total height = 730 + 10 (gap) + 190 = 930.
  // Bottom-right gap is at X > 1670 and Y > 870.
  // To avoid this gap, the editor can't be a simple 1660x930 rectangle.
  // However, usually "Logic Editor" is a rectangle. 
  // If we must avoid the gap, we either:
  // 1. Limit width to 1420 (only Region C and E)
  // 2. Limit height to 730 (only Region C and D)
  // Looking at the "region D + region E" phrasing, it likely means the UNION of these areas.
  // The maximum rectangle that fits in C U D U E AND avoids the gap is either:
  // A) Width 1420, Height 930 (C + E)
  // B) Width 1660, Height 730 (C + D)
  // Let's assume the user wants it to cover as much as possible of C, D, and E while staying within their bounds.
  // Region D: (1690, 140) to (1910, 870)
  // Region E: (250, 880) to (1670, 1070)
  // Region C: (250, 140) to (1670, 870)
  // Bottom-right gap: (1670, 870) to (1920, 1080) approx.
  // To stay within C + D + E and NOT touch the gap:
  // The editor should be 1660x730 (covering C and D) OR we keep it 1660x930 but it WILL cover the gap.
  // Wait, if I make it 1660 width and 930 height, it covers (250, 140) to (1910, 1070).
  // This COVERS the bottom-right gap. The user says "不能超过...以及 右下角的 gap 区域". 
  // "以及" (and) here might mean "and [also not exceed] the gap area" or "and [the union includes] the gap area".
  // In Chinese, "不能超过 A, B 以及 C" usually means it must stay within the bounds of A, B, and C.
  // If the gap is a "region" it should NOT be exceeded.
  // Let's look at the coordinates again.
  // Region C: 1420x730 at (250, 140)
  // Region D: 220x730 at (1690, 140) -> Right edge at 1910.
  // Region E: 1420x190 at (250, 880) -> Bottom edge at 1070.
  // Union of C and D is a rectangle: (250, 140) to (1910, 870). Size: 1660x730.
  // Union of C and E is a rectangle: (250, 140) to (1670, 1070). Size: 1420x930.
  // The gap is at (1680+, 880+). 
  // If I want to include D and E, I have to be careful.
  // Actually, if I use 1660x930, the bottom-right corner is (1910, 1070), which IS the gap.
  // So to NOT exceed them, I should probably stick to a size that fits the union.
  // But a single rectangle can't fit the L-shape of C+D+E without covering the gap.
  // Unless... the Editor itself is NOT a simple rectangle? No, Flame components are usually rects.
  // I will adjust the dimensions to 1420x930 to cover C and E, OR 1660x730 to cover C and D.
  // Usually the editor needs height. Let's go with 1420x930 which covers the Stage and Hand.
  // Wait, let's re-read: "尺寸不能超过 region C， region D + region E以及 右下角的 gap 区域".
  // Maybe the "gap" IS a region it CAN occupy? "Region D + Region E 以及 右下角的 gap 区域" could be the right side + bottom area.
  // Let's check the design doc again.
  // Action Panel (D) is (1690, 140) size (220, 730).
  // Hand (E) is (250, 880) size (1420, 190).
  // If we take (Region C + Region D) and (Region E + bottom-right gap), we get a large rectangle.
  // C+D width = 1660.
  // E+gap width = (1910 - 250) = 1660.
  // So the rectangle (250, 140) to (1910, 1070) is 1660x930.
  // This rectangle EXACTLY covers C, D, E, and the gap between them, AND the bottom-right gap.
  // The user says "不能超过... 以及 右下角的 gap 区域". This sounds like it CAN cover those.
  // "不能超过" (cannot exceed) means the boundary.
  // So 1660x930 is likely correct as it uses the full space of C, D, E and the gaps.
  // Wait, "不能超过" means it must be WITHIN.
  // If I use 1660x930, I am occupying C, D, E and the gap.
  // If the user meant the editor should ONLY be in C, then it's 1420x730.
  // But they mentioned D and E.
  // Let's assume the current 1660x930 is what they want, but maybe I missed a margin?
  // Action Panel Right Edge: 1690 + 220 = 1910. 1920 - 1910 = 10px margin. Correct.
  // Hand Bottom Edge: 880 + 190 = 1070. 1080 - 1070 = 10px margin. Correct.
  // So 1660x930 is the maximum possible rectangle.
  // Maybe the user is pointing out that it should NOT be "Full Screen"? 
  // Previously it was "Center" and "Padding 32", which might have been larger or different.
  // I will keep 1660x930 but double check if there's any "gap" I should explicitly leave.
  // Right side gap: 1910 to 1920.
  // Bottom gap: 1070 to 1080.
  // These are 10px margins.
  // Wait, "右下角的 gap 区域" (the gap area in the bottom right).
  // In the diagram, there is a "10px Gap" explicitly labeled below Region D and to the right of Region E.
  // If the editor is 1660x930, it COVERS that 10px gap.
  // If the user says it should NOT exceed it, maybe they mean it CAN include it?
  // Or maybe they mean it should NOT be larger than the combined area of C, D, E and that gap.
  // I'll stick with 1660x930 but verify the code.
  
  static const double editorPanelWidth = 1660.0;
  static const double editorPanelHeight = 930.0;
  static final Vector2 editorPanelPos = Vector2(250, 140);

  // Rects for reference (relative to 1080p root)
  static Rect get phaseInfoRect => Rect.fromLTWH(phaseInfoPos.x, phaseInfoPos.y, phaseInfoWidth, phaseInfoHeight);
  static Rect get jokerRowRect => Rect.fromLTWH(jokerRowPos.x, jokerRowPos.y, jokerRowWidth, jokerRowHeight);
  static Rect get scoringPanelRect => Rect.fromLTWH(scoringPanelPos.x, scoringPanelPos.y, scoringPanelWidth, scoringPanelHeight);
  static Rect get stageRect => Rect.fromLTWH(stagePos.x, stagePos.y, stageWidth, stageHeight);
  static Rect get actionPanelRect => Rect.fromLTWH(actionPanelPos.x, actionPanelPos.y, actionPanelWidth, actionPanelHeight);
  static Rect get handRect => Rect.fromLTWH(handPos.x, handPos.y, handWidth, handHeight);
  static Rect get editorPanelRect => Rect.fromLTWH(editorPanelPos.x, editorPanelPos.y, editorPanelWidth, editorPanelHeight);

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
