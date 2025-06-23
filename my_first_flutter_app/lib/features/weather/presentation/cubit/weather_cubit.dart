import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/features/weather/data/models/daily_weather.dart';
import 'package:my_first_flutter_app/features/weather/domain/repositories/weather_repository.dart';

/// Base class for all weather-related states
abstract class WeatherState {}

/// State when weather data is being fetched
class WeatherLoading extends WeatherState {}

/// State holding successfully fetched weather data
class WeatherLoaded extends WeatherState {
  final List<DailyWeather> data;
  WeatherLoaded(this.data);
}

/// State when weather data loading fails
class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

/// Manages weather data state and handles fetching logic
class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository repository;
  final CampusCubit campusCubit;

  WeatherCubit({
    required this.repository,
    required this.campusCubit,
  }) : super(WeatherLoading());

  /// Fetches daily weather based on selected campus location
  Future<void> loadWeather() async {
    if (isClosed) return;
    emit(WeatherLoading());

    final campus = campusCubit.state;

    try {
      final temps = await repository.fetchDailyWeather(
        latitude: campus.latitude,
        longitude: campus.longitude,
      );

      if (isClosed) return;
      emit(WeatherLoaded(temps));
    } catch (e) {
      if (isClosed) return;
      emit(WeatherError('Fehler: ${e.toString()}'));
    }
  }
}
