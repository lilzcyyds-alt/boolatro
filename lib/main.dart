import 'package:flutter/material.dart';

import 'screens/game_screen.dart';

void main() {
  runApp(const BoolatroApp());
}

class BoolatroApp extends StatelessWidget {
  const BoolatroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boolatro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
