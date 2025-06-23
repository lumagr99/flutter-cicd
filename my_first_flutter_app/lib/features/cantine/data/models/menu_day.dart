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

  /// Factory constructor to create a MenuDay instance from JSON
  factory MenuDay.fromJson(Map<String, dynamic> json) {
    final isoDateRaw = json['iso-date'];
    if (isoDateRaw == null || isoDateRaw is! String || isoDateRaw.trim().isEmpty) {
      throw const FormatException("Invalid or missing 'iso-date'");
    }

    final date = DateTime.tryParse(isoDateRaw);
    if (date == null) {
      throw const FormatException("Invalid date format in 'iso-date'");
    }

    final meals = <Meal>[];

    for (final category in json['categories']) {
      final name = category['name']?.toString().toLowerCase() ?? '';
      if (name.contains('beilage')) continue;

      final mealList = category['meals'] as List;
      for (final mealJson in mealList) {
        if (mealJson['name'].toString().toLowerCase().contains('speiseplan')) continue;
        meals.add(Meal.fromJson(mealJson));
      }
    }

    return MenuDay(
      date: date,
      label: json['date'],
      meals: meals,
    );
  }
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
