import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static Future<void> init() async {
    // Configure FlameAudio to use the custom directories
    // By default FlameAudio looks in assets/audio/
    // We can use prefix if we want to change it globally, but music and sfx are separate here.
    // For now we just ensure they are preloaded if needed.
  }

  static void playMusic(String fileName, {double volume = 0.5}) {
    FlameAudio.bgm.play('music/$fileName', volume: volume);
  }

  static void stopMusic() {
    FlameAudio.bgm.stop();
  }

  static void playSfx(String fileName, {double volume = 1.0}) {
    FlameAudio.play('sfx/$fileName', volume: volume);
  }
}
