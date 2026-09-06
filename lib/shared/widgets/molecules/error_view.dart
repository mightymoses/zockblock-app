import 'package:flutter/material.dart';
import 'package:zockblock_app/core/error/app_exception.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';

/// Übersetzt einen Fehler in einen Text, den man einem Nutzer zeigen kann.
///
/// Alles, was keine [AppException] ist, landet bewusst im generischen Fall –
/// Fehlertexte aus Libraries sind für Nutzer unbrauchbar.
String appErrorMessage(AppLocalizations l10n, Object error) {
  return switch (error) {
    NetworkException() => l10n.errorNetwork,
    ServerException() => l10n.errorServer,
    UnauthorizedException() => l10n.errorUnauthorized,
    _ => l10n.errorUnknown,
  };
}

/// Zeigt einen fehlgeschlagenen Ladevorgang an, optional mit Wiederholen.
class ErrorView extends StatelessWidget {
  /// Erstellt die Fehleranzeige für [error].
  const ErrorView({
    required this.error,
    super.key,
    this.onRetry,
  });

  /// Der aufgetretene Fehler.
  final Object error;

  /// Wird vom Wiederholen-Button aufgerufen; ohne ihn entfällt der Button.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          appErrorMessage(l10n, error),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'ComradeBold',
            fontSize: 16,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(
            height: AppSpacing.lg,
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              l10n.retry,
              style: const TextStyle(
                fontFamily: 'ComradeBold',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
