import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import '../models/campus.dart';

/// Manages campus state and determines the nearest campus based on geolocation
class CampusCubit extends Cubit<Campus> {
  final GeolocatorPlatform geolocator;

  // Initializes with the first campus as default
  CampusCubit({GeolocatorPlatform? geolocator})
      : geolocator = geolocator ?? GeolocatorPlatform.instance,
        super(CampusData.campuses.first);

  /// Emits the selected campus
  void select(Campus campus) => emit(campus);

  /// Automatically selects the nearest campus based on current position
  Future<void> autoSelectNearestCampus() async {
    final position = await _getCurrentPosition();

    // Finds the closest campus using Geolocator's distanceBetween
    final nearest = CampusData.campuses.reduce((a, b) {
      final da = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        a.latitude,
        a.longitude,
      );
      final db = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        b.latitude,
        b.longitude,
      );
      return da < db ? a : b;
    });

    emit(nearest);
  }

  /// Gets the current device position, requesting permission if needed
  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Standortdienste sind deaktiviert');
    }

    LocationPermission permission = await geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Standortberechtigung verweigert');
    }

    return await geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
