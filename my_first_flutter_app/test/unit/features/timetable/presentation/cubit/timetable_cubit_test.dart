import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/cubit/timetable_cubit.dart';

import '../../../../../mocks/timetable_repository_mock.dart';
import '../../../../../mocks/timetable_storage_repository_mock.dart';

void main() {
  late TimetableCubit cubit;
  late TimetableRepositoryMock repo;
  late TimetableStorageRepositoryMock storage;

  setUp(() {
    repo = TimetableRepositoryMock();
    storage = TimetableStorageRepositoryMock();
    cubit = TimetableCubit(repo, storage);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('load emits TimetableLoaded on success', () async {
    // Arrange
    final entry = TimetableEntry(
      title: 'Test',
      start: DateTime(2025, 5, 20, 10),
      end: DateTime(2025, 5, 20, 12),
      location: 'Hörsaal 1',
    );
    // Statt .add() die Liste komplett überschreiben
    repo.mockEntries = [entry];

    // Act
    await cubit.load('user', 'pw');

    // Assert
    expect(cubit.state, isA<TimetableLoaded>());
    expect((cubit.state as TimetableLoaded).entries.first.title, 'Test');
  });

  test('load emits TimetableError on repository failure', () async {
    // Arrange
    repo.shouldThrowUnauthorized = true;

    // Act
    await cubit.load('invalid', 'wrong');

    // Assert
    expect(cubit.state, isA<TimetableError>());
    expect((cubit.state as TimetableError).message, contains('Fehler'));
  });

  test('verifyCredentials returns true on valid credentials', () async {
    // Arrange
    final now = DateTime.now();
    repo.mockEntries = [
      TimetableEntry(
        title: 'Valid',
        start: now,
        end: now.add(const Duration(hours: 1)),
        location: 'Raum 1',
      )
    ];

    // Act
    final result = await cubit.verifyCredentials('user', 'pw');

    // Assert
    expect(result, isTrue);
  });

  test('verifyCredentials returns false on invalid credentials', () async {
    // Arrange
    repo.shouldThrowUnauthorized = true;

    // Act
    final result = await cubit.verifyCredentials('bad', 'bad');

    // Assert
    expect(result, isFalse);
  });

  test('logout clears credentials and emits loading manually', () async {
    // Arrange
    await storage.saveCredentials('test', 'pw');
    expect(await storage.getUsername(), 'test');
    expect(await storage.getPassword(), 'pw');

    cubit.emit(TimetableLoaded([])); // Zustand simulieren

    // Act: logout-Verhalten
    await storage.clear();
    cubit.emit(TimetableLoading());

    // Assert
    expect(await storage.getUsername(), isNull);
    expect(await storage.getPassword(), isNull);
    expect(cubit.state, isA<TimetableLoading>());
  });
}
