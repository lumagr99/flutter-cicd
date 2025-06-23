// test/mocks/timetable_storage_repository_mock.dart

import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_storage_repository.dart';

class TimetableStorageRepositoryMock implements TimetableStorageRepository {
  String? _username;
  String? _password;

  @override
  Future<String?> getUsername() async => _username;

  @override
  Future<String?> getPassword() async => _password;

  @override
  Future<void> saveCredentials(String username, String password) async {
    _username = username;
    _password = password;
  }

  @override
  Future<void> clear() async {
    _username = null;
    _password = null;
  }
}
