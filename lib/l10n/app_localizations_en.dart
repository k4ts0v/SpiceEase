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
  String estimatedTime(Object time, Object unit) {
    return 'Estimated time: $time $unit';
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
}
