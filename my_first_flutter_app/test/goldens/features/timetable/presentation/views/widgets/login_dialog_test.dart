import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:my_first_flutter_app/features/timetable/presentation/views/widgets/login_dialog.dart';
import '../../../../../utils/device_setups.dart'; // Falls du defaultDevices definiert hast

const String basePath = '../../../../../../../../goldens/features/timetable/presentation/views/widgets/login_dialog';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting('de');
  });

  Future<void> showDialogWithState(
      WidgetTester tester, {
        bool showError = false,
        bool isLoading = false,
      }) async {
    await tester.pumpWidgetBuilder(
      Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              showLoginDialog(
                rootContext: context,
                onSubmit: (user, pass) async {
                  if (isLoading) await Future.delayed(const Duration(seconds: 2));
                  return !showError;
                },
                onSuccess: () async {},
                onCancel: () {},
              );
            },
            child: const Text('Open Dialog'),
          );
        },
      ),
      wrapper: materialAppWrapper(),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();
  }

  testGoldens('LoginDialog - initial state (multi-device)', (tester) async {
    await showDialogWithState(tester);
    await multiScreenGolden(
      tester,
      '$basePath/initial',
      devices: defaultDevices,
    );
  });

  testGoldens('LoginDialog - with error message (multi-device)', (tester) async {
    await showDialogWithState(tester, showError: true);

    await tester.tap(find.text('Einloggen'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await multiScreenGolden(
      tester,
      '$basePath/error',
      devices: defaultDevices,
    );
  });

  testGoldens('LoginDialog - loading state (multi-device)', (tester) async {
    await showDialogWithState(tester, isLoading: true);

    await tester.enterText(find.byType(TextFormField).first, 'demo');
    await tester.enterText(find.byType(TextFormField).last, 'pass');
    await tester.tap(find.text('Einloggen'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 500)); // mid-load

    await multiScreenGolden(
      tester,
      '$basePath/loading',
      devices: defaultDevices,
    );
  });
}
