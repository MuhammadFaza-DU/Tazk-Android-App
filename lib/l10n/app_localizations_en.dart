// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tazk';

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navHabits => 'Habits';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navPomodoro => 'Pomodoro';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String comingSoonMessage(String title) {
    return '$title — coming soon';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get okButton => 'OK';

  @override
  String get deleteButton => 'Delete';

  @override
  String get startButton => 'Start';

  @override
  String get yesLabel => 'Yes';

  @override
  String get noLabel => 'No';

  @override
  String get onboardingWelcome => 'Welcome to Tazk!';

  @override
  String get onboardingAskName => 'What\'s your name?';

  @override
  String get fieldNameLabel => 'Name';

  @override
  String get onboardingNameEmptyError => 'Name cannot be empty';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeTasksToday => 'Today\'s Tasks';

  @override
  String get homeNoTasksToday => 'No tasks today yet';

  @override
  String errorLoadingTasks(String error) {
    return 'Failed to load tasks: $error';
  }

  @override
  String get homeHabitsToday => 'Today\'s Habits';

  @override
  String get homeNoActiveHabits => 'No active habits yet';

  @override
  String errorLoadingHabits(String error) {
    return 'Failed to load habits: $error';
  }

  @override
  String get homeStartPomodoroButton => 'Start Pomodoro';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String xpProgress(int xp, int needed) {
    return '$xp/$needed XP';
  }

  @override
  String streakSummary(int days, String rank) {
    return '🔥 $days-day streak · $rank';
  }

  @override
  String get tasksScreenTitle => 'Tasks — Today';

  @override
  String get taskDuplicateTooltip => 'Duplicate';

  @override
  String get priorityLowShort => 'Low';

  @override
  String get priorityMedShort => 'Med';

  @override
  String get priorityHighShort => 'High';

  @override
  String get editTaskTitle => 'Edit Task';

  @override
  String get addTaskTitle => 'Add Task';

  @override
  String get fieldTitleLabel => 'Title';

  @override
  String get taskTitleRequiredError => 'Title is required';

  @override
  String get fieldDateLabel => 'Date';

  @override
  String get fieldTimeOptionalLabel => 'Time (optional)';

  @override
  String get fieldPriorityLabel => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get fieldLocationOptionalLabel => 'Location (optional)';

  @override
  String get checklistOptionalLabel => 'Checklist/Subtasks (optional)';

  @override
  String get addItemHint => 'Add item';

  @override
  String get habitsScreenTitle => 'Habits';

  @override
  String habitProgressLabel(int current, int target) {
    return '$current/$target min';
  }

  @override
  String get editHabitTitle => 'Edit Habit';

  @override
  String get addHabitTitle => 'Add Habit';

  @override
  String get habitNameRequiredError => 'Name is required';

  @override
  String get fieldFrequencyLabel => 'Frequency';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyCustom => 'Custom';

  @override
  String get fieldScheduledTimeOptionalLabel => 'Time (optional)';

  @override
  String get hasProgressLabel => 'Gradual progress?';

  @override
  String get targetMinutesLabel => 'Target duration (minutes)';

  @override
  String get targetMinutesInvalidError => 'Enter a valid target duration';

  @override
  String frequencyDisplay(String frequency) {
    return 'Frequency: $frequency';
  }

  @override
  String streakContributionDisplay(String status) {
    return 'Streak contribution: $status';
  }

  @override
  String get streakContributionActive => 'active';

  @override
  String get streakContributionInactive => 'not yet today';

  @override
  String get historyTitle => 'History';

  @override
  String errorLoadingHistory(String error) {
    return 'Failed to load history: $error';
  }

  @override
  String get deleteHabitDialogTitle => 'Delete habit?';

  @override
  String deleteHabitDialogContent(String name) {
    return '\"$name\"\'s history and streak stay saved, but this habit will no longer be active.';
  }

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String calendarScreenTitle(String month, int year) {
    return 'Calendar — $month $year';
  }

  @override
  String errorLoadingCalendar(String error) {
    return 'Failed to load: $error';
  }

  @override
  String taskMovedMessage(String title, String date) {
    return '\"$title\" moved to $date';
  }

  @override
  String get noTasksHabitsThisDate => 'No tasks/habits on this date';

  @override
  String get tasksLabel => 'Tasks';

  @override
  String get dailyHabitsLabel => 'Habits (daily)';

  @override
  String get dailyHabitInfo =>
      'Daily habits apply every day — see status on the Habits page.';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get pomodoroScreenTitle => 'Pomodoro';

  @override
  String get modeLabel => 'Mode';

  @override
  String get modeHabitLinked => 'Habit-linked';

  @override
  String get modeFreeStanding => 'Free Standing';

  @override
  String get selectHabitLabel => 'Select Habit';

  @override
  String get durationMinutesLabel => 'Duration (minutes)';

  @override
  String get durationHelperText => 'Fully customizable';

  @override
  String get pauseButton => 'Pause';

  @override
  String get resumeButton => 'Resume';

  @override
  String get cancelSessionButton => 'Cancel';

  @override
  String get sessionCompleteTitle => 'Session complete!';

  @override
  String sessionCompleteHabitMessage(String name) {
    return 'Progress for \"$name\" has been recorded.';
  }

  @override
  String get sessionCompleteFreeMessage => 'Free focus session complete.';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get changeAvatarTooltip => 'Change Avatar';

  @override
  String get editNameTooltip => 'Edit Name';

  @override
  String get noNamePlaceholder => '(No name yet)';

  @override
  String get badgeCollectionTitle => 'Badge Collection';

  @override
  String errorLoadingBadges(String error) {
    return 'Failed to load badges: $error';
  }

  @override
  String get avatarCollectionTitle =>
      'Avatar Collection — unlocks every 10 levels';

  @override
  String errorLoadingAvatars(String error) {
    return 'Failed to load avatars: $error';
  }

  @override
  String get editNameDialogTitle => 'Edit Name';

  @override
  String get splashTagline => 'Growing every day';

  @override
  String get rankPerintis => 'Pioneer';

  @override
  String get rankPetarung => 'Fighter';

  @override
  String get rankPenakluk => 'Conqueror';

  @override
  String get rankSangAhli => 'Expert';

  @override
  String get rankSangMaster => 'Master';

  @override
  String get rankLegenda => 'Legend';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Task, Habit, Streak Warning, Freeze';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAbout => 'About App';

  @override
  String get notificationsScreenTitle => 'Notifications';

  @override
  String get notifTaskLabel => 'Task';

  @override
  String get notifHabitLabel => 'Habit';

  @override
  String get notifStreakWarningLabel => 'Streak Warning';

  @override
  String get notifFreezeLabel => 'Freeze';

  @override
  String get aboutScreenTitle => 'About App';

  @override
  String aboutVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription =>
      'Tazk combines task management, habit tracking, and RPG-style gamification in one 100% offline app.';

  @override
  String notifTaskReminderTitle(String title) {
    return 'Time for: $title';
  }

  @override
  String get notifTaskReminderBody =>
      'This task is scheduled now. Let\'s get it done!';

  @override
  String notifHabitReminderTitle(String name) {
    return 'Time for: $name';
  }

  @override
  String get notifHabitReminderBody =>
      'This habit is scheduled now. Keep your streak alive!';

  @override
  String get notifStreakWarningTitle => 'Don\'t break your streak!';

  @override
  String get notifStreakWarningBody =>
      'No task/habit completed yet today. Finish one before midnight!';

  @override
  String get notifFreezeUsedTitle => 'Freeze used!';

  @override
  String get notifFreezeUsedBody =>
      'Your streak stayed safe because a freeze was automatically used for the missed day.';
}
