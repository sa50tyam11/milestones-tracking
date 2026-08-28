import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/welcome_screen.dart';
import 'screens/registration/registration_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/milestone_service.dart';

// ---------------------------------------------------------------------------
// Application entry point
// ---------------------------------------------------------------------------

/// Application entry point.
///
/// ## Startup sequence
/// 1. [WidgetsFlutterBinding.ensureInitialized] — prepares the Flutter engine
///    for async work before [runApp] is called.
/// 2. [_initializeServices] — loads and caches milestone data from the local
///    JSON asset. All screens that need milestone data depend on this.
/// 3. [runApp] — starts the widget tree with [ShishuCareApp] at the root.
///
/// ## Why initialize before runApp?
/// [MilestoneService.initialise] reads a file from the asset bundle.
/// If we called [runApp] first and let screens initialize the service lazily,
/// the first screen to query milestones could fail with a
/// [MilestoneServiceException] if initialization hasn't completed.
/// Initializing eagerly in main() guarantees the data is ready before
/// any screen can request it.
///
/// ## Error handling
/// If milestone initialization fails (e.g. milestones.json is missing or
/// malformed), the error is printed and the app still launches — the
/// error will surface on the screen that first queries milestone data.
/// A better UX (error screen at startup) will be implemented in Phase 18.
Future<void> main() async {
  // Step 1: Initialize Flutter binding.
  // Required before any async code runs before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Initialize application services.
  await _initializeServices();

  // Step 3: Launch the application.
  runApp(const ShishuCareApp());
}

/// Initializes all services that must be ready before the first screen renders.
///
/// Currently initializes:
/// - [MilestoneService] — loads milestones.json into memory cache
///
/// ## Phase 3 note
/// In Phase 3, the initialized [MilestoneService] instance will be stored
/// in a [Provider] so the entire widget tree can access it.
/// For now, we initialize it here and rely on the fact that
/// [MilestoneService] is safe to construct again from any screen
/// (subsequent calls to [initialise] are no-ops due to the [isInitialised] guard).
///
/// Future services (Firebase, analytics) will be initialized here too.
Future<void> _initializeServices() async {
  try {
    final milestoneService = MilestoneService();
    await milestoneService.initialise();
    // Phase 3 will inject this into the Provider tree.
    // For now, initialization ensures the internal cache is populated.
  } on MilestoneServiceException catch (e) {
    // Log the failure — the app still launches, but milestone screens
    // will show errors when they try to query the uninitialized service.
    // Phase 18 will add a proper startup error screen.
    debugPrint('[ShishuCare] MilestoneService initialization failed: $e');
  }
}

// ---------------------------------------------------------------------------
// Root application widget
// ---------------------------------------------------------------------------

/// The root widget of the ShishuCare application.
///
/// ## Responsibilities
/// - Provides services and state to the entire widget tree via [MultiProvider].
/// - Applies the centralized [AppTheme.lightTheme].
/// - Registers all named routes via [AppRoutes].
/// - Sets the initial route to [AppRoutes.splash].
///
/// ## Provider architecture
/// [MultiProvider] wraps [MaterialApp]. This means every widget anywhere
/// in the app can call [Provider.of<T>(context)] or [context.read<T>()]
/// to access a provided value.
///
/// In Phase 2, [MultiProvider] has no providers yet — it is an empty
/// container ready for Phase 3 (ChildProvider, MilestoneProvider).
/// Adding providers in Phase 3 will require only adding entries to
/// the [providers] list below — no structural changes to this file.
///
/// ## Why not put providers inside MaterialApp?
/// [MaterialApp] creates an internal [BuildContext] that is not accessible
/// from inside the [routes] callbacks. Wrapping with [MultiProvider] OUTSIDE
/// [MaterialApp] ensures providers are accessible from every route.
class ShishuCareApp extends StatelessWidget {
  const ShishuCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ----------------------------------------------------------------
        // Phase 3 will add providers here.
        //
        // Example (DO NOT add yet — Phase 3 only):
        //   Provider<MilestoneService>.value(value: _milestoneService!),
        //   ChangeNotifierProvider(create: (_) => ChildProvider()),
        //   ChangeNotifierProvider(create: (_) => MilestoneProvider()),
        // ----------------------------------------------------------------
      ],
      child: MaterialApp(
        // Application title — shown in device task switcher
        title: AppStrings.appName,

        // Debug banner removed — cleaner in demo
        debugShowCheckedModeBanner: false,

        // Centralized theme — every widget inherits colors, typography,
        // button styles, input styles from here
        theme: AppTheme.lightTheme,

        // Initial route — the first screen the user sees
        initialRoute: AppRoutes.splash,

        // Named route registry
        // Every screen must be registered here before it can be navigated to.
        // Routes not registered here will throw a RouteException at runtime.
        routes: {
          // Phase 2 routes — implemented and functional
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.welcome: (_) => const WelcomeScreen(),
          AppRoutes.registration: (_) => const RegistrationScreen(),

          // Phase 5+ routes — will be added as screens are built
          // AppRoutes.home:         (_) => const HomeScreen(),
          // AppRoutes.childProfile: (_) => const ChildProfileScreen(),

          // Phase 8+ routes
          // AppRoutes.milestoneAssessment: (_) => const MilestoneAssessmentScreen(),
          // AppRoutes.milestoneResult:     (_) => const MilestoneResultScreen(),

          // Phase 11+ routes
          // AppRoutes.growth:      (_) => const GrowthScreen(),
          // AppRoutes.vaccination: (_) => const VaccinationScreen(),

          // Phase 14+ routes
          // AppRoutes.compositeResult:    (_) => const CompositeResultScreen(),
          // AppRoutes.assessmentHistory:  (_) => const AssessmentHistoryScreen(),
          // AppRoutes.dashboard:          (_) => const DashboardScreen(),
        },
      ),
    );
  }
}
