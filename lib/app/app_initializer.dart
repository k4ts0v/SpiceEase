import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/providers/current_user_provider.dart';
import 'package:spiceease/data/services/notification_service.dart';

/// App initializer that handles auth service initialization
/// and conditionally initializes database if user is authenticated
final appInitializerProvider = FutureProvider<void>((ref) async {
  print('Starting app initialization...');

  try {
    print('Initializing auth service...');
    final authService = ref.read(authServiceProvider);
    await authService.initialize();
    print('Auth service initialized successfully');

    // Check if user is authenticated FIRST
    print('Checking authentication status...');
    final isSignedIn = await ref.watch(isUserSignedInProvider.future);

    if (isSignedIn) {
      print('User is authenticated, initializing database...');
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.initialize();
      print('Database initialized successfully');

      // // Initialize notification service AFTER database is ready
      // print('Initializing notification service...');
      // final notificationService = ref.read(notificationServiceProvider);
      // await notificationService.initialize();
      // print('Notification service initialized successfully');

      // // Schedule category reminders ONLY after everything is ready
      // print('Setting up notification reminders...');
      // await notificationService.scheduleCategoryReminders();
    //   print('Notification reminders configured');
    // } else {
    //   print('User not authenticated, only initializing basic notification service...');
    //   // For non-authenticated users, only initialize the notification service without scheduling
    //   final notificationService = ref.read(notificationServiceProvider);
    //   await notificationService.initialize();
    //   print('Basic notification service initialized');
    }

    print('App initialization completed');
    return;
  } catch (e, stack) {
    print('Error during initialization: $e');
    print('Stack trace: $stack');
    throw e;
  }
});