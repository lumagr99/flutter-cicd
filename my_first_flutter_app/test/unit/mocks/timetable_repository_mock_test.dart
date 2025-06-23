import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';

import '../../mocks/timetable_repository_mock.dart';

void main() {
  group('TimetableRepositoryMock', () {
    test('returns mock entries as expected', () async {
      // Arrange
      final mockData = [
        TimetableEntry(
          title: 'Mathematik',
          start: DateTime(2025, 4, 20, 10),
          end: DateTime(2025, 4, 20, 12),
          location: 'Raum 101',
        ),
      ];
      final repo = TimetableRepositoryMock(mockEntries: mockData);

      // Act
      final result = await repo.fetchEntries('alice', 'pass');

      // Assert
      expect(result, isA<List<TimetableEntry>>());
      expect(result.length, 1);
      expect(result.first.title, 'Mathematik');
      expect(result.first.location, 'Raum 101');
      expect(result.first.start, DateTime(2025, 4, 20, 10));
      expect(result.first.end, DateTime(2025, 4, 20, 12));
    });

    test('throws exception when shouldThrowUnauthorized is true', () async {
      // Arrange
      final repo = TimetableRepositoryMock(shouldThrowUnauthorized: true);

      // Act & Assert
      expect(
            () async => await repo.fetchEntries('bob', 'wrongpass'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Unauthorized'))),
      );
    });

    test('returns empty list by default', () async {
      // Arrange
      final repo = TimetableRepositoryMock();

      // Act
      final result = await repo.fetchEntries('user', 'pass');

      // Assert
      expect(result, isA<List<TimetableEntry>>());
      expect(result, isEmpty);
    });
  });
}
