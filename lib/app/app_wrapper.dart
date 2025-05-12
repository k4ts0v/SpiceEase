
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/providers/current_user_provider.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';
import 'package:spiceease/features/navigation_bar.dart';

class AppWrapper extends ConsumerWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUserSignedInAsync = ref.watch(isUserSignedInProvider);

    return isUserSignedInAsync.when(
      data: (isSignedIn) {
        if (isSignedIn) {
          // If user is already signed in, navigate directly to your app’s main screen (e.g. NavBar).
          return const NavBar();
        } else {
          // Otherwise, show AuthScreen.
          return const AuthScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const AuthScreen(),
    );
  }
}