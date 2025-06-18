// ===== CORE FLUTTER/DART IMPORTS =====
// Material Design UI framework for building cross-platform interfaces
import 'package:flutter/material.dart';
// State management and provider framework for reactive app state handling
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== APPLICATION INFRASTRUCTURE IMPORTS =====
// App initialization provider for coordinating startup dependencies
import 'package:spiceease/app/app_initializer.dart';
// Splash screen component for displaying loading state during app startup
import 'package:spiceease/app/splash_screen.dart';
// Unified authentication provider for centralized user session management
import 'package:spiceease/data/providers/unified_auth_provider.dart';

// ===== FEATURE SCREEN IMPORTS =====
// Authentication screen for user login and registration flows
import 'package:spiceease/features/auth/presentation/auth_screen.dart';
// Main navigation container for authenticated user experience
import 'package:spiceease/features/navigation_bar.dart';

// ===== APPLICATION BOOTSTRAP WRAPPER =====

/// Root application wrapper responsible for coordinated app initialization and routing
///
/// This widget serves as the entry point for the main application flow, handling the
/// critical bootstrap sequence that prepares all necessary services and determines
/// the appropriate initial screen based on user authentication status.
///
/// Key responsibilities:
/// - Orchestrates sequential initialization of core application services
/// - Manages authentication state evaluation during startup
/// - Provides seamless navigation to appropriate initial screen
/// - Displays splash screen during initialization to maintain user experience
/// - Handles initialization failures gracefully with appropriate error states
///
/// Bootstrap sequence:
/// 1. Display splash screen immediately for responsive startup experience
/// 2. Initialize core services (Firebase, authentication, database connections)
/// 3. Evaluate current user authentication status
/// 4. Navigate to authenticated or unauthenticated experience accordingly
/// 5. Handle any initialization errors with fallback behaviors
///
/// Navigation flow:
/// - Authenticated users: Navigate directly to main app (NavBar)
/// - Unauthenticated users: Navigate to authentication flow (AuthScreen)
/// - Initialization errors: Remain on splash with error handling
class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({super.key});

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

/// State manager for application bootstrap and initial navigation coordination
///
/// Handles the asynchronous initialization sequence and manages navigation
/// to the appropriate initial screen based on authentication status and
/// service availability. Ensures a smooth user experience during app startup.
class _AppWrapperState extends ConsumerState<AppWrapper> {
  /// Initializes the widget and triggers the bootstrap sequence
  ///
  /// Called when the widget is first created, immediately starting the
  /// asynchronous bootstrap process while displaying the splash screen
  /// to provide immediate visual feedback to the user.
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Executes the complete application bootstrap sequence
  ///
  /// Coordinates the initialization of all critical app services and performs
  /// authentication-based routing to determine the user's initial experience.
  /// This method runs asynchronously while the splash screen is displayed.
  ///
  /// Bootstrap phases:
  /// 1. **Service Initialization**: Wait for all core services to be ready
  /// 2. **Authentication Evaluation**: Check current user session status
  /// 3. **Conditional Navigation**: Route to appropriate initial screen
  /// 4. **Error Handling**: Manage any initialization failures gracefully
  ///
  /// The method ensures that navigation only occurs when the widget is still
  /// mounted, preventing potential errors from async operations completing
  /// after the widget has been disposed.
  Future<void> _bootstrap() async {
    try {
      // ===== PHASE 1: CORE SERVICE INITIALIZATION =====
      // Wait for critical app services to be fully initialized and ready
      // This includes Firebase setup, authentication service, and database connections
      await ref.read(appInitializerProvider.future);

      // ===== PHASE 2: AUTHENTICATION STATUS EVALUATION =====
      // Retrieve the current user authentication state after services are ready
      // This ensures we have accurate auth information for routing decisions
      final user = await ref.read(unifiedAuthProvider.future);

      // ===== PHASE 3: SAFETY CHECK =====
      // Ensure the widget is still mounted before performing navigation
      // Prevents errors if the bootstrap completes after widget disposal
      if (!mounted) return;

      // ===== PHASE 4: AUTHENTICATION-BASED NAVIGATION =====
      if (user != null) {
        // ===== AUTHENTICATED USER FLOW =====
        // User has valid authentication, navigate to main app experience
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NavBar()),
        );
      } else {
        // ===== UNAUTHENTICATED USER FLOW =====
        // No valid user session, navigate to authentication screens
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    } catch (e) {
      // ===== INITIALIZATION ERROR HANDLING =====
      // Log the error for debugging while maintaining app stability
      print('Bootstrap error: $e');

      // ===== FALLBACK NAVIGATION =====
      // On initialization failure, default to authentication screen
      // This provides a recovery path for users even when services fail
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    }
  }

  /// Builds the initial UI during the bootstrap process
  ///
  /// Displays the splash screen consistently while the asynchronous bootstrap
  /// sequence runs in the background. The splash screen provides immediate
  /// visual feedback and maintains user engagement during initialization.
  ///
  /// The splash screen remains visible until the bootstrap process completes
  /// and navigation to the appropriate main screen occurs.
  @override
  Widget build(BuildContext context) {
    // ===== BOOTSTRAP LOADING STATE =====
    // Display splash screen during entire initialization process
    // Provides consistent user experience regardless of initialization duration
    return const SplashScreen();
  }
}
