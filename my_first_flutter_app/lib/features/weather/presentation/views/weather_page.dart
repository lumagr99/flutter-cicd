import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:my_first_flutter_app/features/weather/domain/repositories/weather_repository.dart';
import '../cubit/weather_cubit.dart';
import 'weather_view.dart';

/// Provides the WeatherCubit and displays the WeatherView
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final WeatherRepository repository = WeatherRepositoryImpl(); // Concrete implementation

    return BlocProvider(
      create: (context) => WeatherCubit(
        repository: repository,
        campusCubit: context.read<CampusCubit>(), // Campus state dependency
      )..loadWeather(), // Load weather immediately on creation
      child: const WeatherView(), // UI layer
    );
  }
}
