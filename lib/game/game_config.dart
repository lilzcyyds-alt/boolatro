import 'dart:convert';
import 'package:flutter/services.dart';
import 'systems/blind_system.dart';
import 'systems/card_system.dart';

class GameConfig {
  static late int initialHands;
  static late int initialDiscards;
  static late int maxHandSize;
  static late int initialMoney;
  static late List<String> allowedAtoms;

  static Future<void> load() async {
    try {
      final String response = await rootBundle.loadString('assets/config/game_config.json');
      final data = await json.decode(response);
      
      final gameplay = data['gameplay'];
      initialHands = gameplay['initialHands'] ?? 3;
      initialDiscards = gameplay['initialDiscards'] ?? 3;
      maxHandSize = gameplay['maxHandSize'] ?? 6;
      initialMoney = gameplay['initialMoney'] ?? 0;
      allowedAtoms = List<String>.from(gameplay['allowedAtoms'] ?? ['P', 'Q', 'R', 'S', 'T']);
      
      // Initialize systems
      await BlindSystem.load();
      await CardSystem.load();
      
    } catch (e) {
      print('Error loading GameConfig: $e');
      // Fallback values
      initialHands = 3;
      initialDiscards = 3;
      maxHandSize = 6;
      initialMoney = 0;
      allowedAtoms = ['P', 'Q', 'R', 'S', 'T'];
    }
  }
}
