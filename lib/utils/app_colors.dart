import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales du drapeau ivoirien
  static const Color orange = Color(0xFFFF8C00);
  static const Color gold = Color(0xFFFFD700);
  static const Color green = Color(0xFF228B22);

  // Couleur principale de l'app
  static const Color primary = orange;
  static const Color secondary = gold;

  // Couleurs secondaires
  static const Color redOrange = Color(0xFFFF6B35);
  static const Color royalBlue = Color(0xFF4169E1);

  // Couleurs neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFF9E9E9E);

  // Couleurs de fond et texte
  static const Color background = lightGray;
  static const Color textPrimary = darkGray;
  static const Color textSecondary = mediumGray;

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradients ivoiriens
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [orange, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient flagGradient = LinearGradient(
    colors: [orange, white, green],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [redOrange, royalBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [lightGray, white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
