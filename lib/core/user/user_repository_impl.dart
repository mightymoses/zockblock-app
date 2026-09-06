import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/error/app_exception.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/core/user/user_repository.dart';
import 'package:zockblock_app/core/user/user_service.dart';

/// Stellt das [UserRepository] bereit.
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  final userService = ref.watch(userServiceProvider);
  return UserRepositoryImpl(userService);
});

/// Implementiert [UserRepository] über [UserService] (Backend-REST-API).
class UserRepositoryImpl implements UserRepository {
  /// Erstellt das Repository mit dem [UserService], den es kapselt.
  UserRepositoryImpl(this._userService);

  final UserService _userService;

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await _userService.getCurrentUser();
    } on NotFoundException {
      // Noch kein Profil angelegt - kein Fehler, sondern ein gültiger Zustand.
      return null;
    }
  }

  @override
  Future<User> createUser(User newUser) {
    return _userService.createUser(newUser);
  }
}
