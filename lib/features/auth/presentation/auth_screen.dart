import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
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

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _animation;
  final _random = Random();
  late AuthMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = AuthMode.values[_random.nextInt(AuthMode.values.length)];
    print('Initial mode: $_mode');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _startLoop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animation.dispose();
    super.dispose();
  }

  Future<void> _startLoop() async {
    await Future.delayed(const Duration(milliseconds: 500));
    while (mounted) {
      await _controller.forward(from: 0);
      setState(() => _mode = AuthMode.values[_random.nextInt(AuthMode.values.length)]);
    }
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
    final firstLargeRowIndex = totalRows ~/ 2 - 1;

    final randomDirection = _random.nextInt(2);
    final stopSmallRows = _random.nextBool();

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
                    final isZock = ((rowIndex % 2 == 0) == (firstLargeRowIndex % 2 == 0)) == (rowIndex <= middleOfBottom);
                    final direction = (rowIndex % 2 == randomDirection) == (rowIndex <= middleOfBottom);
                    final isFirstLargeRow = rowIndex == firstLargeRowIndex;
                    final isSecondLargeRow = rowIndex == firstLargeRowIndex + 1;
                    final isLargeRow = isFirstLargeRow || isSecondLargeRow;

                    return Stack(
                      children: [
                        rowIndex == middleOfBottom 
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
                                        AppLocalizations.of(context)!.signIn,
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
                                asset: isZock
                                    ? 'assets/graphics/zock.svg'
                                    : 'assets/graphics/block.svg',
                                marqueAnimation: _animation,
                                reverse: direction,
                                color: color,
                                height: isLargeRow ? largeHeight : smallHeight,
                                speedMultiplier: (_mode != AuthMode.running && isLargeRow) || (stopSmallRows && !isLargeRow) ? 0 : (isLargeRow ? _random.nextInt(2) + 1 : _random.nextInt(3) + 2),
                              ),
                        if (_mode == AuthMode.spinning && isLargeRow) 
                          Row (
                            children: [
                              SpinningCircle(
                                spinAnimation: _animation,
                                size: largeHeight,
                                isDark: isDark,
                                assetName: isFirstLargeRow ? 'Zock-Links' : 'Block-Links',
                                speedMultiplier: _random.nextInt(4) + 1,
                                reverse: _random.nextBool(),
                              ),
                              SpinningCircle(
                                spinAnimation: _animation,
                                size: largeHeight,
                                isDark: isDark,
                                assetName: isFirstLargeRow ? 'Zock-Rechts' : 'Block-Rechts',
                                speedMultiplier: _random.nextInt(4) + 1,
                                reverse: _random.nextBool(),
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