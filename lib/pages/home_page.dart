import 'package:flutter/material.dart';
import 'package:zockblock_app/features/home/presentation/home_section.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/shared/widgets/organisms/app_page_scaffold.dart';

/// Startseite der App.
class HomePage extends StatelessWidget {
  /// Erstellt die Seite.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppLocalizations.of(context)!.homeTitle,
      child: const HomeSection(),
    );
  }
}
