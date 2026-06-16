import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'auth_service.dart';
import 'auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService);
});

final onAuthStateChangedProvider = StreamProvider<bool>((ref) {
  return ref.read(authRepositoryProvider).onAuthStateChanged;
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;
  final _authStatusController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onAuthStateChanged => _authStatusController.stream;

  @override
  Future<AuthSession> login() async {
    final credentials = await _authService.login();
    final authSession = AuthSession.fromCredentials(credentials);

    _authStatusController.add(true);
    return authSession;
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
    _authStatusController.add(false);
  }

  @override
  Future<AuthSession?> getExistingSession() async {
    try {
      final hasValid = await _authService.hasValidCredentials();
      if (!hasValid) {
        _authStatusController.add(false);
        return null;
      }

      final credentials = await _authService.getCredentials();
      final authSession = AuthSession.fromCredentials(credentials);

      _authStatusController.add(true);
      return authSession;
    } catch (e) {
      _authStatusController.add(false);
      return null;
    }
  }
}
