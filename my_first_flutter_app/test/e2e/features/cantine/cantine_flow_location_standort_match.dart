/// End-to-End Test `e2e_100`: Automatic campus selection based on dynamic mock location
///
/// Flow:
/// 1. Start the app
/// 2. Set the mock location to the campus coordinates
/// 3. Verify that the correct campus is automatically selected

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import 'package:my_first_flutter_app/main.dart' as app;

import '../../utils/pump_helper.dart';
import '../../utils/screenshot_helper.dart';

/// Dynamic mock geolocator with configurable position
class DynamicMockGeolocator extends GeolocatorPlatform {
  final double lat;
  final double lon;

  DynamicMockGeolocator({required this.lat, required this.lon});

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;


  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<Position> getCurrentPosition(
      {LocationSettings? locationSettings}) async {
    return Position(
      latitude: lat,
      longitude: lon,
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

void main() {
  // 1) Initialize the test binding
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setTestPrefix("e2e_100");

  // Run a test for each campus
  for (final campus in CampusData.campuses) {
    testWidgets('e2e_100: Auto-selection of ${campus.name}', (tester) async {
      // 2) Set the mock location
      await binding.convertFlutterSurfaceToImage();
      GeolocatorPlatform.instance = DynamicMockGeolocator(
        lat: campus.latitude,
        lon: campus.longitude,
      );

      // Start the app
      app.main();
      await tester.pumpAndSettle();
      await takeScreenshot('tap_mensa_tab');

      // 3) Verify automatic campus selection
      final testCampusFinder = find.byKey(const Key('test-campus'));
      await pumpUntilVisible(tester, testCampusFinder);
      final textWidget = tester.widget<Text>(testCampusFinder);
      expect(textWidget.data, 'TEST_CAMPUS:${campus.name}');
    });
  }
}
