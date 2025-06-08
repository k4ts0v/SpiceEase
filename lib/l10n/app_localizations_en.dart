// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign out';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create new account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get sessionExpired => 'Session expired. Please login again.';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get recoveryEmailSent => 'A recovery email has been sent.';

  @override
  String get invalidLoginCredentials => 'Incorrect email or password.';

  @override
  String get wrongPassword => 'Incorrect email or password.';

  @override
  String get userNotFound => 'Incorrect email or password.';

  @override
  String get emailAlreadyInUse => 'This email is already registered. Try logging in instead.';

  @override
  String get missingPassword => 'Please enter your password.';

  @override
  String get passwordMismatch => 'The passwords are not equal.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordReset => 'Password reset';

  @override
  String get emailHint => 'Enter your email.';

  @override
  String get resetEmail => 'Send reset email.';

  @override
  String get cancel => 'Cancel';

  @override
  String get passwordResetEmail => 'The email for resetting the password was sent!';

  @override
  String get resetPasswordError => 'An error ocurred while resetting the password.';

  @override
  String get unknownError => 'An unknown error happened.';

  @override
  String get username => 'Username';

  @override
  String get username_required => 'Username is required.';

  @override
  String get symptom => 'Symptom';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get task => 'Task';

  @override
  String get tasks => 'Tasks';

  @override
  String get habit => 'Habit';

  @override
  String get habits => 'Habits';

  @override
  String get category => 'Category';

  @override
  String get severity => 'Severity';

  @override
  String get due => 'Due';

  @override
  String get status => 'Status';

  @override
  String get noDueDate => 'No due date';

  @override
  String get noTimeEstimate => 'No time estimate';

  @override
  String get done => 'Done';

  @override
  String get pending => 'Pending';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthlyDays => 'Monthly (days)';

  @override
  String get noDescription => 'No description';

  @override
  String get frequency => 'Frequency';

  @override
  String get title => 'Title';

  @override
  String get additionalText => 'Additional Text';

  @override
  String get noItemsYet => 'No items yet';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String deleteConfirmationMessage(Object item) {
    return 'Are you sure you want to delete \"$item\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get calendarFirstDay => 'First Day';

  @override
  String get calendarLastDay => 'Last Day';

  @override
  String get calendarMonday => 'Monday';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarSelectedDay => 'Selected Day';

  @override
  String get calendarStyleHeaderTitle => 'Calendar Header Title';

  @override
  String get calendarStyleHeaderFormatButtonVisible => 'Format Button Visible';

  @override
  String get calendarStyleHeaderTitleCentered => 'Header Title Centered';

  @override
  String get calendarStyleDaysOfWeek => 'Days of Week';

  @override
  String editTitle(Object item) {
    return 'Edit $item';
  }

  @override
  String newTitle(Object item) {
    return 'New $item';
  }

  @override
  String deleteConfirmationTitle(Object item) {
    return 'Delete $item?';
  }

  @override
  String get save => 'Save';

  @override
  String get name => 'Name';

  @override
  String get customCategory => 'Custom Category';

  @override
  String requiredField(Object field) {
    return '$field is required';
  }

  @override
  String get monthly => 'Monthly';

  @override
  String get dayOfMonth => 'Day of Month (1-31)';

  @override
  String pleaseSelectA(Object field) {
    return 'Please select at least one $field';
  }

  @override
  String get addDayOfMonth => 'Add Day of Month';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get description => 'Description';

  @override
  String get priority => 'Priority';

  @override
  String dueDate(Object date) {
    return 'Due: $date';
  }

  @override
  String get noDueDateSet => 'No due date set';

  @override
  String get setDueDate => 'Set Due Date';

  @override
  String completedAt(Object date) {
    return 'Completed: $date';
  }

  @override
  String get notCompleted => 'Not completed';

  @override
  String get setCompleted => 'Set Completed';

  @override
  String get estimate => 'Estimate';

  @override
  String estimatedTime(Object time) {
    return 'Estimated time: $time';
  }

  @override
  String get generateSubtasks => 'Break it into subtasks';

  @override
  String get generatingSubtasks => 'Generating subtasks...';

  @override
  String get noSubtasksGenerated => 'No subtasks were generated';

  @override
  String failedToGenerateSubtasks(Object error) {
    return 'Failed to generate subtasks: $error';
  }

  @override
  String get completed => 'Completed';

  @override
  String get notes => 'Notes';

  @override
  String get timesPerDay => 'Times per day';

  @override
  String get customTimes => 'Custom Times';

  @override
  String get dose => 'Dose';

  @override
  String get customUnit => 'Custom Unit';

  @override
  String get unit => 'Unit';

  @override
  String get markAsTaken => 'Mark as taken';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get physical => 'Physical';

  @override
  String get psychological => 'Psychological';

  @override
  String get custom => 'Custom';

  @override
  String get thisSymptom => 'this symptom';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get enterDayOfMonth => 'Enter Day of Month (1-31)';

  @override
  String get dayOfMonthHint => 'e.g., 1, 15, 31';

  @override
  String dayNumber(Object number) {
    return 'Day $number';
  }

  @override
  String get selectWeekday => 'Please select at least one weekday';

  @override
  String get selectDayOfMonth => 'Please select at least one day of the month';

  @override
  String get thisHabit => 'this habit';

  @override
  String get thisTask => 'this task';

  @override
  String get breakIntoSubtasks => 'Break into subtasks';

  @override
  String get breakIntoSubtasksPrompt => 'Do you want to break this task into subtasks?';

  @override
  String get subtask => 'Subtask';

  @override
  String get subtasks => 'Subtasks';

  @override
  String subtaskFor(Object taskTitle) {
    return 'Subtask for: $taskTitle';
  }

  @override
  String currentEstimate(Object time, Object unit) {
    return 'Current estimate: $time $unit';
  }

  @override
  String get mood => 'Mood';

  @override
  String get thisMoodEntry => 'this mood entry';

  @override
  String get energy => 'Energy';

  @override
  String get thisEnergyEntry => 'this energy entry';

  @override
  String get selectMoodLevel => 'Select mood level';

  @override
  String get moodLevelScale => '1 = Very low, 10 = Excellent';

  @override
  String get medication => 'Medication';

  @override
  String get thisMedication => 'this medication';

  @override
  String get doseRequired => 'Dose is required';

  @override
  String get customValue => 'Custom Value';

  @override
  String get enterDayHint => 'Enter a number and press Add';

  @override
  String get addDay => 'Add day';

  @override
  String get selectAtLeastOneDay => 'Please select at least one day';

  @override
  String minutesAbbreviation(Object value) {
    return '$value min';
  }

  @override
  String get estimatedTimeLabel => 'Estimated time';

  @override
  String get titleRequiredForSubtasks => 'Title is required for subtasks';

  @override
  String get addNew => 'Add new';

  @override
  String get additionalNotes => 'Additional notes';

  @override
  String get timeManagement => 'Time Management';

  @override
  String get kanban => 'Kanban';

  @override
  String get kanbanDescription => 'Visualize your workflow with cards organized in columns to track progress.';

  @override
  String get timeBlocks => 'Time Blocks';

  @override
  String get timeBlocksDescription => 'Schedule your day in dedicated time blocks to increase focus and productivity.';

  @override
  String get flowmodoro => 'Flowmodoro';

  @override
  String get flowmodoroDescription => 'Work while you feel productive, then take a proportional break to recharge.';

  @override
  String get noTasksInThisColumn => 'No tasks in this column';

  @override
  String get inProgress => 'In Progress';

  @override
  String get todo => 'To Do';

  @override
  String get error => 'Error';

  @override
  String get tasksWithoutDueDate => 'Tasks without due date';

  @override
  String get noTasksWithoutDueDate => 'No tasks without due date';

  @override
  String get noTasks => 'No tasks';

  @override
  String get unitsTaken => 'Units Taken Today';

  @override
  String unitTakenOf(Object taken, Object total) {
    return '$taken of $total taken';
  }

  @override
  String get taken => 'Taken';

  @override
  String get takenS => 'Taken';

  @override
  String get notTaken => 'Not taken';

  @override
  String get refresh => 'Refresh';

  @override
  String errorSavingTask(Object error) {
    return 'Error saving task: $error';
  }

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get insights => 'Insights';

  @override
  String get profile => 'Profile';

  @override
  String get dragTasksHere => 'Drag tasks here';

  @override
  String get lowestPriority => 'Lowest Priority';

  @override
  String get lowPriority => 'Low Priority';

  @override
  String get mediumPriority => 'Medium Priority';

  @override
  String get highPriority => 'High Priority';

  @override
  String get highestPriority => 'Highest Priority';

  @override
  String get newTask => 'New Task';

  @override
  String get loading => 'Loading...';

  @override
  String get initializationError => 'Initialization error';

  @override
  String get close => 'Close';

  @override
  String get clearCompletion => 'Clear completion';

  @override
  String get tablets => 'Tablets';

  @override
  String get second => 'second';

  @override
  String get seconds => 'seconds';

  @override
  String get minute => 'minute';

  @override
  String get minutes => 'minutes';

  @override
  String get hour => 'hour';

  @override
  String get hours => 'hours';

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String get week => 'week';

  @override
  String get weeks => 'weeks';

  @override
  String get month => 'month';

  @override
  String get months => 'months';

  @override
  String get year => 'year';

  @override
  String get estimateInstructions => 'Give the estimate in numbers. For ranges, separate them using \'to\'.';

  @override
  String get allTasksScheduled => 'All tasks are scheduled';

  @override
  String get unscheduledTasks => 'Unscheduled tasks';

  @override
  String get unschedule => 'Unschedule';

  @override
  String get unscheduleTaskConfirmation => 'Remove this task from the schedule? It will remain in your task list.';

  @override
  String get noEndTime => 'No end time set';

  @override
  String get setEndTime => 'Set end time';

  @override
  String get setStartTime => 'Set start time';

  @override
  String get startTime => 'Start time';

  @override
  String get noStartTime => 'No start time set';

  @override
  String get endTime => 'End time';

  @override
  String get clear => 'Clear';

  @override
  String get selectTaskForFlowmodoro => 'Select a task for Flowmodoro';

  @override
  String get flowmodoroExplanation => 'Focus on one task at a time with timed work and break intervals';

  @override
  String get selectATaskToStart => 'Select a task to start';

  @override
  String get configureFlowmodoro => 'Configure flowmodoro';

  @override
  String get focusTime => 'Focus Time';

  @override
  String get breakTime => 'Break Time';

  @override
  String get cyclesToComplete => 'Cycles to complete';

  @override
  String get cycles => 'cycles';

  @override
  String get startFlowmodoro => 'Start flowmodoro';

  @override
  String get stopFlowmodoro => 'Stop flowmodoro';

  @override
  String get flowmodoroCompleted => 'Flowmodoro completed';

  @override
  String get markTaskAsCompleted => 'Would you like to mark this task as completed?';

  @override
  String get notYet => 'Not Yet';

  @override
  String get markAsDone => 'Mark as done';

  @override
  String get taskMarkedAsCompleted => 'Task marked as completed';

  @override
  String get cycleProgress => 'Cycle \$1 of \$2';

  @override
  String get relax => 'Relax';

  @override
  String get focus => 'Focus';

  @override
  String get noTasksAvailable => 'No tasks available';

  @override
  String errorMarkingTaskComplete(Object error) {
    return 'Error marking task as complete: $error';
  }

  @override
  String get breakTimeEnded => 'Break Time Ended';

  @override
  String get focusTimeEnded => 'Focus Time Ended';

  @override
  String get timeToFocusAgain => 'Time to focus on your task again!';

  @override
  String get timeToTakeABreak => 'Great work! Time to take a short break.';

  @override
  String get gotIt => 'Got it';

  @override
  String get errorLoadingSubtasks => 'Error loading subtasks: ';

  @override
  String get noSubtasks => 'No subtasks';

  @override
  String get thisSubtask => 'this subtask';

  @override
  String get subtaskTitle => 'Subtask title';

  @override
  String get addNewSubtask => 'Add new subtask';

  @override
  String get speedrun => 'Speedrun';

  @override
  String get speedrunDescription => 'Prove yourself by completing tasks in a limited time. The faster you finish, the more points you earn.';

  @override
  String get diceRoller => 'Dice Roller';

  @override
  String get diceRollerDescription => 'Roll dice to generate random numbers for your tasks. Use it to know how many items you have to complete.';

  @override
  String get metricsOverTime => 'Metrics over time';

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get streaks => 'Streaks';

  @override
  String longestTasksStreak(Object days) {
    return 'Longest tasks streak: $days days';
  }

  @override
  String longestHabitsStreak(Object days) {
    return 'Longest habits streak: $days days';
  }

  @override
  String get timeManagementTechniques => 'Time Management Techniques';

  @override
  String get flowmodoroInsights => 'Flowmodoro Insights';

  @override
  String sessions(Object count) {
    return 'Sessions: $count';
  }

  @override
  String combinedTime(Object time) {
    return 'Combined Time: $time';
  }

  @override
  String get timeBlockInsights => 'Time-Block Insights';

  @override
  String get blocks => 'Blocks';

  @override
  String get time => 'Time';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get language => 'Language';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get security => 'Security';

  @override
  String get incompleteSubtasksWarning => 'Some subtasks are not completed yet.';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get historyRetention => 'History Retention';

  @override
  String daysOfHistory(String days) {
    return '$days days';
  }

  @override
  String get contextAwareness => 'Context Awareness';

  @override
  String get alwaysShowCritical => 'Always Show Critical Notifications';

  @override
  String get alwaysShowCriticalDescription => 'Critical notifications will be shown regardless of energy levels or symptoms';

  @override
  String get lowEnergyThreshold => 'Low Energy Threshold';

  @override
  String get lowEnergyDescription => 'When your energy is below this level, only high priority notifications will be shown';

  @override
  String get highSymptomThreshold => 'High Symptom Threshold';

  @override
  String get highSymptomDescription => 'When your symptoms are above this level, only critical notifications will be shown';

  @override
  String get quietHours => 'Quiet Hours';

  @override
  String get enableQuietHours => 'Enable Quiet Hours';

  @override
  String get quietHoursStart => 'Start Time';

  @override
  String get quietHoursEnd => 'End Time';

  @override
  String get notificationCategories => 'Notification Categories';

  @override
  String get appointments => 'Appointments';

  @override
  String get system => 'System';

  @override
  String get notificationHistory => 'Notification History';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get configureNotificationPreferences => 'Configure how and when notifications appear';

  @override
  String get viewPastNotifications => 'View previously received notifications';

  @override
  String get reminders => 'Reminders';

  @override
  String get loggingReminders => 'Logging Reminders';

  @override
  String get reminderSettings => 'Reminder Settings';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get reminderDays => 'Reminder Days';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get taskReminderDescription => 'Daily reminder to review pending tasks';

  @override
  String get habitReminderDescription => 'Daily reminder to check habit progress';

  @override
  String get medicationReminderDescription => 'Daily reminder to take medications';

  @override
  String get symptomReminderDescription => 'Daily reminder to log symptoms';

  @override
  String get energyReminderDescription => 'Daily reminder to log energy levels';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get loggingRemindersDescription => 'Daily reminders to log your health data';

  @override
  String get categoryReminders => 'Category Reminders';

  @override
  String get categoryRemindersDescription => 'Set up daily reminders for each type of data you want to track';

  @override
  String get specificItemReminders => 'Specific Item Reminders';

  @override
  String get specificItemRemindersDescription => 'Allow setting reminders for individual tasks, habits, and medications';

  @override
  String get enableSpecificRemindersFor => 'Enable specific reminders for:';

  @override
  String get notificationCategoriesDescription => 'Choose which types of notifications you want to receive';

  @override
  String get taskSpecificRemindersDescription => 'Set due date reminders for individual tasks';

  @override
  String get habitSpecificRemindersDescription => 'Set time-based reminders for individual habits';

  @override
  String get medicationSpecificRemindersDescription => 'Set medication time reminders';

  @override
  String get specificRemindersDescription => 'Set individual reminders';

  @override
  String thisItem(String itemName) {
    return 'this $itemName';
  }

  @override
  String item(String itemName) {
    return '$itemName';
  }

  @override
  String failedToSaveItem(String itemName) {
    return 'Failed to save $itemName';
  }

  @override
  String failedToDeleteItem(String itemName) {
    return 'Failed to delete $itemName';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get lightThemeDesc => 'Always use light theme';

  @override
  String get darkThemeDesc => 'Always use dark theme';

  @override
  String get systemThemeDesc => 'Follow system setting';

  @override
  String get customizeAppColors => 'Customize app colors';

  @override
  String get toggleDarkMode => 'Toggle dark mode';

  @override
  String get languageAndRegion => 'Language & Region';

  @override
  String get languageChangedTo => 'Language changed to';

  @override
  String get systemDefault => 'System Default';

  @override
  String get dataAndPrivacy => 'Data & Privacy';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportImportData => 'Export, import, and backup data';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacySettings => 'Privacy settings and data usage';

  @override
  String get supportAndInfo => 'Support & Information';

  @override
  String get help => 'Help';

  @override
  String get faqAndSupport => 'FAQ and support';

  @override
  String get about => 'About';

  @override
  String get appInfo => 'App information and credits';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get developer => 'Developer';

  @override
  String get website => 'Website';

  @override
  String get sourceCode => 'Source Code';

  @override
  String get licenses => 'Licenses';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get contact => 'Contact';

  @override
  String get reportBug => 'Report a Bug';

  @override
  String get requestFeature => 'Request a Feature';

  @override
  String get rateApp => 'Rate the App';

  @override
  String get shareApp => 'Share the App';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get backupData => 'Backup Data';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get clearData => 'Clear Data';

  @override
  String get clearDataWarning => 'This will permanently delete all your data. This action cannot be undone.';

  @override
  String get clearDataConfirm => 'Are you sure you want to clear all data?';

  @override
  String get confirm => 'Confirm';

  @override
  String get dataExported => 'Data exported successfully';

  @override
  String get dataImported => 'Data imported successfully';

  @override
  String get dataBackedUp => 'Data backed up successfully';

  @override
  String get dataRestored => 'Data restored successfully';

  @override
  String get dataCleared => 'Data cleared successfully';

  @override
  String get exportFailed => 'Failed to export data';

  @override
  String get importFailed => 'Failed to import data';

  @override
  String get backupFailed => 'Failed to backup data';

  @override
  String get restoreFailed => 'Failed to restore data';

  @override
  String get clearFailed => 'Failed to clear data';

  @override
  String get selectFile => 'Select File';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get invalidFile => 'Invalid file format';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get storagePermissionRequired => 'Storage permission is required to export/import data';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get dataProtection => 'Data Protection';

  @override
  String get dataProtectionDesc => 'Your data is stored locally on your device and is not shared with third parties';

  @override
  String get analytics => 'Analytics';

  @override
  String get analyticsDesc => 'Help improve the app by sending anonymous usage data';

  @override
  String get crashReporting => 'Crash Reporting';

  @override
  String get crashReportingDesc => 'Send crash reports to help fix bugs';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get howToUse => 'How to Use';

  @override
  String get tutorials => 'Tutorials';

  @override
  String get keyboardShortcuts => 'Keyboard Shortcuts';

  @override
  String get tips => 'Tips & Tricks';

  @override
  String get troubleshooting => 'Troubleshooting';

  @override
  String get commonIssues => 'Common Issues';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get tracker => 'Tracker';

  @override
  String get appCrashesOrFreezes => 'App Crashes or freezes';

  @override
  String get appCrashesDescription => 'The app stops responding or closes unexpectedly';

  @override
  String get dataSyncIssues => 'Data Not Syncing';

  @override
  String get dataSyncDescription => 'Changes aren\'t being saved or data appears missing';

  @override
  String get performanceIssues => 'Performance issues';

  @override
  String get performanceDescription => 'The app is running slowly or taking long to load';

  @override
  String get timerNotWorking => 'Timer not working';

  @override
  String get timerDescription => 'Flowmodoro or other timers aren\'t functioning properly';

  @override
  String get tryTheseSolutions => 'Try these solutions:';

  @override
  String get stillHavingIssues => 'Still having issues? Contact support for personalized help.';

  @override
  String get forceCloseRestart => 'Force close and restart the app';

  @override
  String get restartDevice => 'Restart your device';

  @override
  String get checkStorageSpace => 'Check if you have enough storage space (need at least 100MB free)';

  @override
  String get updateApp => 'Update to the latest version of the app';

  @override
  String get clearAppCache => 'Clear app cache in device settings';

  @override
  String get uninstallReinstall => 'Uninstall, and reinstall the app';

  @override
  String get checkInternetConnection => 'Verify that you have a stable internet connection';

  @override
  String get checkCorrectDate => 'Check if you\'re viewing the correct date';

  @override
  String get ensureNoFilters => 'Ensure no filters are applied that might hide your data';

  @override
  String get forceCloseReopen => 'Force close and reopen the app';

  @override
  String get tryLoggingAgain => 'Try logging the same data again';

  @override
  String get closeBackgroundApps => 'Close other apps running in the background';

  @override
  String get clearOldData => 'Clear old data you no longer need (Settings > Data Management)';

  @override
  String get checkAvailableStorage => 'Check available storage space';

  @override
  String get unableToLoadVersionInfo => 'Unable to load version info';

  @override
  String get viewOnGitHub => 'View on GitHub';

  @override
  String get reportBugsOnGitHub => 'Report bugs and issues on GitHub';

  @override
  String get suggestFeaturesOnGitHub => 'Suggest new features on GitHub';

  @override
  String get bugReport => 'Bug Report';

  @override
  String get featureRequest => 'Feature Request';

  @override
  String get create => 'Create';

  @override
  String unableToOpenGitHubAutomatically(String issueType) {
    return 'Unable to open GitHub automatically. Copy this link to create a $issueType with a pre-filled template:';
  }

  @override
  String get gitHubIssueUrlCopied => 'GitHub issue URL copied to clipboard';

  @override
  String get copyUrl => 'Copy URL';

  @override
  String get openLink => 'Open Link';

  @override
  String get unableToOpenLinkAutomatically => 'Unable to open link automatically. Copy this link and open it in your browser:';

  @override
  String get urlCopied => 'URL copied to clipboard';

  @override
  String get unableToShowLicenses => 'Unable to show licenses at this time';

  @override
  String get ok => 'OK';

  @override
  String get bugReportTitle => 'Bug Report';

  @override
  String get featureRequestTitle => 'Feature Request';

  @override
  String get describeTheBug => 'Describe the bug';

  @override
  String get bugDescription => 'A clear and concise description of what the bug is.';

  @override
  String get toReproduce => 'To Reproduce';

  @override
  String get stepsToReproduce => 'Steps to reproduce the behavior';

  @override
  String get stepGoTo => 'Go to \'...\'';

  @override
  String get stepClickOn => 'Click on \'....\'';

  @override
  String get stepScrollTo => 'Scroll down to \'....\'';

  @override
  String get stepSeeError => 'See error';

  @override
  String get expectedBehavior => 'Expected behavior';

  @override
  String get expectedBehaviorDescription => 'A clear and concise description of what you expected to happen.';

  @override
  String get screenshots => 'Screenshots';

  @override
  String get screenshotsDescription => 'If applicable, add screenshots to help explain your problem.';

  @override
  String get deviceInformation => 'Device Information';

  @override
  String get device => 'Device';

  @override
  String get operatingSystem => 'OS';

  @override
  String get appVersion => 'App Version';

  @override
  String get unknown => 'Unknown';

  @override
  String get additionalContext => 'Additional context';

  @override
  String get additionalContextDescription => 'Add any other context about the problem here.';

  @override
  String get featureRequestProblem => 'Is your feature request related to a problem? Please describe.';

  @override
  String get featureRequestProblemDescription => 'A clear and concise description of what the problem is. Ex. I\'m always frustrated when [...]';

  @override
  String get describeSolution => 'Describe the solution you\'d like';

  @override
  String get describeSolutionDescription => 'A clear and concise description of what you want to happen.';

  @override
  String get describeAlternatives => 'Describe alternatives you\'ve considered';

  @override
  String get describeAlternativesDescription => 'A clear and concise description of any alternative solutions or features you\'ve considered.';

  @override
  String get featureAdditionalContext => 'Add any other context or screenshots about the feature request here.';

  @override
  String get useCase => 'Use Case';

  @override
  String get useCaseDescription => 'Describe how this feature would be used and who would benefit from it.';

  @override
  String get faqCategoryGettingStarted => 'Getting Started';

  @override
  String get faqCategoryTimeManagement => 'Time Management';

  @override
  String get faqCategoryHealthTracking => 'Health Tracking';

  @override
  String get faqCategoryDataPrivacy => 'Data & Privacy';

  @override
  String get faqCategoryTroubleshooting => 'Troubleshooting';

  @override
  String get faqHowCreateFirstTask => 'How do I create my first task?';

  @override
  String get faqHowCreateFirstTaskAnswer => 'Tap the \"+\" button on the main tracker screen, select \"Task\", fill in the details, and tap \"Save\". You can add a title, description, due date, and priority. Subtasks are automatically generated based on your task description, but you can add more by pressing the add button in the list, below the last subtask.';

  @override
  String get faqDifferenceTasksHabits => 'What\'s the difference between tasks and habits?';

  @override
  String get faqDifferenceTasksHabitsAnswer => 'Tasks are one-time activities with specific deadlines, while habits are recurring activities you want to do regularly (daily, weekly, etc.). Habits help build long-term routines.';

  @override
  String get faqEnergyTrackingTasks => 'How does energy tracking affect my tasks?';

  @override
  String get faqEnergyTrackingTasksAnswer => 'Your energy level (tracked daily from 1-10) is used by the app\'s AI to provide smarter task management. Higher energy levels result in longer estimated durations and more detailed subtask breakdowns, as the app assumes you can handle more complex work. Lower energy levels lead to shorter, simpler tasks to match your capacity. This helps ensure your daily planning is realistic based on how you\'re actually feeling.';

  @override
  String get faqTaskEstimatesEnergy => 'Why do my task estimates change based on energy?';

  @override
  String get faqTaskEstimatesEnergyAnswer => 'The app uses your energy level to adjust time estimates because your productivity varies with how you feel. On high-energy days (7-10), tasks might be estimated to take longer because you can work more thoroughly and handle complexity. On low-energy days (1-4), the same task gets shorter estimates with simpler steps, assuming you need to work more efficiently and take more breaks.';

  @override
  String get faqWhatIsFlowmodoro => 'What is the Flowmodoro Technique?';

  @override
  String get faqWhatIsFlowmodoroAnswer => 'Flowmodoro is a flexible productivity method where you work until you naturally feel like taking a break, then take a break proportional to your work time (usually 1/5th of work time). You can set up custom time periods, but the app uses Pomodoro defaults (25-minute work sessions, 5-minute breaks) as a starting point.';

  @override
  String get faqKanbanBoards => 'How do Kanban boards work?';

  @override
  String get faqKanbanBoardsAnswer => 'Kanban boards help you visualize your workflow with columns like \"To Do\", \"In Progress\", and \"Done\". You can drag tasks between columns to track their status and see your progress at a glance.';

  @override
  String get faqTimeBlocks => 'What are Time Blocks?';

  @override
  String get faqTimeBlocksAnswer => 'Time blocking is a scheduling method where you assign specific time slots to different activities or types of work. This helps you stay focused and ensures important tasks get dedicated time.';

  @override
  String get faqCustomizeTimers => 'Can I customize timer durations?';

  @override
  String get faqCustomizeTimersAnswer => 'Yes! You can adjust work periods, break lengths, and long break intervals in the timer settings to match your personal productivity rhythm.';

  @override
  String get faqEnergyTaskScheduling => 'How does my energy level affect task scheduling?';

  @override
  String get faqEnergyTaskSchedulingAnswer => 'The app considers your daily energy when suggesting task scheduling. High-energy periods are better for complex, demanding tasks, while low-energy periods are reserved for simpler, routine activities. The AI learns your patterns over time to suggest optimal timing for different types of work.';

  @override
  String get faqSymptomRatingsAccuracy => 'How accurate should my symptom ratings be?';

  @override
  String get faqSymptomRatingsAccuracyAnswer => 'Use a consistent scale (1-10) and try to be as objective as possible. The 1-10 scale is based on the [Mankoski Pain Scale](https://www.painscale.com/article/mankoski-pain-scale), which provides specific descriptions for each level (1 = barely noticeable, 10 = unconscious from pain). The key is consistency over time rather than perfect accuracy on individual entries.';

  @override
  String get faqCustomSymptoms => 'Can I track custom symptoms?';

  @override
  String get faqCustomSymptomsAnswer => 'Yes! You can add custom symptom types beyond the defaults. This allows you to track anything specific to your health condition.';

  @override
  String get faqDataStorage => 'Where is my data stored?';

  @override
  String get faqDataStorageAnswer => 'Currently, all your data is stored in a cloud database. However, the developer is working on implementing a local storage solution and a way for users to self-host their data if they prefer.';

  @override
  String get faqMultipleDevices => 'Can I use the app on multiple devices?';

  @override
  String get faqMultipleDevicesAnswer => 'Yes! Since your data is stored in a cloud database, you can access it from any device as long as you\'re logged into your account.';

  @override
  String get faqDeleteApp => 'What happens if I delete the app?';

  @override
  String get faqDeleteAppAnswer => 'Your data will remain safely stored in the cloud database. You can reinstall the app and log back into your account to access all your data.';

  @override
  String get faqDataMissing => 'My data seems to be missing';

  @override
  String get faqDataMissingAnswer => 'Verify that you have an active internet connection. Check if you\'re looking at the correct date. If the problem persists, try logging out and back into your account to refresh the data sync.';

  @override
  String get faqAppSlow => 'The app is running slowly';

  @override
  String get faqAppSlowAnswer => 'Try restarting the app first. If problems persist, you can clear the app\'s cache and data in your phone\'s Settings > Apps > SpiceEase > Storage.';

  @override
  String get faqFeatureMissing => 'I can\'t find a feature I used before';

  @override
  String get faqFeatureMissingAnswer => 'Features may be located in different sections after updates. Check the help section or use the search function to find what you\'re looking for.';

  @override
  String get searchFAQs => 'Search FAQs...';

  @override
  String get noFAQsFound => 'No FAQs found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get tutorialsSubtitle => 'Step-by-step tutorials';

  @override
  String get tipsSubtitle => 'Tips and tricks for better productivity';

  @override
  String get frequentlyAskedQuestionsSubtitle => 'Find answers to common questions';

  @override
  String get troubleshootingSubtitle => 'Solve common problems';

  @override
  String get contactSupportSubtitle => 'Get help from our support team';

  @override
  String get sendFeedbackSubtitle => 'Share your thoughts and suggestions';

  @override
  String get tutorialCategoryGettingStarted => 'Getting Started';

  @override
  String get tutorialCategoryTasks => 'Tasks';

  @override
  String get tutorialCategoryHabits => 'Habits';

  @override
  String get tutorialCategoryHealth => 'Health';

  @override
  String get tutorialCategoryTimeManagement => 'Time Management';

  @override
  String get tutorialCategoryReports => 'Reports';

  @override
  String get tutorialCategorySettings => 'Settings';

  @override
  String get tutorial2Min => '2 min';

  @override
  String get tutorial3Min => '3 min';

  @override
  String get tutorial4Min => '4 min';

  @override
  String get tutorial5Min => '5 min';

  @override
  String get tutorialBeginner => 'Beginner';

  @override
  String get tutorialIntermediate => 'Intermediate';

  @override
  String get tutorialAdvanced => 'Advanced';

  @override
  String get tutorialUnderstandingIconGrid => 'Understanding the Icon Grid';

  @override
  String get tutorialUnderstandingListView => 'Understanding the List View';

  @override
  String get tutorialCreatingFirstTask => 'Creating Your First Task';

  @override
  String get tutorialEditingDeletingTasks => 'Editing and Deleting Tasks';

  @override
  String get tutorialWorkingWithSubtasks => 'Working with Subtasks';

  @override
  String get tutorialTaskEstimationTimePlanning => 'Task Estimation and Time Planning';

  @override
  String get tutorialSettingUpDailyHabits => 'Setting Up Daily Habits';

  @override
  String get tutorialManagingHabitStreaks => 'Managing Habit Streaks';

  @override
  String get tutorialTrackingHealthSymptoms => 'Tracking Health Symptoms';

  @override
  String get tutorialAddingMedicationTracking => 'Adding Medication Tracking';

  @override
  String get tutorialRecordingMoodEntries => 'Recording Mood Entries';

  @override
  String get tutorialRecordingEnergyEntries => 'Recording Energy Entries';

  @override
  String get tutorialUsingFlowmodoroTechnique => 'Using the Flowmodoro Technique';

  @override
  String get tutorialManagingKanbanBoard => 'Managing Your Kanban Board';

  @override
  String get tutorialSchedulingTimeBlocks => 'Scheduling with Time Blocks';

  @override
  String get tutorialUnderstandingReportsCharts => 'Understanding Reports and Charts';

  @override
  String get tutorialCustomizingReportViews => 'Customizing Report Views';

  @override
  String get tutorialPersonalizingSettings => 'Personalizing Your Settings';

  @override
  String get tutorialManagingAccount => 'Managing Your Account';

  @override
  String get tutorialIconGridStep1 => 'The main screen shows an icon grid with different categories';

  @override
  String get tutorialIconGridStep2 => 'Each icon represents a different type of data you can track';

  @override
  String get tutorialIconGridStep3 => 'Tap any icon to see your existing entries for that category';

  @override
  String get tutorialIconGridStep4 => 'Use the \"+\" button within each category to add new entries';

  @override
  String get tutorialIconGridStep5 => 'Alternatively, for habits, medications, tasks or symptoms, use the \"Add [Item]\" buttons for quick access';

  @override
  String get tutorialIconGridStep6 => 'The grid layout makes it easy to see all your tracking options';

  @override
  String get tutorialListViewStep1 => 'Tap the list icon in the bottom navigation to switch to list view';

  @override
  String get tutorialListViewStep2 => 'The list shows all your items grouped by type (tasks, habits, etc.)';

  @override
  String get tutorialListViewStep3 => 'Items are color-coded by category for easy identification';

  @override
  String get tutorialListViewStep4 => 'You can see completion status and due dates at a glance';

  @override
  String get tutorialListViewStep5 => 'Tap any item to view details or mark as complete';

  @override
  String get tutorialListViewStep6 => 'Use the filter and sort options to organize your view';

  @override
  String get tutorialListViewStep7 => 'Switch back to grid view anytime using the grid icon';

  @override
  String get tutorialFirstTaskStep1 => 'Go to the tracker screen';

  @override
  String get tutorialFirstTaskStep2 => 'Choose the task icon from the icon grid OR tap \"Add Task\" button';

  @override
  String get tutorialFirstTaskStep3 => 'If using icon grid: tap the \"+\" button in the top-right corner';

  @override
  String get tutorialFirstTaskStep4 => 'Enter a title and description for your task';

  @override
  String get tutorialFirstTaskStep5 => 'Set a due date if desired and a priority level';

  @override
  String get tutorialFirstTaskStep6 => 'Add subtasks if needed by pressing the \"Divide into subtasks\" button';

  @override
  String get tutorialFirstTaskStep7 => 'Tap \"Save\" to create your task';

  @override
  String get tutorialEditTaskStep1 => 'Navigate to the task icon in the grid';

  @override
  String get tutorialEditTaskStep2 => 'Tap on any existing task to open it';

  @override
  String get tutorialEditTaskStep3 => 'To edit: tap the edit button and modify any field';

  @override
  String get tutorialEditTaskStep4 => 'You can change title, description, due date or priority';

  @override
  String get tutorialEditTaskStep5 => 'To delete: tap the delete button and confirm';

  @override
  String get tutorialEditTaskStep6 => 'Save changes when editing';

  @override
  String get tutorialSubtasksStep1 => 'When creating or editing a task, tap \"Divide into subtasks\"';

  @override
  String get tutorialSubtasksStep2 => 'This generates a list of subtasks under the main task automatically';

  @override
  String get tutorialSubtasksStep3 => 'Each subtask can be marked complete independently and has its own estimated time';

  @override
  String get tutorialSubtasksStep4 => 'The main task shows progress based on completed subtasks';

  @override
  String get tutorialSubtasksStep5 => 'Subtasks help break down complex tasks into manageable steps';

  @override
  String get tutorialSubtasksStep6 => 'You can add, edit, or delete subtasks at any time';

  @override
  String get tutorialSubtasksStep7 => 'The main task is completed when all subtasks are done';

  @override
  String get tutorialEstimationStep1 => 'When creating or editing a task, look for the \"Estimate task\" button';

  @override
  String get tutorialEstimationStep2 => 'Your current energy level directly impacts task estimation';

  @override
  String get tutorialEstimationStep3 => 'Higher energy levels suggest shorter completion times and less subdivision needed';

  @override
  String get tutorialEstimationStep4 => 'Lower energy levels may require breaking tasks into smaller, more manageable chunks';

  @override
  String get tutorialEstimationStep5 => 'The app considers your energy patterns when suggesting time estimates';

  @override
  String get tutorialEstimationStep6 => 'Estimated times help with scheduling and time blocking';

  @override
  String get tutorialHabitsStep1 => 'Go to the tracker screen';

  @override
  String get tutorialHabitsStep2 => 'Choose the habit icon from the icon grid OR tap \"Add Habit\" button';

  @override
  String get tutorialHabitsStep3 => 'If using icon grid: tap the \"+\" button in the top-right corner';

  @override
  String get tutorialHabitsStep4 => 'Enter the habit name (e.g., \"Drink 8 glasses of water\")';

  @override
  String get tutorialHabitsStep5 => 'Choose the frequency: daily, weekly, or custom';

  @override
  String get tutorialHabitsStep6 => 'For custom frequency, select specific days of the week';

  @override
  String get tutorialHabitsStep7 => 'Set target times per day if applicable';

  @override
  String get tutorialHabitsStep8 => 'Add a description if desired';

  @override
  String get tutorialHabitsStep9 => 'Save your habit and mark it complete each day you do it';

  @override
  String get tutorialStreaksStep1 => 'View your habits in the grid or list';

  @override
  String get tutorialStreaksStep2 => 'Each habit shows if it was completed today';

  @override
  String get tutorialStreaksStep3 => 'Tap a habit\'s checkbox to mark it complete for the day';

  @override
  String get tutorialStreaksStep4 => 'Mark habits complete daily to maintain streaks';

  @override
  String get tutorialStreaksStep5 => 'Streaks reset if you miss a day (based on your frequency)';

  @override
  String get tutorialStreaksStep6 => 'Use the reports screen to see your habit history';

  @override
  String get tutorialStreaksStep7 => 'Aim for consistency rather than perfection';

  @override
  String get tutorialStreaksStep8 => 'Celebrate milestone streaks to stay motivated';

  @override
  String get tutorialSymptomsStep1 => 'Go to the tracker screen';

  @override
  String get tutorialSymptomsStep2 => 'Choose the symptom icon from the icon grid OR tap \"Add Symptom\" button';

  @override
  String get tutorialSymptomsStep3 => 'If using icon grid: tap the \"+\" button in the top-right corner';

  @override
  String get tutorialSymptomsStep4 => 'Choose from common categories or add a custom one';

  @override
  String get tutorialSymptomsStep5 => 'Rate the severity on a scale of 1-10 (use Mankoski scale if preferred)';

  @override
  String get tutorialSymptomsStep6 => 'Add notes about triggers, context, or treatments tried';

  @override
  String get tutorialSymptomsStep7 => 'Include location on body if applicable';

  @override
  String get tutorialSymptomsStep8 => 'Save the entry to track patterns over time';

  @override
  String get tutorialMedicationStep1 => 'Go to the tracker screen';

  @override
  String get tutorialMedicationStep2 => 'Choose the medication icon from the icon grid';

  @override
  String get tutorialMedicationStep3 => 'Tap the \"+\" button in the top-right corner';

  @override
  String get tutorialMedicationStep4 => 'Enter the medication name and dosage amount';

  @override
  String get tutorialMedicationStep5 => 'Select the unit (mg, ml, tablets, etc.)';

  @override
  String get tutorialMedicationStep6 => 'Set the frequency: daily, weekly, as needed, or custom schedule';

  @override
  String get tutorialMedicationStep7 => 'Save the medication and mark as taken when you take your dose';

  @override
  String get tutorialMoodStep1 => 'Go to the tracker screen';

  @override
  String get tutorialMoodStep2 => 'Choose the mood icon from the icon grid';

  @override
  String get tutorialMoodStep3 => 'Tap the \"+\" button in the top-right corner';

  @override
  String get tutorialMoodStep4 => 'Select your current mood level on a scale of 1-10';

  @override
  String get tutorialMoodStep5 => 'Add notes about what influenced your mood';

  @override
  String get tutorialMoodStep6 => 'Include any relevant triggers, events, or circumstances';

  @override
  String get tutorialMoodStep7 => 'Note any coping strategies used';

  @override
  String get tutorialMoodStep8 => 'Save the mood entry to track patterns over time';

  @override
  String get tutorialEnergyStep1 => 'Go to the tracker screen';

  @override
  String get tutorialEnergyStep2 => 'Choose the energy icon from the icon grid';

  @override
  String get tutorialEnergyStep3 => 'Tap the \"+\" button in the top-right corner';

  @override
  String get tutorialEnergyStep4 => 'Select your current energy level on a scale of 1-10';

  @override
  String get tutorialEnergyStep5 => 'Add notes about what influenced your energy';

  @override
  String get tutorialEnergyStep6 => 'Include any relevant triggers, events, or circumstances';

  @override
  String get tutorialFlowmodoroStep1 => 'Navigate to the Time Management page';

  @override
  String get tutorialFlowmodoroStep2 => 'Tap on \"Flowmodoro\"';

  @override
  String get tutorialFlowmodoroStep3 => 'Choose a task to work on from your task list';

  @override
  String get tutorialFlowmodoroStep4 => 'Set your work duration (start with 25 minutes if unsure)';

  @override
  String get tutorialFlowmodoroStep5 => 'Set your break duration (typically 5-15 minutes)';

  @override
  String get tutorialFlowmodoroStep6 => 'Tap \"Start\" to begin the work timer';

  @override
  String get tutorialFlowmodoroStep7 => 'Work focused on your task until the timer ends';

  @override
  String get tutorialFlowmodoroStep8 => 'Take the break when prompted - step away from work';

  @override
  String get tutorialFlowmodoroStep9 => 'After break, start another work session or finish';

  @override
  String get tutorialFlowmodoroStep10 => 'Track your completed sessions for productivity insights';

  @override
  String get tutorialKanbanStep1 => 'Go to Time Management and select \"Kanban\"';

  @override
  String get tutorialKanbanStep2 => 'Your tasks are organized in columns: To Do, In Progress, Done';

  @override
  String get tutorialKanbanStep3 => 'Drag tasks between columns to update their status';

  @override
  String get tutorialKanbanStep4 => 'Add new tasks directly to the To Do column';

  @override
  String get tutorialKanbanStep5 => 'Move tasks to In Progress when you start working on them';

  @override
  String get tutorialKanbanStep6 => 'Complete tasks by moving them to Done';

  @override
  String get tutorialKanbanStep7 => 'Use filters to show only specific categories or priorities';

  @override
  String get tutorialKanbanStep8 => 'Customize columns and workflow to match your needs';

  @override
  String get tutorialTimeBlocksStep1 => 'Navigate to Time Management and tap \"Time Blocks\"';

  @override
  String get tutorialTimeBlocksStep2 => 'View your calendar with existing scheduled items';

  @override
  String get tutorialTimeBlocksStep3 => 'To schedule a task: set a start time and an end time, or set a start time only if the task has a time estimate';

  @override
  String get tutorialTimeBlocksStep4 => 'To unschedule: press the x button on top of the scheduled item';

  @override
  String get tutorialTimeBlocksStep5 => 'Color coding helps distinguish the priorities of tasks';

  @override
  String get tutorialReportsStep1 => 'Navigate to the Reports section';

  @override
  String get tutorialReportsStep2 => 'Choose your time range: day, week, month or year';

  @override
  String get tutorialReportsStep3 => 'If there is any data that you don\'t want to see, click it in the legend to hide it';

  @override
  String get tutorialReportsStep4 => 'Charts automatically update based on your selections';

  @override
  String get tutorialReportsStep5 => 'Hover or tap data points for detailed information';

  @override
  String get tutorialReportsStep6 => 'Use charts to identify patterns and trends in your data';

  @override
  String get tutorialCustomReportsStep1 => 'In the Reports section, look for the legend below charts';

  @override
  String get tutorialCustomReportsStep2 => 'Tap on any item in the legend to hide/show that data series';

  @override
  String get tutorialCustomReportsStep3 => 'Hidden items appear grayed out in the legend';

  @override
  String get tutorialCustomReportsStep4 => 'This lets you focus on specific data points';

  @override
  String get tutorialCustomReportsStep5 => 'For example, hide the habits to see other items more clearly';

  @override
  String get tutorialCustomReportsStep6 => 'Combine with date filters for precise analysis';

  @override
  String get tutorialSettingsStep1 => 'Navigate to Settings from the main menu';

  @override
  String get tutorialSettingsStep2 => 'Customize your theme (light, dark, or system)';

  @override
  String get tutorialSettingsStep3 => 'Set your preferred language and region';

  @override
  String get tutorialAccountStep1 => 'Go to Settings and tap \"Account\"';

  @override
  String get tutorialAccountStep2 => 'View your account details and email address';

  @override
  String get tutorialAccountStep3 => 'Change your or email password if needed';

  @override
  String get account => 'Account';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get manageAccountInfo => 'Manage your account information';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get accountActions => 'Account Actions';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get newEmail => 'New Email';

  @override
  String get signOutFromAccount => 'Sign out from your account';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get pleaseEnterEmail => 'Please enter an email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterCurrentPassword => 'Please enter your current password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get emailUpdatedSuccessfully => 'Email updated successfully';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully';

  @override
  String get signedOutSuccessfully => 'Signed out successfully';

  @override
  String get weakPassword => 'Password is too weak';

  @override
  String get incorrectPassword => 'Current password is incorrect';

  @override
  String get requiresRecentLogin => 'Please sign in again to continue';

  @override
  String get tooManyAttempts => 'Too many failed attempts. Please try again later';

  @override
  String get userDisabled => 'This account has been disabled';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get securityVerificationRequired => 'For security purposes, please verify your current password to change your email address.';

  @override
  String get passwordChangeVerification => 'For security purposes, please verify your current password before setting a new one.';

  @override
  String get passwordRequiredForEmailChange => 'Your password is required to verify this security change';

  @override
  String get passwordRequirements => 'Password must be at least 6 characters long';

  @override
  String get emailMustBeDifferent => 'New email must be different from current email';

  @override
  String get passwordMustBeDifferent => 'New password must be different from current password';

  @override
  String get updatingEmail => 'Updating email address...';

  @override
  String get updatingPassword => 'Updating password...';

  @override
  String get verifyNewEmail => 'Verify New Email';

  @override
  String get emailVerificationSent => 'A verification email has been sent to your new email address:';

  @override
  String get emailVerificationInstructions => 'Please check your inbox and click the verification link to complete the email change. Your email address will not be updated until verified.';

  @override
  String get resendVerification => 'Resend';

  @override
  String get understood => 'Understood';

  @override
  String get verificationEmailResent => 'Verification email sent again';

  @override
  String get failedToResendVerification => 'Failed to resend verification email';

  @override
  String get failedToLoadUser => 'Failed to load user information';

  @override
  String get retry => 'Retry';

  @override
  String get verifyingCredentials => 'Verifying credentials...';

  @override
  String get emailChangeRequiresVerification => 'Email Verification Required';

  @override
  String get emailChangeVerificationMessage => 'To change your email address, you must first verify your current email. This is a security requirement.';

  @override
  String get currentEmail => 'Current Email:';

  @override
  String get emailVerificationInstructions2 => 'We will send a verification email to your current address. Please verify it, then try changing your email again.';

  @override
  String get verificationEmailSent2 => 'Verification email sent to your current address';

  @override
  String get failedToSendVerification => 'Failed to send verification email';

  @override
  String get sendVerification => 'Send Verification';

  @override
  String get emailVerificationRequired => 'Email verification is required before changing email address';

  @override
  String get operationNotAllowed => 'This operation is not allowed';
}
