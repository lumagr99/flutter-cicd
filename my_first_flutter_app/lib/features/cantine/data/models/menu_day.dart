import 'meal.dart'; // Voraussetzung: Meal und MealValidation sind dort definiert

/// Represents a day's menu with a list of meals and related metadata
class MenuDay {
  /// The actual calendar date of the menu
  final DateTime date;

  /// A human-readable label (e.g. "Monday") for display purposes
  final String label;

  /// The list of main meals available on this day
  final List<Meal> meals;

  MenuDay({
    required this.date,
    required this.label,
    required this.meals,
  });
}

/// Extension for validating MenuDay
extension MenuDayValidation on MenuDay {
  /// Returns true if the MenuDay and all nested meals are valid
  bool isValid() {
    return label.trim().isNotEmpty &&
        meals.isNotEmpty &&
        meals.every((meal) => meal.isValid());
  }
}
