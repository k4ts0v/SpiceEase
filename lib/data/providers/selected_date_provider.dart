import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final rawNow = DateTime.now();
  print(DateTime(rawNow.year, rawNow.month, rawNow.day));
  return DateTime(rawNow.year, rawNow.month, rawNow.day);
});
