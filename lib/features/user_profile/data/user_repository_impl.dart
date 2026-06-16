import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/user_profile/data/user.dart';
import 'package:zockblock_app/features/user_profile/data/user_repository.dart';
import 'package:zockblock_app/features/user_profile/data/user_service.dart';

final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  final userService = ref.watch(userServiceProvider);
  return UserRepositoryImpl(userService);
});

final onUserStateChangedProvider = StreamProvider<bool>((ref) {
  return ref.read(userRepositoryProvider).onUserStateChanged;
});

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._userService);

  final UserService _userService;
  final _userStatusController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onUserStateChanged => _userStatusController.stream;

  @override
  Future<User?> getCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      _userStatusController.add(true);
      return user;
    } catch (e) {
      _userStatusController.add(false);
      return null;
    }
  }

  @override
  Future<User?> createUser(User newUser) async {
    try {
      final user = await _userService.createUser(newUser);
      _userStatusController.add(true);
      return user;
    } catch (e) {
      _userStatusController.add(false);
      return null;
    }
  }
}
