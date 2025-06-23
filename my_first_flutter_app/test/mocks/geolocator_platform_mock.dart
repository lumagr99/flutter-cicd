import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGeolocatorPlatform extends GeolocatorPlatform with MockPlatformInterfaceMixin {
  Position? mockPosition;
  LocationPermission mockPermission = LocationPermission.always;
  bool mockServiceEnabled = true;

  @override
  Future<bool> isLocationServiceEnabled() async => mockServiceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => mockPermission;

  @override
  Future<LocationPermission> requestPermission() async => mockPermission;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    return mockPosition!;
  }
}
