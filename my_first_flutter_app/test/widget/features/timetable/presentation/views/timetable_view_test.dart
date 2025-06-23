import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_repository.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/cubit/timetable_cubit.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/views/timetable_view.dart';

import '../../../../../mocks/timetable_storage_repository_mock.dart';

class TimetableRepositoryMock implements TimetableRepository {
  List<TimetableEntry> mockEntries;
  bool shouldThrow;

  TimetableRepositoryMock({
    this.mockEntries = const [],
    this.shouldThrow = false,
  });

  @override
  Future<List<TimetableEntry>> fetchEntries(
      String username, String password) async {
    if (shouldThrow) {
      throw Exception('Fehler vom Server');
    }
    return Future.value(mockEntries);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
  });

  group('TimetableView Widget Tests', () {
    testWidgets('zeigt Timetable-Einträge korrekt an', (tester) async {
      final now = DateTime.now();
      final mockRepo = TimetableRepositoryMock(mockEntries: [
        TimetableEntry(
          title: 'Mathematik',
          location: 'Raum A1',
          start: now.add(const Duration(hours: 1)),
          end: now.add(const Duration(hours: 2)),
        ),
      ]);
      final mockStorage = TimetableStorageRepositoryMock();
      await mockStorage.saveCredentials('testuser', 'secure123');

      final cubit = TimetableCubit(mockRepo, mockStorage);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => cubit,
            child: const TimetableView(),
          ),
        ),
      );

      await tester.pump(); // initTimetable
      await tester.pump(const Duration(milliseconds: 100)); // async load
      await tester.pumpAndSettle();

      expect(find.text('Mathematik'), findsOneWidget);
      expect(find.textContaining('Raum A1'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('zeigt Fehlermeldung bei Ladevorgang mit Fehler',
            (tester) async {
          final mockRepo = TimetableRepositoryMock(shouldThrow: true);
          final mockStorage = TimetableStorageRepositoryMock();
          await mockStorage.saveCredentials('user', 'wrong');

          final cubit = TimetableCubit(mockRepo, mockStorage);

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (_) => cubit,
                child: const TimetableView(),
              ),
            ),
          );

          await tester.pump(); // PostFrameCallback
          await tester.pumpAndSettle();

          expect(find.textContaining('Fehler'), findsOneWidget);
        });

    testWidgets('zeigt Login-Dialog wenn keine Zugangsdaten vorhanden sind',
            (tester) async {
          final mockRepo = TimetableRepositoryMock(); // wird hier nicht aufgerufen
          final mockStorage =
          TimetableStorageRepositoryMock(); // keine Zugangsdaten gespeichert

          final cubit = TimetableCubit(mockRepo, mockStorage);

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (_) => cubit,
                child: const TimetableView(),
              ),
            ),
          );

          await tester.pump(); // PostFrameCallback
          await tester.pump(const Duration(milliseconds: 500)); // Warten auf Dialog

          expect(find.text('Zugangsdaten eingeben'), findsOneWidget);
        });

    testWidgets('führt Logout durch und zeigt erneut Login-Dialog',
            (tester) async {
          final now = DateTime.now();
          final mockRepo = TimetableRepositoryMock(mockEntries: [
            TimetableEntry(
              title: 'Mathematik',
              location: 'Raum A1',
              start: now.add(const Duration(hours: 1)),
              end: now.add(const Duration(hours: 2)),
            ),
          ]);
          final mockStorage = TimetableStorageRepositoryMock();
          await mockStorage.saveCredentials('user', 'pw');

          final cubit = TimetableCubit(mockRepo, mockStorage);

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (_) => cubit,
                child: const TimetableView(),
              ),
            ),
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.logout), findsOneWidget);

          await tester.tap(find.byIcon(Icons.logout));
          await tester.pump(); // Trigger logout
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.text('Zugangsdaten eingeben'), findsOneWidget);
        });

    testWidgets('zeigt mehrere Einträge gruppiert nach Tag', (tester) async {
      final now = DateTime.now();
      final entryToday = TimetableEntry(
        title: 'Deutsch',
        location: 'Raum B1',
        start: now.add(const Duration(hours: 1)),
        end: now.add(const Duration(hours: 2)),
      );
      final entryTomorrow = TimetableEntry(
        title: 'Physik',
        location: 'Raum C3',
        start: now.add(const Duration(days: 1, hours: 3)),
        end: now.add(const Duration(days: 1, hours: 4)),
      );

      final mockRepo =
      TimetableRepositoryMock(mockEntries: [entryTomorrow, entryToday]);
      final mockStorage = TimetableStorageRepositoryMock();
      await mockStorage.saveCredentials('testuser', 'pw');

      final cubit = TimetableCubit(mockRepo, mockStorage);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => cubit,
            child: const TimetableView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      final heuteLabel =
      DateFormat('EEEE, dd.MM.', 'de').format(entryToday.start);
      final morgenLabel =
      DateFormat('EEEE, dd.MM.', 'de').format(entryTomorrow.start);

      expect(find.text(heuteLabel), findsOneWidget);
      expect(find.text(morgenLabel), findsOneWidget);

      expect(find.text('Deutsch'), findsOneWidget);
      expect(find.text('Physik'), findsOneWidget);
    });
  });
}