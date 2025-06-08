import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/providers/current_user_provider.dart';
import 'package:spiceease/features/settings/account_settings_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _checkEmailVerification();
  }

  void _loadUserEmail() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
      final email = await controller.getCurrentUserEmail();
      if (email != null && mounted) {
        setState(() {
          _emailController.text = email;
        });
      }
    });
  }

  void _checkEmailVerification() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final controller = ref.read(accountSettingsControllerProvider.notifier);
        final isVerified = await controller.isCurrentEmailVerified();
        final email = await controller.getCurrentUserEmail();

        print('DEBUG: Email: $email, IsVerified: $isVerified');

        if (!isVerified && email != null && email.isNotEmpty && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showAccountVerificationDialog();
            }
          });
        }
      } catch (e) {
        print('DEBUG: Error checking email verification: $e');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(accountSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.accountSettings,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVerificationStatusCard(theme),
          _buildSectionHeader(localizations.accountInformation, theme),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: localizations.email,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: state.isUpdatingEmail
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: _updateEmail,
                            ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      child: Text(localizations.signOut),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSectionHeader(localizations.security, theme),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: localizations.currentPassword,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: localizations.newPassword,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      helperText: localizations.passwordRequirements,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: localizations.confirmPassword,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: state.isUpdatingPassword
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: _updatePassword,
                            ),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusCard(ThemeData theme) {
    return FutureBuilder<bool>(
      future: ref.read(accountSettingsControllerProvider.notifier).isCurrentEmailVerified(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final isVerified = snapshot.data ?? false;

        if (isVerified) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Verified',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Your account is fully verified and secure',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Not Verified',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Verify your email to secure your account',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showAccountVerificationDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Verify'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _updateEmail() async {
    try {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
      final newEmail = _emailController.text.trim();
      final currentEmail = await controller.getCurrentUserEmail();

      if (newEmail == currentEmail) {
        _showErrorSnackbar('Please enter a different email address');
        return;
      }

      if (newEmail.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
        _showErrorSnackbar('Please enter a valid email address');
        return;
      }

      final result = await controller.updateEmail(newEmail);

      if (!mounted) return;

      if (result.isSuccess) {
        _showEmailChangeVerificationDialog(newEmail);
        _loadUserEmail(); // Reset to current email since change is pending
      } else if (result.retryAction != null) {
        _showReAuthDialog(context, result.retryAction!);
      } else {
        _showErrorSnackbar(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Email update failed: ${e.toString()}');
      }
    }
  }

  void _showEmailChangeVerificationDialog(String newEmail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mark_email_read, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text('Verify New Email')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('A verification email has been sent to:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(newEmail, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text('Click the verification link in the email to complete your email change.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  void _updatePassword() async {
    try {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
      final result = await controller.updatePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        _showSuccessSnackbar(result.message);
        _clearPasswordFields();
      } else if (result.retryAction != null) {
        _showReAuthDialog(context, result.retryAction!);
      } else {
        _showErrorSnackbar(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Password update failed: ${e.toString()}');
      }
    }
  }

  void _showAccountVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.verified_user_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text('Verify Your Account')),
          ],
        ),
        content: Text('Please verify your email address to secure your account and access all features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final controller = ref.read(accountSettingsControllerProvider.notifier);
                await controller.sendEmailVerification();
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackbar('Verification email sent! Please check your inbox.');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showErrorSnackbar('Failed to send verification email: ${e.toString()}');
                }
              }
            },
            icon: const Icon(Icons.mark_email_read),
            label: const Text('Send Verification'),
          ),
        ],
      ),
    );
  }

  void _clearPasswordFields() {
    setState(() {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _showReAuthDialog(
    BuildContext context,
    Future<AccountSettingsResult> Function() retryAction,
  ) async {
    final passwordController = TextEditingController();
    final controller = ref.read(accountSettingsControllerProvider.notifier);
    final email = await controller.getCurrentUserEmail();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Security Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter your password to continue.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final authResult = await controller.reauthenticate(email ?? '', passwordController.text);
                if (!mounted) return;

                if (authResult.isSuccess) {
                  Navigator.pop(context);
                  final result = await retryAction();
                  if (mounted) {
                    if (result.isSuccess) {
                      _showSuccessSnackbar(result.message);
                      if (result.message.contains('Password')) {
                        _clearPasswordFields();
                      }
                    } else {
                      _showErrorSnackbar(result.message);
                    }
                  }
                } else {
                  _showErrorSnackbar(authResult.message);
                }
              } catch (e) {
                if (mounted) {
                  _showErrorSnackbar('Authentication failed: ${e.toString()}');
                }
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    final controller = ref.read(accountSettingsControllerProvider.notifier);
    final result = await controller.signOut();

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      _showSuccessSnackbar(result.message);
    } else {
      _showErrorSnackbar(result.message);
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}