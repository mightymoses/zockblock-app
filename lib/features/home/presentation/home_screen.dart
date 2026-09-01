import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/routing/app_router.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/features/user_profile/data/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Home',
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(flex: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final asyncUser = ref.watch(userProvider);

                    return asyncUser.maybeWhen(
                      data: (user) {
                        if (user != null) {
                          return Text(
                            'Herzlich Willkommen, ${user.username}!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ComradeBold',
                              fontSize: 28,
                            ),
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
                  onPressed: () => router.go('/user-profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'Zum Nutzerprofil',
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
