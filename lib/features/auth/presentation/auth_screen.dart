import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/app/home_screen.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/l10n/l10n.dart';
import 'package:spiceease/l10n/locale_provider.dart';
import 'auth_controller.dart';

// Main authentication screen widget that handles both login and registration
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current authentication state
    final state = ref.watch(authControllerProvider);
    // Get the auth controller for actions
    final controller = ref.read(authControllerProvider.notifier);
    // Get localization strings
    final loc = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    // Listen for authentication state changes
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      // If user was null and now is not null (successful login/register)
      if (prev?.user == null && next.user != null) {
        // Navigate to home screen and replace current route
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });

    // Check if screen width is small (for responsive design)
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        actions: const [
          LanguageSwitcher(), // Language switcher in app bar
          SizedBox(width: 12), // Add some spacing
        ],
      ),
      body: Center(
        child: isSmall
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo section
                  _AuthLogo(loc: loc),
                  // Authentication form (login/register)
                  _AuthForm(controller: controller, state: state, loc: loc),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    // Logo on left side for larger screens
                    Expanded(child: _AuthLogo(loc: loc)),
                    // Form on right side for larger screens
                    Expanded(
                      child: _AuthForm(
                        controller: controller,
                        state: state,
                        loc: loc,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// Language switcher dropdown widget
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current locale from provider
    final currentLocale = ref.watch(localeProvider);

    return DropdownButton<Locale>(
      value: currentLocale,
      icon: const Icon(Icons.language),
      items: L10n.all.map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              // Display flag for the language
              Text(L10n.getFlag(locale.languageCode)),
              const SizedBox(width: 8),
              // Display language name
              Text(L10n.getLanguageName(locale.languageCode)),
            ],
          ),
        );
      }).toList(),
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          // Update locale when new language is selected
          ref.read(localeProvider.notifier).state = newLocale;
        }
      },
    );
  }
}

// Widget for displaying the application logo and title
class _AuthLogo extends StatelessWidget {
  final AppLocalizations loc;
  const _AuthLogo({required this.loc});

  @override
  Widget build(BuildContext context) {
    // Check if screen is small for responsive sizing
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Display the custom logo from assets
        Image.asset(
          'assets/images/logo.png',
          width: isSmall ? 100 : 200, // Adjust size for different screens
          height: isSmall ? 100 : 200,
        ),
        const SizedBox(height: 16),
        // Display the application title
        Container(
          margin: EdgeInsets.only(bottom: 20.0),
          child: Text(
            "SpiceEase",
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// Form widget for authentication (login/register)
class _AuthForm extends StatefulWidget {
  final AuthController controller;
  final AuthState state;
  final AppLocalizations loc;

  const _AuthForm({
    required this.controller,
    required this.state,
    required this.loc,
  });

  @override
  State<_AuthForm> createState() => __AuthFormState();
}

// State class for the authentication form
class __AuthFormState extends State<_AuthForm> {
  // Controllers for form fields
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're in login mode (vs registration)
    final isLogin = widget.state.isLogin;

    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email input field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: widget.loc.email,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          // Password input field
          TextFormField(
            controller: _passwordController,
            obscureText: !widget.state.isPasswordVisible,
            decoration: InputDecoration(
              labelText: widget.loc.password,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(widget.state.isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: widget.controller.togglePasswordVisibility,
              ),
            ),
          ),
          // Show confirm password field only in registration mode
          if (!isLogin) const SizedBox(height: 16),
          if (!isLogin)
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: TextFormField(
                controller: _confirmPasswordController,
                obscureText: !widget.state.isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: widget.loc.confirmPassword,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(widget.state.isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: widget.controller.toggleConfirmPasswordVisibility,
                  ),
                ),
              ),
            ),
          // Forgot password link (only in login mode)
          if (isLogin) const SizedBox(height: 8),
          if (isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showResetPasswordDialog(context),
                child: Text(widget.loc.forgotPassword),
              ),
            ),
          // Display error message if any
          if (widget.state.error != null)
            Text(
              widget.state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 16),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.state.isLoading
                  ? null
                  : () => widget.controller.submit(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        isLogin ? null : _confirmPasswordController.text.trim(),
                        context,
                      ),
              child: widget.state.isLoading
                  ? const CircularProgressIndicator()
                  : Text(isLogin ? widget.loc.signIn : widget.loc.register),
            ),
          ),
          // Toggle between login and register modes
          TextButton(
            onPressed: widget.controller.toggleAuthMode,
            child: Container(
              margin: EdgeInsets.all(16),
              child: Text(isLogin
                  ? widget.loc.createAccount
                  : widget.loc.alreadyHaveAccount),
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog for password reset
  void _showResetPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final loc = AppLocalizations.of(context)!;
    final controller = widget.controller;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.passwordReset),
        content: TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: loc.email,
            hintText: loc.emailHint,
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          // Reset password button
          ElevatedButton(
            onPressed: () async {
              await controller.resetPassword(emailController.text, context);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(loc.resetEmail),
          ),
        ],
      ),
    );
  }
}
