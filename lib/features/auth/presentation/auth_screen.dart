import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/tracker/presentation/tracker_screen.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/l10n/l10n.dart';
import 'package:spiceease/l10n/locale_provider.dart';
import 'auth_controller.dart';

/// Main authentication screen handling both login and registration
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final loc = AppLocalizations.of(context)!;
    final isSmall = MediaQuery.of(context).size.width < 600;

    // Handle successful authentication redirect
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (prev?.user == null && next.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TrackerScreen()),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(actions: const [LanguageSwitcher(), SizedBox(width: 12)]),
      body: Center(
        child: isSmall
            ? _buildMobileLayout(loc, controller, state)
            : _buildDesktopLayout(loc, controller, state),
      ),
    );
  }

  /// Responsive layout for mobile devices
  Widget _buildMobileLayout(
      AppLocalizations loc, AuthController controller, AuthState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _AuthLogo(),
        _AuthForm(controller: controller, state: state, loc: loc),
      ],
    );
  }

  /// Responsive layout for desktop/tablet
  Widget _buildDesktopLayout(
      AppLocalizations loc, AuthController controller, AuthState state) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(child: _AuthLogo()),
          Expanded(
              child: _AuthForm(controller: controller, state: state, loc: loc)),
        ],
      ),
    );
  }
}

/// Language selection dropdown
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return DropdownButton<Locale>(
      value: currentLocale,
      icon: const Icon(Icons.language),
      items: L10n.all
          .map((locale) => DropdownMenuItem(
                value: locale,
                child: Row(
                  children: [
                    Text(L10n.getFlag(locale.languageCode)),
                    const SizedBox(width: 8),
                    Text(L10n.getLanguageName(locale.languageCode)),
                  ],
                ),
              ))
          .toList(),
      onChanged: (locale) => locale != null
          ? ref.read(localeProvider.notifier).state = locale
          : null,
    );
  }
}

/// Application logo and title
class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: isSmall ? 100 : 200,
          height: isSmall ? 100 : 200,
        ),
        const SizedBox(height: 16),
        Text(
          "SpiceEase",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

/// Authentication form with dynamic fields for login/register
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

class __AuthFormState extends State<_AuthForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.state.isLogin;

    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username field (registration only)
          if (!isLogin) ...[
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10), // Bottom margin
          ],

          // Email field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: widget.loc.email,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),

          // Password field
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

          // Confirm password (registration only)
          if (!isLogin) ...[
            const SizedBox(height: 10),
            TextFormField(
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
          ],

          // Forgot password (login only)
          if (isLogin) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showResetDialog(context),
                child: Text(widget.loc.forgotPassword),
              ),
            ),
          ],

          // Error message
          if (widget.state.error != null)
            Text(
              widget.state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),

          const SizedBox(height: 10),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.state.isLoading ? null : _handleSubmit,
              child: widget.state.isLoading
                  ? const CircularProgressIndicator()
                  : Text(isLogin ? widget.loc.signIn : widget.loc.register),
            ),
          ),

          // Toggle auth mode
          TextButton(
            onPressed: widget.controller.toggleAuthMode,
            child: Text(isLogin
                ? widget.loc.createAccount
                : widget.loc.alreadyHaveAccount),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    widget.controller.submit(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      widget.state.isLogin ? null : _confirmPasswordController.text.trim(),
      widget.state.isLogin ? null : _usernameController.text.trim(),
      context,
    );
  }

  void _showResetDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.loc.passwordReset),
        content: TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: widget.loc.email,
            hintText: widget.loc.emailHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.controller
                  .resetPassword(emailController.text, context);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(widget.loc.resetEmail),
          ),
        ],
      ),
    );
  }
}