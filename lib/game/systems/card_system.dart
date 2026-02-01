import 'dart:convert';
import 'package:flutter/services.dart';

class CardConfig {
  final String id;
  final String name;
  final String imagePath;
  final String abilityDescription;
  final String category;
  final int cost;

  CardConfig({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.abilityDescription,
    required this.category,
    required this.cost,
  });

  factory CardConfig.fromJson(Map<String, dynamic> json) {
    return CardConfig(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      abilityDescription: json['abilityDescription'],
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
      print('Error loading cards.json: $e');
    }
  }
}
