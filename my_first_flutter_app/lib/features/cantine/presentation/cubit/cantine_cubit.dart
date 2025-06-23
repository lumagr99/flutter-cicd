import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/menu_day.dart';

import '../../domain/repositories/cantine_repository.dart';

/// Base class for all cantine states
abstract class CantineState {}

/// State indicating menu is currently loading
class CantineLoading extends CantineState {}

/// State containing successfully loaded menu data
class CantineLoaded extends CantineState {
  final List<MenuDay> days;
  CantineLoaded(this.days);
}

/// State indicating an error occurred while loading the menu
class CantineError extends CantineState {
  final String message;
  CantineError(this.message);
}

/// Cubit responsible for loading and managing menu data
class CantineCubit extends Cubit<CantineState> {
  final CantineRepository repository;
  final CampusCubit campusCubit;

  CantineCubit({
    required this.repository,
    required this.campusCubit,
  }) : super(CantineLoading());

  /// Loads menu data for the selected campus and emits appropriate state
  Future<void> loadMenu() async {
    if (isClosed) return;
    emit(CantineLoading());

    final campus = campusCubit.state;
    final url = campus.menuUrl.trim();

    if (url.isEmpty) {
      if (isClosed) return;
      emit(CantineError('Fehler: Ungültige oder fehlende Menü-URL'));
      return;
    }

    try {
      final days = await repository.fetchMenu(url: url);

      for (final day in days) {
        day.isValid();
      }

      if (isClosed) return;
      emit(CantineLoaded(days));
    } catch (e) {
      if (isClosed) return;
      emit(CantineError('Fehler: ${e.toString()}'));
    }
  }
}
