import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/database/database_provider.dart';

final appInitializerProvider = FutureProvider<void>((ref) async {

  // Define and initialize Firebase (Both for auth and database)- If there are different providers, initialize auth first and then the database.
  final authService = ref.read(authServiceProvider);
  await authService.initialize();

  // Define and initialize auth services
  final databaseService = ref.read(databaseServiceProvider);
  await databaseService.initialize();
});
