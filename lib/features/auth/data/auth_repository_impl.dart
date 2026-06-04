import 'package:auth0_flutter/auth0_flutter.dart';
import 'auth_repository.dart';
import 'auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);
  
  @override
  Future<Credentials> login() async {
    return await _authService.login();
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }
}