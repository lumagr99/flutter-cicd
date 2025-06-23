import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_first_flutter_app/features/timetable/domain/repositories/timetable_storage_repository.dart';

/// Implementation for securely storing and retrieving timetable credentials
class TimetableStorageRepositoryImpl implements TimetableStorageRepository {
  final _storage = const FlutterSecureStorage();

  /// Reads the saved username from secure storage
  @override
  Future<String?> getUsername() => _storage.read(key: 'username');

  /// Reads the saved password from secure storage
  @override
  Future<String?> getPassword() => _storage.read(key: 'password');

  /// Stores the given credentials in secure storage
  @override
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  /// Clears all saved credentials from storage
  @override
  Future<void> clear() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }
}
