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
      const campus = Campus(
        name: 'Test Campus',
        latitude: 50.0,
        longitude: 7.0,
        menuUrl: 'https://example.com/menu',
      );

      campusCubit.select(campus);

      expect(campusCubit.state, campus);
    });

    test('autoSelectNearestCampus() should emit the nearest campus', () async {
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

      await campusCubit.autoSelectNearestCampus();

      final expectedCampus = CampusData.campuses.reduce((a, b) {
        final da = _distance(position.latitude, position.longitude, a.latitude, a.longitude);
        final db = _distance(position.latitude, position.longitude, b.latitude, b.longitude);
        return da < db ? a : b;
      });

      expect(campusCubit.state, expectedCampus);
    });

    test('autoSelectNearestCampus() should throw if location services are disabled', () async {
      mockGeolocator.mockServiceEnabled = false;

      expect(
            () async => await campusCubit.autoSelectNearestCampus(),
        throwsA(isA<Exception>()),
      );
    });

    test('autoSelectNearestCampus() should throw if permission is denied', () async {
      mockGeolocator.mockPermission = LocationPermission.denied;

      expect(
            () async => await campusCubit.autoSelectNearestCampus(),
        throwsA(isA<Exception>()),
      );
    });

    test('autoSelectNearestCampus() should throw if permission is denied forever', () async {
      mockGeolocator.mockPermission = LocationPermission.deniedForever;

      expect(
            () async => await campusCubit.autoSelectNearestCampus(),
        throwsA(isA<Exception>()),
      );
    });
  });
}

double _distance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Erdradius in km
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _deg2rad(double deg) => deg * (pi / 180);
