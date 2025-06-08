import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/core/database/firebase_database_rest.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'dart:io' show Platform;

import 'package:spiceease/core/database/firebase_database_service.dart';

/// Provider for the database service
/// Uses REST implementation on Linux, Firebase SDK on other platforms
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  if (Platform.isLinux) {
    // Use REST implementation for Linux
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
    if (projectId == null) {
      throw Exception('FIREBASE_PROJECT_ID not found in .env file');
    }

    return FirestoreDatabaseRestService(
      projectId: projectId,
      authService: ref.read(authServiceProvider),
    );
  } else {
    // For other platforms, use the SDK.
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
    if (projectId == null) {
      throw Exception('FIREBASE_PROJECT_ID not found in .env file');
    }

    return FirebaseDatabaseService();
  }
});
