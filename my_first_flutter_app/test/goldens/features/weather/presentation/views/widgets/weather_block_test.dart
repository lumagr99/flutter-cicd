import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:my_first_flutter_app/features/weather/presentation/views/widgets/weather_block.dart';
import '../../../../../utils/device_setups.dart'; // falls dort defaultDevices liegt

const String basePath = '../../../../../../../../goldens/features/weather/presentation/views/widgets/weather_block';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting('de');
  });

  testGoldens('WeatherBlock - multi screen (responsive)', (tester) async {
    const widget = WeatherBlock(
      icon: Icons.water_drop,
      label: 'Luftfeuchtigkeit',
      value: '68%',
    );

    await tester.pumpWidgetBuilder(widget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await multiScreenGolden(
      tester,
      '$basePath/responsive',
      devices: defaultDevices,
    );
  });
}
