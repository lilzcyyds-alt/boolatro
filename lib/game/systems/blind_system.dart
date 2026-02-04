import 'dart:convert';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

class BlindConfig {
  final String id;
  final String name;
  final String category;
  final int targetScore;
  final int reward;
  final String premise;

  BlindConfig({
    required this.id,
    required this.name,
    required this.category,
    required this.targetScore,
    required this.reward,
    required this.premise,
  });

  factory BlindConfig.fromJson(Map<String, dynamic> json) {
    return BlindConfig(
      id: json['id'],
      name: json['name'],
      category: json['category'] ?? 'small blind',
      targetScore: json['targetScore'],
      reward: json['reward'],
      premise: json['premise'],
    );
  }
}

class BlindSystem {
  static final List<BlindConfig> _blinds = [];

  static List<BlindConfig> get blinds => List.unmodifiable(_blinds);

  static Future<void> load() async {
    try {
      final String response = await rootBundle.loadString('assets/config/blinds.json');
      final List<dynamic> data = json.decode(response);
      _blinds.clear();
      _blinds.addAll(data.map((json) => BlindConfig.fromJson(json)).toList());
    } catch (e) {
      Log.e('Error loading blinds.json', error: e);
      // Fallback or empty list
    }
  }

  static BlindConfig? getBlind(String id) {
    try {
      return _blinds.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
