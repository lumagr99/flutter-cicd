// test/mocks/cantine_repository_mock.dart

import 'package:my_first_flutter_app/features/cantine/data/models/menu_day.dart';
import 'package:my_first_flutter_app/features/cantine/domain/repositories/cantine_repository.dart';

class CantineRepositoryMock implements CantineRepository {
  final List<MenuDay> mockData;
  final bool shouldThrow;

  CantineRepositoryMock({
    this.mockData = const [],
    this.shouldThrow = false,
  });

  @override
  Future<List<MenuDay>> fetchMenu({required String url}) async {
    if (shouldThrow) {
      throw Exception('Mocked fetchMenu failure');
    }
    return Future.value(mockData);
  }
}
