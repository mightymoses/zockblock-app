import 'package:flutter/material.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';

/// Grundgerüst der Inhaltsseiten: AppBar mit [title] und der Hintergrundgrafik
/// der App, in die [child] mittig eingebettet wird.
class AppPageScaffold extends StatelessWidget {
  /// Erstellt das Seitengerüst.
  const AppPageScaffold({required this.title, required this.child, super.key});

  /// Text in der AppBar.
  final String title;

  /// Inhalt der Seite, üblicherweise eine Section aus `features/`.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'ComradeBold',
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/zockblock-background-dark.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(child: child),
        ),
      ),
    );
  }
}
