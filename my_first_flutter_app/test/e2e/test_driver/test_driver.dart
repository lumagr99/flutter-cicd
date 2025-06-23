import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

/// Integration Test Driver
///
/// This script is executed via `flutter drive`.
/// It enables capturing screenshots during integration test runs
/// and saves them locally in the `screenshots/` directory.
///
/// Example usage:
/// flutter drive --driver=test_driver/test_driver.dart --target=integration_test/your_test.dart

Future<void> main() async {
  await integrationDriver(
    // Callback function to handle screenshot saving
    onScreenshot: (String name, List<int> bytes,
        [Map<String, Object?>? metadata]) async {
      // Define the screenshot output file
      final file = File('screenshots/$name.png');

      // Ensure the target directory exists
      await file.parent.create(recursive: true);

      // Write the image bytes to a .png file
      await file.writeAsBytes(bytes);

      // Confirm that the screenshot was saved
      return true;
    },
  );
}
