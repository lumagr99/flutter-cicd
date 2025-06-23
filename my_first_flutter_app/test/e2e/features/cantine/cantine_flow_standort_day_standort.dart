/// End-to-End Test `e2e_102`: Campus switch and date toggle
///
/// This test verifies that the menu content is displayed correctly
/// when switching between campuses and toggling between "Today" and "Tomorrow".
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
  final dropdown = find.byType(DropdownButtonFormField<Campus>);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();

  final option = find.text(campus.name).last;
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> verifyCurrentCampus(WidgetTester tester, Campus campus) async {
  final testCampusFinder = find.byKey(const Key('test-campus'));
  await pumpUntilVisible(tester, testCampusFinder);
  final widget = tester.widget<Text>(testCampusFinder);
  expect(widget.data, 'TEST_CAMPUS:${campus.name}');
}

Future<void> toggleDate(WidgetTester tester) async {
  final toggleButtons = find.byType(ToggleButtons);
  expect(toggleButtons, findsOneWidget);
  await tester.tap(toggleButtons);
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setTestPrefix("e2e_102");

  testWidgets('e2e_102: Campus switch and date toggle', (tester) async {
    // Arrange
    await binding.convertFlutterSurfaceToImage();
    GeolocatorPlatform.instance = MockGeolocatorPlatform();

    app.main();
    await tester.pumpAndSettle();
    await takeScreenshot('app_started');

    final mensaTabFinder = find.byIcon(Icons.restaurant);
    await tester.tap(mensaTabFinder);
    await tester.pumpAndSettle();
    await takeScreenshot('mensa_tab_opened');

    // Act and Assert
    for (final campus in CampusData.campuses) {
      await selectCampus(tester, campus);
      await takeScreenshot('selected_today_${campus.name}');

      await verifyCurrentCampus(tester, campus);
      await takeScreenshot('verified_today_${campus.name}');

      await toggleDate(tester);
      await takeScreenshot('toggled_to_morgen_${campus.name}');

      await verifyCurrentCampus(tester, campus);
      await takeScreenshot('verified_morgen_${campus.name}');

      await toggleDate(tester);
      await takeScreenshot('toggled_back_today_${campus.name}');

      await verifyCurrentCampus(tester, campus);
      await takeScreenshot('verified_back_today_${campus.name}');
    }
  });
}
