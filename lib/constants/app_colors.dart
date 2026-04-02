import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF4ECDC4); // Teal
  static const Color primaryDark = Color(0xFF2A9D8F); // Dark Teal
  static const Color primaryLight = Color(0xFFB8E6E3); // Light Teal
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B6B); // Coral Red
  static const Color secondaryDark = Color(0xFFE63946); // Dark Red
  static const Color secondaryLight = Color(0xFFFFB3B3); // Light Red
  
  // Accent Colors
  static const Color accent = Color(0xFFFFD93D); // Golden Yellow
  static const Color accentDark = Color(0xFFFFC300); // Dark Yellow
  
  // Dark Theme
  static const Color darkBg = Color(0xFF0F0F0F); // Almost black
  static const Color darkCard = Color(0xFF1A1A1A); // Dark card
  static const Color darkCardAlt = Color(0xFF252525); // Alternative dark card
  
  // Light Theme
  static const Color lightBg = Color(0xFFFAFAFA); // Off white
  static const Color lightCard = Color(0xFFFFFFFF); // White
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White text
  static const Color textSecondary = Color(0xFFB0B0B0); // Gray text
  static const Color textTertiary = Color(0xFF808080); // Darker gray
  
  // Background & Surface
  static const Color background = darkBg;
  static const Color surface = darkCard;
  static const Color surfaceAlt = darkCardAlt;
  
  // Divider & Borders
  static const Color divider = Color(0xFF333333);
  static const Color border = Color(0xFF404040);
  
  // Status Colors
  static const Color success = Color(0xFF2ECC71); // Green
  static const Color warning = Color(0xFFF39C12); // Orange
  static const Color error = Color(0xFFE74C3C); // Red
  static const Color info = Color(0xFF3498DB); // Blue
  
  // Gradient Colors
  static const Color streakStart = Color(0xFFFF6B6B);
  static const Color streakEnd = Color(0xFFFF8E53);
  static const Color completedStart = Color(0xFF4ECDC4);
  static const Color completedEnd = Color(0xFF2A9D8F);
  static const Color progressStart = Color(0xFFFFD93D);
  static const Color progressEnd = Color(0xFFFFC300);
  
  // Overlay & Transparency
  static const Color overlay = Color(0x00000000); // Transparent
  static final Color overlayDark = Colors.black.withOpacity(0.5);
  static final Color overlayLight = Colors.white.withOpacity(0.1);
}
