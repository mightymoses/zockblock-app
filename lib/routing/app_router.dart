import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/core/auth/auth_session_provider.dart';
import 'package:zockblock_app/core/consent/crash_report_consent.dart';
import 'package:zockblock_app/core/consent/crash_report_consent_provider.dart';
import 'package:zockblock_app/core/user/current_user_provider.dart';
import 'package:zockblock_app/pages/auth_page.dart';
import 'package:zockblock_app/pages/consent_page.dart';
import 'package:zockblock_app/pages/home_page.dart';
import 'package:zockblock_app/pages/profile_setup_page.dart';
import 'package:zockblock_app/pages/user_profile_page.dart';

/// GoRouter der App. `redirect` steuert das Einwilligungs-, Auth- und
/// Profil-Gate anhand von [crashReportConsentProvider], [authSessionProvider]
/// und [currentUserProvider]; `refreshListenable` sorgt dafür, dass `redirect`
/// neu ausgewertet wird, sobald sich einer der drei ändert.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(
        path: '/consent',
        builder: (context, state) => const ConsentPage(),
      ),
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
      final consent = ref.read(crashReportConsentProvider).value;
      final onConsentPage = state.matchedLocation == '/consent';

      // Vor allem anderen: solange die Entscheidung aussteht, wird nur
      // gefragt. `null` heisst noch am Laden - dann gar nicht umleiten.
      if (consent == CrashReportConsent.notAsked) {
        return onConsentPage ? null : '/consent';
      }
      if (consent != null && onConsentPage) {
        // Beantwortet - raus hier, die Auth-Kette entscheidet, wohin.
        return '/';
      }

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

/// Löst einen [GoRouter]-Refresh aus, wenn sich [crashReportConsentProvider],
/// [authSessionProvider] oder [currentUserProvider] ändern, damit `redirect`
/// neu ausgewertet wird.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref
      ..listen(crashReportConsentProvider, (_, _) => notifyListeners())
      ..listen(authSessionProvider, (_, _) => notifyListeners())
      ..listen(currentUserProvider, (_, _) => notifyListeners());
  }
}
