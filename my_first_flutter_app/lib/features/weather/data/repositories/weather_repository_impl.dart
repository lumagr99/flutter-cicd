import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_first_flutter_app/features/weather/data/models/daily_weather.dart';
import 'package:my_first_flutter_app/features/weather/domain/repositories/weather_repository.dart';

/// Implementation of [WeatherRepository] using the Open-Meteo REST API
class WeatherRepositoryImpl implements WeatherRepository {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  final http.Client _client;

  WeatherRepositoryImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<DailyWeather>> fetchDailyWeather({
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final startDateTime = DateTime(now.year, now.month, now.day);
    final endDateTime = startDateTime.add(const Duration(days: 1));

    final startDate = startDateTime.toIso8601String().split('T').first;
    final endDate = endDateTime.toIso8601String().split('T').first;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code',
      'timezone': 'Europe/Berlin',
      'start_date': startDate,
      'end_date': endDate,
    });

    final resp = await _client.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch weather: HTTP ${resp.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(resp.body) as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>?;

    if (daily == null) {
      throw Exception('Malformed response: no daily section');
    }

    final dates = _requireList<String>(daily, 'time');
    final maxList = _requireList<num>(daily, 'temperature_2m_max');
    final minList = _requireList<num>(daily, 'temperature_2m_min');
    final rainList = _requireList<num>(daily, 'precipitation_sum');
    final weatherCodeList = _requireList<num>(daily, 'weather_code');

    if ({
      dates.length,
      maxList.length,
      minList.length,
      rainList.length,
      weatherCodeList.length,
    }.length != 1) {
      throw Exception('Inconsistent array lengths in daily data');
    }

    final List<DailyWeather> result = [];
    for (var i = 0; i < dates.length; i++) {
      final rawDate = dates[i];
      final utcDate = DateTime.parse(rawDate);
      final date = DateTime(utcDate.year, utcDate.month, utcDate.day);

      final tempMax = maxList[i].toDouble();
      final tempMin = minList[i].toDouble();
      final rain = rainList[i].toDouble();
      final weatherCode = weatherCodeList[i].toInt();

      final dailyWeather = DailyWeather(
        date: date,
        temperatureMax: tempMax,
        temperatureMin: tempMin,
        precipitationSum: rain,
        weatherCode: weatherCode,
      );

      if (dailyWeather.isValid()) {
        result.add(dailyWeather);
      }
    }

    return result;
  }

  List<T> _requireList<T>(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) {
      throw Exception('Missing key "$key" in response');
    }
    if (value is! List) {
      throw Exception('Expected List for "$key", got ${value.runtimeType}');
    }
    try {
      return value.cast<T>();
    } catch (_) {
      throw Exception('List "$key" contains unexpected types');
    }
  }
}
