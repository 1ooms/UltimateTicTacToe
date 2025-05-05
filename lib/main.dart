import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.teal,
  textTheme: GoogleFonts.latoTextTheme(),
);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: App()));
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Tic Tac Toe", theme: theme, home: HomeScreen(), navigatorKey: navigatorKey,);
  }
}
