// ===== CORE FLUTTER/RIVERPOD IMPORTS =====
// State management and reactive programming framework
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== APPLICATION AUTH IMPORTS =====
// Core authentication service and user model
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/auth_user_model.dart';

// ===== UNIFIED AUTHENTICATION PROVIDER =====
/// Single source of truth for authentication state across the entire application
///
/// This provider creates a unified, reactive authentication state that all other
/// providers and widgets can depend on. It directly streams Firebase authentication
/// state changes and transforms them into application-level user objects.
///
/// Benefits:
/// - Eliminates authentication state duplication across the app
/// - Provides consistent auth state to all dependent providers
/// - Automatically triggers rebuilds when auth state changes
/// - Centralizes auth state debugging and logging
/// - Simplifies dependency management for auth-dependent features
///
/// The provider streams Firebase auth state changes and maps them to AppUser objects,
/// providing real-time authentication status updates throughout the application.
final unifiedAuthProvider = StreamProvider<AppUser?>((ref) {
  // ===== AUTH SERVICE DEPENDENCY =====
  // Get the core authentication service for Firebase integration
  final authService = ref.read(authServiceProvider);

  // ===== STREAM AUTH STATE CHANGES =====
  // Listen to Firebase auth state changes directly and transform to AppUser
  return authService.authStateChanges().map((user) {
    // ===== AUTHENTICATION STATE DEBUGGING =====
    // Log auth state changes for debugging and monitoring
    print('🔍 UnifiedAuth: Auth state changed - user=${user?.email ?? 'null'}');
    return user;
  });
});

// ===== AUTHENTICATION STATUS HELPER PROVIDER =====
/// Simplified boolean provider for checking authentication status
///
/// This helper provider transforms the complex auth state into a simple boolean
/// value indicating whether a user is currently authenticated. It handles all
/// async states (loading, error, data) and provides a reliable boolean result.
///
/// Use cases:
/// - Conditional widget rendering based on auth status
/// - Route guards and navigation logic
/// - Feature access control
/// - UI state management for auth-dependent components
///
/// Returns:
/// - true: User is authenticated and data is available
/// - false: User is not authenticated, data is loading, or error occurred
///
/// This conservative approach ensures that protected features are only accessible
/// when authentication is definitively confirmed.
final isAuthenticatedProvider = Provider<bool>((ref) {
  // ===== WATCH UNIFIED AUTH STATE =====
  // React to changes in the unified authentication state
  final authState = ref.watch(unifiedAuthProvider);

  // ===== HANDLE ASYNC AUTH STATES =====
  // Transform AsyncValue<AppUser?> into a simple boolean
  return authState.when(
    // ===== AUTHENTICATED STATE =====
    // User data available - check if user exists
    data: (user) => user != null,

    // ===== LOADING STATE =====
    // Auth state still loading - assume not authenticated for safety
    loading: () => false,

    // ===== ERROR STATE =====
    // Auth error occurred - assume not authenticated for safety
    error: (_, __) => false,
  );
});
