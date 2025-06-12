import 'package:flutter_riverpod/flutter_riverpod.dart';

// A provider to track if the app is currently active in the foreground
final appActiveStateProvider = StateProvider<bool>((ref) => true);