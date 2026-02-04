import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

class CardConfig {
  final String id;
  final String name;
  final String? content;
  final String imagePath;
  final String description;
  final String category;
  final int cost;

  CardConfig({
    required this.id,
    required this.name,
    this.content,
    required this.imagePath,
    required this.description,
    required this.category,
    required this.cost,
  });

  factory CardConfig.fromJson(Map<String, dynamic> json) {
    return CardConfig(
      id: json['id'],
      name: json['name'],
      content: json['content'],
      imagePath: json['imagePath'],
      description: json['description'] ?? '',
      category: json['category'],
      cost: json['cost'],
    );
  }
}

class CardSystem {
  static final List<CardConfig> _cards = [];

  static List<CardConfig> get cards => List.unmodifiable(_cards);

  static Future<void> load() async {
    try {
      final String response = await rootBundle.loadString('assets/config/cards.json');
      final List<dynamic> data = json.decode(response);
      _cards.clear();
      _cards.addAll(data.map((json) => CardConfig.fromJson(json)).toList());
    } catch (e) {
      Log.e('Error loading cards.json', error: e);
    }
  }

  static CardConfig? findRandomByContent(String content) {
    final candidates = _cards.where((c) => c.content == content).toList();
    if (candidates.isEmpty) return null;
    return candidates[Random().nextInt(candidates.length)];
  }

  static CardConfig? findById(String id) {
    return _cards.firstWhere((c) => c.id == id, orElse: () => _cards.first);
  }
}
