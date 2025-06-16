import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_user_model.dart';
import 'package:spiceease/features/navigation_bar.dart';
import 'package:spiceease/features/auth/presentation/auth_controller.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/l10n/locale_provider.dart';
import 'package:spiceease/l10n/l10n.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AppUser?>>(unifiedAuthProvider, (previous, next) {
      final oldUser = previous?.value;
      final newUser = next.value;
      if (oldUser == null && newUser != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NavBar()),
        );
      }
    });

    final controller = ref.watch(authControllerProvider.notifier);
    final state = ref.watch(authControllerProvider);

    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isSmall = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: const [
          LanguageSwitcher(),
          SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: isSmall
            ? _buildMobileLayout(loc, controller, state)
            : _buildDesktopLayout(loc, controller, state),
      ),
    );
  }

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

  Widget _buildDesktopLayout(
      AppLocalizations loc, AuthController controller, AuthState state) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          const Expanded(child: _AuthLogo()),
          Expanded(
            child: _AuthForm(controller: controller, state: state, loc: loc),
          ),
        ],
      ),
    );
  }
}

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
          ? ref.read(localeProvider.notifier).setLocale(locale)
          : null,
    );
  }
}

class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/spiceease_logo.png',
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
        const SizedBox(height: 8),
        Text(
          "Track your health journey",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }
}

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
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.state.isLogin;

    return SizedBox(
      width: 400,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isLogin ? widget.loc.signIn : widget.loc.register,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: widget.loc.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !widget.state.isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: widget.loc.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(widget.state.isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: widget.controller.togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (!isLogin && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                if (!isLogin) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !widget.state.isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: widget.loc.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(widget.state.isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed:
                            widget.controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],

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

                const SizedBox(height: 16),

                if (widget.state.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.state.error!,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.state.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: widget.state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isLogin ? widget.loc.signIn : widget.loc.register,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin
                          ? "Don't have an account? "
                          : "Already have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: widget.controller.toggleAuthMode,
                      child: Text(
                        isLogin ? widget.loc.register : widget.loc.signIn,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.controller.submit(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        widget.state.isLogin ? null : _confirmPasswordController.text.trim(),
        context,
      );
    }
  }

  void _showResetDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.loc.passwordReset),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: widget.loc.email,
              hintText: widget.loc.emailHint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                await widget.controller
                    .resetPassword(emailController.text.trim(), context);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(widget.loc.resetEmail),
          ),
        ],
      ),
    );
  }
}