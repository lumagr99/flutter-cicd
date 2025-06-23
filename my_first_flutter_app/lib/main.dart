import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:my_first_flutter_app/app.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/tab_cubit.dart';
import 'package:my_first_flutter_app/core/widgets/connectivity_guard.dart';
import 'package:my_first_flutter_app/features/cantine/data/repositories/cantine_repository_impl.dart';
import 'package:my_first_flutter_app/features/cantine/domain/repositories/cantine_repository.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/cubit/cantine_cubit.dart';
import 'package:my_first_flutter_app/features/timetable/data/repositories/timetable_repository_impl.dart';
import 'package:my_first_flutter_app/features/timetable/data/repositories/timetable_storage_repository_impl.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_repository.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_storage_repository.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/cubit/timetable_cubit.dart';
import 'package:my_first_flutter_app/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:my_first_flutter_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:my_first_flutter_app/features/weather/presentation/cubit/weather_cubit.dart';

Future<void> main() async {
  // Ensures widget binding is initialized before other async work
  WidgetsFlutterBinding.ensureInitialized();

  // Enables locale-specific date formatting for 'de_DE'
  await initializeDateFormatting('de_DE');

  // Instantiate repositories
  final TimetableRepository timetableRepository = TimetableRepositoryImpl();
  final TimetableStorageRepository timetableStorage = TimetableStorageRepositoryImpl();
  final CantineRepository cantineRepository = CantineRepositoryImpl();
  final WeatherRepository weatherRepository = WeatherRepositoryImpl();

  // Run application inside a connectivity-aware wrapper
  runApp(
    ConnectivityGuard(
      child: MultiBlocProvider(
        providers: [
          // Provides date selection for today/tomorrow
          BlocProvider(create: (_) => SelectedDateCubit()),

          // Provides navigation tab state
          BlocProvider(create: (_) => TabCubit()),

          // Provides and auto-selects the nearest campus
          BlocProvider(
            create: (_) {
              final cubit = CampusCubit();
              cubit.autoSelectNearestCampus();
              return cubit;
            },
          ),

          // Provides weather data state based on selected campus
          BlocProvider(
            create: (context) => WeatherCubit(
              repository: weatherRepository,
              campusCubit: context.read<CampusCubit>(),
            )..loadWeather(),
          ),

          // Provides cantine menu data state based on selected campus
          BlocProvider(
            create: (context) => CantineCubit(
              repository: cantineRepository,
              campusCubit: context.read<CampusCubit>(),
            )..loadMenu(),
          ),

          // Provides timetable state and secure credential handling
          BlocProvider(
            create: (_) => TimetableCubit(timetableRepository, timetableStorage),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
