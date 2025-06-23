/// End-to-End Test `e2e_002`: Cancel login twice and check tab navigation behavior
///
/// Goal:
/// This test verifies that canceling the login prompt in the Timetable tab
/// navigates the user back to the previous tab (either Mensa or Weather).
///
/// Steps:
/// 1. Launch app
/// 2. Tap timetable tab and cancel login -> should return to Mensa
/// 3. Switch to weather tab
/// 4. Tap timetable tab again and cancel login -> should return to Weather

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_first_flutter_app/main.dart' as app;

import '../../utils/pump_helper.dart';
import '../../utils/screenshot_helper.dart';

/// Mock Geolocator used in integration tests
class MockGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<LocationPermission> checkPermission() async {
    return LocationPermission.always;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return LocationPermission.always;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return true;
  }

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
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  setTestPrefix('e2e_002');

  testWidgets('e2e_002: Cancel login twice and return to previous tabs', (tester) async {
    // 1. Clear any stored credentials to ensure login prompt appears
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'username');
    await storage.delete(key: 'password');

    // 2. Configure mocks and launch app
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();
    await app.main();
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('app_started');

    // 3. Open timetable tab
    final timetableTab = find.byIcon(Icons.schedule);
    await tester.tap(timetableTab);
    await tester.pump(const Duration(seconds: 2));
    await takeScreenshot('timetable_tab_selected');

    // 4. Assert: Login prompt should be shown
    await pumpUntilVisible(
      tester,
      find.textContaining('Zugangsdaten'),
      timeout: const Duration(seconds: 30),
    );
    expect(find.textContaining('Zugangsdaten'), findsOneWidget);

    // 5. Cancel login and verify return to Mensa
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    final mensaHeadline = find.textContaining('Mensa');
    await pumpUntilVisible(tester, mensaHeadline);
    await takeScreenshot('after_cancel_back_on_mensa');
    expect(mensaHeadline, findsWidgets);

    // 6. Switch to weather tab and verify
    final weatherTab = find.byIcon(Icons.cloud);
    await tester.tap(weatherTab);
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('weather_tab_selected');
    expect(find.textContaining('Wetter'), findsWidgets);

    // 7. Tap timetable again, cancel, and verify return to Weather
    await tester.tap(timetableTab);
    await tester.pump(const Duration(seconds: 2));
    await takeScreenshot('timetable_tab_selected_again');
    await pumpUntilVisible(
      tester,
      find.textContaining('Zugangsdaten'),
      timeout: const Duration(seconds: 30),
    );
    expect(find.textContaining('Zugangsdaten'), findsOneWidget);

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    final wetterText = find.textContaining('Wetter');
    await pumpUntilVisible(tester, wetterText);
    await takeScreenshot('after_second_cancel_back_on_weather');
    expect(wetterText, findsWidgets);
  });
}