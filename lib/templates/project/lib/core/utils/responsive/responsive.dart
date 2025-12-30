import 'package:flutter/material.dart';

// ==========================================
// 1. CORE RESPONSIVE UTILITIES
// ==========================================

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  // Design Reference Dimensions (e.g., from Figma)
  // Standard iPhone size used by most designers
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    // Grid blocks for calculation
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  // Get device type based on width
  static DeviceType get deviceType {
    if (screenWidth >= 1100) return DeviceType.desktop;
    if (screenWidth >= 600) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  bool get isMobile => SizeConfig.deviceType == DeviceType.mobile;
  bool get isTablet => SizeConfig.deviceType == DeviceType.tablet;
  bool get isDesktop => SizeConfig.deviceType == DeviceType.desktop;

  //
}

enum DeviceType { mobile, tablet, desktop }

// ==========================================
// 2. EXTENSION METHODS (The Magic Helper)
// ==========================================

extension ResponsiveExtension on num {
  /// Calculates width based on design reference.
  /// Usage: 20.w (Where 20 is the pixel width in Figma)
  double get w {
    double scale = SizeConfig.screenWidth / SizeConfig.designWidth;
    // We limit scaling on desktop to prevent elements looking cartoonishly large
    if (SizeConfig.deviceType == DeviceType.desktop) {
      scale = scale * 0.6; // Scale down slightly on massive screens
    } else if (SizeConfig.deviceType == DeviceType.tablet) {
      scale = scale * 0.8;
    }
    return this * scale;
  }

  /// Calculates height based on design reference.
  /// Usage: 50.h
  double get h {
    double scale = SizeConfig.screenHeight / SizeConfig.designHeight;
    return this * scale;
  }

  /// Calculates responsive font size (Scalable Pixels).
  /// Usage: 16.sp
  double get sp {
    // Determine the scale factor based on width (usually text scales with width)
    double scale = SizeConfig.screenWidth / SizeConfig.designWidth;

    // Adjust scale for larger devices to keep text readable but not huge
    if (SizeConfig.deviceType == DeviceType.tablet) scale *= 0.5;
    if (SizeConfig.deviceType == DeviceType.desktop) scale *= 0.6;

    return this * scale;
  }

  /// sw: screen width percentage
  double get sw => SizeConfig.screenWidth * (this / 100);

  /// sh: screen height percentage
  double get sh => SizeConfig.screenHeight * (this / 100);

  /// Use for percentage of screen width
  /// Usage: 50.pw (50% of screen width)
  double get pw => SizeConfig.screenWidth * (this / 100);

  /// Use for percentage of screen height
  /// Usage: 20.ph (20% of screen height)
  double get ph => SizeConfig.screenHeight * (this / 100);

  // r // radius
  double get r {
    double scale = SizeConfig.screenWidth / SizeConfig.designWidth;
    return this * scale;
  }
}

// ==========================================
// 3. RESPONSIVE LAYOUT BUILDER
// ==========================================

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
