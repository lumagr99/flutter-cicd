import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/meal.dart';

void main() {

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