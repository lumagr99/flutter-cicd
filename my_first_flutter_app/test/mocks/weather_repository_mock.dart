import 'package:my_first_flutter_app/features/weather/data/models/daily_weather.dart';
import 'package:my_first_flutter_app/features/weather/domain/repositories/weather_repository.dart';

class WeatherRepositoryMock implements WeatherRepository {
  final DateTime baseDate;
  final num? weatherCodeOverride;
  final bool throwError;

  WeatherRepositoryMock({
    required this.baseDate,
    this.weatherCodeOverride,
    this.throwError = false,
  });

  @override
  Future<List<DailyWeather>> fetchDailyWeather({
    required double latitude,
    required double longitude,
  }) async {
    if (throwError) {
      throw Exception('Simulierter Fehler im Mock');
    }

    final today = DateTime(baseDate.year, baseDate.month, baseDate.day);
    final tomorrow = today.add(const Duration(days: 1));

    return [
      DailyWeather(
        date: today,
        temperatureMax: 25,
        temperatureMin: 15,
        weatherCode: weatherCodeOverride ?? 0,
        precipitationSum: 0,
      ),
      DailyWeather(
        date: tomorrow,
        temperatureMax: 22,
        temperatureMin: 13,
        weatherCode: 0,
        precipitationSum: 1.5,
      ),
    ];
  }
}
