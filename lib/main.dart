import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/welcome_screen.dart';
import 'screens/registration/registration_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/milestone_service.dart';
import 'repositories/milestone_repository.dart';
import 'providers/child_provider.dart';
import 'providers/milestone_provider.dart';

// ---------------------------------------------------------------------------
// Application entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  // Step 1: Initialize Flutter binding.
  // Required before any async code runs before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Initialize application services.
  final milestoneService = await _initializeServices();

  // Step 3: Launch the application.
  runApp(ShishuCareApp(milestoneService: milestoneService));
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
Future<MilestoneService?> _initializeServices() async {
  try {
    final milestoneService = MilestoneService();
    await milestoneService.initialise();
    return milestoneService;
  } on MilestoneServiceException catch (e) {
    debugPrint('[ShishuCare] MilestoneService initialization failed: $e');
    return null;
  }
}

// ---------------------------------------------------------------------------
// Root application widget
// ---------------------------------------------------------------------------

class ShishuCareApp extends StatelessWidget {
  const ShishuCareApp({super.key, this.milestoneService});

  final MilestoneService? milestoneService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Base Services & Repositories (Dependency Injection)
        if (milestoneService != null)
          Provider<MilestoneService>.value(value: milestoneService!),
        
        // Note: As per architecture inspection, MilestoneRepository currently acts
        // as the business logic layer (filtering by age) and MilestoneService acts
        // as the data layer (parsing JSON). We preserve these class names to avoid
        // large refactors, but inject them accordingly.
        ProxyProvider<MilestoneService, MilestoneRepository>(
          update: (context, service, previous) => MilestoneRepository(service: service),
        ),

        // 2. Application State Providers
        ChangeNotifierProvider<ChildProvider>(
          create: (_) => ChildProvider(),
        ),
        
        ChangeNotifierProxyProvider2<MilestoneRepository, ChildProvider, MilestoneProvider>(
          create: (_) => MilestoneProvider(),
          update: (_, repository, childProvider, previousProvider) {
            return (previousProvider ?? MilestoneProvider())
              ..updateDependencies(
                repository: repository,
                childProvider: childProvider,
              );
          },
        ),
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

          // Phase 5+ routes
          AppRoutes.home:         (_) => const HomeScreen(),
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
