import 'package:flutter/material.dart';
import 'game/game_config.dart';
import 'game/utils/logger.dart';
import 'screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Log.i('Starting Boolatro...');
  await GameConfig.load();
  runApp(const BoolatroApp());
}

class BoolatroApp extends StatelessWidget {
  const BoolatroApp({super.key, this.enableTicker = true});

  /// Disable the ticker in widget tests so `pumpAndSettle()` can terminate.
  final bool enableTicker;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boolatro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: GameScreen(enableTicker: enableTicker),
    );
  }
}
