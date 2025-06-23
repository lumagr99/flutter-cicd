import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';

import 'package:my_first_flutter_app/features/cantine/data/models/meal.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/menu_day.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/cubit/cantine_cubit.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/views/cantine_view.dart';

import '../../../../../mocks/cantine_repository_mock.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
  });

  group('CantineView Widget Tests', () {
    late DateTime today;
    late Campus testCampus;

    setUp(() {
      today = DateTime.now();
      testCampus = CampusData.campuses.first;
    });

    Widget buildTestWidget({
      required CantineCubit cantineCubit,
      required CampusCubit campusCubit,
      DateTime? selected,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cantineCubit),
          BlocProvider.value(value: campusCubit),
          BlocProvider(create: (_) => SelectedDateCubit()..emit(selected ?? today)),
        ],
        child: const MaterialApp(home: CantineView()),
      );
    }

    testWidgets('zeigt Ladespinner bei CantineLoading', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final cubit = CantineCubit(
        repository: CantineRepositoryMock(),
        campusCubit: campusCubit,
      )..emit(CantineLoading());

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('zeigt Fehlermeldung bei CantineError', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final cubit = CantineCubit(
        repository: CantineRepositoryMock(),
        campusCubit: campusCubit,
      )..emit(CantineError('Fehler beim Laden'));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      expect(find.text('Fehler beim Laden'), findsOneWidget);
    });

    testWidgets('zeigt Gerichte bei exaktem Datum', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final menuDay = MenuDay(
        date: today,
        label: "Montag",
        meals: [Meal(id: "1", name: 'Pizza', prices: [300, 500])],
      );

      final cubit = CantineCubit(
        repository: CantineRepositoryMock(mockData: [menuDay]),
        campusCubit: campusCubit,
      )..emit(CantineLoaded([menuDay]));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      await tester.pumpAndSettle();

      expect(find.text('Pizza'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('zeigt Fallback-Menü wenn kein Menü für today', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final fallbackDate = today.add(const Duration(days: 1));
      final menuDay = MenuDay(
        date: fallbackDate,
        label: "Montag",
        meals: [Meal(id: "2", name: 'Burger', prices: [400, 600])],
      );

      final cubit = CantineCubit(
        repository: CantineRepositoryMock(mockData: [menuDay]),
        campusCubit: campusCubit,
      )..emit(CantineLoaded([menuDay]));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('Kein Menü am gewählten Tag'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('zeigt letzten verfügbaren Tag wenn kein späterer existiert', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final earlierDate = today.subtract(const Duration(days: 2));
      final menuDay = MenuDay(
        date: earlierDate,
        label: "Montag",
        meals: [Meal(id: "3", name: 'Wok-Gemüse', prices: [320, 520])],
      );

      final cubit = CantineCubit(
        repository: CantineRepositoryMock(mockData: [menuDay]),
        campusCubit: campusCubit,
      )..emit(CantineLoaded([menuDay]));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      await tester.pumpAndSettle();

      expect(find.text('Wok-Gemüse'), findsOneWidget);
    });

    testWidgets('zeigt keine Gerichte bei leerer Liste', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final cubit = CantineCubit(
        repository: CantineRepositoryMock(mockData: []),
        campusCubit: campusCubit,
      )..emit(CantineLoaded([]));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('zeigt unsichtbare Campus-/Datumsinformationen', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final menuDay = MenuDay(
        date: today,
        label: "Montag",
        meals: [Meal(id: "4", name: 'Salat', prices: [200, 400])],
      );

      final cubit = CantineCubit(
        repository: CantineRepositoryMock(mockData: [menuDay]),
        campusCubit: campusCubit,
      )..emit(CantineLoaded([menuDay]));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('test-campus')), findsOneWidget);
      expect(find.byKey(const Key('test-date')), findsOneWidget);
    });

    testWidgets('zeigt unbekannten Zustand', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final cubit = CantineCubit(
        repository: CantineRepositoryMock(),
        campusCubit: campusCubit,
      )..emit(_UnknownState());

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      expect(find.text('Unbekannter Zustand'), findsOneWidget);
    });

    // Neue Tests:

    testWidgets('zeigt mehrere Gerichte für denselben Tag', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final menuDay = MenuDay(
        date: today,
        label: "Montag",
        meals: [
          Meal(id: "1", name: 'Currywurst', prices: [250, 450]),
          Meal(id: "2", name: 'Veggie Bowl', prices: [300, 500]),
        ],
      );

      final cubit = CantineCubit(
        repository: CantineRepositoryMock(mockData: [menuDay]),
        campusCubit: campusCubit,
      )..emit(CantineLoaded([menuDay]));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      await tester.pumpAndSettle();

      expect(find.text('Currywurst'), findsOneWidget);
      expect(find.text('Veggie Bowl'), findsOneWidget);
    });

    testWidgets('zeigt Gericht ohne Preis an', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      final menuDay = MenuDay(
        date: today,
        label: "Montag",
        meals: [
          Meal(id: "3", name: 'Suppe', prices: []),
        ],
      );

      final cubit = CantineCubit(
        repository: CantineRepositoryMock(mockData: [menuDay]),
        campusCubit: campusCubit,
      )..emit(CantineLoaded([menuDay]));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      await tester.pumpAndSettle();

      expect(find.text('Suppe'), findsOneWidget);
    });

    testWidgets('zeigt lange Gerichtnamen korrekt an', (tester) async {
      final campusCubit = CampusCubit()..emit(testCampus);
      const longTitle = 'Spaghetti mit sehr langer Beschreibung und Sauce';
      final menuDay = MenuDay(
        date: today,
        label: "Montag",
        meals: [
          Meal(id: "5", name: longTitle, prices: [450, 650]),
        ],
      );

      final cubit = CantineCubit(
        repository: CantineRepositoryMock(mockData: [menuDay]),
        campusCubit: campusCubit,
      )..emit(CantineLoaded([menuDay]));

      await tester.pumpWidget(buildTestWidget(cantineCubit: cubit, campusCubit: campusCubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('Spaghetti mit sehr langer Beschreibung'), findsOneWidget);
    });
  });
}

/// Dummy-State zur Simulation eines unbekannten Cantine-Zustands
class _UnknownState extends CantineState {}
