import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_first_flutter_app/core/cubit/tab_cubit.dart';

import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/views/timetable_view.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/cubit/timetable_cubit.dart';

import '../../../../../mocks/timetable_repository_mock.dart';
import '../../../../../mocks/timetable_storage_repository_mock.dart';
import '../../../../utils/device_setups.dart';

const String basePath = '../../../../../../../goldens/features/timetable/presentation/views/timetable_view';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting('de');
  });

  Future<Widget> buildTestWidget({
    required List<TimetableEntry> entries,
    bool withCredentials = true,
    bool unauthorized = false,
  }) async {
    final repository = TimetableRepositoryMock(
      mockEntries: entries,
      shouldThrowUnauthorized: unauthorized,
    );

    final storage = TimetableStorageRepositoryMock();
    if (withCredentials) {
      await storage.saveCredentials('user', 'pass');
    }

    final cubit = TimetableCubit(repository, storage);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => cubit),
        BlocProvider(create: (_) => TabCubit()),
      ],
      child: Builder(
        builder: (context) {
          cubit.initTimetable(context);
          return const MaterialApp(
            home: TimetableView(),
          );
        },
      ),
    );
  }

  testGoldens('TimetableView - Loaded with grouped entries (multi-device)', (tester) async {
    final now = DateTime(2025, 5, 26, 9);

    final entries = [
      TimetableEntry(
        title: 'Mathe',
        location: 'Raum A',
        start: now,
        end: now.add(const Duration(hours: 1)),
      ),
      TimetableEntry(
        title: 'Physik',
        location: 'Raum B',
        start: now.add(const Duration(days: 1, hours: 1)),
        end: now.add(const Duration(days: 1, hours: 2)),
      ),
    ];

    final widget = await buildTestWidget(entries: entries);

    await tester.pumpWidgetBuilder(widget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await multiScreenGolden(
      tester,
      '$basePath/loaded_real_cubit',
      devices: defaultDevices,
    );
  });

  testGoldens('TimetableView - Fehlerzustand bei ungültigen Login-Daten (multi-device)', (tester) async {
    final widget = await buildTestWidget(
      entries: [],
      withCredentials: true,
      unauthorized: true,
    );

    await tester.pumpWidgetBuilder(widget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await multiScreenGolden(
      tester,
      '$basePath/error_real_cubit',
      devices: defaultDevices,
    );
  });
}
