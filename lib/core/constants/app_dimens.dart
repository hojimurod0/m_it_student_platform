import 'package:flutter/material.dart';

/// Design tokens for consistent spacing across the application.
class AppSpacing {
  AppSpacing._();

  /// 2.0 dp
  static const double xxs = 2.0;

  /// 4.0 dp
  static const double xs = 4.0;

  /// 8.0 dp
  static const double sm = 8.0;

  /// 12.0 dp
  static const double md = 12.0;

  /// 16.0 dp
  static const double lg = 16.0;

  /// 20.0 dp
  static const double xl = 20.0;

  /// 24.0 dp
  static const double xxl = 24.0;

  /// 32.0 dp
  static const double xxxl = 32.0;

  /// 48.0 dp
  static const double huge = 48.0;

  // EdgeInsets helpers
  static const EdgeInsets p4 = EdgeInsets.all(xs);
  static const EdgeInsets p8 = EdgeInsets.all(sm);
  static const EdgeInsets p12 = EdgeInsets.all(md);
  static const EdgeInsets p16 = EdgeInsets.all(lg);
  static const EdgeInsets p20 = EdgeInsets.all(xl);
  static const EdgeInsets p24 = EdgeInsets.all(xxl);

  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets h20 = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: xxl);

  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: lg);

  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(xl, md, xl, 100);
}

/// Design tokens for consistent border radii.
class AppRadius {
  AppRadius._();

  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  static final BorderRadius r8 = BorderRadius.circular(sm);
  static final BorderRadius r12 = BorderRadius.circular(md);
  static final BorderRadius r16 = BorderRadius.circular(lg);
  static final BorderRadius r20 = BorderRadius.circular(xl);
  static final BorderRadius r24 = BorderRadius.circular(xxl);
  static final BorderRadius rFull = BorderRadius.circular(full);

  static final BorderRadius topR28 = const BorderRadius.vertical(top: Radius.circular(28));
}
