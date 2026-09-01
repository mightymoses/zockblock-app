import 'package:flutter/material.dart';
import 'package:zockblock_app/features/user_profile/presentation/profile_setup_section.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/organisms/app_page_scaffold.dart';

/// Seite zum Anlegen des Nutzerprofils nach dem ersten Login.
class ProfileSetupPage extends StatelessWidget {
  /// Erstellt die Seite.
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppLocalizations.of(context)!.profileSetupTitle,
      child: const ProfileSetupSection(),
    );
  }
}
