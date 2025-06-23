/// End-to-End Test `e2e_003`: Weather display for campus and date switch
///
/// Goal:
/// Verifies that weather data (temperature, rainfall, date) updates correctly
/// when switching between campuses and toggling between "Today" and "Tomorrow".
///
/// Steps:
/// 1. Launch app
/// 2. Open weather tab
/// 3. For each campus (Today):
///    a) Select campus
///    b) Verify weather content
///    c) Capture screenshot
/// 4. Toggle to "Tomorrow" and capture screenshot
/// 5. Repeat verification for each campus (Tomorrow)
/// 6. Toggle back to "Today" and capture screenshot

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

/// Mock geolocator returning fixed location and always granting permissions
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
      altitude: 1.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 1.0,
      headingAccuracy: 1.0,
    );
  }
}

/// Utility to extract visible weather values
Future<Map<String, String>> extractWeatherValues(WidgetTester tester) async {
  final maxText = find.textContaining('Max').last;
  final minText = find.textContaining('Min').last;
  final regenText = find.textContaining('mm').first;

  return {
    'max': (tester.widget<Text>(maxText)).data!,
    'min': (tester.widget<Text>(minText)).data!,
    'regen': (tester.widget<Text>(regenText)).data!,
  };
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setTestPrefix('e2e_003');

  testWidgets('e2e_003: Weather data for each campus and date toggle', (tester) async {
    // ARRANGE: Prepare environment
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();

    app.main();
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('app_started');

    // ACT: Open weather tab
    final weatherTab = find.byIcon(Icons.cloud);
    await tester.tap(weatherTab);
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('weather_tab_selected');

    Future<void> verifyCampuses(String suffix) async {
      for (final campus in CampusData.campuses) {
        // ACT: Select campus
        await tester.tap(find.byType(DropdownButtonFormField<Campus>));
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text(campus.name).last);
        await tester.pump(const Duration(seconds: 1));
        await takeScreenshot('selected_${campus.name}_$suffix');

        // ASSERT: Validate campus label and weather content
        final campusText = find.byKey(const Key('test-campus'));
        await pumpUntilVisible(tester, campusText);
        final offstage = tester.widget<Offstage>(campusText);
        final textWidget = offstage.child! as Text;
        expect(textWidget.data, campus.name);

        expect(find.textContaining('°C'), findsNWidgets(2));
        expect(find.textContaining('mm'), findsOneWidget);
        expect(find.textContaining('📅'), findsOneWidget);

        await extractWeatherValues(tester);
        await takeScreenshot('verified_${campus.name}_$suffix');
      }
    }

    // ACT + ASSERT: Verify today data
    await verifyCampuses('today');

    // ACT: Toggle to tomorrow
    await tester.tap(find.text('Morgen'));
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('toggled_to_tomorrow');

    // ACT + ASSERT: Verify tomorrow data
    await verifyCampuses('tomorrow');

    // ACT: Toggle back to today
    await tester.tap(find.text('Heute'));
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('toggled_back_to_today');
  });
}
