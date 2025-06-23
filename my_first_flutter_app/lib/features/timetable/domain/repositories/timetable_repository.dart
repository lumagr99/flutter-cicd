import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';

/// Contract for fetching timetable entries from a remote source
abstract class TimetableRepository {
  /// Returns a list of timetable entries based on user credentials
  Future<List<TimetableEntry>> fetchEntries(String username, String password);
}
