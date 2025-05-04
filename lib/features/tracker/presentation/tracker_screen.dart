import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/tracker/presentation/widgets/tracker_header.dart';
import 'package:spiceease/features/tracker/presentation/widgets/icon_grid.dart';
import 'package:spiceease/features/tracker/presentation/widgets/entity_sections.dart';
import 'package:spiceease/features/tracker/presentation/calendar_widget.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';

const _backgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFF8F9FA),
    Colors.white,
  ],
);

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({Key? key}) : super(key: key);

  void _showModal(BuildContext context, Widget modal) =>
      showDialog(context: context, builder: (_) => modal);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Material(
      child: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const TrackerHeader(),
              const SizedBox(height: 12),
              const CalendarWidget(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconGrid(
                        showModal: _showModal,
                        selectedDate: selectedDate,
                        ref: ref,
                      ),
                      const SizedBox(height: 24),
                      EntitySections(
                        showModal: _showModal,
                        selectedDate: selectedDate,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}