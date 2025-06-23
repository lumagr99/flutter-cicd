import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/cantine/data/models/menu_day.dart';

import '../../mocks/cantine_repository_mock.dart';

void main() {
  group('CantineRepositoryMock', () {
    test('returns mock data correctly', () async {
      // Arrange
      final mockDays = [
        MenuDay(
          date: DateTime(2025, 5, 17),
          label: 'Sa., 17.05.2025',
          meals: [],
        ),
      ];
      final repo = CantineRepositoryMock(mockData: mockDays);

      // Act
      final result = await repo.fetchMenu(url: 'http://example.com');

      // Assert
      expect(result, isA<List<MenuDay>>());
      expect(result.length, 1);
      expect(result.first.label, 'Sa., 17.05.2025');
      expect(result.first.date, DateTime(2025, 5, 17));
      expect(result.first.meals, isEmpty);
    });

    test('throws when shouldThrow is true', () async {
      // Arrange
      final repo = CantineRepositoryMock(shouldThrow: true);

      // Act & Assert
      expect(
            () async => await repo.fetchMenu(url: 'http://example.com'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Mocked fetchMenu failure'))),
      );
    });

    test('returns empty list by default', () async {
      // Arrange
      final repo = CantineRepositoryMock();

      // Act
      final result = await repo.fetchMenu(url: 'http://example.com');

      // Assert
      expect(result, isA<List<MenuDay>>());
      expect(result, isEmpty);
    });
  });
}
