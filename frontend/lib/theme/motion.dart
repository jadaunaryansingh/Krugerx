import 'package:flutter/animation.dart';

class KrugerMotion {
  static const fast = Duration(milliseconds: 80);   // hover states
  static const base = Duration(milliseconds: 120);  // menu slide-in, tab open/close
  static const slow = Duration(milliseconds: 200);  // sidebar toggle
  static const curve = Curves.easeOutCubic;
}
