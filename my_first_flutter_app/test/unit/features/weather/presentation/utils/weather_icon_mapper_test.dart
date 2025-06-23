import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/weather/presentation/views/utils/weather_icon_mapper.dart';
void main() {
  group('getWeatherCodeIcon', () {
    test('liefert Icons.wb_sunny für Code 0', () {
      expect(getWeatherCodeIcon(0), equals(Icons.wb_sunny));
    });

    test('liefert Icons.wb_cloudy für Codes 1–3', () {
      expect(getWeatherCodeIcon(1), equals(Icons.wb_cloudy));
      expect(getWeatherCodeIcon(3), equals(Icons.wb_cloudy));
    });

    test('liefert Icons.cloud für Codes 4–9', () {
      expect(getWeatherCodeIcon(4), equals(Icons.cloud));
      expect(getWeatherCodeIcon(9), equals(Icons.cloud));
    });

    test('liefert Icons.blur_on für Codes 10–12 und 45', () {
      expect(getWeatherCodeIcon(10), equals(Icons.blur_on));
      expect(getWeatherCodeIcon(45), equals(Icons.blur_on));
    });

    test('liefert Icons.umbrella für Codes 20–29', () {
      expect(getWeatherCodeIcon(20), equals(Icons.umbrella));
      expect(getWeatherCodeIcon(29), equals(Icons.umbrella));
    });

    test('liefert Icons.thunderstorm für Codes 30–32 und 95–97', () {
      expect(getWeatherCodeIcon(30), equals(Icons.thunderstorm));
      expect(getWeatherCodeIcon(97), equals(Icons.thunderstorm));
    });

    test('liefert Icons.blur_on für Codes 40–44 und 46–49', () {
      expect(getWeatherCodeIcon(40), equals(Icons.blur_on));
      expect(getWeatherCodeIcon(49), equals(Icons.blur_on));
    });

    test('liefert Icons.grain für Codes 50–59', () {
      expect(getWeatherCodeIcon(50), equals(Icons.grain));
      expect(getWeatherCodeIcon(59), equals(Icons.grain));
    });

    test('liefert Icons.invert_colors für Codes 60–69', () {
      expect(getWeatherCodeIcon(60), equals(Icons.invert_colors));
      expect(getWeatherCodeIcon(69), equals(Icons.invert_colors));
    });

    test('liefert Icons.ac_unit für Codes 70–79', () {
      expect(getWeatherCodeIcon(70), equals(Icons.ac_unit));
      expect(getWeatherCodeIcon(79), equals(Icons.ac_unit));
    });

    test('liefert Icons.grain für Codes 80–84', () {
      expect(getWeatherCodeIcon(80), equals(Icons.grain));
      expect(getWeatherCodeIcon(84), equals(Icons.grain));
    });

    test('liefert Icons.ac_unit für Codes 85–86', () {
      expect(getWeatherCodeIcon(85), equals(Icons.ac_unit));
      expect(getWeatherCodeIcon(86), equals(Icons.ac_unit));
    });

    test('liefert Icons.flash_on für Codes 90–94 und 98–99', () {
      expect(getWeatherCodeIcon(90), equals(Icons.flash_on));
      expect(getWeatherCodeIcon(99), equals(Icons.flash_on));
    });

    test('liefert Icons.help_outline für unbekannte Codes', () {
      expect(getWeatherCodeIcon(999), equals(Icons.help_outline));
      expect(getWeatherCodeIcon(-1), equals(Icons.help_outline));
    });
  });
}
