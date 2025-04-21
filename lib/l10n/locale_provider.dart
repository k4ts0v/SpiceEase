import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/l10n/l10n.dart';

/// A [StateProvider] that manages the app's current locale setting.
///
/// By default:
/// - Uses the device's locale if it is supported.
/// - Defaults to English ('en') if the device's locale is unsupported.
final localeProvider = StateProvider<Locale>((ref) {
  /// Fetches the device's current locale using the system settings.
  final deviceLocale = WidgetsBinding.instance.window.locale;

  /// Checks whether the device's locale is supported by the app.
  /// If not supported, defaults to English ('en').
  return L10n.all.contains(deviceLocale) ? deviceLocale : const Locale('en');
});
