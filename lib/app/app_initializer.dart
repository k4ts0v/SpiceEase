// ===== CORE FLUTTER/RIVERPOD IMPORTS =====
// State management and provider framework for dependency injection and async state handling
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== APPLICATION SERVICE IMPORTS =====
// Authentication service provider for user session management
import 'package:spiceease/core/auth/auth_provider.dart';
// Database service provider for data persistence and synchronization
import 'package:spiceease/core/database/database_provider.dart';
// Unified authentication provider for centralized auth state management
import 'package:spiceease/data/providers/unified_auth_provider.dart';

// ===== APPLICATION INITIALIZATION PROVIDERS =====

/// Primary application initialization provider for core services and dependencies
///
/// Handles the sequential initialization of critical application services required
/// for proper app functionality. This provider orchestrates the startup process
/// and ensures all essential services are properly configured before the app
/// becomes fully operational.
///
/// Key initialization tasks:
/// - Authentication service setup and configuration
/// - Core service dependency resolution
/// - Error handling for initialization failures
/// - Graceful degradation when services are unavailable
///
/// The provider follows the fail-fast principle: if core services cannot be
/// initialized, the error is propagated to prevent the app from running in
/// an inconsistent state.
///
/// Usage: Watch this provider during app startup to ensure all dependencies
/// are ready before presenting the main application interface.
final appInitializerProvider = FutureProvider<void>((ref) async {
  try {
    // ===== CORE AUTHENTICATION SERVICE INITIALIZATION =====
    // Initialize the authentication service to handle user sessions,
    // token management, and security context setup
    final authService = ref.read(authServiceProvider);
    await authService.initialize();

    // ===== SUCCESSFUL INITIALIZATION =====
    // All core services have been successfully initialized
    return;
  } catch (e) {
    // ===== INITIALIZATION FAILURE HANDLING =====
    // Propagate initialization errors to the calling context
    // This ensures the app doesn't start with incomplete services
    rethrow;
  }
});

/// Database initialization provider with authentication-dependent activation
///
/// Manages the conditional initialization of database services based on user
/// authentication status. This provider ensures that database connections and
/// data synchronization are only established when a user is properly authenticated,
/// following security best practices and optimizing resource usage.
///
/// Key features:
/// - Authentication-gated database initialization
/// - Automatic activation when user signs in
/// - Resource optimization by avoiding unnecessary connections
/// - Secure data access patterns
///
/// Lifecycle behavior:
/// - Inactive when user is not authenticated (no database operations)
/// - Automatically initializes when user authentication is detected
/// - Handles authentication state changes gracefully
/// - Supports clean shutdown when user signs out
///
/// Usage: This provider is automatically managed by the authentication system
/// and does not require manual intervention under normal circumstances.
final databaseInitializerProvider = FutureProvider<void>((ref) async {
  // ===== AUTHENTICATION STATUS CHECK =====
  // Monitor the current authentication status to determine if database
  // initialization should proceed. Only authenticated users get database access.
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  if (isAuthenticated) {
    // ===== AUTHENTICATED USER DATABASE SETUP =====
    // User is properly authenticated, proceed with database initialization
    // This includes connection establishment, schema validation, and sync setup
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.initialize();
  }

  // ===== UNAUTHENTICATED STATE =====
  // If user is not authenticated, this provider completes without action,
  // ensuring no database resources are allocated for unauthenticated sessions
});
