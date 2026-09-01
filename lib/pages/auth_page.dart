import 'package:flutter/material.dart';
import 'package:zockblock_app/features/auth/presentation/auth_section.dart';

/// Anmeldeseite; zeigt formatfüllend die [AuthSection].
class AuthPage extends StatelessWidget {
  /// Erstellt die Seite.
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const AuthSection(),
    );
  }
}
