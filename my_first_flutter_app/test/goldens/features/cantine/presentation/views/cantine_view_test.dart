import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';

import 'package:my_first_flutter_app/features/cantine/presentation/views/cantine_view.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/cubit/cantine_cubit.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/menu_day.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/meal.dart';

import '../../../../../mocks/cantine_repository_mock.dart';
import '../../../../utils/device_setups.dart';

const String basePath = '../../../../../../../goldens/features/cantine/presentation/view/cantine_view';

void main() {
  // Lokales Absicherungs-Setup für die Locale-Daten
  setUpAll(() async {
    await initializeDateFormatting('de');
  });

  Meal testMeal(String name) => Meal(id: "1", name: name, prices: [250, 400, 550]);

  Future<({Widget widget, CantineCubit cubit})> buildCantineView({
    required CantineRepositoryMock repository,
    required DateTime selectedDate,
    int campusIndex = 0,
  }) async {
    final campus = CampusData.campuses[campusIndex];
    final campusCubit = CampusCubit()..emit(campus);
    final cantineCubit = CantineCubit(repository: repository, campusCubit: campusCubit);

    final widget = MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SelectedDateCubit()..emit(selectedDate)),
        BlocProvider<CampusCubit>.value(value: campusCubit),
        BlocProvider<CantineCubit>.value(value: cantineCubit),
      ],
      child: const MaterialApp(
        home: Scaffold(body: CantineView()),
      ),
    );

    return (widget: widget, cubit: cantineCubit);
  }

  testGoldens('CantineView – fallback Menü (real Cubit, multi-device)', (tester) async {
    final selectedDate = DateTime(2025, 5, 24);
    final fallbackDate = DateTime(2025, 5, 26);

    final repository = CantineRepositoryMock(
      mockData: [
        MenuDay(
          date: fallbackDate,
          label: "Montag",
          meals: [
            testMeal('Linseneintopf'),
            testMeal('Käsespätzle'),
          ],
        ),
      ],
    );

    final setup = await buildCantineView(
      repository: repository,
      selectedDate: selectedDate,
      campusIndex: 0,
    );

    await setup.cubit.loadMenu();

    await tester.pumpWidgetBuilder(setup.widget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await multiScreenGolden(
      tester,
      '$basePath/fallback_real_cubit',
      devices: defaultDevices,
    );
  });

  testGoldens('CantineView – Fehlerzustand (real Cubit, multi-device)', (tester) async {
    final repository = CantineRepositoryMock(shouldThrow: true);

    final setup = await buildCantineView(
      repository: repository,
      selectedDate: DateTime(2025, 5, 26),
      campusIndex: 1,
    );

    await setup.cubit.loadMenu();

    await tester.pumpWidgetBuilder(setup.widget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await multiScreenGolden(
      tester,
      '$basePath/error_real_cubit',
      devices: defaultDevices,
    );
  });
}
