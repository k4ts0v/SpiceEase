import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/auth/presentation/auth_controller.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';
import 'package:spiceease/features/navigation_bar.dart';

/// A widget that decides whether to display the HomeScreen or AuthScreen
/// based on the user's authentication state.
class AppWrapper extends ConsumerWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Watches the authentication state using [authControllerProvider].
    final authState = ref.watch(authControllerProvider);

    /// Displays the HomeScreen if the user is authenticated.
    /// Otherwise, shows the AuthScreen to handle authentication.
    return authState.user != null ? const NavBar() : const AuthScreen();
  }
}
