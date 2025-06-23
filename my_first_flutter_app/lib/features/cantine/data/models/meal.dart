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

  /// Factory constructor to create a Meal instance from JSON
  factory Meal.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException("Missing 'id' field");
    }
    if (json['name'] == null) {
      throw const FormatException("Missing 'name' field");
    }
    final pricing = json['pricing'];
    if (pricing == null || pricing['for'] == null) {
      throw const FormatException("Missing 'pricing.for' field");
    }
    if (pricing['for'] is! List) {
      throw const FormatException("'pricing.for' must be a List");
    }

    final pricesRaw = pricing['for'];
    if (!(pricesRaw as List).every((e) => e is int)) {
      throw const FormatException("All elements in 'pricing.for' must be integers");
    }

    return Meal(
      id: json['id'].toString(),
      name: json['name'],
      prices: List<int>.from(pricesRaw),
    );
  }
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
