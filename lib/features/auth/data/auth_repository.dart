import 'auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login();
  Future<void> logout();
}