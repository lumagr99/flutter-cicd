import '../../data/models/menu_day.dart';

/// Abstract repository contract for fetching menu data
abstract class CantineRepository {
  /// Returns a list of MenuDay objects from the given API URL
  Future<List<MenuDay>> fetchMenu({required String url});
}
