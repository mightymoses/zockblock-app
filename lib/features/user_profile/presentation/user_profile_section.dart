import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/core/auth/auth_session_provider.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/features/user_profile/data/user_provider.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/atoms/app_filled_button.dart';

const _valueStyle = TextStyle(fontFamily: 'ComradeBold', fontSize: 16);

/// Zeigt die Kenndaten des angemeldeten Nutzers und bietet Abmelden an.
class UserProfileSection extends ConsumerWidget {
  /// Erstellt die Section.
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncAuthSession = ref.watch(authSessionProvider);
    final asyncUser = ref.watch(userProvider);

    return Column(
      children: [
        const Spacer(),
        asyncAuthSession.maybeWhen(
          data: (authSession) => authSession == null
              ? const SizedBox.shrink()
              : Text(
                  l10n.authIdValue(authSession.externalAuthId),
                  textAlign: TextAlign.center,
                  style: _valueStyle,
                ),
          orElse: SizedBox.shrink,
        ),
        asyncUser.maybeWhen(
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
          orElse: SizedBox.shrink,
        ),
        const Spacer(),
        AppFilledButton(
          label: l10n.signOut,
          onPressed: () => ref.read(authSessionProvider.notifier).logout(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppFilledButton(
          label: l10n.toHome,
          onPressed: () => context.go('/'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
