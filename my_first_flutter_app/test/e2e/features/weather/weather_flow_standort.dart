/// End-to-End Test `e2e_001`: Weather display after changing campus
///
/// Goal:
/// This test verifies that selecting each campus correctly updates
/// the weather information including temperature, rainfall, and date.
///
/// Steps:
/// 1. Launch app
/// 2. Switch to Weather tab
/// 3. For each campus:
///    a) Select campus via dropdown
///    b) Verify weather information
///    c) Capture screenshots

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

/// Simulated geolocation with fixed coordinates for integration tests
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

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setTestPrefix('e2e_001');

  testWidgets('e2e_001: Weather display updates on campus change', (tester) async {
    // ARRANGE: Start app and configure mock geolocation
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();

    app.main();
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('app_started');

    // ACT: Tap the weather tab
    final weatherTab = find.byIcon(Icons.cloud);
    await tester.tap(weatherTab);
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('weather_tab_selected');

    for (final campus in CampusData.campuses) {
      // ACT: Select campus from dropdown
      await tester.tap(find.byType(DropdownButtonFormField<Campus>));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text(campus.name).last);
      await tester.pump(const Duration(seconds: 1));
      await takeScreenshot('selected_${campus.name}');

      // ASSERT: Verify weather content is displayed correctly
      final campusText = find.byKey(const Key('test-campus'));
      await pumpUntilVisible(tester, campusText);
      final offstage = tester.widget<Offstage>(campusText);
      final textWidget = offstage.child! as Text;
      expect(textWidget.data, campus.name);

      expect(find.textContaining('°C'), findsNWidgets(2));
      expect(find.textContaining('mm'), findsOneWidget);
      expect(find.textContaining('📅'), findsOneWidget);

      await takeScreenshot('verified_${campus.name}');
    }
  });
}
