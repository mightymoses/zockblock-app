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
  /// [ProfileSetup.usernameError]/[ProfileSetup.submitError]).
  Future<bool> submitForm() async {
    final error = Username.validate(state.username);
    if (error != null) {
      state = state.copyWith(
        usernameError: _usernameErrorMessage(error),
        showErrors: true,
      );
      return false;
    }

    state = state.copyWith(isLoading: true);
    await ref
        .read(userProvider.notifier)
        .createUser(User(username: state.username));

    final hasError = ref.read(userProvider).hasError;
    state = state.copyWith(
      isLoading: false,
      submitError: hasError
          ? 'Profil konnte nicht angelegt werden. Bitte versuch es erneut.'
          : null,
    );

    return !hasError;
  }

  /// Übersetzt einen [UsernameValidationError] in einen Anzeigetext.
  // TODO(mightymoses): Auf AppLocalizations umstellen (Checklisten-Punkt E).
  String _usernameErrorMessage(UsernameValidationError error) {
    return switch (error) {
      UsernameValidationError.empty => 'Bitte gib einen Nutzernamen an.',
      UsernameValidationError.tooShort =>
        'Der Nutzername muss mindestens ${Username.minLength} Zeichen '
            'enthalten.',
    };
  }
}

/// UI-Zustand des Profil-Anlegen-Formulars.
class ProfileSetup {
  /// Anfangszustand: leeres Formular, kein Fehler, nicht ladend.
  ProfileSetup({
    this.username = '',
    this.usernameError,
    this.showErrors = false,
    this.isLoading = false,
    this.submitError,
  });

  /// Aktuell eingegebener Nutzername.
  final String username;

  /// Validierungsfehler zu [username], nur sichtbar wenn [showErrors].
  final String? usernameError;

  /// Ob [usernameError] angezeigt werden soll (erst nach einem Submit-Versuch).
  final bool showErrors;

  /// Ob gerade ein `createUser`-Request läuft.
  final bool isLoading;

  /// Fehlermeldung, wenn das Anlegen des Profils fehlgeschlagen ist.
  final String? submitError;

  /// Erstellt eine Kopie mit einzelnen geänderten Feldern. Wie
  /// `usernameError` wird auch `submitError` bei jedem Aufruf überschrieben
  /// (Default `null`), nicht nur wenn explizit gesetzt.
  ProfileSetup copyWith({
    String? username,
    String? usernameError,
    bool? showErrors,
    bool? isLoading,
    String? submitError,
  }) {
    return ProfileSetup(
      username: username ?? this.username,
      usernameError: usernameError,
      showErrors: showErrors ?? this.showErrors,
      isLoading: isLoading ?? this.isLoading,
      submitError: submitError,
    );
  }
}
