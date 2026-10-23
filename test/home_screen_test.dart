import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/controllers/ad_controller.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/game_mode_card.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/home_screen.dart';

import 'package:ultimate_tic_tac_toe/widgets/ads/banner_ad_widget.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdController().adSettingNotifier.value = false;
  });

  group('GameModeGradients', () {
    test('provides blue gradient for local mode', () {
      final light = CardGradients.local(false);
      final dark = CardGradients.local(true);

      expect(light.colors.length, greaterThanOrEqualTo(2));
      expect(dark.colors.length, greaterThanOrEqualTo(2));
      expect(CardGradients.forMode(GameMode.local, false), equals(light));
    });

    test('provides orange gradient for online mode', () {
      final light = CardGradients.online(false);
      final dark = CardGradients.online(true);

      expect(light.colors.length, greaterThanOrEqualTo(2));
      expect(dark.colors.length, greaterThanOrEqualTo(2));
      expect(CardGradients.forMode(GameMode.online, false), equals(light));
    });

    test('provides purple gradient for bot mode', () {
      final light = CardGradients.bot(false);
      final dark = CardGradients.bot(true);

      expect(light.colors.length, greaterThanOrEqualTo(2));
      expect(dark.colors.length, greaterThanOrEqualTo(2));
      expect(CardGradients.forMode(GameMode.bot, false), equals(light));
    });
  });

  group('GameModeCard', () {
    testWidgets('renders title in Expanded without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 220,
              child: GameModeCard(
                title: 'Online game',
                icon: Icons.public,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Online game'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with gradient and white foreground text/icon', (
      tester,
    ) async {
      final gradient = CardGradients.local(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 220,
              child: GameModeCard(
                title: 'Local game',
                icon: Icons.group,
                gradient: gradient,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final ink = tester.widget<Ink>(find.byType(Ink));
      final decoration = ink.decoration as BoxDecoration;
      expect(decoration.gradient, equals(gradient));

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, equals(Colors.white));

      final textWidget = tester.widget<Text>(find.text('Local game'));
      expect(textWidget.style?.color, equals(Colors.white));
    });
  });

  group('BannerAdWidget', () {
    testWidgets('reserves vertical space when ad is not rendered', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(bottomNavigationBar: BannerAdWidget()),
        ),
      );

      final bannerAdFinder = find.byType(BannerAdWidget);
      expect(bannerAdFinder, findsOneWidget);
      final size = tester.getSize(bannerAdFinder);
      expect(size.height, equals(50.0));
    });
  });

  group('HomeScreen', () {
    Widget createHomeScreen({ThemeMode themeMode = ThemeMode.light}) {
      return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Colors.teal,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.teal,
        ),
        themeMode: themeMode,
        home: HomeScreen(
          onChangeThemeMode: (_) {},
          themeMode: themeMode,
          showWelcomeDialog: false,
        ),
      );
    }

    testWidgets('displays single line titles in portrait mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      expect(find.text('Local game'), findsOneWidget);
      expect(find.text('Online game'), findsOneWidget);
      expect(find.text('Bot game'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'displays "game" on a new line and horizontally centered in landscape mode',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createHomeScreen());
        await tester.pumpAndSettle();

        expect(find.text('Local\ngame'), findsOneWidget);
        expect(find.text('Online\ngame'), findsOneWidget);
        expect(find.text('Bot\ngame'), findsOneWidget);

        final card1Rect = tester.getRect(
          find.widgetWithText(GameModeCard, 'Local\ngame'),
        );
        final card3Rect = tester.getRect(
          find.widgetWithText(GameModeCard, 'Bot\ngame'),
        );

        // Verify the row of cards is horizontally centered across the 1920 width
        expect(
          (card1Rect.left - (1920 - card3Rect.right)).abs(),
          lessThan(1.0),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('renders all three gradient cards in dark theme', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createHomeScreen(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.byType(GameModeCard), findsNWidgets(3));
      final inks = tester.widgetList<Ink>(find.byType(Ink));
      expect(inks.length, equals(3));
      for (final ink in inks) {
        final decoration = ink.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
      }
      expect(tester.takeException(), isNull);
    });
  });
}
