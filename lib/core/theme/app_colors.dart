import 'package:flutter/material.dart';

/// Palette terinspirasi dari Pawli Brand Identity:
/// Coral, Sage Green, Steel Blue, Forest Dark, Cream
class AppColors {
  AppColors._();

  // === PRIMARY: Coral / Salmon ===
  static const Color coral = Color(0xFFFD7F65);
  static const Color coralLight = Color(0xFFFFEDE9);
  static const Color coralMedium = Color(0xFFFFBFB3);
  static const Color coralDark = Color(0xFFD45A42);

  // === SECONDARY: Sage Green ===
  static const Color sage = Color(0xFF8FA87A);
  static const Color sageLight = Color(0xFFEDF2E8);
  static const Color sageMedium = Color(0xFFCAC597);
  static const Color sageDark = Color(0xFF3E4F2C);

  // === TERTIARY: Steel Blue ===
  static const Color blue = Color(0xFF6B87C7);
  static const Color blueLight = Color(0xFFE8EDF8);
  static const Color blueMedium = Color(0xFFA5B4E1);
  static const Color blueDark = Color(0xFF3A5299);

  // === ACCENT: Forest Dark ===
  static const Color forestDark = Color(0xFF3E4F2C);
  static const Color forestMedium = Color(0xFF5A6E40);
  static const Color forestLight = Color(0xFF8FA87A);

  // === SEMANTIC: Income / Expense / Transfer ===
  static const Color income = Color(0xFF4CAF81);       // Hijau sukses
  static const Color incomeLight = Color(0xFFE8F7F0);
  static const Color expense = Color(0xFFFF6B6B);      // Merah expense
  static const Color expenseLight = Color(0xFFFFEEEE);
  static const Color transfer = Color(0xFF6B87C7);     // Biru transfer
  static const Color transferLight = Color(0xFFE8EDF8);

  // === STATUS ===
  static const Color success = Color(0xFF4CAF81);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF6B87C7);

  // === NEUTRALS: Light Mode ===
  static const Color background = Color(0xFFFAF9F6);   // Cream off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F3EE);
  static const Color border = Color(0xFFE5E2DA);
  static const Color borderLight = Color(0xFFF0EDE5);

  // === TEXT ===
  static const Color textPrimary = Color(0xFF1E1E2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textTertiary = Color(0xFFADADB8);
  static const Color textHint = Color(0xFFC8C8D0);

  // === GRADIENTS ===
  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A7E), Color(0xFFFD7F65)],
  );

  static const LinearGradient sageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCAC597), Color(0xFF8FA87A)],
  );

  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5A6E40), Color(0xFF3E4F2C)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA5B4E1), Color(0xFF6B87C7)],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6DD5A8), Color(0xFF4CAF81)],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8E8E), Color(0xFFFF6B6B)],
  );

  // === NEUTRALS: Dark Mode ===
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1B1B2F);
  static const Color darkSurfaceVariant = Color(0xFF26263F);
  static const Color darkBorder = Color(0xFF33334E);
  static const Color darkBorderLight = Color(0xFF2A2A44);
  static const Color darkTextPrimary = Color(0xFFF3F3F8);
  static const Color darkTextSecondary = Color(0xFFA0A0B8);
  static const Color darkTextTertiary = Color(0xFF707088);

  // Helper: get color by transaction type
  static Color byType(String type) {
    switch (type) {
      case 'income': return income;
      case 'expense': return expense;
      case 'transfer': return transfer;
      default: return textSecondary;
    }
  }

  static Color lightByType(String type, {bool isDark = false}) {
    if (isDark) {
      switch (type) {
        case 'income': return const Color(0xFF163426);
        case 'expense': return const Color(0xFF3D1F24);
        case 'transfer': return const Color(0xFF1F2B45);
        default: return darkSurfaceVariant;
      }
    }
    switch (type) {
      case 'income': return incomeLight;
      case 'expense': return expenseLight;
      case 'transfer': return transferLight;
      default: return surfaceVariant;
    }
  }

  static LinearGradient gradientByType(String type) {
    switch (type) {
      case 'income': return incomeGradient;
      case 'expense': return expenseGradient;
      case 'transfer': return blueGradient;
      default: return coralGradient;
    }
  }
}
