import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';
import 'package:spiceease/components/settings/settings_section.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
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

        if (!isVerified && email != null && email.isNotEmpty && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showAccountVerificationDialog();
            }
          });
        }
      } catch (e) {
        debugPrint('Error checking email verification: $e');
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
        title: Text(localizations.accountSettings),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Verification Status Card
          _buildVerificationStatusCard(theme),

          // Email Settings Section
          SettingsSection(
            title: localizations.email,
            children: [
              SettingsOptionTile(
                icon: Icons.email_outlined,
                title: localizations.changeEmail,
                subtitle: _emailController.text.isNotEmpty 
                    ? _emailController.text 
                    : 'Loading...',
                onTap: () => _showChangeEmailDialog(),
                trailing: state.isUpdatingEmail
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              SettingsOptionTile(
                icon: Icons.mark_email_read_outlined,
                title: 'Send Verification Email',
                subtitle: 'Verify your email address',
                onTap: () => _sendVerificationEmail(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Password Settings Section
          SettingsSection(
            title: localizations.security,
            children: [
              SettingsOptionTile(
                icon: Icons.lock_outline,
                title: localizations.changePassword,
                subtitle: 'Update your account password',
                onTap: () => _showChangePasswordDialog(),
                trailing: state.isUpdatingPassword
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Account Actions Section
          SettingsSection(
            title: 'Account Actions',
            children: [
              SettingsOptionTile(
                icon: Icons.logout_outlined,
                title: localizations.signOut,
                subtitle: 'Sign out of your account',
                onTap: () => _showSignOutConfirmation(),
              ),
            ],
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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
                    child: const Text('Verify'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _showChangeEmailDialog() {
    final localizations = AppLocalizations.of(context)!;
    final newEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.changeEmail),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current email: ${_emailController.text}'),
            const SizedBox(height: 16),
            TextField(
              controller: newEmailController,
              decoration: InputDecoration(
                labelText: 'New Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateEmail(newEmailController.text);
            },
            child: const Text('Update Email'),
          ),
        ],
      ),
    );
  }

  
    void _showChangePasswordDialog() {
      final localizations = AppLocalizations.of(context)!;
      final currentPasswordController = TextEditingController();
      final newPasswordController = TextEditingController();
      final confirmPasswordController = TextEditingController();
      bool isCurrentPasswordVisible = false;
      bool isNewPasswordVisible = false;
      bool isConfirmPasswordVisible = false;
      bool isUpdating = false;
      String progressMessage = '';
      Timer? progressTimer;
      
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(localizations.changePassword),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpdating) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(progressMessage.isNotEmpty 
                      ? progressMessage 
                      : 'Updating password, please wait...'),
                  const SizedBox(height: 8),
                  const Text(
                    'This may take up to 2 minutes due to security checks...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: currentPasswordController,
                  enabled: !isUpdating,
                  decoration: InputDecoration(
                    labelText: localizations.currentPassword,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(isCurrentPasswordVisible 
                          ? Icons.visibility_off 
                          : Icons.visibility),
                      onPressed: isUpdating ? null : () {
                        setState(() {
                          isCurrentPasswordVisible = !isCurrentPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isCurrentPasswordVisible,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  enabled: !isUpdating,
                  decoration: InputDecoration(
                    labelText: localizations.newPassword,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    helperText: localizations.passwordRequirements,
                    suffixIcon: IconButton(
                      icon: Icon(isNewPasswordVisible 
                          ? Icons.visibility_off 
                          : Icons.visibility),
                      onPressed: isUpdating ? null : () {
                        setState(() {
                          isNewPasswordVisible = !isNewPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isNewPasswordVisible,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  enabled: !isUpdating,
                  decoration: InputDecoration(
                    labelText: localizations.confirmPassword,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(isConfirmPasswordVisible 
                          ? Icons.visibility_off 
                          : Icons.visibility),
                      onPressed: isUpdating ? null : () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isConfirmPasswordVisible,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isUpdating ? null : () {
                  progressTimer?.cancel();
                  Navigator.pop(context);
                },
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: isUpdating ? null : () async {
                  setState(() {
                    isUpdating = true;
                    progressMessage = 'Verifying current password...';
                  });
                  
                  // Update progress messages periodically
                  progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
                    if (!isUpdating || !mounted) {
                      timer.cancel();
                      return;
                    }
                    
                    setState(() {
                      switch (timer.tick) {
                        case 1:
                          progressMessage = 'Authenticating with Firebase...';
                          break;
                        case 2:
                          progressMessage = 'Processing security checks...';
                          break;
                        case 3:
                          progressMessage = 'Updating password...';
                          break;
                        case 4:
                          progressMessage = 'Finalizing changes...';
                          break;
                        default:
                          progressMessage = 'Please wait, this is taking longer than usual...';
                      }
                    });
                  });
                  
                  try {
                    await _updatePasswordFromDialog(
                      currentPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } finally {
                    progressTimer?.cancel();
                    if (mounted) {
                      setState(() {
                        isUpdating = false;
                        progressMessage = '';
                      });
                    }
                  }
                },
                child: isUpdating 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Password'),
              ),
            ],
          ),
        ),
      );
    }
  
  // ...existing code...


  void _showSignOutConfirmation() {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.signOut),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(localizations.signOut),
          ),
        ],
      ),
    );
  }

  Future<void> _updateEmail(String newEmail) async {
    try {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
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
        // Update the displayed email immediately
        setState(() {
          _emailController.text = newEmail;
        });
        
        _showEmailChangeVerificationDialog(newEmail);
        // Remove the _loadUserEmail() call since we've already updated the display
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

  Future<void> _updatePasswordFromDialog(String currentPassword, String newPassword, String confirmPassword) async {
    print('DEBUG: Screen - _updatePasswordFromDialog called');
    print('DEBUG: Current password provided: ${currentPassword.isNotEmpty}');
    print('DEBUG: New password provided: ${newPassword.isNotEmpty}');
    print('DEBUG: Confirm password provided: ${confirmPassword.isNotEmpty}');

    try {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
      final result = await controller.updatePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      if (!mounted) return;

      print('DEBUG: Screen - Password update result: ${result.isSuccess}');
      print('DEBUG: Screen - Result message: ${result.message}');

      if (result.isSuccess) {
        _showSuccessSnackbar(result.message);
      } else if (result.retryAction != null) {
        _showReAuthDialog(context, result.retryAction!);
      } else {
        _showErrorSnackbar(result.message);
      }
    } catch (e) {
      print('DEBUG: Screen - Exception in _updatePasswordFromDialog: $e');
      if (mounted) {
        _showErrorSnackbar('Password update failed: ${e.toString()}');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
      await controller.sendEmailVerification();
      if (mounted) {
        _showSuccessSnackbar('Verification email sent! Please check your inbox.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to send verification email: ${e.toString()}');
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
            const Expanded(child: Text('Verify New Email')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A verification email has been sent to:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(newEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Text('Click the verification link in the email to complete your email change.'),
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

  void _showAccountVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.verified_user_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Verify Your Account')),
          ],
        ),
        content: const Text('Please verify your email address to secure your account and access all features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
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

  Future<void> _showReAuthDialog(
    BuildContext context,
    Future<AccountSettingsResult> Function() retryAction,
  ) async {
    final passwordController = TextEditingController();
    final controller = ref.read(accountSettingsControllerProvider.notifier);
    final email = await controller.getCurrentUserEmail();
    bool isPasswordVisible = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Security Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your current password to continue.'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible 
                        ? Icons.visibility_off 
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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