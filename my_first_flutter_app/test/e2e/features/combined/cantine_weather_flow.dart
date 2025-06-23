/// End-to-End Test `e2e_301`: Combined display – Mensa and Weather after campus and date switch
///
/// This test verifies that both the canteen menu and the weather display
/// are correctly updated when switching between campuses and toggling dates.

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';
import 'package:my_first_flutter_app/main.dart' as app;

import '../../utils/screenshot_helper.dart';

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
  setTestPrefix('e2e_301');

  testWidgets('e2e_301: Combined display of canteen and weather on campus and date switch', (tester) async {
    // Arrange
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();

    app.main();
    await tester.pumpAndSettle();
    await takeScreenshot('app_started');

    final mensaTab = find.byIcon(Icons.restaurant);
    final weatherTab = find.byIcon(Icons.cloud);
    final toggleButtons = find.byType(ToggleButtons);

    for (final campus in CampusData.campuses) {
      // Act: Select canteen tab and campus
      await tester.tap(mensaTab);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<Campus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(campus.name).last);
      await tester.pumpAndSettle();
      await takeScreenshot('mensa_${campus.name}');

      // Act: Switch to weather tab and campus
      await tester.tap(weatherTab);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<Campus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(campus.name).last);
      await tester.pumpAndSettle();
      await takeScreenshot('weather_today_${campus.name}');

      // Act: Toggle to tomorrow
      await tester.tap(toggleButtons);
      await tester.pumpAndSettle();
      await takeScreenshot('weather_morgen_${campus.name}');

      // Act: Toggle back to today
      await tester.tap(toggleButtons);
      await tester.pumpAndSettle();
      await takeScreenshot('weather_back_today_${campus.name}');
    }
  });
}
