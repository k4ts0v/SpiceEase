import 'package:flutter_riverpod/flutter_riverpod.dart';

// A provider to track if the user is in focus mode
final focusModeActiveProvider = StateProvider<bool>((ref) => false);