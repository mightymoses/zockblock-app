import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/consent/crash_report_consent_provider.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/atoms/app_filled_button.dart';

/// Fragt beim ersten Start nach der Einwilligung in Absturzberichte.
///
/// Beide Antworten sehen bewusst gleich aus und stehen gleichwertig
/// nebeneinander – eine Einwilligung ist nur wirksam, wenn Ablehnen genauso
/// leicht fällt wie Zustimmen.
class CrashReportConsentSection extends ConsumerWidget {
  /// Erstellt die Section.
  const CrashReportConsentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(crashReportConsentProvider.notifier);
    final isSaving = ref.watch(crashReportConsentProvider).isLoading;

    return Column(
      children: [
        const Spacer(),
        Text(
          l10n.consentHeadline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'ComradeBold',
            fontSize: 22,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.consentBody,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'ComradeBold',
            fontSize: 16,
          ),
        ),
        const Spacer(),
        AppFilledButton(
          label: l10n.consentAccept,
          onPressed: isSaving ? null : () => unawaited(notifier.grant()),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFilledButton(
          label: l10n.consentDecline,
          onPressed: isSaving ? null : () => unawaited(notifier.deny()),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
