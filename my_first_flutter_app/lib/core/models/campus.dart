/// Represents a campus location with name, coordinates and menu API URL
class Campus {
  final String name;           // Display name of the campus
  final double latitude;       // Latitude coordinate for geolocation
  final double longitude;      // Longitude coordinate for geolocation
  final String menuUrl;        // URL to fetch the cantine menu for this campus

  const Campus({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.menuUrl,
  });
}
