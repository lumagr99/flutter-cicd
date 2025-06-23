// lib/features/timetable/data/repositories/timetable_repository_impl.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_repository.dart';
import 'package:xml/xml.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final http.Client client;
  TimetableRepositoryImpl({http.Client? client})
      : client = client ?? http.Client();

  /// Parses an ICS date/time string into a DateTime.
  DateTime? parseIcsDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      // Suche 8-stellige Datumskomponente + optional 'T' + 6-stellige Zeit
      final match = RegExp(r'(\d{8}(?:T\d{6})?)').firstMatch(value);
      if (match != null) {
        final raw = match.group(1)!;
        final y = int.parse(raw.substring(0, 4));
        final M = int.parse(raw.substring(4, 6));
        final d = int.parse(raw.substring(6, 8));
        if (raw.length == 8) {
          return DateTime(y, M, d);
        }
        final h = int.parse(raw.substring(9, 11));
        final m = int.parse(raw.substring(11, 13));
        final s = int.parse(raw.substring(13, 15));
        return DateTime(y, M, d, h, m, s);
      }
      // Fallback auf ISO-Format, falls vorhanden
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  Future<List<TimetableEntry>> fetchEntries(String username, String password) async {
    final apiUrl = Uri.parse('https://vpis.fh-swf.de/vpisapp.php');
    final credentials = base64Encode(utf8.encode('$username:$password'));
    final headers = {'Authorization': 'Basic $credentials'};

    final metaResp = await client.get(apiUrl, headers: headers);
    if (metaResp.statusCode != 200) {
      throw Exception('Failed to load timetable metadata: ${metaResp.statusCode}');
    }

    final document = XmlDocument.parse(metaResp.body);
    final icsUrls = document
        .findAllElements('*')
        .where((e) =>
    (e.name.local == 'student' || e.name.local == 'staff') &&
        e.getAttribute('type') == 'ics')
        .map((e) => e.getAttribute('href'))
        .whereType<String>()
        .toList();

    if (icsUrls.isEmpty) {
      throw Exception('No .ics URLs found for <student> or <staff>.');
    }

    final entries = <TimetableEntry>[];
    for (final url in icsUrls) {
      final resp = await client.get(Uri.parse(url), headers: headers);
      if (resp.statusCode == 200) {
        final body = resp.body;
        // Alle VEVENT-Blöcke extrahieren
        final eventBlocks = RegExp(r'BEGIN:VEVENT([\s\S]*?)END:VEVENT')
            .allMatches(body)
            .map((m) => m.group(1)!)
            .toList();

        for (final block in eventBlocks) {
          // SUMMARY
          final titleMatch = RegExp(r'SUMMARY:(.+)').firstMatch(block);
          final title = titleMatch?.group(1)?.trim() ?? 'Ohne Titel';

          // DTSTART
          final dtStartMatch = RegExp(r'DTSTART(?:;[^:]+)?:([\dT]+)').firstMatch(block);
          final startRaw = dtStartMatch?.group(1);
          final start = parseIcsDate(startRaw);

          // DTEND (optional)
          final dtEndMatch = RegExp(r'DTEND(?:;[^:]+)?:([\dT]+)').firstMatch(block);
          final end = dtEndMatch != null
              ? parseIcsDate(dtEndMatch.group(1))
              : start?.add(const Duration(hours: 1));

          // LOCATION (optional)
          final locMatch = RegExp(r'LOCATION:(.+)').firstMatch(block);
          final location = locMatch?.group(1)?.trim() ?? '';

          if (start != null && end != null) {
            final entry = TimetableEntry(
              title: title,
              start: start,
              end: end,
              location: location,
            );
            if (entry.isValid()) {
              entries.add(entry);
            }
          }
        }
      } else if (resp.statusCode == 401) {
        throw Exception('Unauthorized access to .ics file at $url');
      }
    }

    entries.sort((a, b) => a.start.compareTo(b.start));
    return entries;
  }
}
