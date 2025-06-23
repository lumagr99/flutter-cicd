import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/weather/data/models/daily_weather.dart';

import '../../mocks/weather_repository_mock.dart';

void main() {
  group('WeatherRepositoryMock', () {
    test('liefert zwei Tage: heute und morgen', () async {
      // Arrange
      final baseDate = DateTime(2025, 5, 26);
      final repo = WeatherRepositoryMock(baseDate: baseDate);
      final today = DateTime(baseDate.year, baseDate.month, baseDate.day);
      final tomorrow = today.add(const Duration(days: 1));

      // Act
      final result = await repo.fetchDailyWeather(latitude: 51.0, longitude: 7.0);

      // Assert
      expect(result, isA<List<DailyWeather>>());
      expect(result.length, 2);
      expect(result[0].date, today);
      expect(result[1].date, tomorrow);
      expect(result[0].temperatureMax, 25);
      expect(result[1].precipitationSum, 1.5);
    });

    test('setzt override weatherCode korrekt', () async {
      final repo = WeatherRepositoryMock(
        baseDate: DateTime(2025, 5, 26),
        weatherCodeOverride: 95,
      );

      final result = await repo.fetchDailyWeather(latitude: 0, longitude: 0);

      expect(result.first.weatherCode, 95);
    });

    test('verwendet default weatherCode 0 ohne override', () async {
      final repo = WeatherRepositoryMock(baseDate: DateTime(2025, 5, 26));

      final result = await repo.fetchDailyWeather(latitude: 0, longitude: 0);

      expect(result.first.weatherCode, 0);
    });

    test('löst Fehler aus bei throwError = true', () async {
      final repo = WeatherRepositoryMock(
        baseDate: DateTime(2025, 5, 26),
        throwError: true,
      );

      expect(
            () => repo.fetchDailyWeather(latitude: 0, longitude: 0),
        throwsA(isA<Exception>()),
      );
    });

    test('liefert plausible Wetterdatenstruktur', () async {
      final repo = WeatherRepositoryMock(baseDate: DateTime(2025, 5, 26));

      final result = await repo.fetchDailyWeather(latitude: 0, longitude: 0);

      for (final entry in result) {
        expect(entry.temperatureMax, greaterThan(-100));
        expect(entry.temperatureMin, greaterThan(-100));
        expect(entry.precipitationSum, greaterThanOrEqualTo(0));
        expect(entry.isValid(), isTrue);
      }
    });
  });
}
