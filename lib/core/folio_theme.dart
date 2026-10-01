import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Warm Glass Color Palette ─────────────────────────────────────────────────
// Night = deep espresso background with glowing orange accents.
// Day   = warm cream background with the same orange accent.

class FolioColors {
  // Day (Light) — 06:00 → 19:00
  static const Color dayBg = Color(0xFFF6F0EB);
  static const Color dayDarkShadow = Color(0xFFE2D3C8);
  static const Color dayLightShadow = Color(0xFFFFFFFF);
  static const Color dayText = Color(0xFF231815);
  static const Color dayTextSub = Color(0xFF8A7A70);
  static const Color dayAccent = Color(0xFFEA580C);
  static const Color dayAccentSoft = Color(0xFFFDE6D8);
  static const Color dayCard = Color(0xFFFFFBF8);
  static const Color dayBorder = Color(0x14000000);

  // Night (Dark) — 19:00 → 06:00
  static const Color nightBg = Color(0xFF0E0908);
  static const Color nightDarkShadow = Color(0xFF050302);
  static const Color nightLightShadow = Color(0xFF221814);
  static const Color nightText = Color(0xFFF7EEE8);
  static const Color nightTextSub = Color(0xFFA8958A);
  static const Color nightAccent = Color(0xFFFF7A2F);
  static const Color nightAccentSoft = Color(0xFF3A1E10);
  static const Color nightCard = Color(0xFF1A1210);
  static const Color nightBorder = Color(0x1AFFFFFF);
}

// ─── Shadow Presets ──────────────────────────────────────────────────────────
// Same API as before (so existing widgets keep working), but softer
// "floating glass" shadows instead of the old neumorphic double shadows.

class NeuShadows {
  static List<BoxShadow> raised(bool isDark, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: isDark ? const Color(0x99000000) : const Color(0x1F5A3A2A),
        offset: Offset(0, 10 * intensity),
        blurRadius: 26 * intensity,
      ),
    ];
  }

  static List<BoxShadow> subtle(bool isDark) => raised(isDark, intensity: 0.5);

  static List<BoxShadow> pressed(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? const Color(0x66000000) : const Color(0x145A3A2A),
        offset: const Offset(0, 3),
        blurRadius: 8,
      ),
    ];
  }

  static List<BoxShadow> inset(bool isDark) => pressed(isDark);
}

// ─── Theme Notifier ───────────────────────────────────────────────────────────

class FolioThemeNotifier extends ChangeNotifier {
  bool? _manualDark; // null = auto-detect by time

  /// True if dark mode should be active.
  /// Auto: dark from 19:00 to 05:59, light from 06:00 to 18:59.
  bool get isDark {
    if (_manualDark != null) return _manualDark!;
    final h = DateTime.now().hour;
    return h < 6 || h >= 19;
  }

  bool get isAuto => _manualDark == null;

  void setDark(bool value) {
    _manualDark = value;
    notifyListeners();
  }

  void setAuto() {
    _manualDark = null;
    notifyListeners();
  }

  // ─── Semantic colours ─────────────────────────────────────────────────────

  Color get bg => isDark ? FolioColors.nightBg : FolioColors.dayBg;
  Color get cardBg => isDark ? FolioColors.nightCard : FolioColors.dayCard;
  Color get text => isDark ? FolioColors.nightText : FolioColors.dayText;
  Color get textSub => isDark ? FolioColors.nightTextSub : FolioColors.dayTextSub;
  Color get accent => isDark ? FolioColors.nightAccent : FolioColors.dayAccent;
  Color get accentSoft => isDark ? FolioColors.nightAccentSoft : FolioColors.dayAccentSoft;
  Color get darkShadow => isDark ? FolioColors.nightDarkShadow : FolioColors.dayDarkShadow;
  Color get lightShadow => isDark ? FolioColors.nightLightShadow : FolioColors.dayLightShadow;

  // ─── Glass helpers (new) ──────────────────────────────────────────────────

  /// Thin border around glass cards.
  Color get border => isDark ? FolioColors.nightBorder : FolioColors.dayBorder;

  /// Top-left → bottom-right fill for frosted glass cards.
  List<Color> get glassFill => isDark
      ? const [Color(0xE62A1D18), Color(0xCC1A1210)]
      : const [Color(0xFFFFFFFF), Color(0xF2FFFBF8)];

  /// Fill for pressed / inset areas (text fields, previews).
  Color get insetFill =>
      isDark ? const Color(0x59000000) : const Color(0x0F5A3A2A);

  /// Orange gradient for primary buttons and active states.
  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFFFF9A4D), Color(0xFFE8500F)]
            : const [Color(0xFFFB8B3C), Color(0xFFE2550E)],
      );

  /// Orange glow used behind buttons and in the background.
  Color get glow => isDark ? const Color(0x8CFF6A1A) : const Color(0x66F97316);

  // ─── Shadow shortcuts ─────────────────────────────────────────────────────

  List<BoxShadow> get raisedShadow => NeuShadows.raised(isDark);
  List<BoxShadow> get subtleShadow => NeuShadows.subtle(isDark);
  List<BoxShadow> get pressedShadow => NeuShadows.pressed(isDark);
  List<BoxShadow> get insetShadow => NeuShadows.inset(isDark);

  // ─── MaterialThemeData ────────────────────────────────────────────────────

  ThemeData get themeData => isDark ? _nightTheme() : _dayTheme();

  ThemeData _dayTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: FolioColors.dayBg,
      colorScheme: const ColorScheme.light(
        primary: FolioColors.dayAccent,
        secondary: FolioColors.dayAccent,
        surface: FolioColors.dayBg,
        onSurface: FolioColors.dayText,
        primaryContainer: FolioColors.dayAccentSoft,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: FolioColors.dayText,
        displayColor: FolioColors.dayText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: FolioColors.dayBg,
        foregroundColor: FolioColors.dayText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: FolioColors.dayText,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FolioColors.dayCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FolioColors.dayText,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ThemeData _nightTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: FolioColors.nightBg,
      colorScheme: const ColorScheme.dark(
        primary: FolioColors.nightAccent,
        secondary: FolioColors.nightAccent,
        surface: FolioColors.nightCard,
        onSurface: FolioColors.nightText,
        primaryContainer: FolioColors.nightAccentSoft,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: FolioColors.nightText,
        displayColor: FolioColors.nightText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: FolioColors.nightBg,
        foregroundColor: FolioColors.nightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: FolioColors.nightText,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FolioColors.nightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FolioColors.nightCard,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: FolioColors.nightText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
