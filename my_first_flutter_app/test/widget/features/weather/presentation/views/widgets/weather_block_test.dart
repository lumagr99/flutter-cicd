import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/weather/presentation/views/widgets/weather_block.dart';

void main() {
  group('WeatherBlock', () {
    testWidgets('zeigt korrektes Icon, Label und Wert', (tester) async {
      const icon = Icons.thermostat;
      const label = 'Max';
      const value = '25°C';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherBlock(
              icon: icon,
              label: label,
              value: value,
            ),
          ),
        ),
      );

      expect(find.byIcon(icon), findsOneWidget);
      expect(find.text(label), findsOneWidget);
      expect(find.text(value), findsOneWidget);
    });

    testWidgets('setzt Stil korrekt für Label und Wert', (tester) async {
      const icon = Icons.umbrella;
      const label = 'Regen';
      const value = '12 mm';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherBlock(
              icon: icon,
              label: label,
              value: value,
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text(label));
      final valueText = tester.widget<Text>(find.text(value));

      expect(labelText.style?.fontSize, 14);
      expect(labelText.style?.color, Colors.grey[700]);

      expect(valueText.style?.fontSize, 16);
      expect(valueText.style?.fontWeight, FontWeight.bold);
      expect(valueText.style?.color, Colors.black87);
    });
  });

  testWidgets('zeigt auch leeres Label korrekt an', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WeatherBlock(
          icon: Icons.cloud,
          label: '',
          value: '-',
        ),
      ),
    ));

    expect(find.text(''), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('zeigt auch leeren Value korrekt an', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WeatherBlock(
          icon: Icons.cloud,
          label: 'Niederschlag',
          value: '',
        ),
      ),
    ));

    expect(find.text('Niederschlag'), findsOneWidget);
    expect(find.text(''), findsOneWidget);
  });
}
