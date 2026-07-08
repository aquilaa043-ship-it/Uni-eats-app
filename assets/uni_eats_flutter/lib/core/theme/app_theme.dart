import 'package:flutter/material.dart';

/// ====================================================================
/// TEMA LUXUOSO E ELITIZADO "DARK PREMIUM" (MATERIAL DESIGN 3)
/// ====================================================================
class AppTheme {
  static const Color background = Color(0xFF121212); // Grafite Ultra Escuro
  static const Color primary = Color(0xFFD4AF37);    // Ouro Velho/Dourado
  static const Color onPrimary = Color(0xFF121212);  // Preto Grafite
  static const Color secondary = Color(0xFFFAF9F6);  // Off-White Sóbrio
  static const Color surface = Color(0xFF1E1E1E);    // Grafite Nobre (Cartões)
  static const Color error = Color(0xFFD32F2F);      // Vermelho Alerta

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),

      // Customização Global de Fontes e Cabeçalhos
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SpaceGrotesk', 
          fontWeight: FontWeight.bold, 
          color: Color(0xFFFAF9F6),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter', 
          color: Color(0xFFFAF9F6),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter', 
          color: Color(0xFF9E9E9E),
        ),
      ),

      // Configuração Padrão do AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),

      // Decoração Padrão para Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF262626),
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),

      // Customização de Elevação de Cartões
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
