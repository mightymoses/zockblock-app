import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_background.dart';
import 'auth_viewmodel.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _startLoop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startLoop() async {
    await Future.delayed(const Duration(milliseconds: 500));
    while (mounted) {
      await _controller.forward(from: 0);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          AuthBackground(controller: _controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authViewModelProvider);
                  return authState.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => ref.read(authViewModelProvider.notifier).login(),
                          child: Text(
                            'ANmeLdeN',
                            style: TextStyle(fontFamily: 'ComradeBold'),
                          ),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}