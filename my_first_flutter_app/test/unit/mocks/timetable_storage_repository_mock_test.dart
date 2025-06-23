import 'package:flutter_test/flutter_test.dart';

import '../../mocks/timetable_storage_repository_mock.dart';

void main() {
  group('TimetableStorageRepositoryMock', () {
    test('returns null initially', () async {
      // Arrange
      final storage = TimetableStorageRepositoryMock();

      // Act
      final username = await storage.getUsername();
      final password = await storage.getPassword();

      // Assert
      expect(username, isNull);
      expect(password, isNull);
      expect(username, isA<String?>());
      expect(password, isA<String?>());
    });

    test('saves and retrieves credentials', () async {
      // Arrange
      final storage = TimetableStorageRepositoryMock();

      // Act
      await storage.saveCredentials('alice', 'secure123');
      final username = await storage.getUsername();
      final password = await storage.getPassword();

      // Assert
      expect(username, 'alice');
      expect(password, 'secure123');
      expect(username, isA<String>());
      expect(password, isA<String>());
    });

    test('clears saved credentials', () async {
      // Arrange
      final storage = TimetableStorageRepositoryMock();
      await storage.saveCredentials('bob', 'topsecret');

      // Act
      await storage.clear();
      final username = await storage.getUsername();
      final password = await storage.getPassword();

      // Assert
      expect(username, isNull);
      expect(password, isNull);
    });

    test('overwrites previous credentials', () async {
      // Arrange
      final storage = TimetableStorageRepositoryMock();
      await storage.saveCredentials('first', '123');

      // Act
      await storage.saveCredentials('second', '456');
      final username = await storage.getUsername();
      final password = await storage.getPassword();

      // Assert
      expect(username, 'second');
      expect(password, '456');
    });
  });
}
