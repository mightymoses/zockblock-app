import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/user_profile/data/user.dart';
import 'package:zockblock_app/features/user_profile/data/user_repository_impl.dart';

/// Profil des angemeldeten Nutzers, `null` wenn noch keines angelegt ist.
final AsyncNotifierProvider<UserNotifier, User?> userProvider =
    AsyncNotifierProvider(UserNotifier.new);

/// Lädt und erzeugt das Profil des angemeldeten Nutzers.
class UserNotifier extends AsyncNotifier<User?> {
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
