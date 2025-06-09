import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get sessionExpired;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @recoveryEmailSent.
  ///
  /// In en, this message translates to:
  /// **'A recovery email has been sent.'**
  String get recoveryEmailSent;

  /// No description provided for @invalidLoginCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get invalidLoginCredentials;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get wrongPassword;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get userNotFound;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Try logging in instead.'**
  String get emailAlreadyInUse;

  /// No description provided for @missingPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get missingPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords are not equal.'**
  String get passwordMismatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passwordReset;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get emailHint;

  /// No description provided for @resetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send reset email.'**
  String get resetEmail;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @passwordResetEmail.
  ///
  /// In en, this message translates to:
  /// **'The email for resetting the password was sent!'**
  String get passwordResetEmail;

  /// No description provided for @resetPasswordError.
  ///
  /// In en, this message translates to:
  /// **'An error ocurred while resetting the password.'**
  String get resetPasswordError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error happened.'**
  String get unknownError;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @username_required.
  ///
  /// In en, this message translates to:
  /// **'Username is required.'**
  String get username_required;

  /// No description provided for @symptom.
  ///
  /// In en, this message translates to:
  /// **'Symptom'**
  String get symptom;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @habit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habit;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @noTimeEstimate.
  ///
  /// In en, this message translates to:
  /// **'No time estimate'**
  String get noTimeEstimate;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthlyDays.
  ///
  /// In en, this message translates to:
  /// **'Monthly (days)'**
  String get monthlyDays;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @additionalText.
  ///
  /// In en, this message translates to:
  /// **'Additional Text'**
  String get additionalText;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{item}\"?'**
  String deleteConfirmationMessage(Object item);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @calendarFirstDay.
  ///
  /// In en, this message translates to:
  /// **'First Day'**
  String get calendarFirstDay;

  /// No description provided for @calendarLastDay.
  ///
  /// In en, this message translates to:
  /// **'Last Day'**
  String get calendarLastDay;

  /// No description provided for @calendarMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get calendarMonday;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarSelectedDay.
  ///
  /// In en, this message translates to:
  /// **'Selected Day'**
  String get calendarSelectedDay;

  /// No description provided for @calendarStyleHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar Header Title'**
  String get calendarStyleHeaderTitle;

  /// No description provided for @calendarStyleHeaderFormatButtonVisible.
  ///
  /// In en, this message translates to:
  /// **'Format Button Visible'**
  String get calendarStyleHeaderFormatButtonVisible;

  /// No description provided for @calendarStyleHeaderTitleCentered.
  ///
  /// In en, this message translates to:
  /// **'Header Title Centered'**
  String get calendarStyleHeaderTitleCentered;

  /// No description provided for @calendarStyleDaysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Days of Week'**
  String get calendarStyleDaysOfWeek;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {item}'**
  String editTitle(Object item);

  /// No description provided for @newTitle.
  ///
  /// In en, this message translates to:
  /// **'New {item}'**
  String newTitle(Object item);

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {item}?'**
  String deleteConfirmationTitle(Object item);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @customCategory.
  ///
  /// In en, this message translates to:
  /// **'Custom Category'**
  String get customCategory;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String requiredField(Object field);

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of Month (1-31)'**
  String get dayOfMonth;

  /// No description provided for @pleaseSelectA.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one {field}'**
  String pleaseSelectA(Object field);

  /// No description provided for @addDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Add Day of Month'**
  String get addDayOfMonth;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String dueDate(Object date);

  /// No description provided for @noDueDateSet.
  ///
  /// In en, this message translates to:
  /// **'No due date set'**
  String get noDueDateSet;

  /// No description provided for @setDueDate.
  ///
  /// In en, this message translates to:
  /// **'Set Due Date'**
  String get setDueDate;

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed: {date}'**
  String completedAt(Object date);

  /// No description provided for @notCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not completed'**
  String get notCompleted;

  /// No description provided for @setCompleted.
  ///
  /// In en, this message translates to:
  /// **'Set Completed'**
  String get setCompleted;

  /// No description provided for @estimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get estimate;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time: {time}'**
  String estimatedTime(Object time);

  /// No description provided for @generateSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Break it into subtasks'**
  String get generateSubtasks;

  /// No description provided for @generatingSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Generating subtasks...'**
  String get generatingSubtasks;

  /// No description provided for @noSubtasksGenerated.
  ///
  /// In en, this message translates to:
  /// **'No subtasks were generated'**
  String get noSubtasksGenerated;

  /// No description provided for @failedToGenerateSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate subtasks: {error}'**
  String failedToGenerateSubtasks(Object error);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @timesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Times per day'**
  String get timesPerDay;

  /// No description provided for @customTimes.
  ///
  /// In en, this message translates to:
  /// **'Custom Times'**
  String get customTimes;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @customUnit.
  ///
  /// In en, this message translates to:
  /// **'Custom Unit'**
  String get customUnit;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @markAsTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as taken'**
  String get markAsTaken;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @physical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// No description provided for @psychological.
  ///
  /// In en, this message translates to:
  /// **'Psychological'**
  String get psychological;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @thisSymptom.
  ///
  /// In en, this message translates to:
  /// **'this symptom'**
  String get thisSymptom;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @enterDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Enter Day of Month (1-31)'**
  String get enterDayOfMonth;

  /// No description provided for @dayOfMonthHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1, 15, 31'**
  String get dayOfMonthHint;

  /// No description provided for @dayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayNumber(Object number);

  /// No description provided for @selectWeekday.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one weekday'**
  String get selectWeekday;

  /// No description provided for @selectDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day of the month'**
  String get selectDayOfMonth;

  /// No description provided for @thisHabit.
  ///
  /// In en, this message translates to:
  /// **'this habit'**
  String get thisHabit;

  /// No description provided for @thisTask.
  ///
  /// In en, this message translates to:
  /// **'this task'**
  String get thisTask;

  /// No description provided for @breakIntoSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Break into subtasks'**
  String get breakIntoSubtasks;

  /// No description provided for @breakIntoSubtasksPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to break this task into subtasks?'**
  String get breakIntoSubtasksPrompt;

  /// No description provided for @subtask.
  ///
  /// In en, this message translates to:
  /// **'Subtask'**
  String get subtask;

  /// No description provided for @subtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks;

  /// No description provided for @subtaskFor.
  ///
  /// In en, this message translates to:
  /// **'Subtask for: {taskTitle}'**
  String subtaskFor(Object taskTitle);

  /// No description provided for @currentEstimate.
  ///
  /// In en, this message translates to:
  /// **'Current estimate: {time} {unit}'**
  String currentEstimate(Object time, Object unit);

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @thisMoodEntry.
  ///
  /// In en, this message translates to:
  /// **'this mood entry'**
  String get thisMoodEntry;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @thisEnergyEntry.
  ///
  /// In en, this message translates to:
  /// **'this energy entry'**
  String get thisEnergyEntry;

  /// No description provided for @selectMoodLevel.
  ///
  /// In en, this message translates to:
  /// **'Select mood level'**
  String get selectMoodLevel;

  /// No description provided for @moodLevelScale.
  ///
  /// In en, this message translates to:
  /// **'1 = Very low, 10 = Excellent'**
  String get moodLevelScale;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @thisMedication.
  ///
  /// In en, this message translates to:
  /// **'this medication'**
  String get thisMedication;

  /// No description provided for @doseRequired.
  ///
  /// In en, this message translates to:
  /// **'Dose is required'**
  String get doseRequired;

  /// No description provided for @customValue.
  ///
  /// In en, this message translates to:
  /// **'Custom Value'**
  String get customValue;

  /// No description provided for @enterDayHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a number and press Add'**
  String get enterDayHint;

  /// No description provided for @addDay.
  ///
  /// In en, this message translates to:
  /// **'Add day'**
  String get addDay;

  /// No description provided for @selectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day'**
  String get selectAtLeastOneDay;

  /// No description provided for @minutesAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutesAbbreviation(Object value);

  /// No description provided for @estimatedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get estimatedTimeLabel;

  /// No description provided for @titleRequiredForSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Title is required for subtasks'**
  String get titleRequiredForSubtasks;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get addNew;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional notes'**
  String get additionalNotes;

  /// No description provided for @timeManagement.
  ///
  /// In en, this message translates to:
  /// **'Time Management'**
  String get timeManagement;

  /// No description provided for @kanban.
  ///
  /// In en, this message translates to:
  /// **'Kanban'**
  String get kanban;

  /// No description provided for @kanbanDescription.
  ///
  /// In en, this message translates to:
  /// **'Visualize your workflow with cards organized in columns to track progress.'**
  String get kanbanDescription;

  /// No description provided for @timeBlocks.
  ///
  /// In en, this message translates to:
  /// **'Time Blocks'**
  String get timeBlocks;

  /// No description provided for @timeBlocksDescription.
  ///
  /// In en, this message translates to:
  /// **'Schedule your day in dedicated time blocks to increase focus and productivity.'**
  String get timeBlocksDescription;

  /// No description provided for @flowmodoro.
  ///
  /// In en, this message translates to:
  /// **'Flowmodoro'**
  String get flowmodoro;

  /// No description provided for @flowmodoroDescription.
  ///
  /// In en, this message translates to:
  /// **'Work while you feel productive, then take a proportional break to recharge.'**
  String get flowmodoroDescription;

  /// No description provided for @noTasksInThisColumn.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this column'**
  String get noTasksInThisColumn;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @todo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get todo;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tasksWithoutDueDate.
  ///
  /// In en, this message translates to:
  /// **'Tasks without due date'**
  String get tasksWithoutDueDate;

  /// No description provided for @noTasksWithoutDueDate.
  ///
  /// In en, this message translates to:
  /// **'No tasks without due date'**
  String get noTasksWithoutDueDate;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasks;

  /// No description provided for @unitsTaken.
  ///
  /// In en, this message translates to:
  /// **'Units Taken Today'**
  String get unitsTaken;

  /// No description provided for @unitTakenOf.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} taken'**
  String unitTakenOf(Object taken, Object total);

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @takenS.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get takenS;

  /// No description provided for @notTaken.
  ///
  /// In en, this message translates to:
  /// **'Not taken'**
  String get notTaken;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @errorSavingTask.
  ///
  /// In en, this message translates to:
  /// **'Error saving task: {error}'**
  String errorSavingTask(Object error);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @dragTasksHere.
  ///
  /// In en, this message translates to:
  /// **'Drag tasks here'**
  String get dragTasksHere;

  /// No description provided for @lowestPriority.
  ///
  /// In en, this message translates to:
  /// **'Lowest Priority'**
  String get lowestPriority;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get lowPriority;

  /// No description provided for @mediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get mediumPriority;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get highPriority;

  /// No description provided for @highestPriority.
  ///
  /// In en, this message translates to:
  /// **'Highest Priority'**
  String get highestPriority;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @initializationError.
  ///
  /// In en, this message translates to:
  /// **'Initialization error'**
  String get initializationError;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @clearCompletion.
  ///
  /// In en, this message translates to:
  /// **'Clear completion'**
  String get clearCompletion;

  /// No description provided for @tablets.
  ///
  /// In en, this message translates to:
  /// **'Tablets'**
  String get tablets;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get second;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @estimateInstructions.
  ///
  /// In en, this message translates to:
  /// **'Give the estimate in numbers. For ranges, separate them using \'to\'.'**
  String get estimateInstructions;

  /// No description provided for @allTasksScheduled.
  ///
  /// In en, this message translates to:
  /// **'All tasks are scheduled'**
  String get allTasksScheduled;

  /// No description provided for @unscheduledTasks.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled tasks'**
  String get unscheduledTasks;

  /// No description provided for @unschedule.
  ///
  /// In en, this message translates to:
  /// **'Unschedule'**
  String get unschedule;

  /// No description provided for @unscheduleTaskConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove this task from the schedule? It will remain in your task list.'**
  String get unscheduleTaskConfirmation;

  /// No description provided for @noEndTime.
  ///
  /// In en, this message translates to:
  /// **'No end time set'**
  String get noEndTime;

  /// No description provided for @setEndTime.
  ///
  /// In en, this message translates to:
  /// **'Set end time'**
  String get setEndTime;

  /// No description provided for @setStartTime.
  ///
  /// In en, this message translates to:
  /// **'Set start time'**
  String get setStartTime;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @noStartTime.
  ///
  /// In en, this message translates to:
  /// **'No start time set'**
  String get noStartTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @selectTaskForFlowmodoro.
  ///
  /// In en, this message translates to:
  /// **'Select a task for Flowmodoro'**
  String get selectTaskForFlowmodoro;

  /// No description provided for @flowmodoroExplanation.
  ///
  /// In en, this message translates to:
  /// **'Focus on one task at a time with timed work and break intervals'**
  String get flowmodoroExplanation;

  /// No description provided for @selectATaskToStart.
  ///
  /// In en, this message translates to:
  /// **'Select a task to start'**
  String get selectATaskToStart;

  /// No description provided for @configureFlowmodoro.
  ///
  /// In en, this message translates to:
  /// **'Configure flowmodoro'**
  String get configureFlowmodoro;

  /// No description provided for @focusTime.
  ///
  /// In en, this message translates to:
  /// **'Focus Time'**
  String get focusTime;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break Time'**
  String get breakTime;

  /// No description provided for @cyclesToComplete.
  ///
  /// In en, this message translates to:
  /// **'Cycles to complete'**
  String get cyclesToComplete;

  /// No description provided for @cycles.
  ///
  /// In en, this message translates to:
  /// **'cycles'**
  String get cycles;

  /// No description provided for @startFlowmodoro.
  ///
  /// In en, this message translates to:
  /// **'Start flowmodoro'**
  String get startFlowmodoro;

  /// No description provided for @stopFlowmodoro.
  ///
  /// In en, this message translates to:
  /// **'Stop flowmodoro'**
  String get stopFlowmodoro;

  /// No description provided for @flowmodoroCompleted.
  ///
  /// In en, this message translates to:
  /// **'Flowmodoro completed'**
  String get flowmodoroCompleted;

  /// No description provided for @markTaskAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Would you like to mark this task as completed?'**
  String get markTaskAsCompleted;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get notYet;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markAsDone;

  /// No description provided for @taskMarkedAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task marked as completed'**
  String get taskMarkedAsCompleted;

  /// No description provided for @cycleProgress.
  ///
  /// In en, this message translates to:
  /// **'Cycle \$1 of \$2'**
  String get cycleProgress;

  /// No description provided for @relax.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get relax;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @noTasksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tasks available'**
  String get noTasksAvailable;

  /// No description provided for @errorMarkingTaskComplete.
  ///
  /// In en, this message translates to:
  /// **'Error marking task as complete: {error}'**
  String errorMarkingTaskComplete(Object error);

  /// No description provided for @breakTimeEnded.
  ///
  /// In en, this message translates to:
  /// **'Break Time Ended'**
  String get breakTimeEnded;

  /// No description provided for @focusTimeEnded.
  ///
  /// In en, this message translates to:
  /// **'Focus Time Ended'**
  String get focusTimeEnded;

  /// No description provided for @timeToFocusAgain.
  ///
  /// In en, this message translates to:
  /// **'Time to focus on your task again!'**
  String get timeToFocusAgain;

  /// No description provided for @timeToTakeABreak.
  ///
  /// In en, this message translates to:
  /// **'Great work! Time to take a short break.'**
  String get timeToTakeABreak;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @errorLoadingSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Error loading subtasks: '**
  String get errorLoadingSubtasks;

  /// No description provided for @noSubtasks.
  ///
  /// In en, this message translates to:
  /// **'No subtasks'**
  String get noSubtasks;

  /// No description provided for @thisSubtask.
  ///
  /// In en, this message translates to:
  /// **'this subtask'**
  String get thisSubtask;

  /// No description provided for @subtaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtask title'**
  String get subtaskTitle;

  /// No description provided for @addNewSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add new subtask'**
  String get addNewSubtask;

  /// No description provided for @speedrun.
  ///
  /// In en, this message translates to:
  /// **'Speedrun'**
  String get speedrun;

  /// No description provided for @speedrunDescription.
  ///
  /// In en, this message translates to:
  /// **'Prove yourself by completing tasks in a limited time. The faster you finish, the more points you earn.'**
  String get speedrunDescription;

  /// No description provided for @diceRoller.
  ///
  /// In en, this message translates to:
  /// **'Dice Roller'**
  String get diceRoller;

  /// No description provided for @diceRollerDescription.
  ///
  /// In en, this message translates to:
  /// **'Roll dice to generate random numbers for your tasks. Use it to know how many items you have to complete.'**
  String get diceRollerDescription;

  /// No description provided for @metricsOverTime.
  ///
  /// In en, this message translates to:
  /// **'Metrics over time'**
  String get metricsOverTime;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataForPeriod;

  /// No description provided for @streaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaks;

  /// No description provided for @longestTasksStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest tasks streak: {days} days'**
  String longestTasksStreak(Object days);

  /// No description provided for @longestHabitsStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest habits streak: {days} days'**
  String longestHabitsStreak(Object days);

  /// No description provided for @timeManagementTechniques.
  ///
  /// In en, this message translates to:
  /// **'Time Management Techniques'**
  String get timeManagementTechniques;

  /// No description provided for @flowmodoroInsights.
  ///
  /// In en, this message translates to:
  /// **'Flowmodoro Insights'**
  String get flowmodoroInsights;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions: {count}'**
  String sessions(Object count);

  /// No description provided for @combinedTime.
  ///
  /// In en, this message translates to:
  /// **'Combined Time: {time}'**
  String combinedTime(Object time);

  /// No description provided for @timeBlockInsights.
  ///
  /// In en, this message translates to:
  /// **'Time-Block Insights'**
  String get timeBlockInsights;

  /// No description provided for @blocks.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get blocks;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @incompleteSubtasksWarning.
  ///
  /// In en, this message translates to:
  /// **'Some subtasks are not completed yet.'**
  String get incompleteSubtasksWarning;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @historyRetention.
  ///
  /// In en, this message translates to:
  /// **'History Retention'**
  String get historyRetention;

  /// No description provided for @daysOfHistory.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysOfHistory(String days);

  /// No description provided for @contextAwareness.
  ///
  /// In en, this message translates to:
  /// **'Context Awareness'**
  String get contextAwareness;

  /// No description provided for @alwaysShowCritical.
  ///
  /// In en, this message translates to:
  /// **'Always Show Critical Notifications'**
  String get alwaysShowCritical;

  /// No description provided for @alwaysShowCriticalDescription.
  ///
  /// In en, this message translates to:
  /// **'Critical notifications will be shown regardless of energy levels or symptoms'**
  String get alwaysShowCriticalDescription;

  /// No description provided for @lowEnergyThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low Energy Threshold'**
  String get lowEnergyThreshold;

  /// No description provided for @lowEnergyDescription.
  ///
  /// In en, this message translates to:
  /// **'When your energy is below this level, only high priority notifications will be shown'**
  String get lowEnergyDescription;

  /// No description provided for @highSymptomThreshold.
  ///
  /// In en, this message translates to:
  /// **'High Symptom Threshold'**
  String get highSymptomThreshold;

  /// No description provided for @highSymptomDescription.
  ///
  /// In en, this message translates to:
  /// **'When your symptoms are above this level, only critical notifications will be shown'**
  String get highSymptomDescription;

  /// No description provided for @quietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get quietHours;

  /// No description provided for @enableQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Enable Quiet Hours'**
  String get enableQuietHours;

  /// No description provided for @quietHoursStart.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get quietHoursStart;

  /// No description provided for @quietHoursEnd.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get quietHoursEnd;

  /// No description provided for @notificationCategories.
  ///
  /// In en, this message translates to:
  /// **'Notification Categories'**
  String get notificationCategories;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @notificationHistory.
  ///
  /// In en, this message translates to:
  /// **'Notification History'**
  String get notificationHistory;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @configureNotificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Configure how and when notifications appear'**
  String get configureNotificationPreferences;

  /// No description provided for @viewPastNotifications.
  ///
  /// In en, this message translates to:
  /// **'View previously received notifications'**
  String get viewPastNotifications;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @loggingReminders.
  ///
  /// In en, this message translates to:
  /// **'Logging Reminders'**
  String get loggingReminders;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettings;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @reminderDays.
  ///
  /// In en, this message translates to:
  /// **'Reminder Days'**
  String get reminderDays;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @taskReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to review pending tasks'**
  String get taskReminderDescription;

  /// No description provided for @habitReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to check habit progress'**
  String get habitReminderDescription;

  /// No description provided for @medicationReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to take medications'**
  String get medicationReminderDescription;

  /// No description provided for @symptomReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to log symptoms'**
  String get symptomReminderDescription;

  /// No description provided for @energyReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to log energy levels'**
  String get energyReminderDescription;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @loggingRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders to log your health data'**
  String get loggingRemindersDescription;

  /// No description provided for @categoryReminders.
  ///
  /// In en, this message translates to:
  /// **'Category Reminders'**
  String get categoryReminders;

  /// No description provided for @categoryRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Set up daily reminders for each type of data you want to track'**
  String get categoryRemindersDescription;

  /// No description provided for @specificItemReminders.
  ///
  /// In en, this message translates to:
  /// **'Specific Item Reminders'**
  String get specificItemReminders;

  /// No description provided for @specificItemRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow setting reminders for individual tasks, habits, and medications'**
  String get specificItemRemindersDescription;

  /// No description provided for @enableSpecificRemindersFor.
  ///
  /// In en, this message translates to:
  /// **'Enable specific reminders for:'**
  String get enableSpecificRemindersFor;

  /// No description provided for @notificationCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which types of notifications you want to receive'**
  String get notificationCategoriesDescription;

  /// No description provided for @taskSpecificRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Set due date reminders for individual tasks'**
  String get taskSpecificRemindersDescription;

  /// No description provided for @habitSpecificRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Set time-based reminders for individual habits'**
  String get habitSpecificRemindersDescription;

  /// No description provided for @medicationSpecificRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Set medication time reminders'**
  String get medicationSpecificRemindersDescription;

  /// No description provided for @specificRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Set individual reminders'**
  String get specificRemindersDescription;

  /// Refers to a specific item, e.g., 'this mood entry'
  ///
  /// In en, this message translates to:
  /// **'this {itemName}'**
  String thisItem(String itemName);

  /// A generic term for an item, often the item's name itself.
  ///
  /// In en, this message translates to:
  /// **'{itemName}'**
  String item(String itemName);

  /// Error message when saving an item fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to save {itemName}'**
  String failedToSaveItem(String itemName);

  /// Error message when deleting an item fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete {itemName}'**
  String failedToDeleteItem(String itemName);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get lightThemeDesc;

  /// No description provided for @darkThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get darkThemeDesc;

  /// No description provided for @systemThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Follow system setting'**
  String get systemThemeDesc;

  /// No description provided for @customizeAppColors.
  ///
  /// In en, this message translates to:
  /// **'Customize app colors'**
  String get customizeAppColors;

  /// No description provided for @toggleDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Toggle dark mode'**
  String get toggleDarkMode;

  /// No description provided for @languageAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get languageAndRegion;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChangedTo;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataAndPrivacy;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @exportImportData.
  ///
  /// In en, this message translates to:
  /// **'Export, import, and backup data'**
  String get exportImportData;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings and data usage'**
  String get privacySettings;

  /// No description provided for @supportAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Support & Information'**
  String get supportAndInfo;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @faqAndSupport.
  ///
  /// In en, this message translates to:
  /// **'FAQ and support'**
  String get faqAndSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App information and credits'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get sourceCode;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// No description provided for @requestFeature.
  ///
  /// In en, this message translates to:
  /// **'Request a Feature'**
  String get requestFeature;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share the App'**
  String get shareApp;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @clearDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your data. This action cannot be undone.'**
  String get clearDataWarning;

  /// No description provided for @clearDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data?'**
  String get clearDataConfirm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get dataExported;

  /// No description provided for @dataImported.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get dataImported;

  /// No description provided for @dataBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Data backed up successfully'**
  String get dataBackedUp;

  /// No description provided for @dataRestored.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get dataRestored;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'Data cleared successfully'**
  String get dataCleared;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get exportFailed;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import data'**
  String get importFailed;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to backup data'**
  String get backupFailed;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore data'**
  String get restoreFailed;

  /// No description provided for @clearFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear data'**
  String get clearFailed;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @invalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format'**
  String get invalidFile;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to export/import data'**
  String get storagePermissionRequired;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @dataProtection.
  ///
  /// In en, this message translates to:
  /// **'Data Protection'**
  String get dataProtection;

  /// No description provided for @dataProtectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored locally on your device and is not shared with third parties'**
  String get dataProtectionDesc;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @analyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Help improve the app by sending anonymous usage data'**
  String get analyticsDesc;

  /// No description provided for @crashReporting.
  ///
  /// In en, this message translates to:
  /// **'Crash Reporting'**
  String get crashReporting;

  /// No description provided for @crashReportingDesc.
  ///
  /// In en, this message translates to:
  /// **'Send crash reports to help fix bugs'**
  String get crashReportingDesc;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @tutorials.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorials;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get keyboardShortcuts;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips & Tricks'**
  String get tips;

  /// No description provided for @troubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get troubleshooting;

  /// No description provided for @commonIssues.
  ///
  /// In en, this message translates to:
  /// **'Common Issues'**
  String get commonIssues;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @tracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get tracker;

  /// No description provided for @appCrashesOrFreezes.
  ///
  /// In en, this message translates to:
  /// **'App Crashes or freezes'**
  String get appCrashesOrFreezes;

  /// No description provided for @appCrashesDescription.
  ///
  /// In en, this message translates to:
  /// **'The app stops responding or closes unexpectedly'**
  String get appCrashesDescription;

  /// No description provided for @dataSyncIssues.
  ///
  /// In en, this message translates to:
  /// **'Data Not Syncing'**
  String get dataSyncIssues;

  /// No description provided for @dataSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Changes aren\'t being saved or data appears missing'**
  String get dataSyncDescription;

  /// No description provided for @performanceIssues.
  ///
  /// In en, this message translates to:
  /// **'Performance issues'**
  String get performanceIssues;

  /// No description provided for @performanceDescription.
  ///
  /// In en, this message translates to:
  /// **'The app is running slowly or taking long to load'**
  String get performanceDescription;

  /// No description provided for @timerNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Timer not working'**
  String get timerNotWorking;

  /// No description provided for @timerDescription.
  ///
  /// In en, this message translates to:
  /// **'Flowmodoro or other timers aren\'t functioning properly'**
  String get timerDescription;

  /// No description provided for @tryTheseSolutions.
  ///
  /// In en, this message translates to:
  /// **'Try these solutions:'**
  String get tryTheseSolutions;

  /// No description provided for @stillHavingIssues.
  ///
  /// In en, this message translates to:
  /// **'Still having issues? Contact support for personalized help.'**
  String get stillHavingIssues;

  /// No description provided for @forceCloseRestart.
  ///
  /// In en, this message translates to:
  /// **'Force close and restart the app'**
  String get forceCloseRestart;

  /// No description provided for @restartDevice.
  ///
  /// In en, this message translates to:
  /// **'Restart your device'**
  String get restartDevice;

  /// No description provided for @checkStorageSpace.
  ///
  /// In en, this message translates to:
  /// **'Check if you have enough storage space (need at least 100MB free)'**
  String get checkStorageSpace;

  /// No description provided for @updateApp.
  ///
  /// In en, this message translates to:
  /// **'Update to the latest version of the app'**
  String get updateApp;

  /// No description provided for @clearAppCache.
  ///
  /// In en, this message translates to:
  /// **'Clear app cache in device settings'**
  String get clearAppCache;

  /// No description provided for @uninstallReinstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall, and reinstall the app'**
  String get uninstallReinstall;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Verify that you have a stable internet connection'**
  String get checkInternetConnection;

  /// No description provided for @checkCorrectDate.
  ///
  /// In en, this message translates to:
  /// **'Check if you\'re viewing the correct date'**
  String get checkCorrectDate;

  /// No description provided for @ensureNoFilters.
  ///
  /// In en, this message translates to:
  /// **'Ensure no filters are applied that might hide your data'**
  String get ensureNoFilters;

  /// No description provided for @forceCloseReopen.
  ///
  /// In en, this message translates to:
  /// **'Force close and reopen the app'**
  String get forceCloseReopen;

  /// No description provided for @tryLoggingAgain.
  ///
  /// In en, this message translates to:
  /// **'Try logging the same data again'**
  String get tryLoggingAgain;

  /// No description provided for @closeBackgroundApps.
  ///
  /// In en, this message translates to:
  /// **'Close other apps running in the background'**
  String get closeBackgroundApps;

  /// No description provided for @clearOldData.
  ///
  /// In en, this message translates to:
  /// **'Clear old data you no longer need (Settings > Data Management)'**
  String get clearOldData;

  /// No description provided for @checkAvailableStorage.
  ///
  /// In en, this message translates to:
  /// **'Check available storage space'**
  String get checkAvailableStorage;

  /// No description provided for @unableToLoadVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'Unable to load version info'**
  String get unableToLoadVersionInfo;

  /// No description provided for @viewOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGitHub;

  /// No description provided for @reportBugsOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'Report bugs and issues on GitHub'**
  String get reportBugsOnGitHub;

  /// No description provided for @suggestFeaturesOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'Suggest new features on GitHub'**
  String get suggestFeaturesOnGitHub;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// No description provided for @featureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get featureRequest;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @unableToOpenGitHubAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Unable to open GitHub automatically. Copy this link to create a {issueType} with a pre-filled template:'**
  String unableToOpenGitHubAutomatically(String issueType);

  /// No description provided for @gitHubIssueUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'GitHub issue URL copied to clipboard'**
  String get gitHubIssueUrlCopied;

  /// No description provided for @copyUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get copyUrl;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open Link'**
  String get openLink;

  /// No description provided for @unableToOpenLinkAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Unable to open link automatically. Copy this link and open it in your browser:'**
  String get unableToOpenLinkAutomatically;

  /// No description provided for @urlCopied.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard'**
  String get urlCopied;

  /// No description provided for @unableToShowLicenses.
  ///
  /// In en, this message translates to:
  /// **'Unable to show licenses at this time'**
  String get unableToShowLicenses;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @bugReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReportTitle;

  /// No description provided for @featureRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get featureRequestTitle;

  /// No description provided for @describeTheBug.
  ///
  /// In en, this message translates to:
  /// **'Describe the bug'**
  String get describeTheBug;

  /// No description provided for @bugDescription.
  ///
  /// In en, this message translates to:
  /// **'A clear and concise description of what the bug is.'**
  String get bugDescription;

  /// No description provided for @toReproduce.
  ///
  /// In en, this message translates to:
  /// **'To Reproduce'**
  String get toReproduce;

  /// No description provided for @stepsToReproduce.
  ///
  /// In en, this message translates to:
  /// **'Steps to reproduce the behavior'**
  String get stepsToReproduce;

  /// No description provided for @stepGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to \'...\''**
  String get stepGoTo;

  /// No description provided for @stepClickOn.
  ///
  /// In en, this message translates to:
  /// **'Click on \'....\''**
  String get stepClickOn;

  /// No description provided for @stepScrollTo.
  ///
  /// In en, this message translates to:
  /// **'Scroll down to \'....\''**
  String get stepScrollTo;

  /// No description provided for @stepSeeError.
  ///
  /// In en, this message translates to:
  /// **'See error'**
  String get stepSeeError;

  /// No description provided for @expectedBehavior.
  ///
  /// In en, this message translates to:
  /// **'Expected behavior'**
  String get expectedBehavior;

  /// No description provided for @expectedBehaviorDescription.
  ///
  /// In en, this message translates to:
  /// **'A clear and concise description of what you expected to happen.'**
  String get expectedBehaviorDescription;

  /// No description provided for @screenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get screenshots;

  /// No description provided for @screenshotsDescription.
  ///
  /// In en, this message translates to:
  /// **'If applicable, add screenshots to help explain your problem.'**
  String get screenshotsDescription;

  /// No description provided for @deviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInformation;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @operatingSystem.
  ///
  /// In en, this message translates to:
  /// **'OS'**
  String get operatingSystem;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @additionalContext.
  ///
  /// In en, this message translates to:
  /// **'Additional context'**
  String get additionalContext;

  /// No description provided for @additionalContextDescription.
  ///
  /// In en, this message translates to:
  /// **'Add any other context about the problem here.'**
  String get additionalContextDescription;

  /// No description provided for @featureRequestProblem.
  ///
  /// In en, this message translates to:
  /// **'Is your feature request related to a problem? Please describe.'**
  String get featureRequestProblem;

  /// No description provided for @featureRequestProblemDescription.
  ///
  /// In en, this message translates to:
  /// **'A clear and concise description of what the problem is. Ex. I\'m always frustrated when [...]'**
  String get featureRequestProblemDescription;

  /// No description provided for @describeSolution.
  ///
  /// In en, this message translates to:
  /// **'Describe the solution you\'d like'**
  String get describeSolution;

  /// No description provided for @describeSolutionDescription.
  ///
  /// In en, this message translates to:
  /// **'A clear and concise description of what you want to happen.'**
  String get describeSolutionDescription;

  /// No description provided for @describeAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Describe alternatives you\'ve considered'**
  String get describeAlternatives;

  /// No description provided for @describeAlternativesDescription.
  ///
  /// In en, this message translates to:
  /// **'A clear and concise description of any alternative solutions or features you\'ve considered.'**
  String get describeAlternativesDescription;

  /// No description provided for @featureAdditionalContext.
  ///
  /// In en, this message translates to:
  /// **'Add any other context or screenshots about the feature request here.'**
  String get featureAdditionalContext;

  /// No description provided for @useCase.
  ///
  /// In en, this message translates to:
  /// **'Use Case'**
  String get useCase;

  /// No description provided for @useCaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe how this feature would be used and who would benefit from it.'**
  String get useCaseDescription;

  /// No description provided for @faqCategoryGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get faqCategoryGettingStarted;

  /// No description provided for @faqCategoryTimeManagement.
  ///
  /// In en, this message translates to:
  /// **'Time Management'**
  String get faqCategoryTimeManagement;

  /// No description provided for @faqCategoryHealthTracking.
  ///
  /// In en, this message translates to:
  /// **'Health Tracking'**
  String get faqCategoryHealthTracking;

  /// No description provided for @faqCategoryDataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get faqCategoryDataPrivacy;

  /// No description provided for @faqCategoryTroubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get faqCategoryTroubleshooting;

  /// No description provided for @faqHowCreateFirstTask.
  ///
  /// In en, this message translates to:
  /// **'How do I create my first task?'**
  String get faqHowCreateFirstTask;

  /// No description provided for @faqHowCreateFirstTaskAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button on the main tracker screen, select \"Task\", fill in the details, and tap \"Save\". You can add a title, description, due date, and priority. Subtasks are automatically generated based on your task description, but you can add more by pressing the add button in the list, below the last subtask.'**
  String get faqHowCreateFirstTaskAnswer;

  /// No description provided for @faqDifferenceTasksHabits.
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between tasks and habits?'**
  String get faqDifferenceTasksHabits;

  /// No description provided for @faqDifferenceTasksHabitsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tasks are one-time activities with specific deadlines, while habits are recurring activities you want to do regularly (daily, weekly, etc.). Habits help build long-term routines.'**
  String get faqDifferenceTasksHabitsAnswer;

  /// No description provided for @faqEnergyTrackingTasks.
  ///
  /// In en, this message translates to:
  /// **'How does energy tracking affect my tasks?'**
  String get faqEnergyTrackingTasks;

  /// No description provided for @faqEnergyTrackingTasksAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your energy level (tracked daily from 1-10) is used by the app\'s AI to provide smarter task management. Higher energy levels result in longer estimated durations and more detailed subtask breakdowns, as the app assumes you can handle more complex work. Lower energy levels lead to shorter, simpler tasks to match your capacity. This helps ensure your daily planning is realistic based on how you\'re actually feeling.'**
  String get faqEnergyTrackingTasksAnswer;

  /// No description provided for @faqTaskEstimatesEnergy.
  ///
  /// In en, this message translates to:
  /// **'Why do my task estimates change based on energy?'**
  String get faqTaskEstimatesEnergy;

  /// No description provided for @faqTaskEstimatesEnergyAnswer.
  ///
  /// In en, this message translates to:
  /// **'The app uses your energy level to adjust time estimates because your productivity varies with how you feel. On high-energy days (7-10), tasks might be estimated to take longer because you can work more thoroughly and handle complexity. On low-energy days (1-4), the same task gets shorter estimates with simpler steps, assuming you need to work more efficiently and take more breaks.'**
  String get faqTaskEstimatesEnergyAnswer;

  /// No description provided for @faqWhatIsFlowmodoro.
  ///
  /// In en, this message translates to:
  /// **'What is the Flowmodoro Technique?'**
  String get faqWhatIsFlowmodoro;

  /// No description provided for @faqWhatIsFlowmodoroAnswer.
  ///
  /// In en, this message translates to:
  /// **'Flowmodoro is a flexible productivity method where you work until you naturally feel like taking a break, then take a break proportional to your work time (usually 1/5th of work time). You can set up custom time periods, but the app uses Pomodoro defaults (25-minute work sessions, 5-minute breaks) as a starting point.'**
  String get faqWhatIsFlowmodoroAnswer;

  /// No description provided for @faqKanbanBoards.
  ///
  /// In en, this message translates to:
  /// **'How do Kanban boards work?'**
  String get faqKanbanBoards;

  /// No description provided for @faqKanbanBoardsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Kanban boards help you visualize your workflow with columns like \"To Do\", \"In Progress\", and \"Done\". You can drag tasks between columns to track their status and see your progress at a glance.'**
  String get faqKanbanBoardsAnswer;

  /// No description provided for @faqTimeBlocks.
  ///
  /// In en, this message translates to:
  /// **'What are Time Blocks?'**
  String get faqTimeBlocks;

  /// No description provided for @faqTimeBlocksAnswer.
  ///
  /// In en, this message translates to:
  /// **'Time blocking is a scheduling method where you assign specific time slots to different activities or types of work. This helps you stay focused and ensures important tasks get dedicated time.'**
  String get faqTimeBlocksAnswer;

  /// No description provided for @faqCustomizeTimers.
  ///
  /// In en, this message translates to:
  /// **'Can I customize timer durations?'**
  String get faqCustomizeTimers;

  /// No description provided for @faqCustomizeTimersAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! You can adjust work periods, break lengths, and long break intervals in the timer settings to match your personal productivity rhythm.'**
  String get faqCustomizeTimersAnswer;

  /// No description provided for @faqEnergyTaskScheduling.
  ///
  /// In en, this message translates to:
  /// **'How does my energy level affect task scheduling?'**
  String get faqEnergyTaskScheduling;

  /// No description provided for @faqEnergyTaskSchedulingAnswer.
  ///
  /// In en, this message translates to:
  /// **'The app considers your daily energy when suggesting task scheduling. High-energy periods are better for complex, demanding tasks, while low-energy periods are reserved for simpler, routine activities. The AI learns your patterns over time to suggest optimal timing for different types of work.'**
  String get faqEnergyTaskSchedulingAnswer;

  /// No description provided for @faqSymptomRatingsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'How accurate should my symptom ratings be?'**
  String get faqSymptomRatingsAccuracy;

  /// No description provided for @faqSymptomRatingsAccuracyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Use a consistent scale (1-10) and try to be as objective as possible. The 1-10 scale is based on the [Mankoski Pain Scale](https://www.painscale.com/article/mankoski-pain-scale), which provides specific descriptions for each level (1 = barely noticeable, 10 = unconscious from pain). The key is consistency over time rather than perfect accuracy on individual entries.'**
  String get faqSymptomRatingsAccuracyAnswer;

  /// No description provided for @faqCustomSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Can I track custom symptoms?'**
  String get faqCustomSymptoms;

  /// No description provided for @faqCustomSymptomsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! You can add custom symptom types beyond the defaults. This allows you to track anything specific to your health condition.'**
  String get faqCustomSymptomsAnswer;

  /// No description provided for @faqDataStorage.
  ///
  /// In en, this message translates to:
  /// **'Where is my data stored?'**
  String get faqDataStorage;

  /// No description provided for @faqDataStorageAnswer.
  ///
  /// In en, this message translates to:
  /// **'Currently, all your data is stored in a cloud database. However, the developer is working on implementing a local storage solution and a way for users to self-host their data if they prefer.'**
  String get faqDataStorageAnswer;

  /// No description provided for @faqMultipleDevices.
  ///
  /// In en, this message translates to:
  /// **'Can I use the app on multiple devices?'**
  String get faqMultipleDevices;

  /// No description provided for @faqMultipleDevicesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! Since your data is stored in a cloud database, you can access it from any device as long as you\'re logged into your account.'**
  String get faqMultipleDevicesAnswer;

  /// No description provided for @faqDeleteApp.
  ///
  /// In en, this message translates to:
  /// **'What happens if I delete the app?'**
  String get faqDeleteApp;

  /// No description provided for @faqDeleteAppAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your data will remain safely stored in the cloud database. You can reinstall the app and log back into your account to access all your data.'**
  String get faqDeleteAppAnswer;

  /// No description provided for @faqDataMissing.
  ///
  /// In en, this message translates to:
  /// **'My data seems to be missing'**
  String get faqDataMissing;

  /// No description provided for @faqDataMissingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Verify that you have an active internet connection. Check if you\'re looking at the correct date. If the problem persists, try logging out and back into your account to refresh the data sync.'**
  String get faqDataMissingAnswer;

  /// No description provided for @faqAppSlow.
  ///
  /// In en, this message translates to:
  /// **'The app is running slowly'**
  String get faqAppSlow;

  /// No description provided for @faqAppSlowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Try restarting the app first. If problems persist, you can clear the app\'s cache and data in your phone\'s Settings > Apps > SpiceEase > Storage.'**
  String get faqAppSlowAnswer;

  /// No description provided for @faqFeatureMissing.
  ///
  /// In en, this message translates to:
  /// **'I can\'t find a feature I used before'**
  String get faqFeatureMissing;

  /// No description provided for @faqFeatureMissingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Features may be located in different sections after updates. Check the help section or use the search function to find what you\'re looking for.'**
  String get faqFeatureMissingAnswer;

  /// No description provided for @searchFAQs.
  ///
  /// In en, this message translates to:
  /// **'Search FAQs...'**
  String get searchFAQs;

  /// No description provided for @noFAQsFound.
  ///
  /// In en, this message translates to:
  /// **'No FAQs found'**
  String get noFAQsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @tutorialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step tutorials'**
  String get tutorialsSubtitle;

  /// No description provided for @tipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tips and tricks for better productivity'**
  String get tipsSubtitle;

  /// No description provided for @frequentlyAskedQuestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions'**
  String get frequentlyAskedQuestionsSubtitle;

  /// No description provided for @troubleshootingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solve common problems'**
  String get troubleshootingSubtitle;

  /// No description provided for @contactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help from our support team'**
  String get contactSupportSubtitle;

  /// No description provided for @sendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts and suggestions'**
  String get sendFeedbackSubtitle;

  /// No description provided for @tutorialCategoryGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get tutorialCategoryGettingStarted;

  /// No description provided for @tutorialCategoryTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tutorialCategoryTasks;

  /// No description provided for @tutorialCategoryHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get tutorialCategoryHabits;

  /// No description provided for @tutorialCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get tutorialCategoryHealth;

  /// No description provided for @tutorialCategoryTimeManagement.
  ///
  /// In en, this message translates to:
  /// **'Time Management'**
  String get tutorialCategoryTimeManagement;

  /// No description provided for @tutorialCategoryReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get tutorialCategoryReports;

  /// No description provided for @tutorialCategorySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tutorialCategorySettings;

  /// No description provided for @tutorial2Min.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get tutorial2Min;

  /// No description provided for @tutorial3Min.
  ///
  /// In en, this message translates to:
  /// **'3 min'**
  String get tutorial3Min;

  /// No description provided for @tutorial4Min.
  ///
  /// In en, this message translates to:
  /// **'4 min'**
  String get tutorial4Min;

  /// No description provided for @tutorial5Min.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get tutorial5Min;

  /// No description provided for @tutorialBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get tutorialBeginner;

  /// No description provided for @tutorialIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get tutorialIntermediate;

  /// No description provided for @tutorialAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get tutorialAdvanced;

  /// No description provided for @tutorialUnderstandingIconGrid.
  ///
  /// In en, this message translates to:
  /// **'Understanding the Icon Grid'**
  String get tutorialUnderstandingIconGrid;

  /// No description provided for @tutorialUnderstandingListView.
  ///
  /// In en, this message translates to:
  /// **'Understanding the List View'**
  String get tutorialUnderstandingListView;

  /// No description provided for @tutorialCreatingFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Creating Your First Task'**
  String get tutorialCreatingFirstTask;

  /// No description provided for @tutorialEditingDeletingTasks.
  ///
  /// In en, this message translates to:
  /// **'Editing and Deleting Tasks'**
  String get tutorialEditingDeletingTasks;

  /// No description provided for @tutorialWorkingWithSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Working with Subtasks'**
  String get tutorialWorkingWithSubtasks;

  /// No description provided for @tutorialTaskEstimationTimePlanning.
  ///
  /// In en, this message translates to:
  /// **'Task Estimation and Time Planning'**
  String get tutorialTaskEstimationTimePlanning;

  /// No description provided for @tutorialSettingUpDailyHabits.
  ///
  /// In en, this message translates to:
  /// **'Setting Up Daily Habits'**
  String get tutorialSettingUpDailyHabits;

  /// No description provided for @tutorialManagingHabitStreaks.
  ///
  /// In en, this message translates to:
  /// **'Managing Habit Streaks'**
  String get tutorialManagingHabitStreaks;

  /// No description provided for @tutorialTrackingHealthSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Tracking Health Symptoms'**
  String get tutorialTrackingHealthSymptoms;

  /// No description provided for @tutorialAddingMedicationTracking.
  ///
  /// In en, this message translates to:
  /// **'Adding Medication Tracking'**
  String get tutorialAddingMedicationTracking;

  /// No description provided for @tutorialRecordingMoodEntries.
  ///
  /// In en, this message translates to:
  /// **'Recording Mood Entries'**
  String get tutorialRecordingMoodEntries;

  /// No description provided for @tutorialRecordingEnergyEntries.
  ///
  /// In en, this message translates to:
  /// **'Recording Energy Entries'**
  String get tutorialRecordingEnergyEntries;

  /// No description provided for @tutorialUsingFlowmodoroTechnique.
  ///
  /// In en, this message translates to:
  /// **'Using the Flowmodoro Technique'**
  String get tutorialUsingFlowmodoroTechnique;

  /// No description provided for @tutorialManagingKanbanBoard.
  ///
  /// In en, this message translates to:
  /// **'Managing Your Kanban Board'**
  String get tutorialManagingKanbanBoard;

  /// No description provided for @tutorialSchedulingTimeBlocks.
  ///
  /// In en, this message translates to:
  /// **'Scheduling with Time Blocks'**
  String get tutorialSchedulingTimeBlocks;

  /// No description provided for @tutorialUnderstandingReportsCharts.
  ///
  /// In en, this message translates to:
  /// **'Understanding Reports and Charts'**
  String get tutorialUnderstandingReportsCharts;

  /// No description provided for @tutorialCustomizingReportViews.
  ///
  /// In en, this message translates to:
  /// **'Customizing Report Views'**
  String get tutorialCustomizingReportViews;

  /// No description provided for @tutorialPersonalizingSettings.
  ///
  /// In en, this message translates to:
  /// **'Personalizing Your Settings'**
  String get tutorialPersonalizingSettings;

  /// No description provided for @tutorialManagingAccount.
  ///
  /// In en, this message translates to:
  /// **'Managing Your Account'**
  String get tutorialManagingAccount;

  /// No description provided for @tutorialIconGridStep1.
  ///
  /// In en, this message translates to:
  /// **'The main screen shows an icon grid with different categories'**
  String get tutorialIconGridStep1;

  /// No description provided for @tutorialIconGridStep2.
  ///
  /// In en, this message translates to:
  /// **'Each icon represents a different type of data you can track'**
  String get tutorialIconGridStep2;

  /// No description provided for @tutorialIconGridStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap any icon to see your existing entries for that category'**
  String get tutorialIconGridStep3;

  /// No description provided for @tutorialIconGridStep4.
  ///
  /// In en, this message translates to:
  /// **'Use the \"+\" button within each category to add new entries'**
  String get tutorialIconGridStep4;

  /// No description provided for @tutorialIconGridStep5.
  ///
  /// In en, this message translates to:
  /// **'Alternatively, for habits, medications, tasks or symptoms, use the \"Add [Item]\" buttons for quick access'**
  String get tutorialIconGridStep5;

  /// No description provided for @tutorialIconGridStep6.
  ///
  /// In en, this message translates to:
  /// **'The grid layout makes it easy to see all your tracking options'**
  String get tutorialIconGridStep6;

  /// No description provided for @tutorialListViewStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap the list icon in the bottom navigation to switch to list view'**
  String get tutorialListViewStep1;

  /// No description provided for @tutorialListViewStep2.
  ///
  /// In en, this message translates to:
  /// **'The list shows all your items grouped by type (tasks, habits, etc.)'**
  String get tutorialListViewStep2;

  /// No description provided for @tutorialListViewStep3.
  ///
  /// In en, this message translates to:
  /// **'Items are color-coded by category for easy identification'**
  String get tutorialListViewStep3;

  /// No description provided for @tutorialListViewStep4.
  ///
  /// In en, this message translates to:
  /// **'You can see completion status and due dates at a glance'**
  String get tutorialListViewStep4;

  /// No description provided for @tutorialListViewStep5.
  ///
  /// In en, this message translates to:
  /// **'Tap any item to view details or mark as complete'**
  String get tutorialListViewStep5;

  /// No description provided for @tutorialListViewStep6.
  ///
  /// In en, this message translates to:
  /// **'Use the filter and sort options to organize your view'**
  String get tutorialListViewStep6;

  /// No description provided for @tutorialListViewStep7.
  ///
  /// In en, this message translates to:
  /// **'Switch back to grid view anytime using the grid icon'**
  String get tutorialListViewStep7;

  /// No description provided for @tutorialFirstTaskStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to the tracker screen'**
  String get tutorialFirstTaskStep1;

  /// No description provided for @tutorialFirstTaskStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose the task icon from the icon grid OR tap \"Add Task\" button'**
  String get tutorialFirstTaskStep2;

  /// No description provided for @tutorialFirstTaskStep3.
  ///
  /// In en, this message translates to:
  /// **'If using icon grid: tap the \"+\" button in the top-right corner'**
  String get tutorialFirstTaskStep3;

  /// No description provided for @tutorialFirstTaskStep4.
  ///
  /// In en, this message translates to:
  /// **'Enter a title and description for your task'**
  String get tutorialFirstTaskStep4;

  /// No description provided for @tutorialFirstTaskStep5.
  ///
  /// In en, this message translates to:
  /// **'Set a due date if desired and a priority level'**
  String get tutorialFirstTaskStep5;

  /// No description provided for @tutorialFirstTaskStep6.
  ///
  /// In en, this message translates to:
  /// **'Add subtasks if needed by pressing the \"Divide into subtasks\" button'**
  String get tutorialFirstTaskStep6;

  /// No description provided for @tutorialFirstTaskStep7.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Save\" to create your task'**
  String get tutorialFirstTaskStep7;

  /// No description provided for @tutorialEditTaskStep1.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the task icon in the grid'**
  String get tutorialEditTaskStep1;

  /// No description provided for @tutorialEditTaskStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap on any existing task to open it'**
  String get tutorialEditTaskStep2;

  /// No description provided for @tutorialEditTaskStep3.
  ///
  /// In en, this message translates to:
  /// **'To edit: tap the edit button and modify any field'**
  String get tutorialEditTaskStep3;

  /// No description provided for @tutorialEditTaskStep4.
  ///
  /// In en, this message translates to:
  /// **'You can change title, description, due date or priority'**
  String get tutorialEditTaskStep4;

  /// No description provided for @tutorialEditTaskStep5.
  ///
  /// In en, this message translates to:
  /// **'To delete: tap the delete button and confirm'**
  String get tutorialEditTaskStep5;

  /// No description provided for @tutorialEditTaskStep6.
  ///
  /// In en, this message translates to:
  /// **'Save changes when editing'**
  String get tutorialEditTaskStep6;

  /// No description provided for @tutorialSubtasksStep1.
  ///
  /// In en, this message translates to:
  /// **'When creating or editing a task, tap \"Divide into subtasks\"'**
  String get tutorialSubtasksStep1;

  /// No description provided for @tutorialSubtasksStep2.
  ///
  /// In en, this message translates to:
  /// **'This generates a list of subtasks under the main task automatically'**
  String get tutorialSubtasksStep2;

  /// No description provided for @tutorialSubtasksStep3.
  ///
  /// In en, this message translates to:
  /// **'Each subtask can be marked complete independently and has its own estimated time'**
  String get tutorialSubtasksStep3;

  /// No description provided for @tutorialSubtasksStep4.
  ///
  /// In en, this message translates to:
  /// **'The main task shows progress based on completed subtasks'**
  String get tutorialSubtasksStep4;

  /// No description provided for @tutorialSubtasksStep5.
  ///
  /// In en, this message translates to:
  /// **'Subtasks help break down complex tasks into manageable steps'**
  String get tutorialSubtasksStep5;

  /// No description provided for @tutorialSubtasksStep6.
  ///
  /// In en, this message translates to:
  /// **'You can add, edit, or delete subtasks at any time'**
  String get tutorialSubtasksStep6;

  /// No description provided for @tutorialSubtasksStep7.
  ///
  /// In en, this message translates to:
  /// **'The main task is completed when all subtasks are done'**
  String get tutorialSubtasksStep7;

  /// No description provided for @tutorialEstimationStep1.
  ///
  /// In en, this message translates to:
  /// **'When creating or editing a task, look for the \"Estimate task\" button'**
  String get tutorialEstimationStep1;

  /// No description provided for @tutorialEstimationStep2.
  ///
  /// In en, this message translates to:
  /// **'Your current energy level directly impacts task estimation'**
  String get tutorialEstimationStep2;

  /// No description provided for @tutorialEstimationStep3.
  ///
  /// In en, this message translates to:
  /// **'Higher energy levels suggest shorter completion times and less subdivision needed'**
  String get tutorialEstimationStep3;

  /// No description provided for @tutorialEstimationStep4.
  ///
  /// In en, this message translates to:
  /// **'Lower energy levels may require breaking tasks into smaller, more manageable chunks'**
  String get tutorialEstimationStep4;

  /// No description provided for @tutorialEstimationStep5.
  ///
  /// In en, this message translates to:
  /// **'The app considers your energy patterns when suggesting time estimates'**
  String get tutorialEstimationStep5;

  /// No description provided for @tutorialEstimationStep6.
  ///
  /// In en, this message translates to:
  /// **'Estimated times help with scheduling and time blocking'**
  String get tutorialEstimationStep6;

  /// No description provided for @tutorialHabitsStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to the tracker screen'**
  String get tutorialHabitsStep1;

  /// No description provided for @tutorialHabitsStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose the habit icon from the icon grid OR tap \"Add Habit\" button'**
  String get tutorialHabitsStep2;

  /// No description provided for @tutorialHabitsStep3.
  ///
  /// In en, this message translates to:
  /// **'If using icon grid: tap the \"+\" button in the top-right corner'**
  String get tutorialHabitsStep3;

  /// No description provided for @tutorialHabitsStep4.
  ///
  /// In en, this message translates to:
  /// **'Enter the habit name (e.g., \"Drink 8 glasses of water\")'**
  String get tutorialHabitsStep4;

  /// No description provided for @tutorialHabitsStep5.
  ///
  /// In en, this message translates to:
  /// **'Choose the frequency: daily, weekly, or custom'**
  String get tutorialHabitsStep5;

  /// No description provided for @tutorialHabitsStep6.
  ///
  /// In en, this message translates to:
  /// **'For custom frequency, select specific days of the week'**
  String get tutorialHabitsStep6;

  /// No description provided for @tutorialHabitsStep7.
  ///
  /// In en, this message translates to:
  /// **'Set target times per day if applicable'**
  String get tutorialHabitsStep7;

  /// No description provided for @tutorialHabitsStep8.
  ///
  /// In en, this message translates to:
  /// **'Add a description if desired'**
  String get tutorialHabitsStep8;

  /// No description provided for @tutorialHabitsStep9.
  ///
  /// In en, this message translates to:
  /// **'Save your habit and mark it complete each day you do it'**
  String get tutorialHabitsStep9;

  /// No description provided for @tutorialStreaksStep1.
  ///
  /// In en, this message translates to:
  /// **'View your habits in the grid or list'**
  String get tutorialStreaksStep1;

  /// No description provided for @tutorialStreaksStep2.
  ///
  /// In en, this message translates to:
  /// **'Each habit shows if it was completed today'**
  String get tutorialStreaksStep2;

  /// No description provided for @tutorialStreaksStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap a habit\'s checkbox to mark it complete for the day'**
  String get tutorialStreaksStep3;

  /// No description provided for @tutorialStreaksStep4.
  ///
  /// In en, this message translates to:
  /// **'Mark habits complete daily to maintain streaks'**
  String get tutorialStreaksStep4;

  /// No description provided for @tutorialStreaksStep5.
  ///
  /// In en, this message translates to:
  /// **'Streaks reset if you miss a day (based on your frequency)'**
  String get tutorialStreaksStep5;

  /// No description provided for @tutorialStreaksStep6.
  ///
  /// In en, this message translates to:
  /// **'Use the reports screen to see your habit history'**
  String get tutorialStreaksStep6;

  /// No description provided for @tutorialStreaksStep7.
  ///
  /// In en, this message translates to:
  /// **'Aim for consistency rather than perfection'**
  String get tutorialStreaksStep7;

  /// No description provided for @tutorialStreaksStep8.
  ///
  /// In en, this message translates to:
  /// **'Celebrate milestone streaks to stay motivated'**
  String get tutorialStreaksStep8;

  /// No description provided for @tutorialSymptomsStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to the tracker screen'**
  String get tutorialSymptomsStep1;

  /// No description provided for @tutorialSymptomsStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose the symptom icon from the icon grid OR tap \"Add Symptom\" button'**
  String get tutorialSymptomsStep2;

  /// No description provided for @tutorialSymptomsStep3.
  ///
  /// In en, this message translates to:
  /// **'If using icon grid: tap the \"+\" button in the top-right corner'**
  String get tutorialSymptomsStep3;

  /// No description provided for @tutorialSymptomsStep4.
  ///
  /// In en, this message translates to:
  /// **'Choose from common categories or add a custom one'**
  String get tutorialSymptomsStep4;

  /// No description provided for @tutorialSymptomsStep5.
  ///
  /// In en, this message translates to:
  /// **'Rate the severity on a scale of 1-10 (use Mankoski scale if preferred)'**
  String get tutorialSymptomsStep5;

  /// No description provided for @tutorialSymptomsStep6.
  ///
  /// In en, this message translates to:
  /// **'Add notes about triggers, context, or treatments tried'**
  String get tutorialSymptomsStep6;

  /// No description provided for @tutorialSymptomsStep7.
  ///
  /// In en, this message translates to:
  /// **'Include location on body if applicable'**
  String get tutorialSymptomsStep7;

  /// No description provided for @tutorialSymptomsStep8.
  ///
  /// In en, this message translates to:
  /// **'Save the entry to track patterns over time'**
  String get tutorialSymptomsStep8;

  /// No description provided for @tutorialMedicationStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to the tracker screen'**
  String get tutorialMedicationStep1;

  /// No description provided for @tutorialMedicationStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose the medication icon from the icon grid'**
  String get tutorialMedicationStep2;

  /// No description provided for @tutorialMedicationStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button in the top-right corner'**
  String get tutorialMedicationStep3;

  /// No description provided for @tutorialMedicationStep4.
  ///
  /// In en, this message translates to:
  /// **'Enter the medication name and dosage amount'**
  String get tutorialMedicationStep4;

  /// No description provided for @tutorialMedicationStep5.
  ///
  /// In en, this message translates to:
  /// **'Select the unit (mg, ml, tablets, etc.)'**
  String get tutorialMedicationStep5;

  /// No description provided for @tutorialMedicationStep6.
  ///
  /// In en, this message translates to:
  /// **'Set the frequency: daily, weekly, as needed, or custom schedule'**
  String get tutorialMedicationStep6;

  /// No description provided for @tutorialMedicationStep7.
  ///
  /// In en, this message translates to:
  /// **'Save the medication and mark as taken when you take your dose'**
  String get tutorialMedicationStep7;

  /// No description provided for @tutorialMoodStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to the tracker screen'**
  String get tutorialMoodStep1;

  /// No description provided for @tutorialMoodStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose the mood icon from the icon grid'**
  String get tutorialMoodStep2;

  /// No description provided for @tutorialMoodStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button in the top-right corner'**
  String get tutorialMoodStep3;

  /// No description provided for @tutorialMoodStep4.
  ///
  /// In en, this message translates to:
  /// **'Select your current mood level on a scale of 1-10'**
  String get tutorialMoodStep4;

  /// No description provided for @tutorialMoodStep5.
  ///
  /// In en, this message translates to:
  /// **'Add notes about what influenced your mood'**
  String get tutorialMoodStep5;

  /// No description provided for @tutorialMoodStep6.
  ///
  /// In en, this message translates to:
  /// **'Include any relevant triggers, events, or circumstances'**
  String get tutorialMoodStep6;

  /// No description provided for @tutorialMoodStep7.
  ///
  /// In en, this message translates to:
  /// **'Note any coping strategies used'**
  String get tutorialMoodStep7;

  /// No description provided for @tutorialMoodStep8.
  ///
  /// In en, this message translates to:
  /// **'Save the mood entry to track patterns over time'**
  String get tutorialMoodStep8;

  /// No description provided for @tutorialEnergyStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to the tracker screen'**
  String get tutorialEnergyStep1;

  /// No description provided for @tutorialEnergyStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose the energy icon from the icon grid'**
  String get tutorialEnergyStep2;

  /// No description provided for @tutorialEnergyStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button in the top-right corner'**
  String get tutorialEnergyStep3;

  /// No description provided for @tutorialEnergyStep4.
  ///
  /// In en, this message translates to:
  /// **'Select your current energy level on a scale of 1-10'**
  String get tutorialEnergyStep4;

  /// No description provided for @tutorialEnergyStep5.
  ///
  /// In en, this message translates to:
  /// **'Add notes about what influenced your energy'**
  String get tutorialEnergyStep5;

  /// No description provided for @tutorialEnergyStep6.
  ///
  /// In en, this message translates to:
  /// **'Include any relevant triggers, events, or circumstances'**
  String get tutorialEnergyStep6;

  /// No description provided for @tutorialFlowmodoroStep1.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the Time Management page'**
  String get tutorialFlowmodoroStep1;

  /// No description provided for @tutorialFlowmodoroStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap on \"Flowmodoro\"'**
  String get tutorialFlowmodoroStep2;

  /// No description provided for @tutorialFlowmodoroStep3.
  ///
  /// In en, this message translates to:
  /// **'Choose a task to work on from your task list'**
  String get tutorialFlowmodoroStep3;

  /// No description provided for @tutorialFlowmodoroStep4.
  ///
  /// In en, this message translates to:
  /// **'Set your work duration (start with 25 minutes if unsure)'**
  String get tutorialFlowmodoroStep4;

  /// No description provided for @tutorialFlowmodoroStep5.
  ///
  /// In en, this message translates to:
  /// **'Set your break duration (typically 5-15 minutes)'**
  String get tutorialFlowmodoroStep5;

  /// No description provided for @tutorialFlowmodoroStep6.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Start\" to begin the work timer'**
  String get tutorialFlowmodoroStep6;

  /// No description provided for @tutorialFlowmodoroStep7.
  ///
  /// In en, this message translates to:
  /// **'Work focused on your task until the timer ends'**
  String get tutorialFlowmodoroStep7;

  /// No description provided for @tutorialFlowmodoroStep8.
  ///
  /// In en, this message translates to:
  /// **'Take the break when prompted - step away from work'**
  String get tutorialFlowmodoroStep8;

  /// No description provided for @tutorialFlowmodoroStep9.
  ///
  /// In en, this message translates to:
  /// **'After break, start another work session or finish'**
  String get tutorialFlowmodoroStep9;

  /// No description provided for @tutorialFlowmodoroStep10.
  ///
  /// In en, this message translates to:
  /// **'Track your completed sessions for productivity insights'**
  String get tutorialFlowmodoroStep10;

  /// No description provided for @tutorialKanbanStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to Time Management and select \"Kanban\"'**
  String get tutorialKanbanStep1;

  /// No description provided for @tutorialKanbanStep2.
  ///
  /// In en, this message translates to:
  /// **'Your tasks are organized in columns: To Do, In Progress, Done'**
  String get tutorialKanbanStep2;

  /// No description provided for @tutorialKanbanStep3.
  ///
  /// In en, this message translates to:
  /// **'Drag tasks between columns to update their status'**
  String get tutorialKanbanStep3;

  /// No description provided for @tutorialKanbanStep4.
  ///
  /// In en, this message translates to:
  /// **'Add new tasks directly to the To Do column'**
  String get tutorialKanbanStep4;

  /// No description provided for @tutorialKanbanStep5.
  ///
  /// In en, this message translates to:
  /// **'Move tasks to In Progress when you start working on them'**
  String get tutorialKanbanStep5;

  /// No description provided for @tutorialKanbanStep6.
  ///
  /// In en, this message translates to:
  /// **'Complete tasks by moving them to Done'**
  String get tutorialKanbanStep6;

  /// No description provided for @tutorialKanbanStep7.
  ///
  /// In en, this message translates to:
  /// **'Use filters to show only specific categories or priorities'**
  String get tutorialKanbanStep7;

  /// No description provided for @tutorialKanbanStep8.
  ///
  /// In en, this message translates to:
  /// **'Customize columns and workflow to match your needs'**
  String get tutorialKanbanStep8;

  /// No description provided for @tutorialTimeBlocksStep1.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Time Management and tap \"Time Blocks\"'**
  String get tutorialTimeBlocksStep1;

  /// No description provided for @tutorialTimeBlocksStep2.
  ///
  /// In en, this message translates to:
  /// **'View your calendar with existing scheduled items'**
  String get tutorialTimeBlocksStep2;

  /// No description provided for @tutorialTimeBlocksStep3.
  ///
  /// In en, this message translates to:
  /// **'To schedule a task: set a start time and an end time, or set a start time only if the task has a time estimate'**
  String get tutorialTimeBlocksStep3;

  /// No description provided for @tutorialTimeBlocksStep4.
  ///
  /// In en, this message translates to:
  /// **'To unschedule: press the x button on top of the scheduled item'**
  String get tutorialTimeBlocksStep4;

  /// No description provided for @tutorialTimeBlocksStep5.
  ///
  /// In en, this message translates to:
  /// **'Color coding helps distinguish the priorities of tasks'**
  String get tutorialTimeBlocksStep5;

  /// No description provided for @tutorialReportsStep1.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the Reports section'**
  String get tutorialReportsStep1;

  /// No description provided for @tutorialReportsStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose your time range: day, week, month or year'**
  String get tutorialReportsStep2;

  /// No description provided for @tutorialReportsStep3.
  ///
  /// In en, this message translates to:
  /// **'If there is any data that you don\'t want to see, click it in the legend to hide it'**
  String get tutorialReportsStep3;

  /// No description provided for @tutorialReportsStep4.
  ///
  /// In en, this message translates to:
  /// **'Charts automatically update based on your selections'**
  String get tutorialReportsStep4;

  /// No description provided for @tutorialReportsStep5.
  ///
  /// In en, this message translates to:
  /// **'Hover or tap data points for detailed information'**
  String get tutorialReportsStep5;

  /// No description provided for @tutorialReportsStep6.
  ///
  /// In en, this message translates to:
  /// **'Use charts to identify patterns and trends in your data'**
  String get tutorialReportsStep6;

  /// No description provided for @tutorialCustomReportsStep1.
  ///
  /// In en, this message translates to:
  /// **'In the Reports section, look for the legend below charts'**
  String get tutorialCustomReportsStep1;

  /// No description provided for @tutorialCustomReportsStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap on any item in the legend to hide/show that data series'**
  String get tutorialCustomReportsStep2;

  /// No description provided for @tutorialCustomReportsStep3.
  ///
  /// In en, this message translates to:
  /// **'Hidden items appear grayed out in the legend'**
  String get tutorialCustomReportsStep3;

  /// No description provided for @tutorialCustomReportsStep4.
  ///
  /// In en, this message translates to:
  /// **'This lets you focus on specific data points'**
  String get tutorialCustomReportsStep4;

  /// No description provided for @tutorialCustomReportsStep5.
  ///
  /// In en, this message translates to:
  /// **'For example, hide the habits to see other items more clearly'**
  String get tutorialCustomReportsStep5;

  /// No description provided for @tutorialCustomReportsStep6.
  ///
  /// In en, this message translates to:
  /// **'Combine with date filters for precise analysis'**
  String get tutorialCustomReportsStep6;

  /// No description provided for @tutorialSettingsStep1.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Settings from the main menu'**
  String get tutorialSettingsStep1;

  /// No description provided for @tutorialSettingsStep2.
  ///
  /// In en, this message translates to:
  /// **'Customize your theme (light, dark, or system)'**
  String get tutorialSettingsStep2;

  /// No description provided for @tutorialSettingsStep3.
  ///
  /// In en, this message translates to:
  /// **'Set your preferred language and region'**
  String get tutorialSettingsStep3;

  /// No description provided for @tutorialAccountStep1.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings and tap \"Account\"'**
  String get tutorialAccountStep1;

  /// No description provided for @tutorialAccountStep2.
  ///
  /// In en, this message translates to:
  /// **'View your account details and email address'**
  String get tutorialAccountStep2;

  /// No description provided for @tutorialAccountStep3.
  ///
  /// In en, this message translates to:
  /// **'Change your or email password if needed'**
  String get tutorialAccountStep3;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @manageAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Manage your account information'**
  String get manageAccountInfo;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @signOutFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your account'**
  String get signOutFromAccount;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @emailUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email updated successfully'**
  String get emailUpdatedSuccessfully;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @signedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOutSuccessfully;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get incorrectPassword;

  /// No description provided for @requiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue'**
  String get requiresRecentLogin;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again later'**
  String get tooManyAttempts;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get userDisabled;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @securityVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'For security purposes, please verify your current password to change your email address.'**
  String get securityVerificationRequired;

  /// No description provided for @passwordChangeVerification.
  ///
  /// In en, this message translates to:
  /// **'For security purposes, please verify your current password before setting a new one.'**
  String get passwordChangeVerification;

  /// No description provided for @passwordRequiredForEmailChange.
  ///
  /// In en, this message translates to:
  /// **'Your password is required to verify this security change'**
  String get passwordRequiredForEmailChange;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordRequirements;

  /// No description provided for @emailMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New email must be different from current email'**
  String get emailMustBeDifferent;

  /// No description provided for @passwordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get passwordMustBeDifferent;

  /// No description provided for @updatingEmail.
  ///
  /// In en, this message translates to:
  /// **'Updating email address...'**
  String get updatingEmail;

  /// No description provided for @updatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Updating password...'**
  String get updatingPassword;

  /// No description provided for @verifyNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify New Email'**
  String get verifyNewEmail;

  /// No description provided for @emailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to your new email address:'**
  String get emailVerificationSent;

  /// No description provided for @emailVerificationInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click the verification link to complete the email change. Your email address will not be updated until verified.'**
  String get emailVerificationInstructions;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendVerification;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent again'**
  String get verificationEmailResent;

  /// No description provided for @failedToResendVerification.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend verification email'**
  String get failedToResendVerification;

  /// No description provided for @failedToLoadUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user information'**
  String get failedToLoadUser;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @verifyingCredentials.
  ///
  /// In en, this message translates to:
  /// **'Verifying credentials...'**
  String get verifyingCredentials;

  /// No description provided for @emailChangeRequiresVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailChangeRequiresVerification;

  /// No description provided for @emailChangeVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'To change your email address, you must first verify your current email. This is a security requirement.'**
  String get emailChangeVerificationMessage;

  /// No description provided for @currentEmail.
  ///
  /// In en, this message translates to:
  /// **'Current Email:'**
  String get currentEmail;

  /// No description provided for @emailVerificationInstructions2.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification email to your current address. Please verify it, then try changing your email again.'**
  String get emailVerificationInstructions2;

  /// No description provided for @verificationEmailSent2.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to your current address'**
  String get verificationEmailSent2;

  /// No description provided for @failedToSendVerification.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email'**
  String get failedToSendVerification;

  /// No description provided for @sendVerification.
  ///
  /// In en, this message translates to:
  /// **'Send Verification'**
  String get sendVerification;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Email verification is required before changing email address'**
  String get emailVerificationRequired;

  /// No description provided for @operationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This operation is not allowed'**
  String get operationNotAllowed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
