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
  String get navMore => 'More';

  @override
  String get navAbout => 'About';

  @override
  String comingSoonMessage(String title) {
    return '$title — coming soon';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get habitTotalDoneLabel => 'Total done';

  @override
  String get habitConsistencyLabel => 'Consistency';

  @override
  String get habitReminderLabel => 'Reminder';

  @override
  String get habitTargetLabel => 'Target';

  @override
  String habitMinutesPerDay(int minutes) {
    return '$minutes min / day';
  }

  @override
  String get habitHistoryWindowTitle => '4-week history';

  @override
  String get habitLegendMissed => 'missed';

  @override
  String get habitLegendDone => 'done';

  @override
  String get habitDayDoneSemantics => 'done';

  @override
  String get habitDayNotDoneSemantics => 'not done';

  @override
  String get habitDayMissedSemantics => 'missed';

  @override
  String get habitDayPartialSemantics => 'partially done';

  @override
  String get habitDayNotDueSemantics => 'not scheduled';

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
  String get onboardingWelcome => 'Hi, I\'m Tazk';

  @override
  String get onboardingAskName =>
      'I help you finish the small things every day. What\'s your name?';

  @override
  String get onboardingNameLabel => 'Your name';

  @override
  String get onboardingNameHelper => 'You can change it anytime in Profile';

  @override
  String get onboardingPickTheme => 'Pick a theme';

  @override
  String get onboardingPickThemeHint =>
      'Light or dark, your call. You can change it anytime in Settings.';

  @override
  String get onboardingPickLanguage => 'Pick a language';

  @override
  String get onboardingPickLanguageHint =>
      'Choose the language you\'re most comfortable with. You can change it anytime.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingFinish => 'Done';

  @override
  String onboardingStepProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get fieldNameLabel => 'Name';

  @override
  String get onboardingNameEmptyError => 'Name cannot be empty';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
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
  String get homeStartPomodoroButton => 'Start focus session';

  @override
  String homeTasksRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left',
      one: '1 left',
    );
    return '$_temp0';
  }

  @override
  String homeHabitsProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String get homeNoTime => 'No time';

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String homeHabitMinutes(int current, int target) {
    return '$current / $target min';
  }

  @override
  String homeXpMeta(int xp, int needed, String rank) {
    return '$xp / $needed XP · $rank';
  }

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
  String get autoCompleteSubtasksLabel =>
      'Complete the task when every subtask is done';

  @override
  String get openInMapsTooltip => 'Open in Maps';

  @override
  String get openInMapsFailedMessage =>
      'No maps app on this phone can open that location.';

  @override
  String get noTimeLabel => 'No time';

  @override
  String get tasksPendingHeader => 'Not done';

  @override
  String get tasksDoneHeader => 'Done';

  @override
  String subtaskProgress(int done, int total) {
    return '$done/$total subtask';
  }

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
  String get customFrequencyConfigTitle => 'Custom frequency settings';

  @override
  String get customFrequencyTypeLabel => 'Custom frequency type';

  @override
  String get customTypeWeeklyDays => 'Specific days of week';

  @override
  String get customTypeIntervalDays => 'Every N days';

  @override
  String get customTypeMonthlyDay => 'Specific day of month';

  @override
  String get customDaysOfWeekLabel => 'Select days';

  @override
  String get customDaysRequiredError => 'Select at least one day';

  @override
  String get customIntervalLabel => 'Interval (days)';

  @override
  String get customIntervalHelper => 'e.g., 2 = every 2 days';

  @override
  String get customIntervalInvalidError => 'Enter a valid interval (1+)';

  @override
  String get customDayOfMonthLabel => 'Day of month';

  @override
  String get customDayOfMonthHelper =>
      '1-31 (will skip months without this day)';

  @override
  String get customDayOfMonthInvalidError => 'Enter a valid day (1-31)';

  @override
  String get weekdayMonShort => 'Mon';

  @override
  String get weekdayTueShort => 'Tue';

  @override
  String get weekdayWedShort => 'Wed';

  @override
  String get weekdayThuShort => 'Thu';

  @override
  String get weekdayFriShort => 'Fri';

  @override
  String get weekdaySatShort => 'Sat';

  @override
  String get weekdaySunShort => 'Sun';

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
    return 'The history and streak of \"$name\" stay saved, but this habit will no longer be active.';
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
  String get profileStreakDaysLabel => 'day streak';

  @override
  String get profileTasksDoneTodayLabel => 'tasks done';

  @override
  String get profileBadgesLabel => 'badges';

  @override
  String get badgeCollectionTitle => 'Badge Collection';

  @override
  String badgesUnlockedCount(int unlocked, int total) {
    return '$unlocked of $total';
  }

  @override
  String errorLoadingBadges(String error) {
    return 'Failed to load badges: $error';
  }

  @override
  String get avatarCollectionTitle => 'Cosmetics';

  @override
  String cosmeticsUnlockedCount(int count) {
    return '$count unlocked';
  }

  @override
  String errorLoadingAvatars(String error) {
    return 'Failed to load avatars: $error';
  }

  @override
  String get editNameDialogTitle => 'Edit Name';

  @override
  String get splashTagline => 'One small step every day';

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
  String get celebrationRankTitle => 'New Rank!';

  @override
  String get celebrationContinueAction => 'Continue';

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
  String get notifFocusSessionLabel => 'Focus session';

  @override
  String get notifTaskSubtitle => 'When the task time arrives';

  @override
  String get notifHabitSubtitle => 'When the habit time arrives';

  @override
  String get notifStreakWarningSubtitle => 'If nothing is done yet';

  @override
  String get notifFreezeSubtitle => 'When a freeze is used automatically';

  @override
  String get notifFocusSessionSubtitle => 'When the Pomodoro timer ends';

  @override
  String get permissionBannerMessage =>
      'Notifications are off. Turn them on so task & habit reminders work.';

  @override
  String get permissionBannerAction => 'Turn On';

  @override
  String get notifStatusLabel => 'Notification status';

  @override
  String get notifStatusEnabled => 'On';

  @override
  String get notifStatusDisabled => 'Off';

  @override
  String get dbResetMessage =>
      'Local data got corrupted, so Tazk safely started fresh.';

  @override
  String get widgetStreakActiveLabel => 'Active streak';

  @override
  String get widgetStreakDaysSuffix => 'days';

  @override
  String get streakDaySingular => 'day';

  @override
  String get exactAlarmBannerMessage =>
      'Exact alarm permission is off. Reminders may be up to 15 minutes late.';

  @override
  String get exactAlarmBannerAction => 'Turn On';

  @override
  String get exactAlarmSettingsTitle => 'Exact alarm';

  @override
  String get exactAlarmActive => 'On';

  @override
  String get exactAlarmInactive => 'Off — reminders may be late';

  @override
  String get aboutScreenTitle => 'About Tazk';

  @override
  String aboutVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription =>
      'Tasks, habits, and focus in one place. All your data stays on your phone.';

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

  @override
  String get stateEmptyTasksTitle => 'No tasks today yet';

  @override
  String get stateEmptyTasksSubtitle =>
      'Take it easy, or add one small task to get started.';

  @override
  String get stateEmptyTasksAction => 'Add task';

  @override
  String get stateLoadingLabel => 'Loading data';

  @override
  String get stateErrorTitle => 'Failed to load data';

  @override
  String get stateErrorMessage =>
      'Try again in a moment. Your local data is still safe.';

  @override
  String get stateRetryAction => 'Try again';

  @override
  String get navStats => 'Statistics';

  @override
  String get statsPeriodWeek => 'Week';

  @override
  String get statsPeriodMonth => 'Month';

  @override
  String get statsPeriodYear => 'Year';

  @override
  String get statsTasksDone => 'tasks done';

  @override
  String get statsFocusTime => 'focus time';

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get statsValueDash => '–';

  @override
  String get statsXpWeek => 'Weekly XP';

  @override
  String get statsXpMonth => 'Monthly XP';

  @override
  String get statsXpYear => 'Yearly XP';

  @override
  String get statsHabitConsistency => 'Habit consistency';

  @override
  String statsDaysCount(int days) {
    return '$days days';
  }

  @override
  String get statsLegendRare => 'rare';

  @override
  String get statsLegendFrequent => 'regular';

  @override
  String get statsVsLastWeek => 'vs last week';

  @override
  String get statsVsLastMonth => 'vs last month';

  @override
  String get statsVsLastYear => 'vs last year';

  @override
  String get statsEmptyWeek => 'No data for this week yet';

  @override
  String get statsEmptyMonth => 'No data for this month yet';

  @override
  String get statsEmptyYear => 'No data for this year yet';

  @override
  String get statsEmptyHint =>
      'Finish a task or run a focus session, then come back here.';

  @override
  String get statsFocusEmpty => 'No focus sessions yet';

  @override
  String get statsXpEmpty => 'No XP yet';

  @override
  String get statsHeatmapEmpty => 'No habit history yet';

  @override
  String get statsInsightTitle => 'Insight';

  @override
  String statsInsightProductive(String day) {
    return 'You are most productive on $day.';
  }

  @override
  String statsInsightConsistentHabit(String habit) {
    return '$habit has been your most consistent habit lately.';
  }

  @override
  String get statsInsightEmpty =>
      'Insights appear once you have finished some tasks and habits.';

  @override
  String get statsNoComparison => 'no comparison yet';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String habitsSummaryHeadline(int done, int total) {
    return '$done of $total habits today';
  }

  @override
  String get habitsSummaryStart => 'Start one habit to keep your rhythm';

  @override
  String get habitsSummaryAllDone => 'All habits done today';

  @override
  String get habitsSummaryOnTrack => 'Keep the rhythm, you are on track';

  @override
  String get aboutPrivacyTitle => 'Privacy policy';

  @override
  String get aboutPrivacyBody =>
      'Tazk runs entirely on your phone. There is no account, no server of ours, and no data sent to anyone. The app never asks for camera, microphone, location, or storage permission. Every task, habit, and focus session lives in the device\'s local database. A backup exists only if you turn on backup to your own Google Drive, and that file stays in your Drive, not with us. Uninstalling the app removes all local data.';

  @override
  String get aboutLicensesTitle => 'Open source licenses';

  @override
  String get aboutFooter => 'Built with Flutter. Free, no ads, no account.';

  @override
  String get pomodoroStatusIdle => 'Ready to focus';

  @override
  String get pomodoroStatusRunning => 'Focus running';

  @override
  String get pomodoroStatusPaused => 'Paused';

  @override
  String get pomodoroDurationHint => 'Tap the time to change duration';

  @override
  String get customDurationTitle => 'Set duration';

  @override
  String get customDurationFieldLabel => 'Minutes';

  @override
  String get customDurationHint => '1 to 180 minutes';

  @override
  String get customDurationInvalid => 'Enter 1 to 180 minutes';

  @override
  String get presetEditTitle => 'Edit duration chip';

  @override
  String get presetEditHint => 'Long-press a chip to change its value';

  @override
  String get fieldCategoryOptionalLabel => 'Category (optional)';

  @override
  String get categoryNoneLabel => 'No category';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get manageCategoriesLabel => 'Manage categories';

  @override
  String get categoriesScreenTitle => 'Manage categories';

  @override
  String get addCategoryTitle => 'New category';

  @override
  String get editCategoryTitle => 'Edit category';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get categoryNameHint => 'e.g. Work, Shopping';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get saveCategoryLabel => 'Save category';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String get deleteCategoryBody =>
      'Tasks and habits in this category stay — only the category is removed.';

  @override
  String get deleteCategoryConfirm => 'Delete';

  @override
  String get categoryEmptyTitle => 'No categories yet';

  @override
  String get categoryEmptyBody =>
      'Create a category to group your tasks and habits.';

  @override
  String get categoryEmptyAction => 'Create category';

  @override
  String get categoryNameDuplicateError => 'That category name is already used';

  @override
  String get categoryNameRequiredError => 'Category name cannot be empty';

  @override
  String get categorySaveFailedMessage => 'Category was not saved. Try again.';

  @override
  String get categoryColorSage => 'Sage';

  @override
  String get categoryColorHoney => 'Honey';

  @override
  String get categoryColorRose => 'Rose';

  @override
  String get categoryColorSky => 'Sky';

  @override
  String get categoryColorPlum => 'Plum';

  @override
  String get categoryColorSand => 'Sand';

  @override
  String get searchScreenTitle => 'Search';

  @override
  String get searchFieldHint => 'Search tasks and habits';

  @override
  String get searchPromptBody =>
      'Matches titles, locations, and category names while you type.';

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchFilterHabits => 'Habit';

  @override
  String get searchFilterCompleted => 'Done';

  @override
  String get searchNoResultsTitle => 'No results';

  @override
  String searchNoResultsBody(String query) {
    return 'Nothing matches \"$query\". Try another word or change the filter.';
  }

  @override
  String get searchClearTooltip => 'Clear search';

  @override
  String get searchTypeTask => 'Task';

  @override
  String get searchTypeHabit => 'Habit';

  @override
  String get searchCompletedLabel => 'completed';
}
