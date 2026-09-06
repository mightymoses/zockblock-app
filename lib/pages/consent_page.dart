import 'package:flutter/material.dart';
import 'package:zockblock_app/features/consent/presentation/crash_report_consent_section.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/organisms/app_page_scaffold.dart';

/// Seite mit der Einwilligungsfrage zu Absturzberichten, vor allem anderen.
class ConsentPage extends StatelessWidget {
  /// Erstellt die Seite.
  const ConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppLocalizations.of(context)!.consentTitle,
      child: const CrashReportConsentSection(),
    );
  }
}
