import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/app_drawer.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildAppDrawerTest({
    ThemeMode themeMode = ThemeMode.light,
    void Function(ThemeMode)? onChangeThemeMode,
  }) {
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
      home: Scaffold(
        drawer: AppDrawer(
          onChangeThemeMode: onChangeThemeMode ?? (_) {},
          themeMode: themeMode,
        ),
        body: const Center(child: Text('Body')),
      ),
    );
  }

  group('AppDrawer', () {
    testWidgets(
      'renders DrawerHeader and standard ListTiles in portrait mode',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildAppDrawerTest());
        final scaffoldState = tester.state<ScaffoldState>(
          find.byType(Scaffold),
        );
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        // DrawerHeader with light mode icon is rendered
        final drawerHeader = tester.widget<DrawerHeader>(
          find.byType(DrawerHeader),
        );
        final decoration = drawerHeader.decoration as BoxDecoration;
        final assetImage = decoration.image?.image as AssetImage;
        expect(assetImage.assetName, equals('assets/icon/icon.png'));

        // All 5 options are present
        expect(find.text('Play'), findsOneWidget);
        expect(find.text('Statistics'), findsOneWidget);
        expect(find.text('Achievements'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('How to play'), findsOneWidget);

        // In portrait, tiles use standard density
        final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
        expect(tiles.length, equals(5));
        for (final tile in tiles) {
          expect(tile.dense, isFalse);
          expect(tile.visualDensity, equals(VisualDensity.standard));
        }
      },
    );

    testWidgets('configures dense and compact ListTiles in landscape mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildAppDrawerTest());
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(DrawerHeader), findsOneWidget);

      // All 5 options exist
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('How to play'), findsOneWidget);

      // In landscape, all ListTiles are dense and compact
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(tiles.length, equals(5));
      for (final tile in tiles) {
        expect(tile.dense, isTrue);
        expect(tile.visualDensity, equals(VisualDensity.compact));
      }
    });

    testWidgets('uses dark icon asset in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildAppDrawerTest(themeMode: ThemeMode.dark));
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final drawerHeader = tester.widget<DrawerHeader>(
        find.byType(DrawerHeader),
      );
      final decoration = drawerHeader.decoration as BoxDecoration;
      final assetImage = decoration.image?.image as AssetImage;
      expect(assetImage.assetName, equals('assets/icon/icon_dark.png'));
    });

    testWidgets('tapping Play closes the drawer', (tester) async {
      await tester.pumpWidget(buildAppDrawerTest());
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Play'));
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsNothing);
    });
  });
}
