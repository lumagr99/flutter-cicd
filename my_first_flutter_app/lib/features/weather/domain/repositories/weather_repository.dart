import 'package:my_first_flutter_app/features/weather/data/models/daily_weather.dart';

/// Contract for retrieving weather data
abstract class WeatherRepository {
  /// Returns a list of daily weather forecasts for today and tomorrow a given location
  Future<List<DailyWeather>> fetchDailyWeather({
    required double latitude,
    required double longitude,
  });
}
