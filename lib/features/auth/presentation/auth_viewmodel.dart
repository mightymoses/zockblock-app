import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/auth/data/auth_repository_impl.dart';
import 'package:zockblock_app/features/auth/data/auth_session.dart';

final authViewModelProvider =
    AsyncNotifierProvider<AuthViewModel, AuthSession?>(() {
      return AuthViewModel();
    });

class AuthViewModel extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    return ref.read(authRepositoryProvider).getExistingSession();
  }

  Future<void> login() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(),
    );
  }
}
