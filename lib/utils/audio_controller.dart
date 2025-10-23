import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioController {
  static final AudioController _singleton = AudioController._internal();
  late bool soundSetting;

  factory AudioController() {
    return _singleton;
  }

  AudioController._internal();

  SoLoud? _soLoud;
  SoundHandle? soundHandle;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    soundSetting = prefs.getBool("soundSetting") ?? true;

    _soLoud = SoLoud.instance;
    await _soLoud!.init(bufferSize: 512);
  }

  void dispose() {
    _soLoud?.deinit();
  }

  void toggleSound() async {
    soundSetting = !soundSetting;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("soundSetting", soundSetting);
  }

  Future<void> playSound(String assetKey) async {
    if (soundSetting) {
      final source = await _soLoud!.loadAsset(assetKey);

      if (soundHandle != null) {
        await _soLoud!.stop(soundHandle!);
      }
      soundHandle = await _soLoud!.play(source);
    }
  }
}