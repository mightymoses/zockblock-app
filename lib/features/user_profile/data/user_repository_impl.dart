import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/user_profile/data/user.dart';
import 'package:zockblock_app/features/user_profile/data/user_repository.dart';
import 'package:zockblock_app/features/user_profile/data/user_service.dart';

/// Stellt das [UserRepository] bereit.
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  final userService = ref.watch(userServiceProvider);
  return UserRepositoryImpl(userService);
});

// TODO(router-refresh-fix): entfällt, sobald refreshListenable steht.
final onUserStateChangedProvider = StreamProvider<bool>((ref) {
  return ref.read(userRepositoryProvider).onUserStateChanged;
});

/// Implementiert [UserRepository] über [UserService] (Backend-REST-API).
class UserRepositoryImpl implements UserRepository {
  /// Erstellt das Repository mit dem [UserService], den es kapselt.
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _userStatusController.add(false);
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<User> createUser(User newUser) async {
    final user = await _userService.createUser(newUser);
    _userStatusController.add(true);
    return user;
  }
}
