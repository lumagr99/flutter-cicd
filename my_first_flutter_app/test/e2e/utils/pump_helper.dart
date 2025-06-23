import 'package:flutter_test/flutter_test.dart';

/// Waits until a widget becomes visible or a timeout is reached.
///
/// This utility is useful when waiting for UI elements that appear asynchronously,
/// such as after navigation transitions or network responses.
///
/// Parameters:
/// - [tester]: The `WidgetTester` from `testWidgets`.
/// - [finder]: A `Finder` used to locate the expected widget.
/// - [timeout]: Maximum time to wait before failing (default: 20 seconds).
///
/// If the widget is not found within the timeout duration, the test fails.
Future<void> pumpUntilVisible(
    WidgetTester tester,
    Finder finder, {
      Duration timeout = const Duration(seconds: 20),
    }) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }

  final type = finder.runtimeType.toString();
  final desc = finder.describeMatch(Plurality.one);
  fail('Widget of type <$type> not visible after ${timeout.inSeconds}s: $desc');
}
