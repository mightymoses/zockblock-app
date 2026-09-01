import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/user_profile/data/user.dart';
import 'package:zockblock_app/features/user_profile/data/user_provider.dart';

final NotifierProvider<ProfileSetupViewModel, ProfileSetup>
profileSetupViewModelProvider =
    NotifierProvider.autoDispose<ProfileSetupViewModel, ProfileSetup>(() {
      return ProfileSetupViewModel();
    });

class ProfileSetupViewModel extends Notifier<ProfileSetup> {
  @override
  ProfileSetup build() {
    return ProfileSetup();
  }

  void updateUsername(String value) {
    state = state.copyWith(username: value, showErrors: false);
  }

  Future<bool> submitForm() async {
    final error = _validate(state.username);
    if (error != null) {
      state = state.copyWith(usernameError: error, showErrors: true);
      return false;
    }

    state = state.copyWith(isLoading: true);
    await ref
        .read(userProvider.notifier)
        .createUser(User(username: state.username));
    state = state.copyWith(isLoading: false);

    return true;
  }

  String? _validate(String value) {
    if (value.trim().isEmpty) {
      return 'Bitte gib einen Nutzernamen an.';
    }
    if (value.trim().length < 3) {
      return 'Der Nutzername muss mindestens 3 Zeichen enthalten.';
    }
    return null;
  }
}

class ProfileSetup {
  ProfileSetup({
    this.username = '',
    this.usernameError,
    this.showErrors = false,
    this.isLoading = false,
  });
  final String username;
  final String? usernameError;
  final bool showErrors;
  final bool isLoading;

  ProfileSetup copyWith({
    String? username,
    String? usernameError,
    bool? showErrors,
    bool? isLoading,
  }) {
    return ProfileSetup(
      username: username ?? this.username,
      usernameError: usernameError,
      showErrors: showErrors ?? this.showErrors,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
