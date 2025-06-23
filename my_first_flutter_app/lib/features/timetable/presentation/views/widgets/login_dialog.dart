import 'package:flutter/material.dart';

typedef LoginSubmitCallback = Future<bool> Function(String username, String password);
typedef OnSuccessCallback = Future<void> Function();

Future<void> showLoginDialog({
  required BuildContext rootContext,
  required LoginSubmitCallback onSubmit,
  required OnSuccessCallback onSuccess,
  required VoidCallback onCancel,
}) {
  return showDialog(
    context: rootContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      final userController = TextEditingController();
      final passController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      bool isLoading = false;
      String? errorMessage;

      Future<void> handleLogin({
        required void Function(VoidCallback fn) setState,
      }) async {
        if (!formKey.currentState!.validate()) return;

        setState(() {
          isLoading = true;
          errorMessage = null;
        });

        final user = userController.text.trim();
        final pass = passController.text;

        try {
          final success = await onSubmit(user, pass);
          if(!dialogContext.mounted) return;
          if (success) {
            Navigator.of(dialogContext).pop();
            await onSuccess();
          } else {
            setState(() {
              isLoading = false;
              errorMessage = 'Zugangsdaten ungültig';
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
            errorMessage = 'Fehler beim Prüfen: ${e.toString()}';
          });
        }
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Zugangsdaten eingeben'),
            content: isLoading
                ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
                : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: userController,
                        decoration: const InputDecoration(labelText: 'Benutzername'),
                        validator: (val) =>
                        val == null || val.isEmpty ? 'Benutzername erforderlich' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Passwort'),
                        validator: (val) =>
                        val == null || val.isEmpty ? 'Passwort erforderlich' : null,
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onCancel();
                },
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () => handleLogin(setState: setState),
                child: const Text('Einloggen'),
              ),
            ],
          );
        },
      );
    },
  );
}
