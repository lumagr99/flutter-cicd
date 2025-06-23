import 'package:flutter/material.dart';

/// Returns weather icon based on WMO/WeatherCode mapping
IconData getWeatherCodeIcon(num code) {
  final c = code.toInt();

  if (c == 0) return Icons.wb_sunny;
  if (c >= 1 && c <= 3) return Icons.wb_cloudy;
  if (c >= 4 && c <= 9) return Icons.cloud;
  if ((c >= 10 && c <= 12) || c == 45) return Icons.blur_on;
  if (c >= 20 && c <= 29) return Icons.umbrella;
  if ((c >= 30 && c <= 32) || (c >= 95 && c <= 97)) return Icons.thunderstorm;
  if ((c >= 40 && c <= 44) || (c >= 46 && c <= 49)) return Icons.blur_on;
  if (c >= 50 && c <= 59) return Icons.grain;
  if (c >= 60 && c <= 69) return Icons.invert_colors;
  if (c >= 70 && c <= 79) return Icons.ac_unit;
  if (c >= 80 && c <= 84) return Icons.grain;
  if (c == 85 || c == 86) return Icons.ac_unit;
  if ((c >= 90 && c <= 94) || c == 98 || c == 99) return Icons.flash_on;

  return Icons.help_outline;
}
