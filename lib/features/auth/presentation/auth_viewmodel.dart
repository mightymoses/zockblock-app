import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/auth_repository_impl.dart';
import '../data/auth_service.dart';
import '../data/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthService());
});

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, AuthUser?>(() {
  return AuthViewModel();
});

class AuthViewModel extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    return await ref.read(authRepositoryProvider).getExistingSession();
  }

  Future<void> login() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(),
    );
  }
}