import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/features/user_profile/domain/username.dart';
import 'package:zockblock_app/features/user_profile/presentation/profile_setup_viewmodel.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/atoms/app_filled_button.dart';

/// Formular zum Anlegen des Nutzerprofils nach dem ersten Login.
class ProfileSetupSection extends HookConsumerWidget {
  /// Erstellt die Section.
  const ProfileSetupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final usernameController = useTextEditingController();
    final formState = ref.watch(profileSetupViewModelProvider);
    final viewModel = ref.read(profileSetupViewModelProvider.notifier);

    return Column(
      children: [
        const Spacer(),
        Text(
          l10n.profileSetupIntro,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'ComradeBold',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: usernameController,
          onChanged: viewModel.updateUsername,
          decoration: InputDecoration(
            labelText: l10n.usernameLabel,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontFamily: 'ComradeBold',
              fontSize: 16,
            ),
            errorText: formState.showErrors
                ? _usernameErrorText(l10n, formState.usernameError)
                : null,
            errorStyle: const TextStyle(color: Colors.red),
            filled: true,
            fillColor: Colors.black,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.white, width: 4),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.red, width: 4),
            ),
          ),
        ),
        if (formState.hasSubmitError) ...[
          Text(
            l10n.profileSetupSubmitError,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        const Spacer(),
        AppFilledButton(
          label: l10n.create,
          isLoading: formState.isLoading,
          onPressed: () => unawaited(viewModel.submitForm()),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Übersetzt einen [UsernameValidationError] in einen Anzeigetext.
String? _usernameErrorText(
  AppLocalizations l10n,
  UsernameValidationError? error,
) {
  return switch (error) {
    null => null,
    UsernameValidationError.empty => l10n.usernameErrorEmpty,
    UsernameValidationError.tooShort => l10n.usernameErrorTooShort(
      Username.minLength,
    ),
  };
}
