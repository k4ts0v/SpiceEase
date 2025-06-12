import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';
import 'package:spiceease/components/settings/settings_section.dart';
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
                    : localizations.loading,
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
                title: localizations.sendVerificationEmail,
                subtitle: localizations.verifyYourEmailAddress,
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
                subtitle: localizations.updateYourAccountPassword,
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
            title: localizations.accountActions,
            children: [
              SettingsOptionTile(
                icon: Icons.logout_outlined,
                title: localizations.signOut,
                subtitle: localizations.signOutOfYourAccount,
                onTap: () => _showSignOutConfirmation(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusCard(ThemeData theme) {
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<bool>(
      future: ref
          .read(accountSettingsControllerProvider.notifier)
          .isCurrentEmailVerified(),
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
                  const Icon(Icons.verified, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.emailVerified,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          localizations.yourAccountIsFullyVerifiedAndSecure,
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
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.emailNotVerified,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          localizations.verifyYourEmailToSecureYourAccount,
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
                    child: Text(localizations.verify),
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
            Text(localizations.currentEmailColon(_emailController.text)),
            const SizedBox(height: 16),
            TextField(
              controller: newEmailController,
              decoration: InputDecoration(
                labelText: localizations.newEmailAddress,
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
            child: Text(localizations.updateEmail),
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
                    : localizations.updatingPasswordPleaseWait),
                const SizedBox(height: 8),
                Text(
                  localizations.thisMayTakeUpTo2Minutes,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                    onPressed: isUpdating
                        ? null
                        : () {
                            setState(() {
                              isCurrentPasswordVisible =
                                  !isCurrentPasswordVisible;
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
                    onPressed: isUpdating
                        ? null
                        : () {
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
                    onPressed: isUpdating
                        ? null
                        : () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
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
              onPressed: isUpdating
                  ? null
                  : () {
                      progressTimer?.cancel();
                      Navigator.pop(context);
                    },
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      setState(() {
                        isUpdating = true;
                        progressMessage =
                            localizations.verifyingCurrentPassword;
                      });

                      // Update progress messages periodically
                      progressTimer =
                          Timer.periodic(const Duration(seconds: 10), (timer) {
                        if (!isUpdating || !mounted) {
                          timer.cancel();
                          return;
                        }

                        setState(() {
                          switch (timer.tick) {
                            case 1:
                              progressMessage =
                                  localizations.authenticatingWithFirebase;
                              break;
                            case 2:
                              progressMessage =
                                  localizations.processingSecurityChecks;
                              break;
                            case 3:
                              progressMessage = localizations.updatingPassword;
                              break;
                            case 4:
                              progressMessage = localizations.finalizingChanges;
                              break;
                            default:
                              progressMessage =
                                  localizations.pleaseWaitTakingLonger;
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
                  : Text(localizations.updatePassword),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.signOut),
        content: Text(localizations.areYouSureYouWantToSignOut),
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
    final localizations = AppLocalizations.of(context)!;

    try {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
      final currentEmail = await controller.getCurrentUserEmail();

      if (newEmail == currentEmail) {
        _showErrorSnackbar(localizations.pleaseEnterADifferentEmailAddress);
        return;
      }

      if (newEmail.isEmpty ||
          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
        _showErrorSnackbar(localizations.pleaseEnterAValidEmailAddress);
        return;
      }

      final result = await controller.updateEmail(newEmail);

      if (!mounted) return;

      if (result.isSuccess) {
        // Show email verification dialog with re-login requirement
        _showEmailChangeVerificationDialog(newEmail);
      } else if (result.retryAction != null) {
        _showReAuthDialog(context, result.retryAction!);
      } else {
        _showErrorSnackbar(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(localizations.emailUpdateFailed(e.toString()));
      }
    }
  }

  void _showEmailChangeVerificationDialog(String newEmail) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mark_email_read,
                color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(localizations.emailChangeInitiated)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.aVerificationEmailHasBeenSentTo),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(newEmail,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizations.importantSteps,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.emailChangeSteps,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.yourDisplayedEmailWillRemainUnchanged,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final controller =
                    ref.read(accountSettingsControllerProvider.notifier);
                await controller.sendEmailVerification();
                if (mounted) {
                  _showSuccessSnackbar(
                      localizations.verificationEmailResentTo(newEmail));
                }
              } catch (e) {
                if (mounted) {
                  _showErrorSnackbar(
                      localizations.failedToResendEmail(e.toString()));
                }
              }
            },
            child: Text(localizations.resendEmail),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.gotIt),
          ),
        ],
      ),
    );
  }

  Future<void> _sendVerificationEmail() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
      await controller.sendEmailVerification();
      if (mounted) {
        _showSuccessSnackbar(localizations.verificationEmailSent);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
            localizations.failedToSendVerificationEmail(e.toString()));
      }
    }
  }

  void _showAccountVerificationDialog() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.verified_user_outlined,
                color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(localizations.verifyYourAccount)),
          ],
        ),
        content: Text(localizations.pleaseVerifyYourEmailAddress),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.later),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final controller =
                    ref.read(accountSettingsControllerProvider.notifier);
                await controller.sendEmailVerification();
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackbar(localizations.verificationEmailSent);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showErrorSnackbar(localizations
                      .failedToSendVerificationEmail(e.toString()));
                }
              }
            },
            icon: const Icon(Icons.mark_email_read),
            label: Text(localizations.sendVerification),
          ),
        ],
      ),
    );
  }

  Future<void> _showReAuthDialog(
    BuildContext context,
    Future<AccountSettingsResult> Function() retryAction,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    final controller = ref.read(accountSettingsControllerProvider.notifier);
    final email = await controller.getCurrentUserEmail();
    bool isPasswordVisible = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(localizations.securityVerification),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(localizations.pleaseEnterYourCurrentPasswordToContinue),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: localizations.currentPassword,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
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
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final authResult = await controller.reauthenticate(
                      email ?? '', passwordController.text);
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
                    _showErrorSnackbar(
                        localizations.authenticationFailed(e.toString()));
                  }
                }
              },
              child: Text(localizations.verify),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePasswordFromDialog(String currentPassword,
      String newPassword, String confirmPassword) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final controller = ref.read(accountSettingsControllerProvider.notifier);
      final result = await controller.updatePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        _showSuccessSnackbar(result.message);
      } else if (result.retryAction != null) {
        _showReAuthDialog(context, result.retryAction!);
      } else {
        _showErrorSnackbar(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(localizations.passwordUpdateFailed(e.toString()));
      }
    }
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
