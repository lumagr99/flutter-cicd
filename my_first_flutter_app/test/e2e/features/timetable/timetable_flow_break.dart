/// End-to-End Test `e2e_002`: Cancel login twice and verify tab navigation behavior
///
/// Objective:
/// This test verifies that cancelling the login prompt in the timetable tab
/// correctly navigates the user back to the previously selected tab (Mensa or Weather).

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_first_flutter_app/main.dart' as app;

import '../../utils/pump_helper.dart';
import '../../utils/screenshot_helper.dart';

/// Mock Geolocator used for integration testing
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
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  setTestPrefix('e2e_002');

  testWidgets('e2e_002: Cancel login twice and return to previous tab', (tester) async {
    // 1. Clear any stored credentials to force login prompt
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'username');
    await storage.delete(key: 'password');

    // 2. Configure mocks and launch app
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();
    await app.main();
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('app_started');

    // 3. Define tab finders
    final timetableTab = find.byIcon(Icons.schedule);
    final weatherTab   = find.byIcon(Icons.cloud);

    // 4. First cancellation flow
    await tester.tap(timetableTab);
    await tester.pump(const Duration(seconds: 2));
    await takeScreenshot('timetable_tab_selected');
    await pumpUntilVisible(
      tester,
      find.textContaining('Zugangsdaten'),
      timeout: const Duration(seconds: 30),
    );
    expect(find.textContaining('Zugangsdaten'), findsOneWidget);

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    final mensaHeadline = find.textContaining('Mensa');
    await pumpUntilVisible(tester, mensaHeadline);
    await takeScreenshot('after_cancel_back_on_mensa');
    expect(mensaHeadline, findsWidgets);

    // 5. Switch to Weather and verify
    await tester.tap(weatherTab);
    await tester.pump(const Duration(seconds: 1));
    await takeScreenshot('weather_tab_selected');
    expect(find.textContaining('Wetter'), findsWidgets);

    // 6. Second cancellation flow
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
