import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/features/user_profile/presentation/profile_setup_viewmodel.dart';

class ProfileSetupScreen extends HookConsumerWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController();
    final formState = ref.watch(profileSetupViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Willkommen',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'ComradeBold',
              fontSize: 22,
            ),
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
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 1),
                Text(
                  'Bevor du loslegen kannst musst du ein Nutzerprofil erstellen!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ComradeBold',
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: usernameController,
                  onChanged: ref
                      .read(profileSetupViewModelProvider.notifier)
                      .updateUsername,
                  decoration: InputDecoration(
                    labelText: 'Nutzername',
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'ComradeBold',
                      fontSize: 16,
                    ),
                    errorText: formState.showErrors
                        ? formState.usernameError
                        : null,
                    errorStyle: TextStyle(color: Colors.red),
                    filled: true,
                    fillColor: Colors.black,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.white, width: 4),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.red, width: 4),
                    ),
                  ),
                ),
                Spacer(flex: 1),
                FilledButton(
                  onPressed: ref
                      .read(profileSetupViewModelProvider.notifier)
                      .submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: formState.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 4,
                          ),
                        )
                      : Text(
                          'Erstellen',
                          style: TextStyle(
                            fontFamily: 'ComradeBold',
                            fontSize: 22,
                          ),
                        ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
