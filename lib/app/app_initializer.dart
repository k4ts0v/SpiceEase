import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/database/database_provider.dart';

// final appInitializerProvider = FutureProvider<void>((ref) async {

//   // Define and initialize Firebase (Both for auth and database)- If there are different providers, initialize auth first and then the database.
//   final authService = ref.read(authServiceProvider);
//   await authService.initialize();

//   // Define and initialize auth services
//   final databaseService = ref.read(databaseServiceProvider);
//   await databaseService.initialize();
// });

final appInitializerProvider = FutureProvider<void>((ref) async {
  print('Starting app initialization...');

  try {
    print('Initializing core services...');

    // Initialize auth first
    print('Initializing auth service...');
    final authService = ref.read(authServiceProvider);
    await authService.initialize();
    print('Auth service initialized successfully');

    // Then initialize database
    print('Initializing database service...');
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.initialize();
    print('Database service initialized successfully');

    print('Core services initialized successfully');
    return;
  } catch (e, stack) {
    print('Error during initialization: $e');
    print('Stack trace: $stack');
    throw e;
  }
});