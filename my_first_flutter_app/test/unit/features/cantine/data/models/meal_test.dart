import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/meal.dart';

void main() {
  group('Meal.fromJson', () {
    test('should parse valid JSON correctly', () {
      // Arrange
      final json = {
        'id': 123,
        'name': 'Currywurst mit Pommes',
        'pricing': {
          'for': [250, 450, 600]
        }
      };

      // Act
      final meal = Meal.fromJson(json);

      // Assert
      expect(meal.id, '123');
      expect(meal.name, 'Currywurst mit Pommes');
      expect(meal.prices, [250, 450, 600]);
    });

    test('should throw if pricing is missing', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Test Meal',
      };

      // Act & Assert
      expect(() => Meal.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw if pricing.for is missing', () {
      // Arrange
      final json = {
        'id': 2,
        'name': 'Another Meal',
        'pricing': {}
      };

      // Act & Assert
      expect(() => Meal.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw if pricing.for is not a List', () {
      // Arrange
      final json = {
        'id': 3,
        'name': 'Bad Meal',
        'pricing': {
          'for': 'invalid'
        }
      };

      // Act & Assert
      expect(() => Meal.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw if pricing.for contains non-integers', () {
      // Arrange
      final json = {
        'id': 4,
        'name': 'Mixed Meal',
        'pricing': {
          'for': [250, 'oops', 600]
        }
      };

      // Act & Assert
      expect(() => Meal.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw if id is missing', () {
      // Arrange
      final json = {
        'name': 'Nameless Meal',
        'pricing': {
          'for': [100, 200, 300]
        }
      };

      // Act & Assert
      expect(() => Meal.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw if name is missing', () {
      // Arrange
      final json = {
        'id': 999,
        'pricing': {
          'for': [120, 230, 340]
        }
      };

      // Act & Assert
      expect(() => Meal.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should handle numeric id and convert to string', () {
      // Arrange
      final json = {
        'id': 42,
        'name': 'Falafel',
        'pricing': {
          'for': [300, 500, 700]
        }
      };

      // Act
      final meal = Meal.fromJson(json);

      // Assert
      expect(meal.id, '42');
    });
  });

  group('MealValidation.isValid', () {
    test('should return true for valid Meal', () {
      // Arrange
      final meal = Meal(
        id: '1',
        name: 'Lasagne',
        prices: [250, 400],
      );

      // Act
      final result = meal.isValid();

      // Assert
      expect(result, isTrue);
    });

    test('should return false if id is empty', () {
      // Arrange
      final meal = Meal(
        id: '',
        name: 'Lasagne',
        prices: [250, 400],
      );

      // Act
      final result = meal.isValid();

      // Assert
      expect(result, isFalse);
    });

    test('should return false if name is empty', () {
      // Arrange
      final meal = Meal(
        id: '1',
        name: '   ',
        prices: [250, 400],
      );

      // Act
      final result = meal.isValid();

      // Assert
      expect(result, isFalse);
    });

    test('should return false if prices is empty', () {
      // Arrange
      final meal = Meal(
        id: '1',
        name: 'Lasagne',
        prices: [],
      );

      // Act
      final result = meal.isValid();

      // Assert
      expect(result, isFalse);
    });

    test('should return false if prices contains negative value', () {
      // Arrange
      final meal = Meal(
        id: '1',
        name: 'Lasagne',
        prices: [250, -100],
      );

      // Act
      final result = meal.isValid();

      // Assert
      expect(result, isFalse);
    });
  });
}