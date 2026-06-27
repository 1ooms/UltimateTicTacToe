import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/home_screen.dart';
import 'package:ultimate_tic_tac_toe/data/pref_keys.dart';
import 'package:ultimate_tic_tac_toe/controllers/ad_controller.dart';
import 'package:ultimate_tic_tac_toe/controllers/audio_controller.dart';

import 'firebase_options.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),
  colorSchemeSeed: Colors.teal,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
  colorSchemeSeed: Colors.teal,
);

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final audioController = AudioController();
  await audioController.initialize();

  final adController = AdController();
  await adController.initialize();

  runApp(ProviderScope(child: App(audioController: audioController)));
}

class App extends StatefulWidget {
  const App({required this.audioController, super.key});

  final AudioController audioController;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late ThemeMode themeMode;
  late SharedPreferences prefs;
  bool isLoading = true;

  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(PrefKeys.themeMode);
    switch (themeModeIndex) {
      case 0:
        themeMode = ThemeMode.light;
        break;
      case 1:
        themeMode = ThemeMode.dark;
        break;
      case 2:
        themeMode = ThemeMode.system;
        break;
      default:
        themeMode = ThemeMode.light;
        break;
    }

    setState(() {
      isLoading = false;
    });
  }

  void _savePrefs() async {
    prefs = await SharedPreferences.getInstance();

    switch (themeMode) {
      case ThemeMode.light:
        prefs.setInt(PrefKeys.themeMode, 0);
        break;
      case ThemeMode.dark:
        prefs.setInt(PrefKeys.themeMode, 1);
        break;
      case ThemeMode.system:
        prefs.setInt(PrefKeys.themeMode, 2);
        break;
    }
  }

  void changeThemeMode(ThemeMode newThemeMode) {
    setState(() {
      themeMode = newThemeMode;
    });
    _savePrefs();
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return MaterialApp(
      title: "Tic Tac Toe",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: HomeScreen(
        onChangeThemeMode: changeThemeMode,
        themeMode: themeMode,
      ),
      navigatorKey: navigatorKey,
      scrollBehavior: AppScrollBehavior(),
    );
  }
}
