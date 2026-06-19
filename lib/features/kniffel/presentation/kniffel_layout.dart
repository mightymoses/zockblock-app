// features/kniffel/presentation/kniffel_layout.dart
import 'dart:math';

import 'package:zockblock_app/core/theme/app_dimensions.dart';

abstract final class KniffelLayout {
  static const double chipWidth = 48;
  static const double chipHeight = 32;
  static const double avatarRadius = 20;
  static final double columnContentWidth = max(chipWidth, avatarRadius * 2);
  static const double columnPadding = AppSpacing.sm;
  static const double columnWidth = chipWidth + columnPadding * 2;
  static const double cardMargin = AppSpacing.lg;
  static const double labelPadding = AppSpacing.md;
  static const double verticalPadding = AppSpacing.sm;
  static const double rowHeight = chipHeight + verticalPadding * 2;
  static const double totalsRowHeight = 24;
  static const double titleRowHeight = avatarRadius * 2 + AppSpacing.md * 2;
  static const double chipRadius = AppRadius.sm;
}