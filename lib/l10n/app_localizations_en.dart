// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signIn => 'LOGIN';

  @override
  String get signOut => 'Sign out';

  @override
  String get homeTitle => 'Home';

  @override
  String homeGreeting(String username) {
    return 'Welcome, $username!';
  }

  @override
  String get toUserProfile => 'To user profile';

  @override
  String get profileSetupTitle => 'Welcome';

  @override
  String get profileSetupIntro =>
      'Before you can get started, you need to create a user profile!';

  @override
  String get profileSetupSubmitError =>
      'Could not create the profile. Please try again.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameErrorEmpty => 'Please enter a username.';

  @override
  String usernameErrorTooShort(int minLength) {
    return 'The username must contain at least $minLength characters.';
  }

  @override
  String get create => 'Create';

  @override
  String get userProfileTitle => 'User profile';

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
    return 'Username:\n$username';
  }

  @override
  String get toHome => 'To home screen';

  @override
  String get retry => 'Try again';

  @override
  String get errorNetwork => 'No connection. Check your internet.';

  @override
  String get errorServer =>
      'Server is unavailable right now. Try again in a moment.';

  @override
  String get errorUnauthorized => 'You are no longer signed in.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get errorSignInFailed => 'Sign-in failed.';

  @override
  String get errorSignOutFailed => 'Sign-out failed.';

  @override
  String get consentTitle => 'Crash reports';

  @override
  String get consentHeadline => 'Send crash reports?';

  @override
  String get consentBody =>
      'If the app crashes, an automatic report helps us track down the problem. It contains technical details about the crash and your device, but nothing from your games. You can change this any time in your user profile.';

  @override
  String get consentAccept => 'Send';

  @override
  String get consentDecline => 'Don\'t send';

  @override
  String get consentToggleLabel => 'Send crash reports';
}
