import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/auth/auth_repository_impl.dart';
import 'package:zockblock_app/core/auth/auth_session.dart';

/// Einzige Quelle für "ist der Nutzer eingeloggt" - `null` heißt nicht
/// eingeloggt. Aktualisiert nur bei App-Start, [AuthSessionNotifier.login]
/// und [AuthSessionNotifier.logout], nicht pro Request.
final AsyncNotifierProvider<AuthSessionNotifier, AuthSession?>
authSessionProvider = AsyncNotifierProvider(AuthSessionNotifier.new);

/// Hält den aktuellen [AuthSession]-Zustand.
class AuthSessionNotifier extends AsyncNotifier<AuthSession?> {
  @override
  FutureOr<AuthSession?> build() async {
    return await ref.watch(authRepositoryProvider).getExistingSession();
  }

  /// Startet den Login-Flow.
  Future<void> login() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).login();
    });
  }

  /// Meldet den Nutzer ab.
  Future<void> logout() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      return null;
    });
  }
}
