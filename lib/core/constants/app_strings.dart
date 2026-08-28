/// Centralized string constants for ShishuCare.
///
/// ## Purpose
/// All user-visible text must be defined here, never hardcoded inside
/// widget files. This enables:
/// - Future localization (Phase 20) — replace static strings with ARB lookups
/// - Consistent wording across the entire application
/// - Easy review of all user-facing copy in one place
///
/// ## Organization
/// Strings are grouped by screen/feature. Add new groups as screens are built.
/// Prefix each group with the screen name (e.g. [splash], [welcome]).
///
/// ## IMPORTANT — Medical Language Policy
/// This application is a SCREENING platform, not a diagnostic tool.
/// All strings that reference health outcomes MUST use screening language:
///   ✅ "developmental concern"  ✅ "risk"  ✅ "further evaluation recommended"
///   ❌ "diagnosis"  ❌ "has autism"  ❌ "confirmed deficiency"
abstract final class AppStrings {
  // ---------------------------------------------------------------------------
  // Application identity
  // ---------------------------------------------------------------------------

  static const String appName = 'ShishuCare';
  static const String appTagline =
      'Early Childhood Development & Nutritional Risk Screening';
  static const String appVersion = '1.0.0';

  // ---------------------------------------------------------------------------
  // Splash screen
  // ---------------------------------------------------------------------------

  static const String splashLoading = 'Loading…';
  static const String splashPoweredBy = 'BioMed Bharat 2026';

  // ---------------------------------------------------------------------------
  // Welcome screen
  // ---------------------------------------------------------------------------

  static const String welcomeTitle = 'Welcome to ShishuCare';
  static const String welcomeSubtitle =
      'A simple, trusted tool to monitor your child\'s development '
      'and nutritional wellbeing.';
  static const String welcomeDisclaimer =
      'ShishuCare provides developmental screening guidance only. '
      'It does not diagnose any medical condition. '
      'Always consult a qualified healthcare professional for medical advice.';
  static const String welcomeGetStarted = 'Get Started';
  static const String welcomeLearnMore = 'Learn More';

  // ---------------------------------------------------------------------------
  // Registration screen (placeholder — full implementation in Phase 5)
  // ---------------------------------------------------------------------------

  static const String registrationTitle = 'Parent & Child Registration';
  static const String registrationPlaceholder =
      'Registration module — coming in Phase 5.';
  static const String registrationSubtitle =
      'Please provide parent and child details to begin screening.';

  // ---------------------------------------------------------------------------
  // Navigation labels (bottom nav / drawer — future use)
  // ---------------------------------------------------------------------------

  static const String navHome = 'Home';
  static const String navMilestone = 'Milestones';
  static const String navVaccination = 'Vaccination';
  static const String navHistory = 'History';
  static const String navDashboard = 'Dashboard';

  // ---------------------------------------------------------------------------
  // Common / shared
  // ---------------------------------------------------------------------------

  static const String buttonNext = 'Next';
  static const String buttonBack = 'Back';
  static const String buttonSubmit = 'Submit';
  static const String buttonCancel = 'Cancel';
  static const String buttonRetry = 'Retry';
  static const String buttonClose = 'Close';
  static const String buttonSave = 'Save';

  static const String labelLoading = 'Loading…';
  static const String labelError = 'Something went wrong.';
  static const String labelNoData = 'No data available.';
  static const String labelRequired = 'This field is required.';

  // ---------------------------------------------------------------------------
  // Error messages (Phase 18 — Error Handling)
  // ---------------------------------------------------------------------------

  static const String errorNoInternet =
      'No internet connection. Some features may be unavailable.';
  static const String errorTimeout =
      'The request timed out. Please try again.';
  static const String errorServerUnreachable =
      'Unable to reach the server. Please check your connection.';
  static const String errorMilestoneLoad =
      'Unable to load milestone data. Please restart the app.';

  // ---------------------------------------------------------------------------
  // Screening language — approved terms (NEVER change without team approval)
  // ---------------------------------------------------------------------------
  // These strings are used in result screens and recommendations.
  // They must always use screening language, never diagnostic language.

  static const String screeningDisclaimer =
      'This screening result is not a medical diagnosis. '
      'It identifies areas that may benefit from further professional evaluation.';
  static const String recommendProfessionalEvaluation =
      'Further professional evaluation is recommended for the flagged areas.';
  static const String developmentalConcern =
      'Some developmental areas may require closer monitoring.';
}
