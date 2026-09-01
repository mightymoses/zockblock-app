import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/features/user_profile/presentation/profile_setup_viewmodel.dart';

/// Formular zum Anlegen des Nutzerprofils nach dem ersten Login.
class ProfileSetupScreen extends HookConsumerWidget {
  /// Erstellt den Screen.
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController();
    final formState = ref.watch(profileSetupViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
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
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'Bevor du loslegen kannst musst du ein Nutzerprofil '
                  'erstellen!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ComradeBold',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: usernameController,
                  onChanged: ref
                      .read(profileSetupViewModelProvider.notifier)
                      .updateUsername,
                  decoration: InputDecoration(
                    labelText: 'Nutzername',
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'ComradeBold',
                      fontSize: 16,
                    ),
                    errorText: formState.showErrors
                        ? formState.usernameError
                        : null,
                    errorStyle: const TextStyle(color: Colors.red),
                    filled: true,
                    fillColor: Colors.black,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.white, width: 4),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.red, width: 4),
                    ),
                  ),
                ),
                if (formState.submitError != null) ...[
                  Text(
                    formState.submitError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: ref
                      .read(profileSetupViewModelProvider.notifier)
                      .submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: formState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 4,
                          ),
                        )
                      : const Text(
                          'Erstellen',
                          style: TextStyle(
                            fontFamily: 'ComradeBold',
                            fontSize: 22,
                          ),
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
