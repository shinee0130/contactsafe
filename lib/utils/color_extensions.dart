import 'dart:ui';

extension ColorWithValues on Color {
  /// Returns a copy of this color with the given channel values replaced.
  /// Values should be in the range 0-255.
  Color withValues({int? alpha, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }

  /// Convenience method to set opacity as a double without precision loss.
  Color withOpacityValue(double opacity) {
    return withValues(alpha: (opacity * 255).round());
  }
}
