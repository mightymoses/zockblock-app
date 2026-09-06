import 'package:zockblock_app/core/error/app_exception.dart';

/// Maximale Anzahl automatischer Wiederholungen pro Provider.
const _maxRetries = 4;

/// Wiederholungsstrategie für fehlgeschlagene Provider.
///
/// Riverpod wiederholt per Default *jeden* Fehler unbegrenzt. Das ist für
/// Netzwerkwackler richtig, für einen 401 oder 404 aber sinnlos – die heilen
/// nicht von selbst. Rückgabe `null` bedeutet "nicht mehr wiederholen".
Duration? appRetryPolicy(int retryCount, Object error) {
  if (error is UnauthorizedException || error is NotFoundException) {
    return null;
  }
  if (retryCount >= _maxRetries) {
    return null;
  }
  return Duration(milliseconds: 300 * (1 << retryCount));
}
