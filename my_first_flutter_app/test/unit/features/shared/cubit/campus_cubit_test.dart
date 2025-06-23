import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';

import '../../../../mocks/geolocator_platform_mock.dart';

void main() {
  late CampusCubit cubit;
  late MockGeolocatorPlatform mockGeolocator;

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    cubit = CampusCubit(geolocator: mockGeolocator);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('select() emits the givconstmpus', () {
    const testCampus = Campus(
      name: 'TestCampus',
      latitude: 51.0,
      longitude: 7.0,
      menuUrl: 'https://example.com',
    );

    cubit.select(testCampus);

    expect(cubit.state, testCampus);
  });

  test('autoSelectNearestCampus() selects correct campus', () async {
    mockGeolocator.mockPosition = Position(
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
      isMocked: false,
    );

    await cubit.autoSelectNearestCampus();

    final expectedCampus = CampusData.campuses.reduce((a, b) {
      final da = Geolocator.distanceBetween(
        mockGeolocator.mockPosition!.latitude,
        mockGeolocator.mockPosition!.longitude,
        a.latitude,
        a.longitude,
      );
      final db = Geolocator.distanceBetween(
        mockGeolocator.mockPosition!.latitude,
        mockGeolocator.mockPosition!.longitude,
        b.latitude,
        b.longitude,
      );
      return da < db ? a : b;
    });

    expect(cubit.state, expectedCampus);
  });

  test('throws if location services are disabled', () async {
    mockGeolocator.mockServiceEnabled = false;

    expect(() async => await cubit.autoSelectNearestCampus(), throwsA(isA<Exception>()));
  });

  test('throws if location permission is denied', () async {
    mockGeolocator.mockPermission = LocationPermission.denied;

    expect(() async => await cubit.autoSelectNearestCampus(), throwsA(isA<Exception>()));
  });

  test('throws if location permission is denied forever', () async {
    mockGeolocator.mockPermission = LocationPermission.deniedForever;

    expect(() async => await cubit.autoSelectNearestCampus(), throwsA(isA<Exception>()));
  });
}
