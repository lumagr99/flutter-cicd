import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import 'package:my_first_flutter_app/features/weather/presentation/views/weather_view.dart';
import 'package:my_first_flutter_app/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../../mocks/weather_repository_mock.dart';


void main() {
  final testCampus = CampusData.campuses.first;

  setUpAll(() async {
    await initializeDateFormatting('de');
  });

  group('WeatherView Widget Tests', () {
    testWidgets('zeigt Wetterdaten für heute', (tester) async {
      final baseDate = DateTime.now();
      final repo = WeatherRepositoryMock(baseDate: baseDate);
      final selectedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SelectedDateCubit()..emit(selectedDate)),
              BlocProvider(create: (_) => CampusCubit()..emit(testCampus)),
              BlocProvider(
                create: (context) => WeatherCubit(
                  repository: repo,
                  campusCubit: context.read<CampusCubit>(),
                )..loadWeather(),
              ),
            ],
            child: const WeatherView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('°C'), findsNWidgets(2));
      expect(find.textContaining('mm'), findsOneWidget);
    });

    testWidgets('zeigt fallback wenn keine Wetterdaten für Datum', (tester) async {
      final baseDate = DateTime(2020);
      final repo = WeatherRepositoryMock(baseDate: baseDate);
      final selectedDate = baseDate.add(const Duration(days: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SelectedDateCubit()..emit(selectedDate)),
              BlocProvider(create: (_) => CampusCubit()..emit(testCampus)),
              BlocProvider(
                create: (context) => WeatherCubit(
                  repository: repo,
                  campusCubit: context.read<CampusCubit>(),
                )..loadWeather(),
              ),
            ],
            child: const WeatherView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Keine Wetterdaten'), findsOneWidget);
    });

    testWidgets('zeigt Fehlertext bei Fehler im Repository', (tester) async {
      final selectedDate = DateTime.now();
      final repo = WeatherRepositoryMock(
        baseDate: selectedDate,
        throwError: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SelectedDateCubit()..emit(selectedDate)),
              BlocProvider(create: (_) => CampusCubit()..emit(testCampus)),
              BlocProvider(
                create: (context) => WeatherCubit(
                  repository: repo,
                  campusCubit: context.read<CampusCubit>(),
                )..loadWeather(),
              ),
            ],
            child: const WeatherView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Fehler'), findsOneWidget);
    });

    testWidgets('zeigt Ladeindikator während Ladephase', (tester) async {
      final selectedDate = DateTime.now();
      final repo = WeatherRepositoryMock(baseDate: selectedDate);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SelectedDateCubit()..emit(selectedDate)),
              BlocProvider(create: (_) => CampusCubit()..emit(testCampus)),
              BlocProvider(
                create: (context) => WeatherCubit(
                  repository: repo,
                  campusCubit: context.read<CampusCubit>(),
                ),
              ),
            ],
            child: const WeatherView(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('zeigt lokalisiertes Datum korrekt formatiert', (tester) async {
      final now = DateTime(2024, 10, 14);
      final repo = WeatherRepositoryMock(baseDate: now);
      final selectedDate = DateTime(now.year, now.month, now.day);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SelectedDateCubit()..emit(selectedDate)),
              BlocProvider(create: (_) => CampusCubit()..emit(testCampus)),
              BlocProvider(
                create: (context) => WeatherCubit(
                  repository: repo,
                  campusCubit: context.read<CampusCubit>(),
                )..loadWeather(),
              ),
            ],
            child: const WeatherView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Montag'), findsOneWidget);
      expect(find.textContaining('14.10.'), findsOneWidget);
    });

    testWidgets('zeigt keine Daten bei Datum vor Basisdatum', (tester) async {
      final baseDate = DateTime.now();
      final repo = WeatherRepositoryMock(baseDate: baseDate);
      final selectedDate = baseDate.subtract(const Duration(days: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SelectedDateCubit()..emit(selectedDate)),
              BlocProvider(create: (_) => CampusCubit()..emit(testCampus)),
              BlocProvider(
                create: (context) => WeatherCubit(
                  repository: repo,
                  campusCubit: context.read<CampusCubit>(),
                )..loadWeather(),
              ),
            ],
            child: const WeatherView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Keine Wetterdaten'), findsOneWidget);
    });
  });
}
