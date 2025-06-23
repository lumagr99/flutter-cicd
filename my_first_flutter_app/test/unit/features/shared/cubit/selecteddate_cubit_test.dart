import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/core/cubit/selecteddate_cubit.dart';

void main() {
  late SelectedDateCubit cubit;

  setUp(() {
    cubit = SelectedDateCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('SelectedDateCubit', () {
    test('initial state is today at midnight', () {
      // Arrange
      final now = DateTime.now();
      final expected = DateTime(now.year, now.month, now.day);

      // Act
      final actual = cubit.state;

      // Assert
      expect(actual, expected);
    });

    test('toggle switches to tomorrow', () {
      // Arrange
      final today = cubit.state;
      final expected = today.add(const Duration(days: 1));

      // Act
      cubit.toggle();

      // Assert
      expect(cubit.state, expected);
    });

    test('toggle twice returns to today', () {
      // Arrange
      final expected = cubit.state;

      // Act
      cubit.toggle(); // -> morgen
      cubit.toggle(); // -> zurück zu heute

      // Assert
      expect(cubit.state, expected);
    });
  });
}
