import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewMode { calendar, kanban }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.calendar);
