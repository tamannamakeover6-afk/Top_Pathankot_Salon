import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 22;
  static const double xl = 32;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get chip => BorderRadius.circular(pill);
  static BorderRadius get input => BorderRadius.circular(md);
}
