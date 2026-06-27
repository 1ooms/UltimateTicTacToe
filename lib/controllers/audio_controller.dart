import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/data/pref_keys.dart';

class AudioController {
  static final AudioController _singleton = AudioController._internal();
  late bool soundSetting;

  factory AudioController() {
    return _singleton;
  }

  AudioController._internal();

  SoLoud? _soLoud;
  SoundHandle? soundHandle;
  final Map<String, AudioSource> _loadedSounds = {};

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    soundSetting = prefs.getBool(PrefKeys.soundSetting) ?? true;

    _soLoud = SoLoud.instance;
    await _soLoud!.init(bufferSize: 256);
    await _loadSounds();
  }

  Future<void> _loadSounds() async {
    final soundAssets = ["assets/sounds/tap.wav"];

    for (final asset in soundAssets) {
      final source = await _soLoud!.loadAsset(asset);
      _loadedSounds[asset] = source;
    }
  }

  void dispose() {
    for (var source in _loadedSounds.values) {
      _soLoud?.disposeSource(source);
    }
    _soLoud?.deinit();
  }

  void toggleSound() async {
    soundSetting = !soundSetting;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(PrefKeys.soundSetting, soundSetting);
  }

  Future<void> playSound(String assetKey) async {
    if (soundSetting && _loadedSounds.containsKey(assetKey)) {
      await _soLoud!.play(_loadedSounds[assetKey]!);
    }
  }
}
