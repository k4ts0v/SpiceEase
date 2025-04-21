import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/core/database/firebase_database_service.dart';
import 'package:spiceease/core/database/firebase_database_rest.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provides the appropriate database service implementation based on platform.
/// Uses Firebase REST API for Linux platform (for compatibility).
/// Uses standard Firebase SDK for another platforms.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  // Get authentication service from dependency tree.
  final authService = ref.watch(authServiceProvider);

  // Load Firebase project ID from environment variables.
  final firebaseProjectId =
      dotenv.env['FIREBASE_PROJECT_ID']!;

  // Use REST implementation for Linux platform.
  if (defaultTargetPlatform == TargetPlatform.linux) {
    return FirestoreDatabaseRestService(
      projectId: firebaseProjectId,
      authService: authService,
    );
  }

  // Use standard Firebase SDK for another platforms.
  return FirebaseDatabaseService();
});
