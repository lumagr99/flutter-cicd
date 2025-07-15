import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_first_flutter_app/features/timetable/data/repositories/timetable_repository_impl.dart';

String _formatIcsDate(DateTime dateTime) {
  final y = dateTime.year.toString().padLeft(4, '0');
  final m = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  final h = dateTime.hour.toString().padLeft(2, '0');
  final min = dateTime.minute.toString().padLeft(2, '0');
  return '$y$m${d}T$h${min}00';
}

void main() {
  group('TimetableRepositoryImpl.fetchEntries - relevante Integrationstests', () {
    test('ignoriert Events ohne DTSTART', () async {
      const ics = '''
BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
SUMMARY:Ohne Startzeit
LOCATION:Is-H999
DTEND;VALUE=DATE-TIME;TZID=Europe/Berlin:20250601T100000
END:VEVENT
END:VCALENDAR
''';

      final client = MockClient((request) async {
        if (request.url.toString().contains('vpisapp.php')) {
          return http.Response('''
<vpisapp>
  <student href="https://example.com/student.ics" type="ics">SS2025</student>
</vpisapp>
''', 200);
        }

        return http.Response(ics, 200);
      });

      final repo = TimetableRepositoryImpl(client: client);
      final entries = await repo.fetchEntries('user', 'pw');

      expect(entries, isEmpty);
    });

    test('akzeptiert doppelte Events', () async {
      final time = DateTime.now().add(const Duration(days: 1, hours: 10));
      final ics = '''
BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
SUMMARY:Duplikat
LOCATION:Is-H300
DTSTART;VALUE=DATE-TIME;TZID=Europe/Berlin:${_formatIcsDate(time)}
DTEND;VALUE=DATE-TIME;TZID=Europe/Berlin:${_formatIcsDate(time.add(const Duration(hours: 1)))}
END:VEVENT
BEGIN:VEVENT
SUMMARY:Duplikat
LOCATION:Is-H300
DTSTART;VALUE=DATE-TIME;TZID=Europe/Berlin:${_formatIcsDate(time)}
DTEND;VALUE=DATE-TIME;TZID=Europe/Berlin:${_formatIcsDate(time.add(const Duration(hours: 1)))}
END:VEVENT
END:VCALENDAR
''';

      final client = MockClient((request) async {
        if (request.url.toString().contains('vpisapp.php')) {
          return http.Response('''
<vpisapp>
  <student href="https://example.com/student.ics" type="ics">SS2025</student>
</vpisapp>
''', 200);
        }

        return http.Response(ics, 200);
      });

      final repo = TimetableRepositoryImpl(client: client);
      final entries = await repo.fetchEntries('user', 'pw');

      expect(entries.length, 2); // oder 1, je nach Duplikatbehandlung
    });

    test('liefert chronologisch sortierte Events', () async {
      final now = DateTime.now();
      final t1 = now.add(const Duration(days: 3));
      final t2 = now.add(const Duration(days: 1)); // früher

      final ics = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
SUMMARY:Später
LOCATION:Is-H500
DTSTART;VALUE=DATE-TIME;TZID=Europe/Berlin:${_formatIcsDate(t1)}
DTEND;VALUE=DATE-TIME;TZID=Europe/Berlin:${_formatIcsDate(t1.add(const Duration(hours: 1)))}
END:VEVENT
BEGIN:VEVENT
SUMMARY:Früher
LOCATION:Is-H400
DTSTART;VALUE=DATE-TIME;TZID=Europe/Berlin:${_formatIcsDate(t2)}
DTEND;VALUE=DATE-TIME;TZID=Europe/Berlin:${_formatIcsDate(t2.add(const Duration(hours: 1)))}
END:VEVENT
END:VCALENDAR
''';

      final client = MockClient((request) async {
        if (request.url.toString().contains('vpisapp.php')) {
          return http.Response('''
<vpisapp>
  <student href="https://example.com/student.ics" type="ics">SS2025</student>
</vpisapp>
''', 200);
        }

        return http.Response(ics, 200);
      });

      final repo = TimetableRepositoryImpl(client: client);
      final entries = await repo.fetchEntries('user', 'pw');

      expect(entries.first.title, 'Früher');
      expect(entries.last.title, 'Später');
    });
  });
}
