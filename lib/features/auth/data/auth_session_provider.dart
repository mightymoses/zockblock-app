import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/auth/data/auth_repository_impl.dart';
import 'package:zockblock_app/features/auth/data/auth_session.dart';

final AsyncNotifierProvider<AuthSessionNotifier, AuthSession?>
authSessionProvider = AsyncNotifierProvider(AuthSessionNotifier.new);

class AuthSessionNotifier extends AsyncNotifier<AuthSession?> {
  @override
  FutureOr<AuthSession?> build() async {
    return await ref.watch(authRepositoryProvider).getExistingSession();
  }

  Future<void> login() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).login();
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      return null;
    });
  }

  Future<void> renewSession() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).getExistingSession();
    });
  }
}
