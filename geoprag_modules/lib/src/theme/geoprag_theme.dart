import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'geoprag_colors.dart';

/// Tema oficial do GeoPrag, compartilhado pelo Portal do Administrador
/// (web) e pelo App do Aplicador (mobile). Ambos os apps devem consumir
/// este tema em vez de definir estilos ad hoc — a marca é única; o que
/// pode variar por prefeitura é apenas um selo institucional e,
/// opcionalmente, uma cor de acento (ver [accentColor]).
class GeopragTheme {
  GeopragTheme._();

  static ThemeData light({Color? accentColor}) {
    final textTheme = _textTheme();
    final accent = accentColor ?? GeopragColors.green900;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: GeopragColors.green900,
          brightness: Brightness.light,
        ).copyWith(
          primary: GeopragColors.green900,
          onPrimary: GeopragColors.white,
          primaryContainer: GeopragColors.green800,
          onPrimaryContainer: GeopragColors.white,
          secondary: GeopragColors.blue600,
          onSecondary: GeopragColors.white,
          error: GeopragColors.statusAtrasado,
          onError: GeopragColors.white,
          surface: GeopragColors.white,
          onSurface: const Color(0xFF1A1F1C),
        );

    final borderRadius = BorderRadius.circular(12);
    final outlineBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: GeopragColors.neutralLight,
      textTheme: textTheme,
      primaryColor: GeopragColors.green900,
      dividerColor: Colors.grey.shade200,
      appBarTheme: AppBarTheme(
        backgroundColor: GeopragColors.green900,
        foregroundColor: GeopragColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: GeopragColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GeopragColors.green900,
          foregroundColor: GeopragColors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GeopragColors.green900,
          side: const BorderSide(color: GeopragColors.green900, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GeopragColors.green900,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GeopragColors.white,
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: const BorderSide(color: GeopragColors.green900, width: 2),
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
      ),
      cardTheme: CardThemeData(
        color: GeopragColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GeopragColors.neutralLight,
        labelStyle: textTheme.labelMedium ?? const TextStyle(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GeopragColors.green900,
      ),
      extensions: [GeopragBrandExtension(accentColor: accent)],
    );
  }

  static TextTheme _textTheme() {
    final base = GoogleFonts.publicSansTextTheme();
    return base.copyWith(
      // Display 800 — títulos de destaque
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w800),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w800),
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w800),
      // Título H1/700 — cabeçalho de tela
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      // Título H2/600 — seção / card
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      // Corpo de texto 16/400 — body
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      // Rótulo / caption — tags, tabelas
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Cor de acento opcional por prefeitura (seção 04 · Sistema multi-prefeitura).
/// A marca geoprag permanece fixa; apenas este acento pode variar por
/// instalação (ex.: barra superior de um card de instituição).
@immutable
class GeopragBrandExtension extends ThemeExtension<GeopragBrandExtension> {
  final Color accentColor;

  const GeopragBrandExtension({required this.accentColor});

  @override
  GeopragBrandExtension copyWith({Color? accentColor}) {
    return GeopragBrandExtension(accentColor: accentColor ?? this.accentColor);
  }

  @override
  GeopragBrandExtension lerp(
    ThemeExtension<GeopragBrandExtension>? other,
    double t,
  ) {
    if (other is! GeopragBrandExtension) return this;
    return GeopragBrandExtension(
      accentColor: Color.lerp(accentColor, other.accentColor, t) ?? accentColor,
    );
  }
}
