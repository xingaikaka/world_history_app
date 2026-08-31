import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 古典史鉴调色板 — 羊皮纸与墨韵
  static const Color bg = Color(0xFFF4EDE0);
  static const Color surface = Color(0xFFFFFBF5);
  static const Color card = Color(0xFFFFFDF8);
  static const Color primary = Color(0xFF5C4033); // 深褐墨
  static const Color primaryLight = Color(0xFF8B6914); // 古金
  static const Color secondary = Color(0xFF2C4A6E); // 靛蓝
  static const Color accent = Color(0xFF8B4513); // 赭石
  static const Color textPrimary = Color(0xFF2A2118);
  static const Color textSecondary = Color(0xFF6B5D4F);
  static const Color divider = Color(0xFFD9CEBD);
  static const Color timelineLine = Color(0xFFC4B49A);
  static const Color headerDark = Color(0xFF1E1408);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: secondary,
          surface: surface,
        ),
        textTheme: GoogleFonts.notoSerifScTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.notoSerifSc(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: divider, width: 0.5),
          ),
        ),
      );

  static TextStyle title({double size = 16, Color? color, FontWeight? weight}) =>
      GoogleFonts.notoSerifSc(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? textPrimary,
      );

  static TextStyle body({double size = 13, Color? color, double? height}) =>
      GoogleFonts.notoSerifSc(
        fontSize: size,
        color: color ?? textSecondary,
        height: height ?? 1.6,
      );

  static TextStyle year({double size = 14, Color? color}) =>
      GoogleFonts.robotoMono(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? primaryLight,
      );

  static TextStyle label({double size = 11, Color? color}) =>
      GoogleFonts.notoSansSc(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? textSecondary,
        letterSpacing: 0.5,
      );
}
