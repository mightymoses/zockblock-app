import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/features/auth/data/auth_session_provider.dart';
import 'package:zockblock_app/features/auth/presentation/auth_screen.dart';
import 'package:zockblock_app/features/home/presentation/home_screen.dart';
import 'package:zockblock_app/features/user_profile/data/user_provider.dart';
import 'package:zockblock_app/features/user_profile/presentation/profile_setup_screen.dart';
import 'package:zockblock_app/features/user_profile/presentation/user_profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/user-profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authSessionAsyncValue = ref.read(authSessionProvider);
      final userAsyncValue = ref.read(userProvider);

      return authSessionAsyncValue.when(
        data: (authSession) {
          if (authSession == null) {
            return '/auth';
          }

          return userAsyncValue.when(
            data: (user) {
              if (user == null) {
                return '/profile-setup';
              }

              if (state.matchedLocation == '/auth' ||
                  state.matchedLocation == '/profile-setup') {
                return '/';
              }

              return null;
            },
            loading: () => null,
            error: (_, _) => '/profile-setup',
          );
        },
        loading: () => null,
        error: (_, _) => '/auth',
      );
    },
  );
});
