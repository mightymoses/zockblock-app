import 'package:flutter/material.dart';
import 'package:zockblock_app/features/user_profile/presentation/user_profile_section.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/organisms/app_page_scaffold.dart';

/// Seite mit den Profildaten des angemeldeten Nutzers.
class UserProfilePage extends StatelessWidget {
  /// Erstellt die Seite.
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppLocalizations.of(context)!.userProfileTitle,
      child: const UserProfileSection(),
    );
  }
}
