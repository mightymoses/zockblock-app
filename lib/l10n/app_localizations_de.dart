// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get signIn => 'ANmeLdeN';

  @override
  String get signOut => 'Abmelden';

  @override
  String get homeTitle => 'Home';

  @override
  String homeGreeting(String username) {
    return 'Herzlich Willkommen, $username!';
  }

  @override
  String get toUserProfile => 'Zum Nutzerprofil';

  @override
  String get profileSetupTitle => 'Willkommen';

  @override
  String get profileSetupIntro =>
      'Bevor du loslegen kannst, musst du ein Nutzerprofil erstellen!';

  @override
  String get profileSetupSubmitError =>
      'Profil konnte nicht angelegt werden. Bitte versuch es erneut.';

  @override
  String get usernameLabel => 'Nutzername';

  @override
  String get usernameErrorEmpty => 'Bitte gib einen Nutzernamen an.';

  @override
  String usernameErrorTooShort(int minLength) {
    return 'Der Nutzername muss mindestens $minLength Zeichen enthalten.';
  }

  @override
  String get create => 'Erstellen';

  @override
  String get userProfileTitle => 'Nutzerprofil';

  @override
  String authIdValue(String id) {
    return 'Auth Id:\n$id';
  }

  @override
  String userIdValue(String id) {
    return 'User Id:\n$id';
  }

  @override
  String usernameValue(String username) {
    return 'Nutzername:\n$username';
  }

  @override
  String get toHome => 'Zum Homescreen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get errorNetwork => 'Keine Verbindung. Prüf mal dein Internet.';

  @override
  String get errorServer =>
      'Server gerade nicht erreichbar. Probier es gleich nochmal.';

  @override
  String get errorUnauthorized => 'Du bist nicht mehr angemeldet.';

  @override
  String get errorUnknown => 'Da ist etwas schiefgelaufen.';

  @override
  String get errorSignInFailed => 'Anmeldung fehlgeschlagen.';

  @override
  String get errorSignOutFailed => 'Abmelden fehlgeschlagen.';

  @override
  String get consentTitle => 'Fehlerberichte';

  @override
  String get consentHeadline => 'Fehlerberichte senden?';

  @override
  String get consentBody =>
      'Wenn die App abstürzt, hilft uns ein automatischer Bericht dabei, den Fehler zu finden. Er enthält technische Daten zum Absturz und zu deinem Gerät, aber keine Inhalte deiner Spiele. Du kannst das jederzeit in den Einstellungen ändern.';

  @override
  String get consentAccept => 'Senden';

  @override
  String get consentDecline => 'Nicht senden';
}
