import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:zockblock_app/features/auth/presentation/auth_screen.dart';

GoRouter createRouter(String initialRoute) {
  return GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home', 
        builder: (context, state) => const SizedBox()
        ), // TODO: Replace with actual home screen
    ],
  );
}