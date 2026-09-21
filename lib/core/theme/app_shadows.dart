import 'package:flutter/material.dart';
import 'package:tamanna/core/theme/app_colors.dart';

class AppShadows {
  static List<BoxShadow> get soft => const [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get hover => const [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
  ];

  static List<BoxShadow> get header => const [
    BoxShadow(
      color: AppColors.softShadow,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
