import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdController {
  static final AdController _singleton = AdController._internal();
  final ValueNotifier<bool> adSettingNotifier = ValueNotifier<bool>(true);

  factory AdController() {
    return _singleton;
  }

  AdController._internal();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    adSettingNotifier.value = prefs.getBool("adSetting") ?? true;
  }

  void setAdSetting(bool value) async {
    adSettingNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("adSetting", value);
  }
}
