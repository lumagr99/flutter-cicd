/// Represents a single meal with identifier, name, and pricing data
class Meal {
  /// Unique identifier for the meal
  final String id;

  /// Descriptive name of the meal
  final String name;

  /// List of prices for different user groups (e.g., student, staff, guest)
  final List<int> prices;

  Meal({
    required this.id,
    required this.name,
    required this.prices,
  });
}

/// Extension for validating Meal instances
extension MealValidation on Meal {
  /// Returns true if the Meal instance contains valid data
  bool isValid() {
    return id.trim().isNotEmpty &&
        name.trim().isNotEmpty &&
        prices.isNotEmpty &&
        prices.every((e) => e >= 0);
  }
}
