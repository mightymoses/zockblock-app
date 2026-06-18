import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';
import 'package:zockblock_app/features/auth/data/auth_repository_impl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Home Screen',
              style: TextStyle(fontFamily: 'ComradeBold', fontSize: 32),
            ),
            SizedBox(height: AppSpacing.huge),
            FilledButton(
              onPressed: () => context.push('/kniffel-test'),
              child: const Text('Kniffel-Screen (Test)'),
            ), 
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).logout(),
              style: TextButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3.0,
                ),
              ),
              child: Text(
                'ABmeLdeN',
                style: TextStyle(fontFamily: 'ComradeBold'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
