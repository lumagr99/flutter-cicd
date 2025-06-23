import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_first_flutter_app/features/weather/data/repositories/weather_repository_impl.dart';

void main() {
  late WeatherRepositoryImpl repository;

  group('WeatherRepositoryImpl.fetchDailyWeather', () {
    const latitude = 51.0;
    const longitude = 7.0;

    test('returns correct data via MockClient', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final responseJson = {
        'daily': {
          'time': [
            today.toIso8601String().split('T').first,
            tomorrow.toIso8601String().split('T').first,
          ],
          'temperature_2m_max': [22.5, 24.0],
          'temperature_2m_min': [12.0, 14.0],
          'precipitation_sum': [1.2, 0.0],
          'weather_code': [1, 2],
        }
      };

      final mockClient = MockClient((http.Request request) async {
        expect(request.url.host, 'api.open-meteo.com');
        return http.Response(jsonEncode(responseJson), 200);
      });

      repository = WeatherRepositoryImpl(client: mockClient);

      final result = await repository.fetchDailyWeather(
        latitude: latitude,
        longitude: longitude,
      );

      expect(result, hasLength(2));
      expect(result[0].temperatureMax, 22.5);
      expect(result[1].temperatureMin, 14.0);
      expect(result[0].weatherCode, 1);
      expect(result[1].weatherCode, 2);
    });

    test('throws when "daily" section is missing', () async {
      final mockClient = MockClient((_) async {
        return http.Response(jsonEncode({}), 200);
      });

      repository = WeatherRepositoryImpl(client: mockClient);

      expect(
            () => repository.fetchDailyWeather(latitude: latitude, longitude: longitude),
        throwsException,
      );
    });

    test('throws when "temperature_2m_max" is missing', () async {
      final mockClient = MockClient((_) async {
        return http.Response(jsonEncode({
          'daily': {
            'time': ['2025-05-26'],
            'temperature_2m_min': [12.0],
            'precipitation_sum': [1.0],
            'weather_code': [1],
          }
        }), 200);
      });

      repository = WeatherRepositoryImpl(client: mockClient);

      expect(
            () => repository.fetchDailyWeather(latitude: latitude, longitude: longitude),
        throwsException,
      );
    });

    test('throws on inconsistent array lengths', () async {
      final mockClient = MockClient((_) async {
        return http.Response(jsonEncode({
          'daily': {
            'time': ['2025-05-26', '2025-05-27'],
            'temperature_2m_max': [22.0],
            'temperature_2m_min': [12.0, 13.0],
            'precipitation_sum': [1.0, 2.0],
            'weather_code': [1, 2],
          }
        }), 200);
      });

      repository = WeatherRepositoryImpl(client: mockClient);

      expect(
            () => repository.fetchDailyWeather(latitude: latitude, longitude: longitude),
        throwsException,
      );
    });

    test('throws on HTTP error response', () async {
      final mockClient = MockClient((_) async {
        return http.Response('Server error', 500);
      });

      repository = WeatherRepositoryImpl(client: mockClient);

      expect(
            () => repository.fetchDailyWeather(latitude: latitude, longitude: longitude),
        throwsException,
      );
    });

    test('filters out invalid DailyWeather via verify()', () async {
      final mockClient = MockClient((_) async {
        return http.Response(jsonEncode({
          'daily': {
            'time': ['2025-05-26', '2025-05-27'],
            'temperature_2m_max': [22.0, -9999.0], // ungültig
            'temperature_2m_min': [12.0, -100.0],
            'precipitation_sum': [1.0, 0.0],
            'weather_code': [1, 2],
          }
        }), 200);
      });

      repository = WeatherRepositoryImpl(client: mockClient);

      final result = await repository.fetchDailyWeather(
        latitude: latitude,
        longitude: longitude,
      );

      expect(result.length, 1);
      expect(result[0].temperatureMax, 22.0);
    });
  });
}
