import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/app/splash_screen.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';
import 'package:spiceease/features/navigation_bar.dart';

class AppWrapper extends ConsumerStatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<AppWrapper> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1) Wait for app initialization (Firebase, AuthService, etc.)
    await ref.read(appInitializerProvider.future);

    // 2) Once initialized, read the current user (first value of the stream)
    final user = await ref.read(unifiedAuthProvider.future);

    // 3) Navigate to the appropriate screen
    if (!mounted) return;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavBar()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always show splash until _bootstrap does its work and pushes a new route
    return const SplashScreen(message: 'Loading SpiceEase…');
  }
}