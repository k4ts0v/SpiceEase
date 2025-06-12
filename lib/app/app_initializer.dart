import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';

final appInitializerProvider = FutureProvider<void>((ref) async {
  try {
    final authService = ref.read(authServiceProvider);
    await authService.initialize();
    return;
  } catch (e) {
    rethrow;
  }
});

final databaseInitializerProvider = FutureProvider<void>((ref) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  if (isAuthenticated) {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.initialize();
  }
});
