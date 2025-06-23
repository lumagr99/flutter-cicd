import 'dart:convert'; // <- wichtig für utf8.encode

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:my_first_flutter_app/features/cantine/data/repositories/cantine_repository_impl.dart';

class _MockHttpClient extends Mock implements http.Client {}

String _htmlWithMeals(List<Map<String, String>> meals) {
  final rows = meals.map((m) => '''
<tr class="meals__row odd">
  <td class="meals__column-title">
    <span class="meals__title">${m['name']}</span>
  </td>
  <td class="meals__column-price"><abbr>S:</abbr> ${m['s']}</td>
  <td class="meals__column-price"><abbr>B:</abbr> ${m['b']}</td>
  <td class="meals__column-price"><abbr>G:</abbr> ${m['g']}</td>
</tr>
''').join();

  return '''
<!DOCTYPE html>
<html lang="de">
  <body>
    <table class="meals">
      <thead><tr><th>Dummy</th></tr></thead>
      <tbody>
        $rows
      </tbody>
    </table>
  </body>
</html>
''';
}

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  late _MockHttpClient mockClient;
  late CantineRepositoryImpl repository;

  setUp(() {
    mockClient = _MockHttpClient();
    repository = CantineRepositoryImpl(client: mockClient);
  });

  group('CantineRepositoryImpl – HTML-Parsing', () {
    test('liefert zwei Tage mit Mahlzeiten, wenn beide Antworten gültig sind', () async {
      final htmlToday = _htmlWithMeals([
        {'name': 'Milchreis', 's': '1,90 €', 'b': '4,00 €', 'g': '5,10 €'},
        {'name': 'Bami Goreng', 's': '2,80 €', 'b': '4,90 €', 'g': '6,00 €'},
      ]);

      final htmlTomorrow = _htmlWithMeals([
        {'name': 'Schnitzel', 's': '3,80 €', 'b': '5,90 €', 'g': '7,00 €'},
      ]);

      var call = 0;
      when(() => mockClient.get(any())).thenAnswer((_) async {
        call++;
        return http.Response.bytes(utf8.encode(call == 1 ? htmlToday : htmlTomorrow), 200);
      });

      final result = await repository.fetchMenu(url: 'http://localhost');

      expect(result.length, 2);
      expect(result[0].meals.length, 2);
      expect(result[1].meals.length, 1);
    });

    test('filtert Tage ohne Mahlzeiten heraus', () async {
      final htmlWithMeals = _htmlWithMeals([
        {'name': 'Lasagne', 's': '2,80 €', 'b': '4,90 €', 'g': '6,00 €'},
      ]);
      final htmlEmpty = _htmlWithMeals([]);

      var call = 0;
      when(() => mockClient.get(any())).thenAnswer((_) async {
        call++;
        return http.Response.bytes(utf8.encode(call == 1 ? htmlWithMeals : htmlEmpty), 200);
      });

      final result = await repository.fetchMenu(url: 'http://localhost');

      expect(result.length, 1);
      expect(result.first.meals.first.name, 'Lasagne');
    });

    test('ignoriert erste Antwort bei HTTP-Fehler und nimmt zweite', () async {
      final htmlOk = _htmlWithMeals([
        {'name': 'Currywurst', 's': '2,50 €', 'b': '4,00 €', 'g': '5,00 €'},
      ]);

      var call = 0;
      when(() => mockClient.get(any())).thenAnswer((_) async {
        call++;
        return call == 1
            ? http.Response('Not Found', 404)
            : http.Response.bytes(utf8.encode(htmlOk), 200);
      });

      final result = await repository.fetchMenu(url: 'http://localhost');

      expect(result.length, 1);
      expect(result.first.meals.first.name, 'Currywurst');
    });

    test('parst Preise im deutschen Format in Cent', () async {
      final html = _htmlWithMeals([
        {'name': 'Preis-Test', 's': '10,99 €', 'b': '15,50 €', 'g': '20,00 €'},
      ]);

      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response.bytes(utf8.encode(html), 200));

      final result = await repository.fetchMenu(url: 'http://localhost');

      expect(result.length, 2); // heute & morgen
      final prices = result.first.meals.first.prices;
      expect(prices, [1099, 1550, 2000]);
    });

    test('gibt leere Liste zurück, wenn beide Requests fehlschlagen', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('Fehler', 500));

      final result = await repository.fetchMenu(url: 'http://localhost');
      expect(result, isEmpty);
    });
  });
}
