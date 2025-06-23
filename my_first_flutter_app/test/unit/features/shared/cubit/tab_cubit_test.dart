import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/core/cubit/tab_cubit.dart';

void main() {
  late TabCubit cubit;

  setUp(() {
    cubit = TabCubit();
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is index 1', () {
    // Arrange
    const expected = 1;

    // Act
    final actual = cubit.state;

    // Assert
    expect(actual, expected);
    expect(cubit.currentIndex, expected);
    expect(cubit.previousIndex, expected); // initially same
  });

  test('setIndex changes the index and updates previousIndex', () {
    // Arrange
    const newIndex = 2;
    final previous = cubit.currentIndex;

    // Act
    cubit.setIndex(newIndex);

    // Assert
    expect(cubit.currentIndex, newIndex);
    expect(cubit.previousIndex, previous);
  });

  test('goBack switches to previous index and updates previousIndex', () {
    // Arrange
    cubit.setIndex(0);
    final original = cubit.previousIndex;

    // Act
    cubit.goBack();

    // Assert
    expect(cubit.currentIndex, original);
    expect(cubit.previousIndex, 0);
  });

  test('goBack does nothing if current and previous index are equal', () {
    // Arrange
    final current = cubit.currentIndex;

    // Act
    cubit.goBack();

    // Assert
    expect(cubit.currentIndex, current);
    expect(cubit.previousIndex, current);
  });
}
