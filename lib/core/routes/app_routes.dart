/// Centralized named route constants for ShishuCare.
///
/// ## How to use
/// Always reference routes via this class, never with raw strings.
///
/// ```dart
/// // ✅ Correct
/// Navigator.pushNamed(context, AppRoutes.welcome);
///
/// // ❌ Wrong — typos will cause silent runtime failures
/// Navigator.pushNamed(context, '/welcome');
/// ```
///
/// ## Route registration
/// Route constants defined here are registered in the [routes] map
/// inside MaterialApp in main.dart. Adding a constant here does NOT
/// automatically register the route — you must also add it to the map.
///
/// ## Navigation architecture decision
/// We use named routes (not go_router or auto_route) for Phase 2 because:
/// - The app flow is linear and simple at this stage
/// - No additional packages required
/// - Easy to migrate to go_router in a later phase if deep-linking is needed
abstract final class AppRoutes {
  // ---------------------------------------------------------------------------
  // Core flow (implemented in Phase 2)
  // ---------------------------------------------------------------------------

  /// Application entry point — shown immediately after launch.
  static const String splash = '/';

  /// Welcome / onboarding screen — shown after splash.
  static const String welcome = '/welcome';

  /// Parent and child registration — entry to the screening flow.
  static const String registration = '/registration';

  // ---------------------------------------------------------------------------
  // Main application screens (implemented in Phase 5+)
  // ---------------------------------------------------------------------------

  /// Home dashboard — shown after registration is complete.
  static const String home = '/home';

  /// Child profile view and edit screen.
  static const String childProfile = '/child-profile';

  // ---------------------------------------------------------------------------
  // Milestone module (implemented in Phase 8+)
  // ---------------------------------------------------------------------------

  /// Milestone assessment — the primary screening interaction.
  static const String milestoneAssessment = '/milestone-assessment';

  /// Milestone result — shows scores and domain breakdown.
  static const String milestoneResult = '/milestone-result';

  // ---------------------------------------------------------------------------
  // Growth and vaccination (implemented in Phase 11+)
  // ---------------------------------------------------------------------------

  /// Growth monitoring screen.
  static const String growth = '/growth';

  /// Vaccination schedule and history screen.
  static const String vaccination = '/vaccination';

  // ---------------------------------------------------------------------------
  // Integration modules (implemented in Phase 12–14)
  // ---------------------------------------------------------------------------

  /// Eye tracking integration screen.
  static const String eyeTracking = '/eye-tracking';

  /// Nutritional risk screening screen.
  static const String nutritionScreening = '/nutrition-screening';

  // ---------------------------------------------------------------------------
  // Composite result and history (implemented in Phase 10+)
  // ---------------------------------------------------------------------------

  /// Composite screening result — combines all module outputs.
  static const String compositeResult = '/composite-result';

  /// Assessment history — all past screening sessions for a child.
  static const String assessmentHistory = '/assessment-history';

  /// Full dashboard — overview of all modules for a child.
  static const String dashboard = '/dashboard';
}
