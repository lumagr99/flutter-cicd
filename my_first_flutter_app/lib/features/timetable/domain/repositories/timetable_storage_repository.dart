/// Contract for secure credential storage related to the timetable feature
abstract class TimetableStorageRepository {
  /// Retrieves the stored username, if any
  Future<String?> getUsername();

  /// Retrieves the stored password, if any
  Future<String?> getPassword();

  /// Saves username and password securely
  Future<void> saveCredentials(String username, String password);

  /// Clears all stored credentials
  Future<void> clear();
}
