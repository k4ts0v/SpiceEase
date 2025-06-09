import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/user_model.dart';

/// Single source of truth for authentication state
final unifiedAuthProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.read(authServiceProvider);
  
  // Listen to Firebase auth state changes directly
  return authService.authStateChanges().map((user) {
    print('🔍 UnifiedAuth: Auth state changed - user=${user?.email ?? 'null'}');
    return user;
  });
});

/// Helper provider for just the boolean auth status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(unifiedAuthProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});