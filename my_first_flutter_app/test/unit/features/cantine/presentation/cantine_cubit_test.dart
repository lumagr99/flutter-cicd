import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/core/cubit/campus_cubit.dart';
import 'package:my_first_flutter_app/core/models/campus.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/menu_day.dart';
import 'package:my_first_flutter_app/features/cantine/presentation/cubit/cantine_cubit.dart';

import '../../../../mocks/cantine_repository_mock.dart';

void main() {
  late CampusCubit campusCubit;
  late CantineRepositoryMock mockRepo;
  late CantineCubit cubit;

  setUp(() {
    campusCubit = CampusCubit();
    mockRepo = CantineRepositoryMock();
    cubit = CantineCubit(repository: mockRepo, campusCubit: campusCubit);
  });

  tearDown(() async {
    await cubit.close();
    await campusCubit.close();
  });

  test('emits CantineLoaded when data is loaded successfully', () async {
    // Arrange
    final mockDay = MenuDay(
      date: DateTime(2025, 5, 20),
      label: 'Montag',
      meals: [],
    );
    mockRepo = CantineRepositoryMock(mockData: [mockDay]);
    cubit = CantineCubit(repository: mockRepo, campusCubit: campusCubit);

    // Act
    await cubit.loadMenu();

    // Assert
    expect(cubit.state, isA<CantineLoaded>());
    final loaded = cubit.state as CantineLoaded;
    expect(loaded.days.first.label, 'Montag');
  });

  test('emits CantineError if menuUrl is empty', () async {
    // Arrange
    const invalidCampus = Campus(
      name: 'Invalid',
      latitude: 0,
      longitude: 0,
      menuUrl: '',
    );
    campusCubit.select(invalidCampus);

    // Act
    await cubit.loadMenu();

    // Assert
    expect(cubit.state, isA<CantineError>());
    expect((cubit.state as CantineError).message, contains('Ungültige'));
  });

  test('emits CantineError if repository throws', () async {
    // Arrange
    mockRepo = CantineRepositoryMock(shouldThrow: true);
    cubit = CantineCubit(repository: mockRepo, campusCubit: campusCubit);

    // Act
    await cubit.loadMenu();

    // Assert
    expect(cubit.state, isA<CantineError>());
    expect((cubit.state as CantineError).message, contains('Fehler'));
  });
}
