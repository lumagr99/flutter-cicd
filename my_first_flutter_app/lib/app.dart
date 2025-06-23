import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/tab_cubit.dart';
import 'package:my_first_flutter_app/core/config/campus_data.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';
import 'package:my_first_flutter_app/core/theme/theme_config.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/views/cantine_page.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/views/timetable_page.dart';
import 'package:my_first_flutter_app/features/weather/presentation/views/weather_page.dart';

/// Root of the app, sets theme and home screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

/// Main navigation container with tab management and shared app bar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1); // Mensa as initial page
  int _currentIndex = 1;

  final List<Widget> _pages = const [
    WeatherPage(),
    CantinePage(),
    TimetablePage(),
  ];

  /// Handles tab selection and animation
  void _onTabTapped(int index) {
    context.read<TabCubit>().setIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Utility to check if given date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(92),
        child: Container(
          color: backgroundColor,
          child: SafeArea(
            // Hide top bar on "Stundenplan"
            child: _currentIndex != 2
                ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Campus selection dropdown
                  Expanded(
                    flex: 3,
                    child: BlocBuilder<CampusCubit, Campus>(
                      builder: (context, selectedCampus) {
                        return DropdownButtonFormField<Campus>(
                          decoration: const InputDecoration(
                            labelText: 'Standort',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          value: selectedCampus,
                          items: CampusData.campuses.map((campus) {
                            return DropdownMenuItem<Campus>(
                              value: campus,
                              child: Text(campus.name),
                            );
                          }).toList(),
                          onChanged: (newCampus) {
                            if (newCampus != null) {
                              context.read<CampusCubit>().select(newCampus);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Today / Tomorrow toggle
                  BlocBuilder<SelectedDateCubit, DateTime>(
                    builder: (context, selected) {
                      final isToday = _isToday(selected);
                      return ToggleButtons(
                        isSelected: [isToday, !isToday],
                        borderRadius: BorderRadius.circular(8),
                        onPressed: (_) =>
                            context.read<SelectedDateCubit>().toggle(),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('Heute'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('Morgen'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(), // No top bar on Timetable
          ),
        ),
      ),
      body: Stack(
        children: [
          BlocListener<TabCubit, int>(
            listener: (context, index) {
              _pageController.jumpToPage(index);
              setState(() => _currentIndex = index);
            },
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Wetter'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Mensa'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Stundenplan'),
        ],
      ),
    );
  }
}
