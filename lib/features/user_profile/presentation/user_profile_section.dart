import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/core/auth/auth_session.dart';
import 'package:zockblock_app/core/auth/auth_session_provider.dart';
import 'package:zockblock_app/core/consent/crash_report_consent.dart';
import 'package:zockblock_app/core/consent/crash_report_consent_provider.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/core/user/current_user_provider.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/atoms/app_filled_button.dart';
import 'package:zockblock_app/shared/widgets/molecules/async_value_view.dart';

const _valueStyle = TextStyle(fontFamily: 'ComradeBold', fontSize: 16);

/// Zeigt die Kenndaten des angemeldeten Nutzers und bietet Abmelden an.
class UserProfileSection extends ConsumerWidget {
  /// Erstellt die Section.
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final consentState = ref.watch(crashReportConsentProvider);
    final consent = consentState.value;
    final consentIsSaving = consentState.isLoading;

    // Abmelden ändert nichts Sichtbares auf dieser Seite - ein Fehlschlag
    // braucht deshalb eine eingeblendete Meldung statt einer Inline-Anzeige.
    ref.listen(authSessionProvider, (previous, next) {
      if (next.hasError && previous?.hasError != true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorSignOutFailed)));
      }
    });

    return Column(
      children: [
        const Spacer(),
        AsyncValueView<AuthSession?>(
          value: ref.watch(authSessionProvider),
          data: (authSession) => authSession == null
              ? const SizedBox.shrink()
              : Text(
                  l10n.authIdValue(authSession.externalAuthId),
                  textAlign: TextAlign.center,
                  style: _valueStyle,
                ),
        ),
        AsyncValueView<User?>(
          value: ref.watch(currentUserProvider),
          onRetry: () => ref.invalidate(currentUserProvider),
          data: (user) => user == null
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.userIdValue('${user.id}'),
                      textAlign: TextAlign.center,
                      style: _valueStyle,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.usernameValue(user.username),
                      textAlign: TextAlign.center,
                      style: _valueStyle,
                    ),
                  ],
                ),
        ),
        const Spacer(),
        // Widerruf der Einwilligung aus dem ersten Start. Muss laut DSGVO
        // genauso einfach sein wie das Zustimmen, deshalb direkt hier und
        // nicht hinter einem weiteren Screen.
        SwitchListTile(
          value: consent == CrashReportConsent.granted,
          onChanged: consentIsSaving
              ? null
              : (granted) => unawaited(
                  granted
                      ? ref.read(crashReportConsentProvider.notifier).grant()
                      : ref.read(crashReportConsentProvider.notifier).deny(),
                ),
          title: Text(l10n.consentToggleLabel, style: _valueStyle),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFilledButton(
          label: l10n.signOut,
          onPressed: () => ref.read(authSessionProvider.notifier).logout(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppFilledButton(label: l10n.toHome, onPressed: () => context.go('/')),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
