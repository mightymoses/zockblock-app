import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/user_profile/data/user.dart';
import 'package:zockblock_app/features/user_profile/data/user_repository_impl.dart';

final userProvider = AsyncNotifierProvider(UserNotifier.new);

class UserNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() {
    return ref.watch(userRepositoryProvider).getCurrentUser();
  }

  Future<void> createUser(User user) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await ref.read(userRepositoryProvider).createUser(user);
    });
  }
}
