import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';

void main() {
  group('TimetableEntry.isValid', () {
    test('returns true for valid entry', () {
      final entry = TimetableEntry(
        title: 'Mathe',
        start: DateTime(2025, 5, 20, 10),
        end: DateTime(2025, 5, 20, 12),
        location: 'Hörsaal 1',
      );

      expect(entry.isValid(), true);
    });

    test('returns false if title is empty', () {
      final entry = TimetableEntry(
        title: ' ',
        start: DateTime(2025, 5, 20, 10),
        end: DateTime(2025, 5, 20, 12),
        location: 'Hörsaal 1',
      );

      expect(entry.isValid(), false);
    });

    test('returns false if location is empty', () {
      final entry = TimetableEntry(
        title: 'Mathe',
        start: DateTime(2025, 5, 20, 10),
        end: DateTime(2025, 5, 20, 12),
        location: '',
      );

      expect(entry.isValid(), false);
    });

    test('returns false if end is before start', () {
      final entry = TimetableEntry(
        title: 'Mathe',
        start: DateTime(2025, 5, 20, 12),
        end: DateTime(2025, 5, 20, 10),
        location: 'Hörsaal 1',
      );

      expect(entry.isValid(), false);
    });
  });
}
