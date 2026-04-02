import 'package:flutter/material.dart';

/// WCAG compliance utilities for accessibility
class AccessibilityUtils {
  // Minimum touch target size (48dp as per Material Design)
  static const double minTouchTarget = 48.0;

  /// Create an accessible button with semantic labels
  static Widget accessibleButton({
    required VoidCallback onPressed,
    required String label,
    required Widget child,
    String? tooltip,
  }) {
    return Semantics(
      button: true,
      enabled: true,
      onTap: onPressed,
      label: label,
      child: Tooltip(
        message: tooltip ?? label,
        child: GestureDetector(
          onTap: onPressed,
          child: Semantics(
            label: label,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Create accessible text with semantic label
  static Widget accessibleText(
    String text, {
    required TextStyle style,
    String? semanticLabel,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  /// Create accessible card with semantic container
  static Widget accessibleCard({
    required Widget child,
    required String label,
    VoidCallback? onTap,
  }) {
    return Semantics(
      container: true,
      label: label,
      button: onTap != null,
      onTap: onTap,
      child: Card(
        child: child,
      ),
    );
  }

  /// Check color contrast ratio (WCAG AA standard: 4.5:1 for normal text)
  static bool hasGoodContrast(Color foreground, Color background) {
    final fgLuminance = _getLuminance(foreground);
    final bgLuminance = _getLuminance(background);
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    final contrast = (lighter + 0.05) / (darker + 0.05);
    return contrast >= 4.5;
  }

  /// Calculate relative luminance for contrast checking
  static double _getLuminance(Color color) {
    final r = _linearize(color.red / 255);
    final g = _linearize(color.green / 255);
    final b = _linearize(color.blue / 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    }
    return ((value + 0.055) / 1.055) * ((value + 0.055) / 1.055);
  }

  /// Ensure minimum touch target size
  static Widget ensureMinTouchTarget({
    required Widget child,
    double minSize = minTouchTarget,
  }) {
    return Semantics(
      enabled: true,
      child: SizedBox(
        width: minSize,
        height: minSize,
        child: Center(child: child),
      ),
    );
  }
}
