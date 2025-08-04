import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ScreenFormFactor { desktop, tablet, phone }

class UiUtil {
  static const double desktop = 900;
  static const double tablet = 600;

  static bool get isMobileDevice =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  static bool get isDesktopDevice =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  static bool get isMobileDeviceOrWeb => kIsWeb || isMobileDevice;
  static bool get isDesktopDeviceOrWeb => kIsWeb || isDesktopDevice;
  static bool get isFormFactorDesktop => screenWidth >= desktop;
  static bool get isFormFactorPhone => screenWidth < tablet;
  static bool get isFormFactorTablet => screenWidth >= tablet;
  static bool get isFormFactorSmall => screenHeight <= 600;

  static ScreenFormFactor get formFactor {
    if (screenWidth >= tablet) return ScreenFormFactor.tablet;
    if (screenWidth < tablet) return ScreenFormFactor.phone;
    return ScreenFormFactor.phone;
  }

  static Size get screenSize {
    final double pixelRatio = _singleView.devicePixelRatio;
    final Size logicalScreenSize = _singleView.physicalSize / pixelRatio;
    return logicalScreenSize;
  }

  static double get screenWidth {
    return screenSize.width;
  }

  static double get screenHeight {
    return screenSize.height;
  }

  static double get screenLargerSide {
    return max(screenSize.width, screenSize.height);
  }

  static double get screenShorterSide {
    return min(screenSize.width, screenSize.height);
  }

  static EdgeInsets get windowPadding {
    return MediaQueryData.fromView(_singleView).padding;
  }

  static EdgeInsets get windowViewPadding {
    return MediaQueryData.fromView(_singleView).viewPadding;
  }

  static EdgeInsets get windowViewInsets {
    return MediaQueryData.fromView(_singleView).viewInsets;
  }

  static FlutterView get _singleView =>
      WidgetsBinding.instance.platformDispatcher.views.single;
}

extension ColorExt on Color {
  ColorFilter get filter => ColorFilter.mode(this, BlendMode.srcIn);
}
