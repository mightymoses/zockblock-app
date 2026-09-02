import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/core/auth/auth_session_provider.dart';
import 'package:zockblock_app/core/user/current_user_provider.dart';
import 'package:zockblock_app/pages/auth_page.dart';
import 'package:zockblock_app/pages/home_page.dart';
import 'package:zockblock_app/pages/profile_setup_page.dart';
import 'package:zockblock_app/pages/user_profile_page.dart';

/// GoRouter der App. `redirect` steuert das Auth-/Profil-Gate anhand von
/// [authSessionProvider]/[currentUserProvider], `refreshListenable` sorgt dafür,
/// dass `redirect` neu ausgewertet wird, sobald sich einer der beiden ändert.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: '/user-profile',
        builder: (context, state) => const UserProfilePage(),
      ),
    ],
    redirect: (context, state) {
      final authSessionAsyncValue = ref.read(authSessionProvider);
      final userAsyncValue = ref.read(currentUserProvider);

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
/// [currentUserProvider] ändern, damit `redirect` neu ausgewertet wird.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref
      ..listen(authSessionProvider, (_, _) => notifyListeners())
      ..listen(currentUserProvider, (_, _) => notifyListeners());
  }
}
