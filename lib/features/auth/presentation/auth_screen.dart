import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'auth_mode.dart';
import 'auth_viewmodel.dart';
import 'dart:math';
import 'marquee_row.dart';
import 'spinning_circle.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _marqueeController;
  late AnimationController _spinController;
  late CurvedAnimation _spinAnimation;
  late CurvedAnimation _marqueeAnimation;
  AuthMode _mode = AuthMode.running;

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeInOut,
    );
    _marqueeAnimation = CurvedAnimation(
      parent: _marqueeController,
      curve: Curves.easeInOut,
    );
    _startLoop();
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    _spinController.dispose();
    _spinAnimation.dispose();
    _marqueeAnimation.dispose();
    super.dispose();
  }

  Future<void> _startLoop() async {
    await Future.delayed(const Duration(milliseconds: 500));
    while (mounted) {
      if (_checkAuthAndTransition()) break;

      setState(() => _mode = AuthMode.running);
      await _marqueeController.forward(from: 0);
      if (!mounted) break;

      if (_checkAuthAndTransition()) break;

      setState(() => _mode = AuthMode.spinning);
      await _spinController.forward(from: 0);

      if (!mounted) break;

      if (_checkAuthAndTransition()) break;
    }

    while (mounted) {
      await _marqueeController.forward(from: 0);
    }
  }

  bool _checkAuthAndTransition() {
    final authState = ref.read(authViewModelProvider);
    if (!authState.isLoading) {
      setState(() => _mode = AuthMode.done);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : Colors.black;

    final smallHeight = screenWidth / 8.6; // 4 SVGs nebeneinander mit dazwischen jeweils 0.2 * height Abstand
    final largeHeight = screenWidth / 2; // 1 SVG (Da Seitenverhältnisse der SVGs genau 1:2 sind)
    final heightAfterLarge = screenHeight - (largeHeight * 2);
    final smallRowCount = ((heightAfterLarge / smallHeight).floor() ~/ 2) * 2;
    final totalRows = smallRowCount + 2;

    final halfSmall = smallRowCount ~/ 2;
    final middleOfBottom = halfSmall + 2 + (halfSmall ~/ 2);

    final random = Random();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ClipRect(
      child: SizedBox.expand(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(totalRows, (rowIndex) {
                    final isEven = rowIndex % 2 == 0;
                    final isFirstLargeRow = rowIndex == totalRows ~/ 2 - 1;
                    final isSecondLargeRow = rowIndex == totalRows ~/ 2;
                    final isLargeRow = isFirstLargeRow || isSecondLargeRow;

                    return Stack(
                      children: [
                        _mode == AuthMode.done && rowIndex == middleOfBottom 
                            ? SizedBox(
                                height: smallHeight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: SvgPicture.asset(
                                          'assets/graphics/Pfeil-Links.svg',
                                          height: smallHeight,
                                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                                        )
                                      )
                                    ),
                                    TextButton(
                                      onPressed: () => ref.read(authViewModelProvider.notifier).login(),
                                      child: Text(
                                        'ANmeLdeN',
                                        style: TextStyle(fontFamily: 'ComradeBold'),
                                      ),
                                    ),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: SvgPicture.asset(
                                          'assets/graphics/Pfeil-Rechts.svg',
                                          height: smallHeight,
                                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                                        )
                                      )
                                    ),
                                  ],
                                ),
                              )
                            : MarqueeRow(
                                asset: isEven && !isSecondLargeRow || isFirstLargeRow
                                    ? 'assets/graphics/zock.svg'
                                    : 'assets/graphics/block.svg',
                                marqueAnimation: _marqueeAnimation,
                                reverse: !isEven,
                                color: color,
                                height: isLargeRow ? largeHeight : smallHeight,
                                speedMultiplier: _mode == AuthMode.done && isLargeRow ? 0 : (isLargeRow ? random.nextInt(2) + 1 : random.nextInt(3) + 3),
                              ),
                        if (_mode == AuthMode.spinning && isLargeRow) 
                          Row (
                            children: [
                              SpinningCircle(
                                spinAnimation: _spinAnimation,
                                size: largeHeight,
                                isDark: isDark,
                                assetName: isFirstLargeRow ? 'Zock-Links' : 'Block-Links',
                                speedMultiplier: random.nextInt(3) + 1,
                                reverse: random.nextBool(),
                              ),
                              SpinningCircle(
                                spinAnimation: _spinAnimation,
                                size: largeHeight,
                                isDark: isDark,
                                assetName: isFirstLargeRow ? 'Zock-Rechts' : 'Block-Rechts',
                                speedMultiplier: random.nextInt(3) + 1,
                                reverse: random.nextBool(),
                              ),
                            ],
                          )
                      ]
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}