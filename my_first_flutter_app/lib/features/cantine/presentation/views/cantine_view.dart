import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/menu_day.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/cubit/cantine_cubit.dart';

/// Widget zur Anzeige der Kantinen-Speisepläne
/// Kombiniert Campus-Auswahl und Datums-Filter
class CantineView extends StatelessWidget {
  const CantineView({super.key});

  /// Prüft ob zwei DateTime-Objekte am gleichen Tag liegen
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Formatiert Datum im deutschen Format (z.B. "Montag, 15.06.2025")
  String _formatGermanDate(DateTime date) {
    return DateFormat('EEEE, dd.MM.yyyy', 'de').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Campus-Änderungen überwachen und Menü neu laden
    return BlocListener<CampusCubit, Campus>(
      // Nur reagieren wenn sich die Menü-URL ändert (= anderer Campus)
      listenWhen: (prev, curr) => prev.menuUrl != curr.menuUrl,
      listener: (context, _) {
        // Neues Menü für den gewählten Campus laden
        context.read<CantineCubit>().loadMenu();
      },
      child: BlocBuilder<CantineCubit, CantineState>(
        builder: (context, state) {
          // Aktuelle Werte aus anderen Cubits abrufen
          final selectedDate = context.watch<SelectedDateCubit>().state;
          final campus = context.watch<CampusCubit>().state;

          // Hauptinhalt je nach Zustand erstellen
          Widget mainContent;
          if (state is CantineLoading) {
            // Ladevorgang läuft
            mainContent = const Center(child: CircularProgressIndicator());
          } else if (state is CantineError) {
            // Fehler beim Laden der Daten
            mainContent = Center(child: Text(state.message));
          } else if (state is CantineLoaded) {
            // Daten erfolgreich geladen - Menü für gewähltes Datum suchen

            // Prüfen ob exaktes Datum verfügbar ist
            final hasExactMatch =
            state.days.any((day) => isSameDay(day.date, selectedDate));

            MenuDay? menu;
            if (hasExactMatch) {
              // Exakte Übereinstimmung gefunden
              menu = state.days.firstWhere(
                      (day) => isSameDay(day.date, selectedDate));
            } else {
              // Fallback: Nächstes verfügbares Datum nach dem gewählten Tag
              final fallback = state.days
                  .where((d) => d.date.isAfter(selectedDate))
                  .toList()
                ..sort((a, b) => a.date.compareTo(b.date));

              if (fallback.isNotEmpty) {
                menu = fallback.first; // Nächster verfügbarer Tag
              } else if (state.days.isNotEmpty) {
                menu = state.days.last; // Letzter verfügbarer Tag als Fallback
              } else {
                menu = null; // Keine Daten verfügbar
              }
            }

            if (menu == null) {
              // Keine Menüdaten verfügbar
              mainContent = const Center(child: Text('Kein Menü verfügbar'));
            } else {
              final safeMenu = menu;
              final hasFallback = !hasExactMatch;

              // ListView mit Speisen erstellen
              mainContent = ListView.builder(
                padding: const EdgeInsets.all(16),
                // +1 Item für Fallback-Warnung falls nötig
                itemCount: safeMenu.meals.length + (hasFallback ? 1 : 0),
                itemBuilder: (context, index) {
                  // Fallback-Warnung als erstes Item anzeigen
                  if (hasFallback && index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kein Menü am gewählten Tag - zeige Menü für '
                                  '${_formatGermanDate(safeMenu.date)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Index für Speise berechnen (bei Fallback -1)
                  final mealIndex = hasFallback ? index - 1 : index;
                  final meal = safeMenu.meals[mealIndex];

                  // Preise von Cent in Euro umrechnen und formatieren
                  final prices = meal.prices
                      .map((c) => (c / 100).toStringAsFixed(2))
                      .join(' € / ');

                  // Animierte Einblendung der Speise-Karten
                  return TweenAnimationBuilder<double>(
                    // Gestaffelte Animation (jede Karte 100ms später)
                    duration:
                    Duration(milliseconds: 200 + mealIndex * 100),
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          // Slide-in Effekt von oben
                          offset: Offset(0, (1 - value) * 20),
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Restaurant-Icon
                            const Icon(Icons.restaurant_menu, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Speisename
                                  Text(
                                    meal.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Preisinformation
                                  Text(
                                    'Preis: $prices €',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            // Unbekannter Zustand (sollte nicht auftreten)
            mainContent = const Center(child: Text('Unbekannter Zustand'));
          }

          // Layout mit Debug-Bereich für Tests
          return Column(
            children: [
              Expanded(child: mainContent),
              // Unsichtbare Debug-Informationen für automatisierte Tests
              Visibility(
                visible: false, // Für normale Nutzer ausgeblendet
                maintainState: true, // State beibehalten
                maintainAnimation: true, // Animationen beibehalten
                maintainSize: true, // Platz reservieren
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Test-Keys für automatisierte Tests
                    Text(
                      'TEST_CAMPUS:${campus.name}',
                      key: const Key('test-campus'),
                    ),
                    Text(
                      'TEST_DATE:${_formatGermanDate(selectedDate)}',
                      key: const Key('test-date'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}