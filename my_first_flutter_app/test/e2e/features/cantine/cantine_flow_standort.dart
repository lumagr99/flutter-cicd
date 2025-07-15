/// End-to-End Test `e2e_101`: Menu display on campus change
///
/// Steps:
/// 1. Start the app
/// 2. Select the Mensa tab
/// 3. For each campus:
///    a) Open the campus dropdown
///    b) Select a campus
///    c) Verify the displayed menu
///    d) Capture a screenshot after each step

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

/// Mock geolocator that always returns a location and allows permission
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
  // 1) Initialize binding
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Set test prefix for screenshots
  setTestPrefix('e2e_101');

  testWidgets('e2e_101: Menu display on campus change', (tester) async {
    // ARRANGE
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();

    // ACT
    app.main();
    await tester.pumpAndSettle();
    await takeScreenshot('app_started');

    final mensaTab = find.byIcon(Icons.restaurant);
    await tester.tap(mensaTab);
    await tester.pumpAndSettle();
    await takeScreenshot('mensa_tab_selected');

    // ASSERT
    for (final campus in CampusData.campuses) {
      await tester.tap(find.byType(DropdownButtonFormField<Campus>));
      await tester.pumpAndSettle();
      await takeScreenshot('dropdown_open_${campus.name}');

      await tester.tap(find.text(campus.name).last);
      await tester.pumpAndSettle();
      await takeScreenshot('selected_${campus.name}');

      final campusText = find.byKey(const Key('test-campus'));
      await pumpUntilVisible(tester, campusText);
      final widget = tester.widget<Text>(campusText);
      expect(widget.data, 'TEST_CAMPUS:${campus.name}');
      await takeScreenshot('verified_${campus.name}');
    }
  });
}
