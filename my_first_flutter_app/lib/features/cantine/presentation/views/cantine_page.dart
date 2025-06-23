import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/features/cantine/data/repositories/cantine_repository_impl.dart';
import 'package:my_first_flutter_app/features/cantine/domain/repositories/cantine_repository.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/cubit/cantine_cubit.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/views/cantine_view.dart';

/// Entry point for the cantine feature
/// Provides necessary dependencies and launches the view
class CantinePage extends StatelessWidget {
  const CantinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CantineRepository repository = CantineRepositoryImpl();

    return BlocProvider(
      create: (context) => CantineCubit(
        repository: repository,
        campusCubit: context.read<CampusCubit>(), // inject selected campus
      )..loadMenu(), // trigger initial menu load
      child: const CantineView(),
    );
  }
}
