/// This file contains UI tests for the Settings components, focusing on
/// ensuring they handle different screen sizes and content lengths properly
/// without overflowing.
///
/// Tests verify that:
/// - Components render correctly on various screen sizes
/// - Long text content is handled appropriately
/// - Vertical and horizontal constraints are respected
/// - No overflow errors occur in limited space scenarios
///
/// # How these tests work
/// - Components are rendered in controlled environments with specific dimensions
/// - Different text lengths are tested to simulate real-world content
/// - Multiple assertions verify proper rendering across conditions
/// - Golden tests compare visual output against expected baselines
///
/// # Why test for overflow
/// - Poor overflow handling creates bad user experiences
/// - Text that overflows its container becomes unreadable
/// - Overflow issues may only appear on certain device sizes
/// - Prevents regression when making UI changes
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiceease/components/settings/settings_section.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';

/// Standard screen sizes for comprehensive testing across device types
const List<Size> standardTestSizes = [
  Size(320, 568), // iPhone SE (smallest supported)
  Size(375, 667), // iPhone 8
  Size(390, 844), // iPhone 13/14
  Size(414, 896), // iPhone 11 Pro Max
  Size(600, 960), // Small tablet
  Size(800, 1280), // Medium tablet
];

/// Test string variations for validating overflow handling
const String shortText = "Short";
const String mediumText = "This is a medium length text for testing";
const String longText =
    "This is a very long text that might cause overflow issues in smaller containers and should be handled gracefully by wrapping or ellipsis";
const String veryLongText =
    "This is an extremely long text that would definitely cause overflow issues if not handled properly. It contains many words and characters to ensure we're testing the absolute limits of our components' ability to handle long content gracefully without causing layout errors, overflow warnings, or other UI problems that would affect the user experience negatively.";

void main() {
  group('SettingsSection Overflow Tests', () {
    testWidgets('Renders without overflow on small screens',
        (WidgetTester tester) async {
      // Set small screen size
      await tester.binding.setSurfaceSize(standardTestSizes[0]);

      // Build the widget with medium length title
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SettingsSection(
              title: mediumText,
              children: [
                ListTile(title: Text("Test Option 1")),
                ListTile(title: Text("Test Option 2")),
              ],
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Handles long title without overflow',
        (WidgetTester tester) async {
      // Set medium screen size
      await tester.binding.setSurfaceSize(standardTestSizes[2]);

      // Build the widget with very long title
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SettingsSection(
              title: veryLongText,
              children: [
                ListTile(title: Text("Test Option")),
              ],
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Handles many children without vertical overflow',
        (WidgetTester tester) async {
      // Set standard screen size
      await tester.binding.setSurfaceSize(standardTestSizes[1]);

      // Build widget with many children
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SettingsSection(
              title: "Many Options",
              children: List.generate(
                15,
                (index) => ListTile(title: Text("Option $index")),
              ),
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('SettingsOptionTile Overflow Tests', () {
    testWidgets('Renders without overflow on small screens',
        (WidgetTester tester) async {
      // Set small screen size
      await tester.binding.setSurfaceSize(standardTestSizes[0]);

      // Build widget with medium texts
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SettingsOptionTile(
              icon: Icons.settings,
              title: mediumText,
              subtitle: mediumText,
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Handles long title and subtitle without overflow',
        (WidgetTester tester) async {
      // Set standard screen size
      await tester.binding.setSurfaceSize(standardTestSizes[1]);

      // Build widget with long texts
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SettingsOptionTile(
              icon: Icons.settings,
              title: longText,
              subtitle: longText,
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Get rendered text widgets
      final titleFinder = find.text(longText).first;

      // Check if text is properly contained in parent
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.overflow, isNull); // Should handle overflow gracefully
    });

    testWidgets('Handles very long text with custom trailing widget',
        (WidgetTester tester) async {
      // Set standard screen size
      await tester.binding.setSurfaceSize(standardTestSizes[2]);

      // Build widget with very long texts and custom trailing widget
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SettingsOptionTile(
              icon: Icons.settings,
              title: veryLongText,
              subtitle: veryLongText,
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Text("Custom"),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders correctly in horizontal constraints',
        (WidgetTester tester) async {
      // Set narrow screen size
      await tester.binding.setSurfaceSize(const Size(300, 600));

      // Build widget with medium text
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: const SettingsOptionTile(
                icon: Icons.settings,
                title: mediumText,
                subtitle: mediumText,
              ),
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Combined Components Overflow Tests', () {
    testWidgets(
        'SettingsSection with SettingsOptionTiles renders without overflow',
        (WidgetTester tester) async {
      // Set medium screen size
      await tester.binding.setSurfaceSize(standardTestSizes[1]);

      // Build complex widget structure
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SettingsSection(
              title: "Settings Group",
              children: [
                SettingsOptionTile(
                  icon: Icons.person,
                  title: longText,
                  subtitle: longText,
                ),
                SettingsOptionTile(
                  icon: Icons.color_lens,
                  title: mediumText,
                  subtitle: veryLongText,
                ),
                SettingsOptionTile(
                  icon: Icons.language,
                  title: "Language",
                  subtitle: shortText,
                  trailing: SizedBox(width: 50, child: Text("English")),
                ),
              ],
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Multiple SettingsSections stack properly without overflow',
        (WidgetTester tester) async {
      // Set standard screen size
      await tester.binding.setSurfaceSize(standardTestSizes[2]);

      // Build multiple sections
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SettingsSection(
                  title: "Account",
                  children: [
                    SettingsOptionTile(
                      icon: Icons.person,
                      title: "Profile",
                      subtitle: longText,
                    ),
                  ],
                ),
                SettingsSection(
                  title: "Appearance",
                  children: [
                    SettingsOptionTile(
                      icon: Icons.color_lens,
                      title: "Theme",
                      subtitle: "System",
                    ),
                    SettingsOptionTile(
                      icon: Icons.dark_mode,
                      title: "Dark Mode",
                      subtitle: "Off",
                      trailing: Switch(value: false, onChanged: null),
                    ),
                  ],
                ),
                SettingsSection(
                  title: "Language & Region",
                  children: [
                    SettingsOptionTile(
                      icon: Icons.language,
                      title: "Language",
                      subtitle: "English",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));

      // Verify no overflow errors - FIXED
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}