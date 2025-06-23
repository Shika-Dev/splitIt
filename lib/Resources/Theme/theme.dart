import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTheme {
  static const Color primaryColor = Color(0xFF262626);
  static const Color backgroundColor = Color(0xFF0D0D0D);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color strokeColor = Color(0xFFFFECBB);

  static TextStyle h1 = GoogleFonts.alata(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle h2 = GoogleFonts.alata(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle h3 = GoogleFonts.alata(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle bodyLarge = GoogleFonts.alata(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.alata(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.alata(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle captionLarge = GoogleFonts.alata(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle captionMedium = GoogleFonts.alata(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static TextStyle captionSmall = GoogleFonts.alata(
    fontSize: 8,
    fontWeight: FontWeight.w400,
  );
}
