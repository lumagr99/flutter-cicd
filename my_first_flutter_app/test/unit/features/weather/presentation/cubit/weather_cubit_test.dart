// test/unit/features/weather/presentation/cubit/weather_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/features/weather/data/models/daily_weather.dart';
import 'package:my_first_flutter_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:my_first_flutter_app/features/weather/presentation/cubit/weather_cubit.dart';

import '../../../../../mocks/weather_repository_mock.dart';

void main() {
  late CampusCubit campusCubit;
  late WeatherCubit cubit;
  final baseDate = DateTime(2025, 5, 26); // festgelegtes Testdatum

  setUp(() {
    campusCubit = CampusCubit();
    cubit = WeatherCubit(
      repository: WeatherRepositoryMock(baseDate: baseDate),
      campusCubit: campusCubit,
    );
  });

  tearDown(() async {
    await cubit.close();
    await campusCubit.close();
  });

  test('emits WeatherLoaded with data on success', () async {
    // Act
    await cubit.loadWeather();

    // Assert
    expect(cubit.state, isA<WeatherLoaded>());
    final data = (cubit.state as WeatherLoaded).data;
    expect(data.length, 2);
    expect(data.first.date, baseDate);
    expect(data.first.temperatureMax, 25);
  });

  test('emits WeatherError on repository exception', () async {
    // Arrange
    final throwingRepo = _ThrowingWeatherRepository();
    final errorCubit = WeatherCubit(
      repository: throwingRepo,
      campusCubit: campusCubit,
    );

    // Act
    await errorCubit.loadWeather();

    // Assert
    expect(errorCubit.state, isA<WeatherError>());
    expect((errorCubit.state as WeatherError).message, contains('Fehler'));

    await errorCubit.close();
  });
}

class _ThrowingWeatherRepository implements WeatherRepository {
  @override
  Future<List<DailyWeather>> fetchDailyWeather({
    required double latitude,
    required double longitude,
  }) {
    throw Exception('API failure');
  }
}
