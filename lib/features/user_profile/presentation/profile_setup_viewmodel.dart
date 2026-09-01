import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/user_profile/data/user.dart';
import 'package:zockblock_app/features/user_profile/data/user_provider.dart';
import 'package:zockblock_app/features/user_profile/domain/username.dart';

/// Formular-Zustand der Profil-Anlegen-Seite.
final NotifierProvider<ProfileSetupViewModel, ProfileSetup>
profileSetupViewModelProvider =
    NotifierProvider.autoDispose<ProfileSetupViewModel, ProfileSetup>(() {
      return ProfileSetupViewModel();
    });

/// Steuert das Profil-Anlegen-Formular: Validierung + Submit.
class ProfileSetupViewModel extends Notifier<ProfileSetup> {
  @override
  ProfileSetup build() {
    return ProfileSetup();
  }

  /// Wird bei jeder Eingabe im Nutzername-Feld aufgerufen.
  void updateUsername(String value) {
    state = state.copyWith(username: value, showErrors: false);
  }

  /// Validiert und legt bei Erfolg das Profil an. Gibt `true` bei Erfolg
  /// zurück, `false` bei Validierungs- oder Server-Fehler (siehe
  /// [ProfileSetup.usernameError]/[ProfileSetup.hasSubmitError]).
  Future<bool> submitForm() async {
    final error = Username.validate(state.username);
    if (error != null) {
      state = state.copyWith(usernameError: error, showErrors: true);
      return false;
    }

    state = state.copyWith(isLoading: true);
    await ref
        .read(userProvider.notifier)
        .createUser(User(username: state.username));

    final hasError = ref.read(userProvider).hasError;
    state = state.copyWith(isLoading: false, hasSubmitError: hasError);

    return !hasError;
  }
}

/// UI-Zustand des Profil-Anlegen-Formulars.
///
/// Hält bewusst nur Fehler*typen*, keine fertigen Texte: Notifier haben keinen
/// `BuildContext` und kommen damit nicht an `AppLocalizations`. Die Übersetzung
/// passiert in der Section.
class ProfileSetup {
  /// Anfangszustand: leeres Formular, kein Fehler, nicht ladend.
  ProfileSetup({
    this.username = '',
    this.usernameError,
    this.showErrors = false,
    this.isLoading = false,
    this.hasSubmitError = false,
  });

  /// Aktuell eingegebener Nutzername.
  final String username;

  /// Validierungsfehler zu [username], nur sichtbar wenn [showErrors].
  final UsernameValidationError? usernameError;

  /// Ob [usernameError] angezeigt werden soll (erst nach einem Submit-Versuch).
  final bool showErrors;

  /// Ob gerade ein `createUser`-Request läuft.
  final bool isLoading;

  /// Ob das Anlegen des Profils zuletzt fehlgeschlagen ist.
  final bool hasSubmitError;

  /// Erstellt eine Kopie mit einzelnen geänderten Feldern. [usernameError] und
  /// [hasSubmitError] werden bei jedem Aufruf zurückgesetzt, wenn sie nicht
  /// explizit übergeben werden – ein alter Fehler soll nie stehen bleiben.
  ProfileSetup copyWith({
    String? username,
    UsernameValidationError? usernameError,
    bool? showErrors,
    bool? isLoading,
    bool? hasSubmitError,
  }) {
    return ProfileSetup(
      username: username ?? this.username,
      usernameError: usernameError,
      showErrors: showErrors ?? this.showErrors,
      isLoading: isLoading ?? this.isLoading,
      hasSubmitError: hasSubmitError ?? false,
    );
  }
}
