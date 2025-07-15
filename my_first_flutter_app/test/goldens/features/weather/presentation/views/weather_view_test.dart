import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';

import 'package:my_first_flutter_app/features/weather/presentation/views/weather_view.dart';
import 'package:my_first_flutter_app/features/weather/presentation/cubit/weather_cubit.dart';

import '../../../../../mocks/weather_repository_mock.dart';
import '../../../../utils/device_setups.dart';

const String basePath = '../../../../../../../goldens/features/weather/presentation/views/weather_view';

Future<Widget> _buildWeatherView() async {
  final baseDate = DateTime(2025, 5, 26);
  final repo = WeatherRepositoryMock(baseDate: baseDate);
  final testCampus = CampusData.campuses.first;

  await initializeDateFormatting('de');

  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => SelectedDateCubit()..emit(baseDate)),
      BlocProvider(create: (_) => CampusCubit()..emit(testCampus)),
      BlocProvider(
        create: (context) => WeatherCubit(
          repository: repo,
          campusCubit: BlocProvider.of<CampusCubit>(context),
        )..loadWeather(),
      ),
    ],
    child: const Scaffold(
      body: WeatherView(),
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('WeatherView - responsive layout on multiple devices', (tester) async {
    final widget = await _buildWeatherView();

    await tester.pumpWidgetBuilder(
      widget,
      wrapper: materialAppWrapper(),
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(
      tester,
      '$basePath/responsive',
      devices: defaultDevices,
    );
  });

  testGoldens('WeatherView - narrow layout only', (tester) async {
    final widget = await _buildWeatherView();

    await tester.pumpWidgetBuilder(
      widget,
      surfaceSize: const Size(280, 800),
      wrapper: materialAppWrapper(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await screenMatchesGolden(
      tester,
      '$basePath/narrow',
    );
  });

  testGoldens('WeatherView - wide layout only', (tester) async {
    final widget = await _buildWeatherView();

    await tester.pumpWidgetBuilder(
      widget,
      surfaceSize: const Size(400, 800),
      wrapper: materialAppWrapper(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await screenMatchesGolden(
      tester,
      '$basePath/wide',
    );
  });
}
