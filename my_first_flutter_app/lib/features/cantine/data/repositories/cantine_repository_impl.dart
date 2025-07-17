import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

import '../../data/models/menu_day.dart';
import '../../data/models/meal.dart';
import '../../domain/repositories/cantine_repository.dart';

/// Holt den Speiseplan (heute + morgen) von einer TYPO3-Site
/// und wandelt ihn in [MenuDay]/[Meal]-Objekte um.
class CantineRepositoryImpl implements CantineRepository {
  final http.Client _client;
  CantineRepositoryImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<MenuDay>> fetchMenu({required String url}) async {
    final today    = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    final results = await Future.wait<MenuDay?>([
      _fetchDay(_buildUrl(url, today),    today),
      _fetchDay(_buildUrl(url, tomorrow), tomorrow),
    ]);

    // nur tatsächlich gefüllte Tage zurückgeben
    return results.whereType<MenuDay>().toList();
  }

  /// URL builder
  String _buildUrl(String base, DateTime date) {
    final d = '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return (base.endsWith('/') ? base : '$base/') + d;
  }

  /// Fetch Menu Data for a day
  Future<MenuDay?> _fetchDay(String url, DateTime date) async {
    final res = await _client.get(Uri.parse(url));
    if (res.statusCode != 200) return null;

    final doc   = html_parser.parse(res.body);
    final meals = _parseMeals(doc);
    if (meals.isEmpty) return null;

    return MenuDay(date: date, label: _germanLabel(date), meals: meals);
  }

  /// HTML parsen
  List<Meal> _parseMeals(Document doc) {
    final meals = <Meal>[];

    // alle Gerichte stehen in <span class="meals__title">
    for (final titleEl in doc.querySelectorAll('.meals__title')) {
      final row = _findAncestorRow(titleEl);
      if (row == null) continue;

      final name = titleEl.text.trim();
      if (name.isEmpty) continue;

      final prices = _extractPrices(row);
      if (prices.length != 3) continue;     // Checken ob alle drei Preisarten (Student, Mitarbeiter, Gast vorhanden sind)

      meals.add(Meal(
        id:     name.hashCode.toString(),
        name:   name,
        prices: prices,
      ));
    }
    return meals;
  }

  /// Extract prices (Studenten, Mitarbeiter, Gäste)
  List<int> _extractPrices(Element row) {
    final values = <int>[];

    for (final cell in row.querySelectorAll('.meals__column-price')) {
      final digits = cell.text.replaceAll(RegExp(r'[^\d]'), '');
      if (digits.isEmpty) continue;
      values.add(int.parse(digits));
    }
    return values;
  }

  /// Returns the nearest ancestor <tr> element or null if none is found.
  Element? _findAncestorRow(Element el) {
    var current = el;
    while (current.localName != 'tr' && current.parent != null) {
      current = current.parent!;
    }
    return current.localName == 'tr' ? current : null;
  }


  /// Parse DateTime to german weekday
  String _germanLabel(DateTime d) {
    const w = [
      'Montag', 'Dienstag', 'Mittwoch',
      'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'
    ];
    return '${w[d.weekday - 1]}, '
        '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}';
  }
}
