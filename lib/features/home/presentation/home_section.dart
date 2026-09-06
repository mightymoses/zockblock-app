import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/core/user/current_user_provider.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/atoms/app_filled_button.dart';
import 'package:zockblock_app/shared/widgets/molecules/async_value_view.dart';

/// Startseiten-Inhalt: Begrüßung des angemeldeten Nutzers und Einstieg ins
/// Nutzerprofil.
class HomeSection extends ConsumerWidget {
  /// Erstellt die Section.
  const HomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const Spacer(),
        AsyncValueView<User?>(
          value: ref.watch(currentUserProvider),
          onRetry: () => ref.invalidate(currentUserProvider),
          data: (user) => user == null
              ? const SizedBox.shrink()
              : Text(
                  l10n.homeGreeting(user.username),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'ComradeBold',
                    fontSize: 28,
                  ),
                ),
        ),
        const Spacer(),
        AppFilledButton(
          label: l10n.toUserProfile,
          onPressed: () => context.go('/user-profile'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
