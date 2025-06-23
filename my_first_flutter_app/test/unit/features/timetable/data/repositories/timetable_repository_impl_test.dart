import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/timetable/data/repositories/timetable_repository_impl.dart';

void main() {
  test('parses date-only ICS string', () {
    // Arrange
    final repo = TimetableRepositoryImpl();
    const ics = 'dt: 20250530';

    // Act
    final result = repo.parseIcsDate(ics);

    // Assert
    expect(result, DateTime(2025, 5, 30));
  });

  test('parses full datetime ICS string', () {
    // Arrange
    final repo = TimetableRepositoryImpl();
    const ics = 'dt: 20250530T081500';

    // Act
    final result = repo.parseIcsDate(ics);

    // Assert
    expect(result, DateTime(2025, 5, 30, 8, 15, 0));
  });

  test('returns DateTime if input is already a DateTime', () {
    // Arrange
    final repo = TimetableRepositoryImpl();
    final input = DateTime(2025, 6, 1, 12);

    // Act
    final result = repo.parseIcsDate(input);

    // Assert
    expect(result, input);
  });

  test('parses ISO 8601 string input', () {
    // Arrange
    final repo = TimetableRepositoryImpl();
    const input = '2025-06-01T12:30:00Z';

    // Act
    final result = repo.parseIcsDate(input);

    // Assert
    expect(result, DateTime.parse(input));
  });

  test('returns null on unsupported format', () {
    // Arrange
    final repo = TimetableRepositoryImpl();
    const input = 'invalid format string';

    // Act
    final result = repo.parseIcsDate(input);

    // Assert
    expect(result, isNull);
  });

  test('returns null on null input', () {
    // Arrange
    final repo = TimetableRepositoryImpl();
    const input = null;

    // Act
    final result = repo.parseIcsDate(input);

    // Assert
    expect(result, isNull);
  });
}
