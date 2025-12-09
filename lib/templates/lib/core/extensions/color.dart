import 'dart:ui';

extension ColorOpacityX on Color {
  /// opacityPercent: 0–100
  Color withOpacityPercent(double opacityPercent) {
    final value = (opacityPercent / 100).clamp(0, 1);

    // withValues() expects a DOUBLE alpha (0–255)
    return withValues(alpha: (255 * value).toDouble());
  }
}
