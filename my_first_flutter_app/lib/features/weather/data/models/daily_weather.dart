/// Represents a single day's weather forecast
class DailyWeather {
  /// Date of the forecast
  final DateTime date;

  /// Maximum temperature in °C
  final num temperatureMax;

  /// Minimum temperature in °C
  final num temperatureMin;

  /// Precipitation sum in mm
  final num precipitationSum;

  /// Weathercode like WMO Weather Interpretation Codes
  final num weatherCode;

  const DailyWeather({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationSum,
    required this.weatherCode,
  });
}

/// Extension for validating DailyWeather
extension DailyWeatherValidation on DailyWeather {
  /// Returns true if the forecast contains plausible values
  bool isValid() {
    return precipitationSum >= 0 &&
        temperatureMax > -100 &&
        temperatureMin > -100 &&
        temperatureMax < 100 &&
        temperatureMin < 100 &&
        weatherCode >= 0;
  }
}
