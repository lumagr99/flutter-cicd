/// End-to-End Test `e2e_103`: Menu and date toggle across campuses
///
/// Goal:
/// This test verifies menu display when changing campuses and toggling between "Today" and "Tomorrow".
///
/// Flow:
/// 1. Launch the app
/// 2. Navigate to the Mensa tab
/// 3. For each campus (Today):
///    a) Select the campus
///    b) Verify the displayed menu
///    c) Take screenshots
/// 4. Toggle to "Tomorrow"
///    a) Take screenshot
/// 5. For each campus (Tomorrow):
///    a) Select the campus
///    b) Verify the displayed menu
///    c) Take screenshots
/// 6. Toggle back to "Today"
///    a) Take screenshot

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

/// Geolocation mock that always returns a valid position
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

/// Helper to select a campus from dropdown
Future<void> selectCampus(WidgetTester tester, Campus campus) async {
  final dropdown = find.byType(DropdownButtonFormField<Campus>);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(campus.name).last);
  await tester.pumpAndSettle();
}

/// Helper to verify the current campus is shown
Future<void> verifyCurrentCampus(WidgetTester tester, Campus campus) async {
  final finder = find.byKey(const Key('test-campus'));
  await pumpUntilVisible(tester, finder);
  final widget = tester.widget<Text>(finder);
  expect(widget.data, 'TEST_CAMPUS:${campus.name}');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setTestPrefix('e2e_103');

  testWidgets('e2e_103: Toggle date and switch campuses', (tester) async {
    // ARRANGE
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();
    app.main();
    await tester.pumpAndSettle();
    await takeScreenshot('app_started');

    // ACT: Select Mensa tab
    final mensaTab = find.byIcon(Icons.restaurant);
    await tester.tap(mensaTab);
    await tester.pumpAndSettle();
    await takeScreenshot('mensa_tab_selected');

    // ASSERT: Verify menus for all campuses (Today)
    for (final campus in CampusData.campuses) {
      await selectCampus(tester, campus);
      await takeScreenshot('today_selected_${campus.name}');
      await verifyCurrentCampus(tester, campus);
      await takeScreenshot('today_verified_${campus.name}');
    }

    // ACT: Toggle to "Tomorrow"
    final toggle = find.byType(ToggleButtons);
    expect(toggle, findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await takeScreenshot('toggled_to_morgen');

    // ASSERT: Verify menus for all campuses (Tomorrow)
    for (final campus in CampusData.campuses) {
      await selectCampus(tester, campus);
      await takeScreenshot('morgen_selected_${campus.name}');
      await verifyCurrentCampus(tester, campus);
      await takeScreenshot('morgen_verified_${campus.name}');
    }

    // ACT: Toggle back to "Today"
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await takeScreenshot('toggled_back_to_today');
  });
}
