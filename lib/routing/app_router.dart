import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/core/auth/auth_session_provider.dart';
import 'package:zockblock_app/features/auth/presentation/auth_screen.dart';
import 'package:zockblock_app/features/home/presentation/home_screen.dart';
import 'package:zockblock_app/features/user_profile/data/user_provider.dart';
import 'package:zockblock_app/features/user_profile/presentation/profile_setup_screen.dart';
import 'package:zockblock_app/features/user_profile/presentation/user_profile_screen.dart';

/// GoRouter der App. `redirect` steuert das Auth-/Profil-Gate anhand von
/// [authSessionProvider]/[userProvider], `refreshListenable` sorgt dafür,
/// dass `redirect` neu ausgewertet wird, sobald sich einer der beiden ändert.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    refreshListenable: refreshListenable,
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
    redirect: (context, state) {
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
            // Echter Fehler (z.B. Netzwerk) - nicht erzwungen zu
            // /profile-setup navigieren, sonst würde ein bereits
            // eingerichteter Nutzer bei einem Wackler dorthin verschoben.
            error: (_, _) => null,
          );
        },
        loading: () => null,
        error: (_, _) => '/auth',
      );
    },
  );
});

/// Löst einen [GoRouter]-Refresh aus, wenn sich [authSessionProvider] oder
/// [userProvider] ändern, damit `redirect` neu ausgewertet wird.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref
      ..listen(authSessionProvider, (_, _) => notifyListeners())
      ..listen(userProvider, (_, _) => notifyListeners());
  }
}
