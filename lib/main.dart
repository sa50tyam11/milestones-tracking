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
import 'services/local_storage_service.dart';
import 'models/child.dart';
import 'screens/milestone/milestone_assessment_screen.dart';
import 'screens/milestone/assessment_complete_screen.dart';
import 'providers/dashboard_provider.dart';
import 'screens/dashboard/final_dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Application entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  // Step 1: Initialize Flutter binding.
  // Required before any async code runs before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Initialize application services.
  final services = await _initializeServices();

  // Step 3: Launch the application.
  runApp(ShishuCareApp(
    milestoneService: services.milestoneService,
    storageService: services.storageService,
    initialChild: services.initialChild,
  ));
}

/// Initializes all services that must be ready before the first screen renders.
///
/// Currently initializes:
/// - [MilestoneService] — loads milestones.json into memory cache
/// - [LocalStorageService] — loads SharedPreferences and restores active child.
Future<({MilestoneService? milestoneService, LocalStorageService storageService, Child? initialChild})> _initializeServices() async {
  MilestoneService? milestoneService;
  try {
    milestoneService = MilestoneService();
    await milestoneService.initialise();
  } on MilestoneServiceException catch (e) {
    debugPrint('[ShishuCare] MilestoneService initialization failed: $e');
  }

  final storageService = LocalStorageService();
  await storageService.init();
  
  Child? initialChild;
  try {
    final activeChildId = storageService.getActiveChildId();
    if (activeChildId != null) {
      initialChild = storageService.getChild(activeChildId);
    }
  } catch (e) {
    debugPrint('[ShishuCare] Failed to restore active child: $e');
  }

  return (
    milestoneService: milestoneService,
    storageService: storageService,
    initialChild: initialChild,
  );
}

// ---------------------------------------------------------------------------
// Root application widget
// ---------------------------------------------------------------------------

class ShishuCareApp extends StatelessWidget {
  const ShishuCareApp({
    super.key,
    this.milestoneService,
    required this.storageService,
    this.initialChild,
  });

  final MilestoneService? milestoneService;
  final LocalStorageService storageService;
  final Child? initialChild;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Base Services & Repositories (Dependency Injection)
        Provider<LocalStorageService>.value(value: storageService),
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
          create: (_) => ChildProvider(
            storageService: storageService,
            initialChild: initialChild,
          ),
        ),
        
        ChangeNotifierProxyProvider3<MilestoneRepository, ChildProvider, LocalStorageService, MilestoneProvider>(
          create: (_) => MilestoneProvider(),
          update: (_, repository, childProvider, storage, previousProvider) {
            return (previousProvider ?? MilestoneProvider())
              ..updateDependencies(
                repository: repository,
                childProvider: childProvider,
                storageService: storage,
              );
          },
        ),
        
        ChangeNotifierProxyProvider2<LocalStorageService, ChildProvider, DashboardProvider>(
          create: (_) => DashboardProvider(),
          update: (_, storage, childProvider, previousProvider) {
            return (previousProvider ?? DashboardProvider())
              ..updateDependencies(
                storageService: storage,
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
          AppRoutes.milestoneAssessment: (_) => const MilestoneAssessmentScreen(),
          AppRoutes.milestoneResult:     (_) => const AssessmentCompleteScreen(),

          // Phase 11+ routes
          // AppRoutes.growth:      (_) => const GrowthScreen(),
          // AppRoutes.vaccination: (_) => const VaccinationScreen(),

          // Phase 14+ routes
          // AppRoutes.compositeResult:    (_) => const CompositeResultScreen(),
          // AppRoutes.assessmentHistory:  (_) => const AssessmentHistoryScreen(),
          AppRoutes.dashboard:          (_) => const FinalDashboardScreen(),
        },
      ),
    );
  }
}
