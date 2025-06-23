import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/cubit/timetable_cubit.dart';

import '../../../../core/theme/theme_config.dart';

/// Displays the user's timetable with grouped events and logout option
class TimetableView extends StatefulWidget {
  const TimetableView({super.key});

  @override
  State<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<TimetableView> {

  @override
  void initState() {
    super.initState();
    // Trigger initial timetable loading after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetableCubit>().initTimetable(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimetableCubit, TimetableState>(
      builder: (context, state) {
        final isLoggedIn = state is TimetableLoaded;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Builder(
            builder: (_) {
              if (state is TimetableLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TimetableError) {
                return Center(child: Text(state.message));
              } else if (state is TimetableLoaded) {
                final now = DateTime.now();
                final entries = state.entries
                    .where((e) => e.end.isAfter(now))
                    .toList()
                  ..sort((a, b) => a.start.compareTo(b.start)); // sort chronologically

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final previous = index > 0 ? entries[index - 1] : null;

                    // Extract date components to detect day boundaries
                    final currentDate = DateTime(entry.start.year, entry.start.month, entry.start.day);
                    final previousDate = previous != null
                        ? DateTime(previous.start.year, previous.start.month, previous.start.day)
                        : null;

                    final isNewDay = previousDate == null || currentDate != previousDate;

                    final timeRange =
                        '${DateFormat('HH:mm').format(entry.start)} - ${DateFormat('HH:mm').format(entry.end)}';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNewDay)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    thickness: 1.5,
                                    color: AppColors.accentPink,
                                    endIndent: 8,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE, dd.MM.', 'de').format(entry.start),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentPink,
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    thickness: 1.5,
                                    color: AppColors.accentPink,
                                    indent: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(entry.title),
                            subtitle: Text('${entry.location}\n$timeRange'),
                            isThreeLine: true,
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return const Center(child: Text('Unbekannter Zustand'));
              }
            },
          ),
          floatingActionButton: isLoggedIn
              ? FloatingActionButton(
            onPressed: () => context.read<TimetableCubit>().logout(context),
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.logout),
          )
              : null,
        );
      },
    );
  }
}
