import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Premium Midnight Navy #00213D & Neon Lime #D3FF32)
  static const Color primary = Color(
    0xFF00213D,
  ); // Midnight Tech Navy (#00213D)
  static const Color primaryDark = Color(0xFF001426); // Deep Obsidian Navy
  static const Color primaryLight = Color(0xFF0A335C); // Deep Steel Navy
  static const Color primaryAccent = Color(
    0xFFD3FF32,
  ); // Neon Lime Accent (#D3FF32)
  static const Color primaryContainer = Color(
    0xFFE2EDF8,
  ); // Soft Navy Ice Container
  static const Color primarySurface = Color(
    0xFFF1F6FB,
  ); // Ultra Light Slate/Navy Tint
  static const Color brandNavy = Color(
    0xFF00213D,
  ); // Midnight Navy from logo 'm'
  static const Color brandNavyLight = Color(0xFF06335C); // Tech Navy Light

  // Brand Accent: Neon Lime (for badges, active pills, indicators & glow)
  static const Color accentLime = Color(
    0xFFD3FF32,
  ); // Electric Brand Lime (#D3FF32)
  static const Color accentLimeDark = Color(0xFFAEE61A); // Lime Active State
  static const Color accentLimeLight = Color(0xFFF5FFD1); // Soft Lime Tint
  static const Color accentLimeSurface = Color(0xFFFAFFE8); // Pale Lime Surface

  // Secondary Accent Colors (Cyan / Tech Blue)
  static const Color secondary = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFFE0F2FE);
  static const Color secondaryDark = Color(0xFF0369A1);
  static const Color secondaryAccent = Color(0xFF38BDF8);

  // Neutral Light Palette
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9); // Slate-100
  static const Color surfaceTertiary = Color(0xFFE2E8F0); // Slate-200
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Neutral Dark Palette (Obsidian / Slate-Navy High-Contrast)
  static const Color darkBackground = Color(0xFF0A0F1D); // Deep Modern Navy
  static const Color darkSurface = Color(
    0xFF111927,
  ); // Refined Dark Card Surface
  static const Color darkSurfaceSecondary = Color(
    0xFF1E293B,
  ); // Component & Tile Surface
  static const Color darkSurfaceTertiary = Color(
    0xFF283548,
  ); // Chip & Pill Surface
  static const Color darkCardBorder = Color(0xFF1E2D42); // Crisp Card Border
  static const Color darkDivider = Color(0xFF1E2D42);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF475569); // Slate-600
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary =
      Colors.white; // Crisp White text on Midnight Navy Primary

  // Functional / Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Accent Colors for Categories & Badges
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleLight = Color(0xFFEDE9FE);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberLight = Color(0xFFFEF3C7);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentIndigo = Color(0xFF6366F1);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF001426), Color(0xFF00213D), Color(0xFF003057)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHeroGradient = LinearGradient(
    colors: [Color(0xFF00192E), Color(0xFF00213D), Color(0xFF003057)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [Color(0xFF0F1A2E), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF001426), Color(0xFF00213D), Color(0xFF06335C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD3FF32), Color(0xFFAEE61A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
