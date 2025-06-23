import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the selected date state (today or tomorrow)
class SelectedDateCubit extends Cubit<DateTime> {
  // Initializes with today's date at 00:00
  SelectedDateCubit() : super(_today());

  /// Returns today’s date with time set to 00:00
  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Toggles between today and tomorrow
  void toggle() {
    final today = _today();
    final tomorrow = today.add(const Duration(days: 1));
    emit(state == today ? tomorrow : today);
  }
}
