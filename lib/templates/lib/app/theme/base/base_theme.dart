import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class BaseTheme {
  Brightness get brightness;
  ColorScheme get colorScheme;

  /* --------------------------------------------------------------- */
  /*  Public API – call <YourTheme>().theme anywhere in the app      */
  /* --------------------------------------------------------------- */
  ThemeData get theme {
    final isDark = brightness == Brightness.dark;
    final scheme = colorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,

      /* ----------  TYPOGRAPHY  ---------- */
      textTheme: _textTheme(isDark),
      typography: Typography.material2021(),

      /* ----------  APP-BAR  ---------- */
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: _textTheme(isDark).titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      /* ----------  FLOATING-ACTION-BUTTON  ---------- */
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 6,
        highlightElevation: 12,
        shape: const StadiumBorder(),
      ),

      /* ----------  ELEVATED-BUTTON  ---------- */
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      /* ----------  OUTLINED-BUTTON  ---------- */
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      /* ----------  TEXT-BUTTON  ---------- */
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      /* ----------  CARDS  ---------- */
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant, width: .5),
        ),
      ),

      /* ----------  CHIPS  ---------- */
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        labelStyle: _textTheme(isDark).labelLarge,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),

      /* ----------  SWITCH  ---------- */
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
        ),
      ),

      /* ----------  SLIDER  ---------- */
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withOpacity(.12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: _abel(
          style: const TextStyle(color: Colors.white),
        ),
      ),

      /* ----------  INPUT-DECORATION  ---------- */
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: _abel(style: TextStyle(color: scheme.onSurfaceVariant)),
        hintStyle: _abel(
          style: TextStyle(color: scheme.onSurfaceVariant.withOpacity(.7)),
        ),
      ),

      /* ----------  DIVIDER  ---------- */
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: .5,
        space: 32,
      ),

      /* ----------  ICON-THEME  ---------- */
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
      primaryIconTheme: IconThemeData(color: scheme.onPrimary, size: 24),

      /* ----------  DIALOG  ---------- */
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: _textTheme(isDark).headlineSmall!.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: _textTheme(
          isDark,
        ).bodyMedium!.copyWith(color: scheme.onSurface),
      ),

      /* ----------  BOTTOM-SHEET  ---------- */
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      /* ----------  SNACK-BAR  ---------- */
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: _abel(
          style: TextStyle(color: scheme.onInverseSurface),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      /* ----------------------------------------------------------- */
      /*  TODO CUSTOM – drop one-off tweaks below this line only     */
      /* ----------------------------------------------------------- */
    );
  }

  /* ------------------------------------------------------------------ */
  /*  Private helpers                                                   */
  /* ------------------------------------------------------------------ */
  TextTheme _textTheme(bool isDark) {
    final base = GoogleFonts.abelTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    return base.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }

  TextStyle _abel({required TextStyle style}) =>
      GoogleFonts.abel(textStyle: style);
}
