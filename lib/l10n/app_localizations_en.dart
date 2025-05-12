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
  String get estimateInstructions => 'Give the estimate in numbers. For ranges, separate them using \'to\'.';

  @override
  String get allTasksScheduled => 'All tasks are scheduled';

  @override
  String get unscheduledTasks => 'Unscheduled tasks';

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
}
