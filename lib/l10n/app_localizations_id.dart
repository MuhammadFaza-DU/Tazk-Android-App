// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Tazk';

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navHabits => 'Habits';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navPomodoro => 'Pomodoro';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String comingSoonMessage(String title) {
    return '$title — segera hadir';
  }

  @override
  String get cancelButton => 'Batal';

  @override
  String get saveButton => 'Simpan';

  @override
  String get okButton => 'OK';

  @override
  String get deleteButton => 'Hapus';

  @override
  String get startButton => 'Mulai';

  @override
  String get yesLabel => 'Ya';

  @override
  String get noLabel => 'Tidak';

  @override
  String get onboardingWelcome => 'Selamat datang di Tazk!';

  @override
  String get onboardingAskName => 'Siapa nama kamu?';

  @override
  String get fieldNameLabel => 'Nama';

  @override
  String get onboardingNameEmptyError => 'Nama tidak boleh kosong';

  @override
  String homeGreeting(String name) {
    return 'Halo, $name!';
  }

  @override
  String get homeTasksToday => 'Tasks Hari Ini';

  @override
  String get homeNoTasksToday => 'Belum ada task hari ini';

  @override
  String errorLoadingTasks(String error) {
    return 'Gagal memuat task: $error';
  }

  @override
  String get homeHabitsToday => 'Habits Hari Ini';

  @override
  String get homeNoActiveHabits => 'Belum ada habit aktif';

  @override
  String errorLoadingHabits(String error) {
    return 'Gagal memuat habit: $error';
  }

  @override
  String get homeStartPomodoroButton => 'Mulai Pomodoro';

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
    return '🔥 Streak $days hari · $rank';
  }

  @override
  String get tasksScreenTitle => 'Tasks — Hari Ini';

  @override
  String get taskDuplicateTooltip => 'Duplikat';

  @override
  String get priorityLowShort => 'Low';

  @override
  String get priorityMedShort => 'Med';

  @override
  String get priorityHighShort => 'High';

  @override
  String get editTaskTitle => 'Edit Task';

  @override
  String get addTaskTitle => 'Tambah Task';

  @override
  String get fieldTitleLabel => 'Judul';

  @override
  String get taskTitleRequiredError => 'Judul wajib diisi';

  @override
  String get fieldDateLabel => 'Tanggal';

  @override
  String get fieldTimeOptionalLabel => 'Jam (opsional)';

  @override
  String get fieldPriorityLabel => 'Prioritas';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get fieldLocationOptionalLabel => 'Lokasi (opsional)';

  @override
  String get checklistOptionalLabel => 'Checklist/Subtask (opsional)';

  @override
  String get addItemHint => 'Tambah item';

  @override
  String get habitsScreenTitle => 'Habits';

  @override
  String habitProgressLabel(int current, int target) {
    return '$current/$target menit';
  }

  @override
  String get editHabitTitle => 'Edit Habit';

  @override
  String get addHabitTitle => 'Tambah Habit';

  @override
  String get habitNameRequiredError => 'Nama wajib diisi';

  @override
  String get fieldFrequencyLabel => 'Frekuensi';

  @override
  String get frequencyDaily => 'Harian';

  @override
  String get frequencyWeekly => 'Mingguan';

  @override
  String get frequencyMonthly => 'Bulanan';

  @override
  String get frequencyCustom => 'Custom';

  @override
  String get fieldScheduledTimeOptionalLabel => 'Waktu (opsional)';

  @override
  String get hasProgressLabel => 'Progress bertahap?';

  @override
  String get targetMinutesLabel => 'Target waktu (menit)';

  @override
  String get targetMinutesInvalidError => 'Masukkan target menit yang valid';

  @override
  String frequencyDisplay(String frequency) {
    return 'Frekuensi: $frequency';
  }

  @override
  String streakContributionDisplay(String status) {
    return 'Streak kontribusi: $status';
  }

  @override
  String get streakContributionActive => 'aktif';

  @override
  String get streakContributionInactive => 'belum hari ini';

  @override
  String get historyTitle => 'Histori';

  @override
  String errorLoadingHistory(String error) {
    return 'Gagal memuat histori: $error';
  }

  @override
  String get deleteHabitDialogTitle => 'Hapus habit?';

  @override
  String deleteHabitDialogContent(String name) {
    return 'Histori dan streak \"$name\" tetap tersimpan, tapi habit ini tidak akan aktif lagi.';
  }

  @override
  String get weekdayMon => 'Sen';

  @override
  String get weekdayTue => 'Sel';

  @override
  String get weekdayWed => 'Rab';

  @override
  String get weekdayThu => 'Kam';

  @override
  String get weekdayFri => 'Jum';

  @override
  String get weekdaySat => 'Sab';

  @override
  String get weekdaySun => 'Min';

  @override
  String calendarScreenTitle(String month, int year) {
    return 'Kalender — $month $year';
  }

  @override
  String errorLoadingCalendar(String error) {
    return 'Gagal memuat: $error';
  }

  @override
  String taskMovedMessage(String title, String date) {
    return '\"$title\" dipindah ke $date';
  }

  @override
  String get noTasksHabitsThisDate => 'Tidak ada task/habit di tanggal ini';

  @override
  String get tasksLabel => 'Tasks';

  @override
  String get dailyHabitsLabel => 'Habits (harian)';

  @override
  String get dailyHabitInfo =>
      'Habit harian berlaku setiap hari — lihat status di halaman Habits.';

  @override
  String get monthJanuary => 'Januari';

  @override
  String get monthFebruary => 'Februari';

  @override
  String get monthMarch => 'Maret';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'Mei';

  @override
  String get monthJune => 'Juni';

  @override
  String get monthJuly => 'Juli';

  @override
  String get monthAugust => 'Agustus';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'Oktober';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'Desember';

  @override
  String get pomodoroScreenTitle => 'Pomodoro';

  @override
  String get modeLabel => 'Mode';

  @override
  String get modeHabitLinked => 'Terkait Habit';

  @override
  String get modeFreeStanding => 'Bebas Mandiri';

  @override
  String get selectHabitLabel => 'Pilih Habit';

  @override
  String get durationMinutesLabel => 'Durasi (menit)';

  @override
  String get durationHelperText => 'Kustomisasi bebas';

  @override
  String get pauseButton => 'Pause';

  @override
  String get resumeButton => 'Lanjutkan';

  @override
  String get cancelSessionButton => 'Batalkan';

  @override
  String get sessionCompleteTitle => 'Sesi selesai!';

  @override
  String sessionCompleteHabitMessage(String name) {
    return 'Progress \"$name\" tercatat.';
  }

  @override
  String get sessionCompleteFreeMessage => 'Sesi fokus bebas selesai.';

  @override
  String get profileScreenTitle => 'Profil';

  @override
  String get changeAvatarTooltip => 'Ganti Avatar';

  @override
  String get editNameTooltip => 'Edit Nama';

  @override
  String get noNamePlaceholder => '(Belum ada nama)';

  @override
  String get badgeCollectionTitle => 'Badge Collection';

  @override
  String errorLoadingBadges(String error) {
    return 'Gagal memuat badge: $error';
  }

  @override
  String get avatarCollectionTitle => 'Avatar Collection — unlock per 10 level';

  @override
  String errorLoadingAvatars(String error) {
    return 'Gagal memuat avatar: $error';
  }

  @override
  String get editNameDialogTitle => 'Edit Nama';

  @override
  String get splashTagline => 'Tumbuh tiap hari';

  @override
  String get rankPerintis => 'Perintis';

  @override
  String get rankPetarung => 'Petarung';

  @override
  String get rankPenakluk => 'Penakluk';

  @override
  String get rankSangAhli => 'Sang Ahli';

  @override
  String get rankSangMaster => 'Sang Master';

  @override
  String get rankLegenda => 'Legenda';

  @override
  String get settingsScreenTitle => 'Pengaturan';

  @override
  String get settingsNotifications => 'Notifikasi';

  @override
  String get settingsNotificationsSubtitle =>
      'Task, Habit, Streak Warning, Freeze';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAbout => 'Tentang App';

  @override
  String get notificationsScreenTitle => 'Notifikasi';

  @override
  String get notifTaskLabel => 'Task';

  @override
  String get notifHabitLabel => 'Habit';

  @override
  String get notifStreakWarningLabel => 'Streak Warning';

  @override
  String get notifFreezeLabel => 'Freeze';

  @override
  String get aboutScreenTitle => 'Tentang App';

  @override
  String aboutVersionLabel(String version) {
    return 'Versi $version';
  }

  @override
  String get aboutDescription =>
      'Tazk menggabungkan manajemen tugas, pelacakan kebiasaan, dan gamifikasi RPG dalam satu aplikasi 100% offline.';

  @override
  String notifTaskReminderTitle(String title) {
    return 'Waktunya: $title';
  }

  @override
  String get notifTaskReminderBody =>
      'Task ini dijadwalkan sekarang. Yuk selesaikan!';

  @override
  String notifHabitReminderTitle(String name) {
    return 'Waktunya: $name';
  }

  @override
  String get notifHabitReminderBody =>
      'Habit ini dijadwalkan sekarang. Jaga streak kamu!';

  @override
  String get notifStreakWarningTitle => 'Jangan putus streak kamu!';

  @override
  String get notifStreakWarningBody =>
      'Belum ada task/habit yang selesai hari ini. Selesaikan sebelum tengah malam ya!';

  @override
  String get notifFreezeUsedTitle => 'Freeze terpakai!';

  @override
  String get notifFreezeUsedBody =>
      'Streak kamu tetap aman karena freeze otomatis dipakai untuk hari yang terlewat.';
}
