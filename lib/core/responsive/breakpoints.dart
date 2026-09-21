import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1280;
  static const double wide = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static int gridCount(BuildContext context, {int max = 5}) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1600) return max;
    if (w >= 1200) return max < 4 ? max : 4;
    if (w >= 900) return max < 3 ? max : 3;
    if (w >= 600) return 2;
    return 1;
  }
}
