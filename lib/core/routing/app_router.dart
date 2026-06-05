import 'package:go_router/go_router.dart';
import 'package:zockblock_app/features/auth/presentation/auth_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),
  ],
);