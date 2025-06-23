/// Integrationstest `e2e_002`: Wetteranzeige – Standortwechsel & Datumstoggle
///
/// Ziel:
/// Für jeden Campus wird geprüft, ob beim Wechsel des Datums von Heute auf Morgen
/// und zurück die Wetteranzeige korrekt dargestellt wird (Max/Min Temperatur & Regen).
/// Nach jedem Schritt wird ein Screenshot aufgenommen.
///
/// Ablauf für jeden Campus:
/// 1. App starten und Wetter-Tab öffnen
/// 2. Campus auswählen
/// 3. Wetterwerte für Heute erfassen
/// 4. Auf Morgen umschalten, Werte erfassen
/// 5. Zurück auf Heute und nochmals erfassen
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';
import 'package:my_first_flutter_app/main.dart' as app;

import '../../utils/pump_helper.dart';
import '../../utils/screenshot_helper.dart';

class MockGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<LocationPermission> checkPermission() async => LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async => LocationPermission.always;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    return Position(
      latitude: 51.365,
      longitude: 7.492,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 1.0,
      headingAccuracy: 1.0,
    );
  }
}

Future<void> selectCampus(WidgetTester tester, Campus campus) async {
  await tester.tap(find.byType(DropdownButtonFormField<Campus>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(campus.name).last);
  await tester.pumpAndSettle();
}

Future<void> verifyCurrentCampus(WidgetTester tester, Campus campus) async {
  final testCampusFinder = find.byKey(const Key('test-campus'));
  await pumpUntilVisible(tester, testCampusFinder);
  final offstage = tester.widget<Offstage>(testCampusFinder);
  final textWidget = offstage.child! as Text;
  expect(textWidget.data, campus.name);
}

Future<void> extractAndVerifyWeatherValues(WidgetTester tester) async {
  expect(find.textContaining('°C'), findsNWidgets(2));
  expect(find.textContaining('mm'), findsOneWidget);
  expect(find.textContaining('📅'), findsOneWidget);
}

Future<void> toggleDate(WidgetTester tester) async {
  final toggleButtons = find.byType(ToggleButtons);
  expect(toggleButtons, findsOneWidget);
  await tester.tap(toggleButtons);
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setTestPrefix("e2e_002");

  testWidgets('e2e_002: Wetteranzeige – Standortwechsel & Datumstoggle', (tester) async {
    // ARRANGE: App starten & Wetter-Tab aktivieren
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();

    app.main();
    await tester.pumpAndSettle();
    await takeScreenshot('app_started');

    final weatherTab = find.byIcon(Icons.cloud);
    await tester.tap(weatherTab);
    await tester.pumpAndSettle();
    await takeScreenshot('weather_tab');

    for (final campus in CampusData.campuses) {
      // ARRANGE: Campus auswählen
      await selectCampus(tester, campus);
      await takeScreenshot('selected_${campus.name}_heute');

      // ASSERT: Campus korrekt und Daten sichtbar
      await verifyCurrentCampus(tester, campus);
      await extractAndVerifyWeatherValues(tester);
      await takeScreenshot('heute_${campus.name}');

      // ACT: Auf morgen toggeln
      await toggleDate(tester);
      await takeScreenshot('morgen_toggle_${campus.name}');

      // ASSERT: Daten morgen
      await verifyCurrentCampus(tester, campus);
      await extractAndVerifyWeatherValues(tester);
      await takeScreenshot('morgen_${campus.name}');

      // ACT: Zurück auf heute
      await toggleDate(tester);
      await takeScreenshot('zurueck_toggle_${campus.name}');

      // ASSERT: Daten wieder sichtbar
      await verifyCurrentCampus(tester, campus);
      await extractAndVerifyWeatherValues(tester);
      await takeScreenshot('zurueck_heute_${campus.name}');
    }
  });
}
