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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
