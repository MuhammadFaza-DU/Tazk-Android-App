import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Tazk'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTasks.
  ///
  /// In id, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navHabits.
  ///
  /// In id, this message translates to:
  /// **'Habits'**
  String get navHabits;

  /// No description provided for @navCalendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender'**
  String get navCalendar;

  /// No description provided for @navPomodoro.
  ///
  /// In id, this message translates to:
  /// **'Pomodoro'**
  String get navPomodoro;

  /// No description provided for @navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get navSettings;

  /// No description provided for @navMore.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get navMore;

  /// No description provided for @navAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get navAbout;

  /// No description provided for @comingSoonMessage.
  ///
  /// In id, this message translates to:
  /// **'{title} — segera hadir'**
  String comingSoonMessage(String title);

  /// No description provided for @cancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get saveButton;

  /// No description provided for @habitTotalDoneLabel.
  ///
  /// In id, this message translates to:
  /// **'Total selesai'**
  String get habitTotalDoneLabel;

  /// No description provided for @habitConsistencyLabel.
  ///
  /// In id, this message translates to:
  /// **'Konsistensi'**
  String get habitConsistencyLabel;

  /// No description provided for @habitReminderLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get habitReminderLabel;

  /// No description provided for @habitTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target'**
  String get habitTargetLabel;

  /// No description provided for @habitMinutesPerDay.
  ///
  /// In id, this message translates to:
  /// **'{minutes} menit / hari'**
  String habitMinutesPerDay(int minutes);

  /// No description provided for @habitHistoryWindowTitle.
  ///
  /// In id, this message translates to:
  /// **'Histori 4 minggu'**
  String get habitHistoryWindowTitle;

  /// No description provided for @habitLegendMissed.
  ///
  /// In id, this message translates to:
  /// **'lewat'**
  String get habitLegendMissed;

  /// No description provided for @habitLegendDone.
  ///
  /// In id, this message translates to:
  /// **'selesai'**
  String get habitLegendDone;

  /// No description provided for @habitDayDoneSemantics.
  ///
  /// In id, this message translates to:
  /// **'selesai'**
  String get habitDayDoneSemantics;

  /// No description provided for @habitDayNotDoneSemantics.
  ///
  /// In id, this message translates to:
  /// **'belum selesai'**
  String get habitDayNotDoneSemantics;

  /// No description provided for @habitDayMissedSemantics.
  ///
  /// In id, this message translates to:
  /// **'terlewat'**
  String get habitDayMissedSemantics;

  /// No description provided for @habitDayPartialSemantics.
  ///
  /// In id, this message translates to:
  /// **'sebagian'**
  String get habitDayPartialSemantics;

  /// No description provided for @habitDayNotDueSemantics.
  ///
  /// In id, this message translates to:
  /// **'tidak dijadwalkan'**
  String get habitDayNotDueSemantics;

  /// No description provided for @okButton.
  ///
  /// In id, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @deleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get deleteButton;

  /// No description provided for @startButton.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get startButton;

  /// No description provided for @yesLabel.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get noLabel;

  /// No description provided for @onboardingWelcome.
  ///
  /// In id, this message translates to:
  /// **'Halo! Aku Tazk'**
  String get onboardingWelcome;

  /// No description provided for @onboardingAskName.
  ///
  /// In id, this message translates to:
  /// **'Aku akan bantu kamu menyelesaikan hal kecil setiap hari. Siapa namamu?'**
  String get onboardingAskName;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama kamu'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHelper.
  ///
  /// In id, this message translates to:
  /// **'Bisa diubah kapan saja di Profil'**
  String get onboardingNameHelper;

  /// No description provided for @onboardingPickTheme.
  ///
  /// In id, this message translates to:
  /// **'Pilih tema'**
  String get onboardingPickTheme;

  /// No description provided for @onboardingPickThemeHint.
  ///
  /// In id, this message translates to:
  /// **'Terang atau gelap, sesukamu. Bisa diganti kapan saja di Pengaturan.'**
  String get onboardingPickThemeHint;

  /// No description provided for @onboardingPickLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa'**
  String get onboardingPickLanguage;

  /// No description provided for @onboardingPickLanguageHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa yang paling nyaman buatmu. Bisa diganti kapan saja.'**
  String get onboardingPickLanguageHint;

  /// No description provided for @onboardingNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onboardingNext;

  /// No description provided for @onboardingFinish.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get onboardingFinish;

  /// No description provided for @onboardingStepProgress.
  ///
  /// In id, this message translates to:
  /// **'{current} dari {total}'**
  String onboardingStepProgress(int current, int total);

  /// No description provided for @fieldNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get fieldNameLabel;

  /// No description provided for @onboardingNameEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nama tidak boleh kosong'**
  String get onboardingNameEmptyError;

  /// No description provided for @homeGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeTasksToday.
  ///
  /// In id, this message translates to:
  /// **'Tugas Hari Ini'**
  String get homeTasksToday;

  /// No description provided for @homeNoTasksToday.
  ///
  /// In id, this message translates to:
  /// **'Belum ada task hari ini'**
  String get homeNoTasksToday;

  /// No description provided for @errorLoadingTasks.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat task: {error}'**
  String errorLoadingTasks(String error);

  /// No description provided for @homeHabitsToday.
  ///
  /// In id, this message translates to:
  /// **'Habits Hari Ini'**
  String get homeHabitsToday;

  /// No description provided for @homeNoActiveHabits.
  ///
  /// In id, this message translates to:
  /// **'Belum ada habit aktif'**
  String get homeNoActiveHabits;

  /// No description provided for @errorLoadingHabits.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat habit: {error}'**
  String errorLoadingHabits(String error);

  /// No description provided for @homeStartPomodoroButton.
  ///
  /// In id, this message translates to:
  /// **'Mulai sesi fokus'**
  String get homeStartPomodoroButton;

  /// No description provided for @homeTasksRemaining.
  ///
  /// In id, this message translates to:
  /// **'{count} sisa'**
  String homeTasksRemaining(int count);

  /// No description provided for @homeHabitsProgress.
  ///
  /// In id, this message translates to:
  /// **'{done} dari {total}'**
  String homeHabitsProgress(int done, int total);

  /// No description provided for @homeNoTime.
  ///
  /// In id, this message translates to:
  /// **'Tanpa jam'**
  String get homeNoTime;

  /// No description provided for @homeStreakDays.
  ///
  /// In id, this message translates to:
  /// **'{count} hari'**
  String homeStreakDays(int count);

  /// No description provided for @homeHabitMinutes.
  ///
  /// In id, this message translates to:
  /// **'{current} / {target} mnt'**
  String homeHabitMinutes(int current, int target);

  /// No description provided for @homeXpMeta.
  ///
  /// In id, this message translates to:
  /// **'{xp} / {needed} XP · {rank}'**
  String homeXpMeta(int xp, int needed, String rank);

  /// No description provided for @levelLabel.
  ///
  /// In id, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @xpProgress.
  ///
  /// In id, this message translates to:
  /// **'{xp}/{needed} XP'**
  String xpProgress(int xp, int needed);

  /// No description provided for @streakSummary.
  ///
  /// In id, this message translates to:
  /// **'🔥 Streak {days} hari · {rank}'**
  String streakSummary(int days, String rank);

  /// No description provided for @tasksScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Tasks — Hari Ini'**
  String get tasksScreenTitle;

  /// No description provided for @taskDuplicateTooltip.
  ///
  /// In id, this message translates to:
  /// **'Duplikat'**
  String get taskDuplicateTooltip;

  /// No description provided for @priorityLowShort.
  ///
  /// In id, this message translates to:
  /// **'Low'**
  String get priorityLowShort;

  /// No description provided for @priorityMedShort.
  ///
  /// In id, this message translates to:
  /// **'Med'**
  String get priorityMedShort;

  /// No description provided for @priorityHighShort.
  ///
  /// In id, this message translates to:
  /// **'High'**
  String get priorityHighShort;

  /// No description provided for @editTaskTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Task'**
  String get editTaskTitle;

  /// No description provided for @addTaskTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Task'**
  String get addTaskTitle;

  /// No description provided for @fieldTitleLabel.
  ///
  /// In id, this message translates to:
  /// **'Judul'**
  String get fieldTitleLabel;

  /// No description provided for @taskTitleRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Judul wajib diisi'**
  String get taskTitleRequiredError;

  /// No description provided for @fieldDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get fieldDateLabel;

  /// No description provided for @fieldTimeOptionalLabel.
  ///
  /// In id, this message translates to:
  /// **'Jam (opsional)'**
  String get fieldTimeOptionalLabel;

  /// No description provided for @fieldPriorityLabel.
  ///
  /// In id, this message translates to:
  /// **'Prioritas'**
  String get fieldPriorityLabel;

  /// No description provided for @priorityLow.
  ///
  /// In id, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In id, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In id, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @fieldLocationOptionalLabel.
  ///
  /// In id, this message translates to:
  /// **'Lokasi (opsional)'**
  String get fieldLocationOptionalLabel;

  /// No description provided for @checklistOptionalLabel.
  ///
  /// In id, this message translates to:
  /// **'Checklist/Subtask (opsional)'**
  String get checklistOptionalLabel;

  /// No description provided for @addItemHint.
  ///
  /// In id, this message translates to:
  /// **'Tambah item'**
  String get addItemHint;

  /// No description provided for @habitsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Habits'**
  String get habitsScreenTitle;

  /// No description provided for @habitProgressLabel.
  ///
  /// In id, this message translates to:
  /// **'{current}/{target} menit'**
  String habitProgressLabel(int current, int target);

  /// No description provided for @editHabitTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Habit'**
  String get editHabitTitle;

  /// No description provided for @addHabitTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Habit'**
  String get addHabitTitle;

  /// No description provided for @habitNameRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get habitNameRequiredError;

  /// No description provided for @fieldFrequencyLabel.
  ///
  /// In id, this message translates to:
  /// **'Frekuensi'**
  String get fieldFrequencyLabel;

  /// No description provided for @frequencyDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get frequencyDaily;

  /// No description provided for @frequencyWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get frequencyWeekly;

  /// No description provided for @frequencyMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get frequencyMonthly;

  /// No description provided for @frequencyCustom.
  ///
  /// In id, this message translates to:
  /// **'Custom'**
  String get frequencyCustom;

  /// No description provided for @customFrequencyConfigTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan frekuensi kustom'**
  String get customFrequencyConfigTitle;

  /// No description provided for @customFrequencyTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis frekuensi kustom'**
  String get customFrequencyTypeLabel;

  /// No description provided for @customTypeWeeklyDays.
  ///
  /// In id, this message translates to:
  /// **'Hari tertentu tiap minggu'**
  String get customTypeWeeklyDays;

  /// No description provided for @customTypeIntervalDays.
  ///
  /// In id, this message translates to:
  /// **'Setiap N hari'**
  String get customTypeIntervalDays;

  /// No description provided for @customTypeMonthlyDay.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tertentu tiap bulan'**
  String get customTypeMonthlyDay;

  /// No description provided for @customDaysOfWeekLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih hari'**
  String get customDaysOfWeekLabel;

  /// No description provided for @customDaysRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Pilih minimal satu hari'**
  String get customDaysRequiredError;

  /// No description provided for @customIntervalLabel.
  ///
  /// In id, this message translates to:
  /// **'Interval (hari)'**
  String get customIntervalLabel;

  /// No description provided for @customIntervalHelper.
  ///
  /// In id, this message translates to:
  /// **'cth: 2 = setiap 2 hari'**
  String get customIntervalHelper;

  /// No description provided for @customIntervalInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Masukkan interval valid (1+)'**
  String get customIntervalInvalidError;

  /// No description provided for @customDayOfMonthLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get customDayOfMonthLabel;

  /// No description provided for @customDayOfMonthHelper.
  ///
  /// In id, this message translates to:
  /// **'1-31 (dilewati jika bulan tidak punya tanggal ini)'**
  String get customDayOfMonthHelper;

  /// No description provided for @customDayOfMonthInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Masukkan tanggal valid (1-31)'**
  String get customDayOfMonthInvalidError;

  /// No description provided for @weekdayMonShort.
  ///
  /// In id, this message translates to:
  /// **'Sen'**
  String get weekdayMonShort;

  /// No description provided for @weekdayTueShort.
  ///
  /// In id, this message translates to:
  /// **'Sel'**
  String get weekdayTueShort;

  /// No description provided for @weekdayWedShort.
  ///
  /// In id, this message translates to:
  /// **'Rab'**
  String get weekdayWedShort;

  /// No description provided for @weekdayThuShort.
  ///
  /// In id, this message translates to:
  /// **'Kam'**
  String get weekdayThuShort;

  /// No description provided for @weekdayFriShort.
  ///
  /// In id, this message translates to:
  /// **'Jum'**
  String get weekdayFriShort;

  /// No description provided for @weekdaySatShort.
  ///
  /// In id, this message translates to:
  /// **'Sab'**
  String get weekdaySatShort;

  /// No description provided for @weekdaySunShort.
  ///
  /// In id, this message translates to:
  /// **'Min'**
  String get weekdaySunShort;

  /// No description provided for @fieldScheduledTimeOptionalLabel.
  ///
  /// In id, this message translates to:
  /// **'Waktu (opsional)'**
  String get fieldScheduledTimeOptionalLabel;

  /// No description provided for @hasProgressLabel.
  ///
  /// In id, this message translates to:
  /// **'Progress bertahap?'**
  String get hasProgressLabel;

  /// No description provided for @targetMinutesLabel.
  ///
  /// In id, this message translates to:
  /// **'Target waktu (menit)'**
  String get targetMinutesLabel;

  /// No description provided for @targetMinutesInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Masukkan target menit yang valid'**
  String get targetMinutesInvalidError;

  /// No description provided for @frequencyDisplay.
  ///
  /// In id, this message translates to:
  /// **'Frekuensi: {frequency}'**
  String frequencyDisplay(String frequency);

  /// No description provided for @streakContributionDisplay.
  ///
  /// In id, this message translates to:
  /// **'Streak kontribusi: {status}'**
  String streakContributionDisplay(String status);

  /// No description provided for @streakContributionActive.
  ///
  /// In id, this message translates to:
  /// **'aktif'**
  String get streakContributionActive;

  /// No description provided for @streakContributionInactive.
  ///
  /// In id, this message translates to:
  /// **'belum hari ini'**
  String get streakContributionInactive;

  /// No description provided for @historyTitle.
  ///
  /// In id, this message translates to:
  /// **'Histori'**
  String get historyTitle;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat histori: {error}'**
  String errorLoadingHistory(String error);

  /// No description provided for @deleteHabitDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus habit?'**
  String get deleteHabitDialogTitle;

  /// No description provided for @deleteHabitDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Histori dan streak \"{name}\" tetap tersimpan, tapi habit ini tidak akan aktif lagi.'**
  String deleteHabitDialogContent(String name);

  /// No description provided for @weekdayMon.
  ///
  /// In id, this message translates to:
  /// **'Sen'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In id, this message translates to:
  /// **'Sel'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In id, this message translates to:
  /// **'Rab'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In id, this message translates to:
  /// **'Kam'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In id, this message translates to:
  /// **'Jum'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In id, this message translates to:
  /// **'Sab'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In id, this message translates to:
  /// **'Min'**
  String get weekdaySun;

  /// No description provided for @calendarScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalender — {month} {year}'**
  String calendarScreenTitle(String month, int year);

  /// No description provided for @errorLoadingCalendar.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat: {error}'**
  String errorLoadingCalendar(String error);

  /// No description provided for @taskMovedMessage.
  ///
  /// In id, this message translates to:
  /// **'\"{title}\" dipindah ke {date}'**
  String taskMovedMessage(String title, String date);

  /// No description provided for @noTasksHabitsThisDate.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada task/habit di tanggal ini'**
  String get noTasksHabitsThisDate;

  /// No description provided for @tasksLabel.
  ///
  /// In id, this message translates to:
  /// **'Tasks'**
  String get tasksLabel;

  /// No description provided for @dailyHabitsLabel.
  ///
  /// In id, this message translates to:
  /// **'Habits (harian)'**
  String get dailyHabitsLabel;

  /// No description provided for @dailyHabitInfo.
  ///
  /// In id, this message translates to:
  /// **'Habit harian berlaku setiap hari — lihat status di halaman Habits.'**
  String get dailyHabitInfo;

  /// No description provided for @monthJanuary.
  ///
  /// In id, this message translates to:
  /// **'Januari'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In id, this message translates to:
  /// **'Februari'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In id, this message translates to:
  /// **'Maret'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In id, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In id, this message translates to:
  /// **'Mei'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In id, this message translates to:
  /// **'Juni'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In id, this message translates to:
  /// **'Juli'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In id, this message translates to:
  /// **'Agustus'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In id, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In id, this message translates to:
  /// **'Oktober'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In id, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In id, this message translates to:
  /// **'Desember'**
  String get monthDecember;

  /// No description provided for @pomodoroScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Pomodoro'**
  String get pomodoroScreenTitle;

  /// No description provided for @modeLabel.
  ///
  /// In id, this message translates to:
  /// **'Mode'**
  String get modeLabel;

  /// No description provided for @modeHabitLinked.
  ///
  /// In id, this message translates to:
  /// **'Terkait Habit'**
  String get modeHabitLinked;

  /// No description provided for @modeFreeStanding.
  ///
  /// In id, this message translates to:
  /// **'Bebas Mandiri'**
  String get modeFreeStanding;

  /// No description provided for @selectHabitLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih Habit'**
  String get selectHabitLabel;

  /// No description provided for @durationMinutesLabel.
  ///
  /// In id, this message translates to:
  /// **'Durasi (menit)'**
  String get durationMinutesLabel;

  /// No description provided for @durationHelperText.
  ///
  /// In id, this message translates to:
  /// **'Kustomisasi bebas'**
  String get durationHelperText;

  /// No description provided for @pauseButton.
  ///
  /// In id, this message translates to:
  /// **'Pause'**
  String get pauseButton;

  /// No description provided for @resumeButton.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get resumeButton;

  /// No description provided for @cancelSessionButton.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get cancelSessionButton;

  /// No description provided for @sessionCompleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Sesi selesai!'**
  String get sessionCompleteTitle;

  /// No description provided for @sessionCompleteHabitMessage.
  ///
  /// In id, this message translates to:
  /// **'Progress \"{name}\" tercatat.'**
  String sessionCompleteHabitMessage(String name);

  /// No description provided for @sessionCompleteFreeMessage.
  ///
  /// In id, this message translates to:
  /// **'Sesi fokus bebas selesai.'**
  String get sessionCompleteFreeMessage;

  /// No description provided for @profileScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileScreenTitle;

  /// No description provided for @changeAvatarTooltip.
  ///
  /// In id, this message translates to:
  /// **'Ganti Avatar'**
  String get changeAvatarTooltip;

  /// No description provided for @editNameTooltip.
  ///
  /// In id, this message translates to:
  /// **'Edit Nama'**
  String get editNameTooltip;

  /// No description provided for @noNamePlaceholder.
  ///
  /// In id, this message translates to:
  /// **'(Belum ada nama)'**
  String get noNamePlaceholder;

  /// No description provided for @profileStreakDaysLabel.
  ///
  /// In id, this message translates to:
  /// **'hari streak'**
  String get profileStreakDaysLabel;

  /// No description provided for @profileTasksDoneTodayLabel.
  ///
  /// In id, this message translates to:
  /// **'tugas selesai'**
  String get profileTasksDoneTodayLabel;

  /// No description provided for @profileBadgesLabel.
  ///
  /// In id, this message translates to:
  /// **'badge'**
  String get profileBadgesLabel;

  /// No description provided for @badgeCollectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Koleksi Badge'**
  String get badgeCollectionTitle;

  /// No description provided for @badgesUnlockedCount.
  ///
  /// In id, this message translates to:
  /// **'{unlocked} dari {total}'**
  String badgesUnlockedCount(int unlocked, int total);

  /// No description provided for @errorLoadingBadges.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat badge: {error}'**
  String errorLoadingBadges(String error);

  /// No description provided for @avatarCollectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Kosmetik'**
  String get avatarCollectionTitle;

  /// No description provided for @cosmeticsUnlockedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} terbuka'**
  String cosmeticsUnlockedCount(int count);

  /// No description provided for @errorLoadingAvatars.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat avatar: {error}'**
  String errorLoadingAvatars(String error);

  /// No description provided for @editNameDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Nama'**
  String get editNameDialogTitle;

  /// No description provided for @splashTagline.
  ///
  /// In id, this message translates to:
  /// **'Satu langkah kecil setiap hari'**
  String get splashTagline;

  /// No description provided for @rankPerintis.
  ///
  /// In id, this message translates to:
  /// **'Perintis'**
  String get rankPerintis;

  /// No description provided for @rankPetarung.
  ///
  /// In id, this message translates to:
  /// **'Petarung'**
  String get rankPetarung;

  /// No description provided for @rankPenakluk.
  ///
  /// In id, this message translates to:
  /// **'Penakluk'**
  String get rankPenakluk;

  /// No description provided for @rankSangAhli.
  ///
  /// In id, this message translates to:
  /// **'Sang Ahli'**
  String get rankSangAhli;

  /// No description provided for @rankSangMaster.
  ///
  /// In id, this message translates to:
  /// **'Sang Master'**
  String get rankSangMaster;

  /// No description provided for @rankLegenda.
  ///
  /// In id, this message translates to:
  /// **'Legenda'**
  String get rankLegenda;

  /// No description provided for @celebrationRankTitle.
  ///
  /// In id, this message translates to:
  /// **'Rank Baru!'**
  String get celebrationRankTitle;

  /// No description provided for @celebrationContinueAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get celebrationContinueAction;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsScreenTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Task, Habit, Streak Warning, Freeze'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get settingsAppearance;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsLanguage;

  /// No description provided for @languageIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageEnglish.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang App'**
  String get settingsAbout;

  /// No description provided for @notificationsScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notificationsScreenTitle;

  /// No description provided for @notifTaskLabel.
  ///
  /// In id, this message translates to:
  /// **'Task'**
  String get notifTaskLabel;

  /// No description provided for @notifHabitLabel.
  ///
  /// In id, this message translates to:
  /// **'Habit'**
  String get notifHabitLabel;

  /// No description provided for @notifStreakWarningLabel.
  ///
  /// In id, this message translates to:
  /// **'Streak Warning'**
  String get notifStreakWarningLabel;

  /// No description provided for @notifFreezeLabel.
  ///
  /// In id, this message translates to:
  /// **'Freeze'**
  String get notifFreezeLabel;

  /// No description provided for @permissionBannerMessage.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi dimatikan. Aktifkan supaya pengingat task & habit berfungsi.'**
  String get permissionBannerMessage;

  /// No description provided for @permissionBannerAction.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan'**
  String get permissionBannerAction;

  /// No description provided for @notifStatusLabel.
  ///
  /// In id, this message translates to:
  /// **'Status notifikasi'**
  String get notifStatusLabel;

  /// No description provided for @notifStatusEnabled.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get notifStatusEnabled;

  /// No description provided for @notifStatusDisabled.
  ///
  /// In id, this message translates to:
  /// **'Mati'**
  String get notifStatusDisabled;

  /// No description provided for @dbResetMessage.
  ///
  /// In id, this message translates to:
  /// **'Data lokal sempat rusak, jadi Tazk amankan dengan mulai dari awal.'**
  String get dbResetMessage;

  /// No description provided for @widgetStreakActiveLabel.
  ///
  /// In id, this message translates to:
  /// **'Streak aktif'**
  String get widgetStreakActiveLabel;

  /// No description provided for @widgetStreakDaysSuffix.
  ///
  /// In id, this message translates to:
  /// **'hari'**
  String get widgetStreakDaysSuffix;

  /// No description provided for @streakDaySingular.
  ///
  /// In id, this message translates to:
  /// **'hari'**
  String get streakDaySingular;

  /// No description provided for @exactAlarmBannerMessage.
  ///
  /// In id, this message translates to:
  /// **'Izin alarm presisi dimatikan. Pengingat bisa telat hingga 15 menit.'**
  String get exactAlarmBannerMessage;

  /// No description provided for @exactAlarmBannerAction.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan'**
  String get exactAlarmBannerAction;

  /// No description provided for @exactAlarmSettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Alarm presisi'**
  String get exactAlarmSettingsTitle;

  /// No description provided for @exactAlarmActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get exactAlarmActive;

  /// No description provided for @exactAlarmInactive.
  ///
  /// In id, this message translates to:
  /// **'Mati — pengingat bisa telat'**
  String get exactAlarmInactive;

  /// No description provided for @aboutScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang Tazk'**
  String get aboutScreenTitle;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi {version}'**
  String aboutVersionLabel(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In id, this message translates to:
  /// **'Task, habit, dan fokus dalam satu tempat. Semua data tersimpan di HP-mu.'**
  String get aboutDescription;

  /// No description provided for @notifTaskReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktunya: {title}'**
  String notifTaskReminderTitle(String title);

  /// No description provided for @notifTaskReminderBody.
  ///
  /// In id, this message translates to:
  /// **'Task ini dijadwalkan sekarang. Yuk selesaikan!'**
  String get notifTaskReminderBody;

  /// No description provided for @notifHabitReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktunya: {name}'**
  String notifHabitReminderTitle(String name);

  /// No description provided for @notifHabitReminderBody.
  ///
  /// In id, this message translates to:
  /// **'Habit ini dijadwalkan sekarang. Jaga streak kamu!'**
  String get notifHabitReminderBody;

  /// No description provided for @notifStreakWarningTitle.
  ///
  /// In id, this message translates to:
  /// **'Jangan putus streak kamu!'**
  String get notifStreakWarningTitle;

  /// No description provided for @notifStreakWarningBody.
  ///
  /// In id, this message translates to:
  /// **'Belum ada task/habit yang selesai hari ini. Selesaikan sebelum tengah malam ya!'**
  String get notifStreakWarningBody;

  /// No description provided for @notifFreezeUsedTitle.
  ///
  /// In id, this message translates to:
  /// **'Freeze terpakai!'**
  String get notifFreezeUsedTitle;

  /// No description provided for @notifFreezeUsedBody.
  ///
  /// In id, this message translates to:
  /// **'Streak kamu tetap aman karena freeze otomatis dipakai untuk hari yang terlewat.'**
  String get notifFreezeUsedBody;

  /// No description provided for @stateEmptyTasksTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas hari ini'**
  String get stateEmptyTasksTitle;

  /// No description provided for @stateEmptyTasksSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Santai dulu, atau tambah satu tugas kecil untuk mulai.'**
  String get stateEmptyTasksSubtitle;

  /// No description provided for @stateEmptyTasksAction.
  ///
  /// In id, this message translates to:
  /// **'Tambah tugas'**
  String get stateEmptyTasksAction;

  /// No description provided for @stateLoadingLabel.
  ///
  /// In id, this message translates to:
  /// **'Memuat data'**
  String get stateLoadingLabel;

  /// No description provided for @stateErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data'**
  String get stateErrorTitle;

  /// No description provided for @stateErrorMessage.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi sebentar. Data lokalmu tetap aman.'**
  String get stateErrorMessage;

  /// No description provided for @stateRetryAction.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get stateRetryAction;

  /// No description provided for @navStats.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get navStats;

  /// No description provided for @statsPeriodWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get statsPeriodWeek;

  /// No description provided for @statsPeriodMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get statsPeriodMonth;

  /// No description provided for @statsPeriodYear.
  ///
  /// In id, this message translates to:
  /// **'Tahun'**
  String get statsPeriodYear;

  /// No description provided for @statsTasksDone.
  ///
  /// In id, this message translates to:
  /// **'task selesai'**
  String get statsTasksDone;

  /// No description provided for @statsFocusTime.
  ///
  /// In id, this message translates to:
  /// **'waktu fokus'**
  String get statsFocusTime;

  /// No description provided for @statsDurationHoursMinutes.
  ///
  /// In id, this message translates to:
  /// **'{hours}j {minutes}m'**
  String statsDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @statsDurationMinutes.
  ///
  /// In id, this message translates to:
  /// **'{minutes}m'**
  String statsDurationMinutes(int minutes);

  /// No description provided for @statsValueDash.
  ///
  /// In id, this message translates to:
  /// **'–'**
  String get statsValueDash;

  /// No description provided for @statsXpWeek.
  ///
  /// In id, this message translates to:
  /// **'XP mingguan'**
  String get statsXpWeek;

  /// No description provided for @statsXpMonth.
  ///
  /// In id, this message translates to:
  /// **'XP bulanan'**
  String get statsXpMonth;

  /// No description provided for @statsXpYear.
  ///
  /// In id, this message translates to:
  /// **'XP tahunan'**
  String get statsXpYear;

  /// No description provided for @statsHabitConsistency.
  ///
  /// In id, this message translates to:
  /// **'Konsistensi habit'**
  String get statsHabitConsistency;

  /// No description provided for @statsDaysCount.
  ///
  /// In id, this message translates to:
  /// **'{days} hari'**
  String statsDaysCount(int days);

  /// No description provided for @statsLegendRare.
  ///
  /// In id, this message translates to:
  /// **'jarang'**
  String get statsLegendRare;

  /// No description provided for @statsLegendFrequent.
  ///
  /// In id, this message translates to:
  /// **'rutin'**
  String get statsLegendFrequent;

  /// No description provided for @statsVsLastWeek.
  ///
  /// In id, this message translates to:
  /// **'vs minggu lalu'**
  String get statsVsLastWeek;

  /// No description provided for @statsVsLastMonth.
  ///
  /// In id, this message translates to:
  /// **'vs bulan lalu'**
  String get statsVsLastMonth;

  /// No description provided for @statsVsLastYear.
  ///
  /// In id, this message translates to:
  /// **'vs tahun lalu'**
  String get statsVsLastYear;

  /// No description provided for @statsEmptyWeek.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data minggu ini'**
  String get statsEmptyWeek;

  /// No description provided for @statsEmptyMonth.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data bulan ini'**
  String get statsEmptyMonth;

  /// No description provided for @statsEmptyYear.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data tahun ini'**
  String get statsEmptyYear;

  /// No description provided for @statsEmptyHint.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan tugas atau jalankan sesi fokus, lalu kembali ke sini.'**
  String get statsEmptyHint;

  /// No description provided for @statsFocusEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada sesi fokus'**
  String get statsFocusEmpty;

  /// No description provided for @statsXpEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada XP'**
  String get statsXpEmpty;

  /// No description provided for @statsHeatmapEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan habit'**
  String get statsHeatmapEmpty;

  /// No description provided for @statsInsightTitle.
  ///
  /// In id, this message translates to:
  /// **'Insight'**
  String get statsInsightTitle;

  /// No description provided for @statsInsightProductive.
  ///
  /// In id, this message translates to:
  /// **'Kamu paling produktif hari {day}.'**
  String statsInsightProductive(String day);

  /// No description provided for @statsInsightConsistentHabit.
  ///
  /// In id, this message translates to:
  /// **'{habit} paling konsisten belakangan ini.'**
  String statsInsightConsistentHabit(String habit);

  /// No description provided for @statsInsightEmpty.
  ///
  /// In id, this message translates to:
  /// **'Insight muncul setelah kamu menyelesaikan beberapa tugas dan habit.'**
  String get statsInsightEmpty;

  /// No description provided for @statsNoComparison.
  ///
  /// In id, this message translates to:
  /// **'belum ada pembanding'**
  String get statsNoComparison;

  /// No description provided for @dayMonday.
  ///
  /// In id, this message translates to:
  /// **'Senin'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In id, this message translates to:
  /// **'Selasa'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In id, this message translates to:
  /// **'Rabu'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In id, this message translates to:
  /// **'Kamis'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In id, this message translates to:
  /// **'Jumat'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In id, this message translates to:
  /// **'Sabtu'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get daySunday;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
