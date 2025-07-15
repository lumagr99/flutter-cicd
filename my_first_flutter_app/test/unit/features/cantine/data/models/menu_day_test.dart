import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';

import '../../../../../mocks/geolocator_platform_mock.dart';

void main() {
  late CampusCubit campusCubit;
  late MockGeolocatorPlatform mockGeolocator;

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocator;
    campusCubit = CampusCubit();
  });

  tearDown(() {
    campusCubit.close();
  });

  group('CampusCubit', () {
    test('select() should emit the selected campus', () {
      // ARRANGE
      const campus = Campus(
        name: 'Test Campus',
        latitude: 50.0,
        longitude: 7.0,
        menuUrl: 'https://example.com/menu',
      );

      // ACT
      campusCubit.select(campus);

      // ASSERT
      expect(campusCubit.state, campus);
    });

    test('autoSelectNearestCampus() should emit the nearest campus', () async {
      // ARRANGE
      final position = Position(
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
      mockGeolocator.mockPosition = position;

      // ACT
      await campusCubit.autoSelectNearestCampus();

      // ASSERT
      final expectedCampus = CampusData.campuses.reduce((a, b) {
        final da = _distance(position.latitude, position.longitude, a.latitude, a.longitude);
        final db = _distance(position.latitude, position.longitude, b.latitude, b.longitude);
        return da < db ? a : b;
      });

      expect(campusCubit.state, expectedCampus);
    });

    test('autoSelectNearestCampus() should throw if location services are disabled', () async {
      // ARRANGE
      mockGeolocator.mockServiceEnabled = false;

      // ACT & ASSERT
      expect(
            () async => await campusCubit.autoSelectNearestCampus(),
        throwsA(isA<Exception>()),
      );
    });

    test('autoSelectNearestCampus() should throw if permission is denied', () async {
      // ARRANGE
      mockGeolocator.mockPermission = LocationPermission.denied;

      // ACT & ASSERT
      expect(
            () async => await campusCubit.autoSelectNearestCampus(),
        throwsA(isA<Exception>()),
      );
    });

    test('autoSelectNearestCampus() should throw if permission is denied forever', () async {
      // ARRANGE
      mockGeolocator.mockPermission = LocationPermission.deniedForever;

      // ACT & ASSERT
      expect(
            () async => await campusCubit.autoSelectNearestCampus(),
        throwsA(isA<Exception>()),
      );
    });
  });
}


/// Berechnet die Entfernung zwischen zwei GPS-Koordinaten in Kilometern
double _distance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Erdradius in Kilometern

  // Umrechnung der Differenzen in Bogenmaß
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);

  // Haversine-Formel
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}

/// Wandelt Grad in Bogenmaß um
double _deg2rad(double deg) => deg * (pi / 180);

