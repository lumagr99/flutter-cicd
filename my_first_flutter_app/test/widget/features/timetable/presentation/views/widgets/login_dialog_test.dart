import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_app/features/timetable/presentation/views/widgets/login_dialog.dart';

void main() {
  testWidgets('zeigt Validierungsfehler bei leeren Feldern', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showLoginDialog(
                  rootContext: context,
                  onSubmit: (_, __) async => true,
                  onSuccess: () async {},
                  onCancel: () {},
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Einloggen'));
    await tester.pump();

    expect(find.text('Benutzername erforderlich'), findsOneWidget);
    expect(find.text('Passwort erforderlich'), findsOneWidget);
  });

  testWidgets('zeigt Fehlermeldung bei falschen Zugangsdaten', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showLoginDialog(
                  rootContext: context,
                  onSubmit: (_, __) async => false,
                  onSuccess: () async {},
                  onCancel: () {},
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');

    await tester.tap(find.text('Einloggen'));
    await tester.pumpAndSettle();

    expect(find.text('Zugangsdaten ungültig'), findsOneWidget);
  });

  testWidgets('führt onSuccess bei erfolgreichem Login aus', (tester) async {
    bool successCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showLoginDialog(
                  rootContext: context,
                  onSubmit: (_, __) async => true,
                  onSuccess: () async {
                    successCalled = true;
                  },
                  onCancel: () {},
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
    await tester.enterText(find.byType(TextFormField).at(1), 'correctpass');

    await tester.tap(find.text('Einloggen'));
    await tester.pumpAndSettle();

    expect(successCalled, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('führt onCancel aus, wenn abgebrochen wird', (tester) async {
    bool cancelCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showLoginDialog(
                  rootContext: context,
                  onSubmit: (_, __) async => true,
                  onSuccess: () async {},
                  onCancel: () {
                    cancelCalled = true;
                  },
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(cancelCalled, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('zeigt Ladeindikator während des Logins', (tester) async {
    final completer = Completer<bool>();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showLoginDialog(
                  rootContext: context,
                  onSubmit: (_, __) => completer.future,
                  onSuccess: () async {},
                  onCancel: () {},
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user');
    await tester.enterText(find.byType(TextFormField).at(1), 'pass');

    await tester.tap(find.text('Einloggen'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(true);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('zeigt Fehlertext wenn onSubmit Exception wirft', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showLoginDialog(
                  rootContext: context,
                  onSubmit: (_, __) async => throw Exception('Netzwerkfehler'),
                  onSuccess: () async {},
                  onCancel: () {},
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'abc');
    await tester.enterText(find.byType(TextFormField).at(1), '123');

    await tester.tap(find.text('Einloggen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Fehler beim Prüfen'), findsOneWidget);
  });

  testWidgets('entfernt Leerzeichen im Benutzernamen (trim)', (tester) async {
    String? receivedUser;
    String? receivedPass;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showLoginDialog(
                  rootContext: context,
                  onSubmit: (user, pass) async {
                    receivedUser = user;
                    receivedPass = pass;
                    return true;
                  },
                  onSuccess: () async {},
                  onCancel: () {},
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '  testuser  ');
    await tester.enterText(find.byType(TextFormField).at(1), ' pass123 ');

    await tester.tap(find.text('Einloggen'));
    await tester.pumpAndSettle();

    expect(receivedUser, 'testuser');
    expect(receivedPass, ' pass123 '); // Passwort bleibt ungetrimmt
  });
}
