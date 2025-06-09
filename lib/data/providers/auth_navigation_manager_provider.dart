import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';
import 'package:spiceease/features/navigation_bar.dart';
import 'package:spiceease/main.dart';

/// Provider that explicitly manages navigation based on auth state
final authNavigationManagerProvider = Provider((ref) {
  ref.listen<AsyncValue>(unifiedAuthProvider, (previous, current) {
    print('🔍 AuthNavigationManager: Auth state changed');
    
    if (previous?.value?.email != current.value?.email) {
      print('🔍 AuthNavigationManager: User changed from ${previous?.value?.email} to ${current.value?.email}');
      
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        print('❌ AuthNavigationManager: Navigator not available');
        return;
      }
      
      final isAuthenticated = current.value != null;
      
      // Clear all routes and push the appropriate screen based on auth state
      if (isAuthenticated) {
        print('🔍 AuthNavigationManager: Navigating to NavBar (authenticated)');
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const NavBar()),
          (route) => false, // Remove all previous routes
        );
      } else {
        print('🔍 AuthNavigationManager: Navigating to AuthScreen (not authenticated)');
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false, // Remove all previous routes
        );
      }
    }
  });
  
  return null;
});