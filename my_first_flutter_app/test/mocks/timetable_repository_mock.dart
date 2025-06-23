import 'package:my_first_flutter_app/features/timetable/data/models/timetable_entry.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_repository.dart';

class TimetableRepositoryMock implements TimetableRepository {
  List<TimetableEntry> mockEntries;
  bool shouldThrowUnauthorized;

  TimetableRepositoryMock({
    this.mockEntries = const [],
    this.shouldThrowUnauthorized = false,
  });

  @override
  Future<List<TimetableEntry>> fetchEntries(String username, String password) async {
    if (shouldThrowUnauthorized) {
      throw Exception('Unauthorized');
    }
    return Future.value(mockEntries);
  }
}
