import 'package:integration_test/integration_test.dart';

String _testPrefix = 'e2e_fallback';
int _stepCounter = 1;

/// Sets the prefix used in screenshot filenames for this test run.
///
/// This should be called at the start of each test to organize screenshot files.
void setTestPrefix(String prefix) {
  _testPrefix = prefix;
  _stepCounter = 1;
}

/// Takes a screenshot using the test driver and auto-names it by step and label.
///
/// - [label]: A short description of the current step.
/// - The filename will follow the format: <prefix>/step_<number>_<label>.png
Future<void> takeScreenshot(String label) async {
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  final step = _stepCounter.toString().padLeft(2, '0');
  final name = '$_testPrefix/step_${step}_$label';
  _stepCounter++;
  await binding.takeScreenshot(name);
}
