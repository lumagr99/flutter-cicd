import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import '../../mocks/geolocator_platform_mock.dart';

void main() {
  late MockGeolocatorPlatform mockGeolocator;

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
  });

  group('MockGeolocatorPlatform', () {
    test('isLocationServiceEnabled returns true by default', () async {
      expect(await mockGeolocator.isLocationServiceEnabled(), isTrue);
    });

    test('isLocationServiceEnabled returns false when set', () async {
      mockGeolocator.mockServiceEnabled = false;
      expect(await mockGeolocator.isLocationServiceEnabled(), isFalse);
    });

    test('checkPermission returns default value', () async {
      expect(await mockGeolocator.checkPermission(), LocationPermission.always);
    });

    test('checkPermission returns custom value', () async {
      mockGeolocator.mockPermission = LocationPermission.denied;
      expect(await mockGeolocator.checkPermission(), LocationPermission.denied);
    });

    test('requestPermission returns custom value', () async {
      mockGeolocator.mockPermission = LocationPermission.deniedForever;
      expect(await mockGeolocator.requestPermission(), LocationPermission.deniedForever);
    });

    test('getCurrentPosition returns the set mock position', () async {
      final position = Position(
        latitude: 10.0,
        longitude: 20.0,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 100.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
        isMocked: false,
      );

      mockGeolocator.mockPosition = position;

      final result = await mockGeolocator.getCurrentPosition();

      expect(result.latitude, equals(10.0));
      expect(result.longitude, equals(20.0));
      expect(result.accuracy, equals(5.0));
    });
  });
}
