import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/core/user/user_repository_impl.dart';

/// Profil des angemeldeten Nutzers, `null` wenn noch keines angelegt ist.
final AsyncNotifierProvider<CurrentUserNotifier, User?> currentUserProvider =
    AsyncNotifierProvider(CurrentUserNotifier.new);

/// Lädt und erzeugt das Profil des angemeldeten Nutzers.
class CurrentUserNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() {
    return ref.watch(userRepositoryProvider).getCurrentUser();
  }

  /// Legt das Profil an; ein Fehler landet als [AsyncError] im State.
  Future<void> createUser(User user) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return ref.read(userRepositoryProvider).createUser(user);
    });
  }
}
