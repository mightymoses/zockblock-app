import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/routing/app_router.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/features/auth/data/auth_session_provider.dart';
import 'package:zockblock_app/features/user_profile/data/user_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Nuzterprofil',
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
                Consumer(
                  builder: (context, ref, _) {
                    final asyncAuthSession = ref.watch(authSessionProvider);

                    return asyncAuthSession.maybeWhen(
                      data: (authSession) {
                        if (authSession != null) {
                          return Text(
                            'Auth Id:\n${authSession.externalAuthId}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ComradeBold',
                              fontSize: 16,
                            ),
                          );
                        }
                        return Container();
                      },
                      orElse: () => Container(),
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final asyncUser = ref.watch(userProvider);

                    return asyncUser.maybeWhen(
                      data: (user) {
                        if (user != null) {
                          return Column(
                            children: [
                              SizedBox(height: AppSpacing.lg),
                              Text(
                                'User Id:\n${user.id}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'ComradeBold',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: AppSpacing.lg),
                              Text(
                                'Nutzername:\n${user.username}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'ComradeBold',
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        }
                        return Container();
                      },
                      orElse: () => Container(),
                    );
                  },
                ),
                Spacer(flex: 1),
                FilledButton(
                  onPressed: () =>
                      ref.read(authSessionProvider.notifier).logout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'Abmelden',
                    style: TextStyle(fontFamily: 'ComradeBold', fontSize: 22),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () => router.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'Zum Homescreen',
                    style: TextStyle(fontFamily: 'ComradeBold', fontSize: 22),
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
