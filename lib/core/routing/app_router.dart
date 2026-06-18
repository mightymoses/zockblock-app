import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/features/auth/data/auth_repository_impl.dart';
import 'package:zockblock_app/features/auth/presentation/auth_screen.dart';
import 'package:zockblock_app/features/home/presentation/home_screen.dart';
import 'package:zockblock_app/features/kniffel/presentation/kniffel_screen.dart';
import 'package:zockblock_app/features/user_profile/presentation/create_user_profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});

GoRouter createRouter(Ref ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/create-user-profile',
        builder: (context, state) => const CreateUserProfileScreen(),
      ),
      GoRoute(
        path: '/kniffel-test',
        builder: (context, state) => const KniffelScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final user = await ref.read(authRepositoryProvider).getExistingSession();

      if (user == null) {
        return '/auth';
      }

      if (state.matchedLocation == '/auth') {
        return '/';
      }

      return null;
    },
  );
}

