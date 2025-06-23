import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_flutter_app/features/timetable/data/repositories/timetable_repository_impl.dart';
import 'package:my_first_flutter_app/features/timetable/data/repositories/timetable_storage_repository_impl.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_repository.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_storage_repository.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/cubit/timetable_cubit.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/views/timetable_view.dart';

/// Entry point for the timetable feature
/// Provides necessary repositories and creates the associated Cubit
class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimetableRepository repository = TimetableRepositoryImpl();
    final TimetableStorageRepository storage = TimetableStorageRepositoryImpl();

    return BlocProvider(
      // Inject the TimetableCubit with required dependencies
      create: (_) => TimetableCubit(repository, storage),
      child: const TimetableView(),
    );
  }
}
