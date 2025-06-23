import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';
import 'package:my_first_flutter_app/features/weather/data/models/daily_weather.dart';
import 'package:my_first_flutter_app/features/weather/presentation/views/utils/weather_icon_mapper.dart';
import 'package:my_first_flutter_app/features/weather/presentation/views/widgets/weather_block.dart';
import '../cubit/weather_cubit.dart';

class WeatherView extends StatelessWidget {
  const WeatherView({super.key});

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = context.watch<SelectedDateCubit>().state;
    final currentCampus = context.watch<CampusCubit>().state;

    return BlocListener<CampusCubit, Campus>(
      listenWhen: (previous, current) =>
      previous.latitude != current.latitude || previous.longitude != current.longitude,
      listener: (context, _) {
        context.read<WeatherCubit>().loadWeather();
      },
      child: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          final hiddenCampus = Offstage(
            key: const Key('test-campus'),
            child: Text(currentCampus.name),
          );

          if (state is WeatherLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  hiddenCampus,
                  const CircularProgressIndicator(),
                ],
              ),
            );
          } else if (state is WeatherLoaded) {
            DailyWeather? weather;
            for (final w in state.data) {
              if (isSameDay(w.date, selectedDate)) {
                weather = w;
                break;
              }
            }

            if (weather == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    hiddenCampus,
                    const Text('Keine Wetterdaten für den gewählten Tag'),
                  ],
                ),
              );
            }

            final w = weather;
            final date = DateFormat('EEEE, dd.MM.yyyy', 'de').format(w.date);
            const IconData tempIcon = Icons.thermostat;
            const IconData rainIcon = Icons.invert_colors;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  hiddenCampus,
                  Text(
                    '📅 $date',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Icon(
                    getWeatherCodeIcon(w.weatherCode),
                    size: 96,
                    color: Colors.blueAccent,
                  ),

                  const SizedBox(height: 32),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 300;

                      final blocks = [
                        WeatherBlock(
                          icon: tempIcon,
                          label: 'Max',
                          value: '${w.temperatureMax.round()}°C',
                        ),
                        WeatherBlock(
                          icon: tempIcon,
                          label: 'Min',
                          value: '${w.temperatureMin.round()}°C',
                        ),
                        WeatherBlock(
                          icon: rainIcon,
                          label: 'Regen',
                          value: '${w.precipitationSum.round()} mm',
                        ),
                      ];

                      return isNarrow
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: blocks
                            .map((block) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: block,
                        ))
                            .toList(),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: blocks,
                      );
                    },
                  ),
                ],
              ),
            );
          } else if (state is WeatherError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  hiddenCampus,
                  Text('Fehler: ${state.message}'),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  hiddenCampus,
                  const Text('Unbekannter Zustand'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
