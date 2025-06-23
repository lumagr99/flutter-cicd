import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/weather/data/models/daily_weather.dart';

void main() {
  group('DailyWeather.isValid', () {
    test('returns true for valid weather data', () {
      final weather = DailyWeather(
        date: DateTime(2025, 5, 20),
        temperatureMax: 25,
        temperatureMin: 15,
        precipitationSum: 0,
        weatherCode: 0,
      );

      expect(weather.isValid(), isTrue);
    });

    test('returns true even if temperatureMin > temperatureMax', () {
      final weather = DailyWeather(
        date: DateTime(2025, 5, 20),
        temperatureMax: 10,
        temperatureMin: 20,
        precipitationSum: 0,
        weatherCode: 0,
      );

      expect(weather.isValid(), isTrue); // This is now allowed
    });

    test('returns false if precipitationSum is negative', () {
      final weather = DailyWeather(
        date: DateTime(2025, 5, 20),
        temperatureMax: 20,
        temperatureMin: 10,
        precipitationSum: -1,
        weatherCode: 0,
      );

      expect(weather.isValid(), isFalse);
    });

    test('returns false if temperatureMin is too low', () {
      final weather = DailyWeather(
        date: DateTime(2025, 5, 20),
        temperatureMax: 5,
        temperatureMin: -150,
        precipitationSum: 0,
        weatherCode: 0,
      );

      expect(weather.isValid(), isFalse);
    });

    test('returns false if temperatureMax is too high', () {
      final weather = DailyWeather(
        date: DateTime(2025, 5, 20),
        temperatureMax: 150,
        temperatureMin: 10,
        weatherCode: 0,
        precipitationSum: 0,
      );

      expect(weather.isValid(), isFalse);
    });
  });
}
