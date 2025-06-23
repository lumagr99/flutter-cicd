import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_flutter_app/core/cubit/tab_cubit.dart';
import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_repository.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_storage_repository.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/views/widgets/login_dialog.dart';

/// Base class for timetable-related states
abstract class TimetableState {}

/// State shown while loading timetable data
class TimetableLoading extends TimetableState {}

/// State that contains the loaded timetable entries
class TimetableLoaded extends TimetableState {
  final List<TimetableEntry> entries;
  TimetableLoaded(this.entries);
}

/// State that indicates an error occurred during loading
class TimetableError extends TimetableState {
  final String message;
  TimetableError(this.message);
}

/// Manages the timetable state, handles loading and credential management
class TimetableCubit extends Cubit<TimetableState> {
  final TimetableRepository repository;
  final TimetableStorageRepository storage;

  TimetableCubit(this.repository, this.storage) : super(TimetableLoading());

  Future<void> initTimetable(BuildContext context) async {
    final username = await storage.getUsername();
    final password = await storage.getPassword();

    // Zwischen await und der Verwendung von context könnte das Widget bereits unmounted worden sein
    if (!context.mounted) return;

    if (username == null || password == null) {
      _showCredentialDialog(context);
    } else {
      load(username, password);
    }
  }

  /// Loads entries from the backend and updates state
  Future<void> load(String username, String password) async {
    emit(TimetableLoading());
    try {
      final data = await repository.fetchEntries(username, password);
      emit(TimetableLoaded(data));
    } catch (e) {
      emit(TimetableError('Fehler: ${e.toString()}'));
    }
  }

  /// Checks whether the provided credentials are valid
  Future<bool> verifyCredentials(String user, String pass) async {
    try {
      await repository.fetchEntries(user, pass);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Opens login dialog and handles user input and state update
  Future<void> _showCredentialDialog(BuildContext context) async {
    String? cachedUser;
    String? cachedPass;

    await showLoginDialog(
      rootContext: context,
      onSubmit: (user, pass) async {
        final success = await verifyCredentials(user, pass);
        if (success) {
          cachedUser = user;
          cachedPass = pass;
        }
        return success;
      },
      onSuccess: () async {
        // Store credentials and reload timetable after dialog is dismissed
        if (cachedUser != null && cachedPass != null) {
          await storage.saveCredentials(cachedUser!, cachedPass!);
          Future.microtask(() => load(cachedUser!, cachedPass!));
        }
      },
      onCancel: () {
        context.read<TabCubit>().goBack();
      },
    );
  }

  /// Clears saved credentials and restarts the timetable init process
  Future<void> logout(BuildContext context) async {
    await storage.clear();
    emit(TimetableLoading());

    // Prüfen ob das aufrunfende Widget noch gemounted
    if (!context.mounted) return;
    initTimetable(context);
  }
}
