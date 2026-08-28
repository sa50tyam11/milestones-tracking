import 'package:flutter/material.dart';

/// Centralized color palette for ShishuCare.
///
/// ## How to use
/// - Import this file in any widget or theme file.
/// - Never hardcode color hex values outside of this file.
/// - Use semantic names (e.g. [error], [success]) rather than
///   raw values like Colors.red, so the whole app can be re-themed
///   by changing only this file.
///
/// ## Palette rationale
/// Teal communicates trust, cleanliness, and calm — appropriate for a
/// healthcare screening tool used by parents and health workers.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Primary — Teal (main brand color)
  // ---------------------------------------------------------------------------

  /// The main brand color. Used for primary buttons, app bars, key icons.
  static const Color primary = Color(0xFF00897B);

  /// Slightly lighter teal — used for hover/focus states on primary elements.
  static const Color primaryLight = Color(0xFF4DB6AC);

  /// Darker teal — used for pressed states and text on light teal surfaces.
  static const Color primaryDark = Color(0xFF00695C);

  /// Very light teal background — used for card highlights and chip backgrounds.
  static const Color primarySurface = Color(0xFFE0F2F1);

  // ---------------------------------------------------------------------------
  // Secondary / Accent — Blue-Teal
  // ---------------------------------------------------------------------------

  /// Secondary accent — used for FABs, selection highlights, badges.
  static const Color secondary = Color(0xFF0288D1);

  /// Light secondary — used for secondary button backgrounds and icons.
  static const Color secondaryLight = Color(0xFF4FC3F7);

  /// Very light secondary — for subtle secondary highlights.
  static const Color secondarySurface = Color(0xFFE1F5FE);

  // ---------------------------------------------------------------------------
  // Neutral — Grays
  // ---------------------------------------------------------------------------

  /// App background — near-white, avoids pure white glare.
  static const Color background = Color(0xFFF5F7F9);

  /// Surface color — used for cards, sheets, dialogs.
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle divider lines and borders.
  static const Color divider = Color(0xFFE0E6ED);

  /// Light gray — disabled states, placeholder backgrounds.
  static const Color neutralLight = Color(0xFFECEFF1);

  /// Medium gray — secondary borders, inactive icons.
  static const Color neutral = Color(0xFFB0BEC5);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  /// Primary text — headings, body copy on white/light surfaces.
  static const Color textPrimary = Color(0xFF1A2332);

  /// Secondary text — captions, hints, metadata.
  static const Color textSecondary = Color(0xFF546E7A);

  /// Disabled text — greyed out labels.
  static const Color textDisabled = Color(0xFFB0BEC5);

  /// Text on dark/primary colored surfaces (e.g. AppBar title, primary buttons).
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Semantic colors — Success, Warning, Error
  // ---------------------------------------------------------------------------

  /// Success — milestone passed, vaccination up-to-date, low risk.
  static const Color success = Color(0xFF2E7D32);

  /// Light success surface — card backgrounds for positive results.
  static const Color successSurface = Color(0xFFE8F5E9);

  /// Warning — moderate risk, partial vaccination, not sure answers.
  static const Color warning = Color(0xFFF57F17);

  /// Light warning surface — card backgrounds for moderate concern.
  static const Color warningSurface = Color(0xFFFFF8E1);

  /// Error — high risk, failed critical milestone, validation error.
  static const Color error = Color(0xFFC62828);

  /// Light error surface — card backgrounds for high-risk results.
  static const Color errorSurface = Color(0xFFFFEBEE);

  // ---------------------------------------------------------------------------
  // Risk level colors — mirrors RiskLevel enum in enums.dart
  // ---------------------------------------------------------------------------

  /// Low risk result color — maps to RiskLevel.low.
  static const Color riskLow = success;

  /// Moderate risk result color — maps to RiskLevel.moderate.
  static const Color riskModerate = warning;

  /// High risk result color — maps to RiskLevel.high.
  static const Color riskHigh = error;
}
