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
  String get navMore => 'Lainnya';

  @override
  String get navAbout => 'Tentang';

  @override
  String comingSoonMessage(String title) {
    return '$title — segera hadir';
  }

  @override
  String get cancelButton => 'Batal';

  @override
  String get saveButton => 'Simpan';

  @override
  String get habitTotalDoneLabel => 'Total selesai';

  @override
  String get habitConsistencyLabel => 'Konsistensi';

  @override
  String get habitReminderLabel => 'Pengingat';

  @override
  String get habitTargetLabel => 'Target';

  @override
  String habitMinutesPerDay(int minutes) {
    return '$minutes menit / hari';
  }

  @override
  String get habitHistoryWindowTitle => 'Histori 4 minggu';

  @override
  String get habitLegendMissed => 'lewat';

  @override
  String get habitLegendDone => 'selesai';

  @override
  String get habitDayDoneSemantics => 'selesai';

  @override
  String get habitDayNotDoneSemantics => 'belum selesai';

  @override
  String get habitDayMissedSemantics => 'terlewat';

  @override
  String get habitDayPartialSemantics => 'sebagian';

  @override
  String get habitDayNotDueSemantics => 'tidak dijadwalkan';

  @override
  String get okButton => 'OK';

  @override
  String get deleteButton => 'Hapus';

  @override
  String get deleteTaskTitle => 'Hapus task ini?';

  @override
  String get deleteTaskBody =>
      'Task ini akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get startButton => 'Mulai';

  @override
  String get yesLabel => 'Ya';

  @override
  String get noLabel => 'Tidak';

  @override
  String get onboardingWelcome => 'Halo! Aku Tazk';

  @override
  String get onboardingAskName =>
      'Aku akan bantu kamu menyelesaikan hal kecil setiap hari. Siapa namamu?';

  @override
  String get onboardingNameLabel => 'Nama kamu';

  @override
  String get onboardingNameHelper => 'Bisa diubah kapan saja di Profil';

  @override
  String get onboardingPickTheme => 'Pilih tema';

  @override
  String get onboardingPickThemeHint =>
      'Terang atau gelap, sesukamu. Bisa diganti kapan saja di Pengaturan.';

  @override
  String get onboardingPickLanguage => 'Pilih bahasa';

  @override
  String get onboardingPickLanguageHint =>
      'Pilih bahasa yang paling nyaman buatmu. Bisa diganti kapan saja.';

  @override
  String get onboardingNext => 'Lanjut';

  @override
  String get onboardingFinish => 'Selesai';

  @override
  String onboardingStepProgress(int current, int total) {
    return '$current dari $total';
  }

  @override
  String get fieldNameLabel => 'Nama';

  @override
  String get onboardingNameEmptyError => 'Nama tidak boleh kosong';

  @override
  String homeGreeting(String name) {
    return 'Halo, $name';
  }

  @override
  String get homeTasksToday => 'Tugas Hari Ini';

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
  String get homeStartPomodoroButton => 'Mulai sesi fokus';

  @override
  String homeTasksRemaining(int count) {
    return '$count sisa';
  }

  @override
  String homeHabitsProgress(int done, int total) {
    return '$done dari $total';
  }

  @override
  String get homeNoTime => 'Tanpa jam';

  @override
  String homeStreakDays(int count) {
    return '$count hari';
  }

  @override
  String homeHabitMinutes(int current, int target) {
    return '$current / $target mnt';
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
  String get autoCompleteSubtasksLabel =>
      'Tandai tugas selesai saat semua subtask beres';

  @override
  String get openInMapsTooltip => 'Buka di Maps';

  @override
  String get openInMapsFailedMessage =>
      'Belum ada aplikasi maps di HP ini yang bisa membuka lokasi itu.';

  @override
  String get noTimeLabel => 'Tanpa jam';

  @override
  String get tasksPendingHeader => 'Belum selesai';

  @override
  String get tasksDoneHeader => 'Selesai';

  @override
  String subtaskProgress(int done, int total) {
    return '$done/$total subtask';
  }

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
  String get customFrequencyConfigTitle => 'Pengaturan frekuensi kustom';

  @override
  String get customFrequencyTypeLabel => 'Jenis frekuensi kustom';

  @override
  String get customTypeWeeklyDays => 'Hari tertentu tiap minggu';

  @override
  String get customTypeIntervalDays => 'Setiap N hari';

  @override
  String get customTypeMonthlyDay => 'Tanggal tertentu tiap bulan';

  @override
  String get customDaysOfWeekLabel => 'Pilih hari';

  @override
  String get customDaysRequiredError => 'Pilih minimal satu hari';

  @override
  String get customIntervalLabel => 'Interval (hari)';

  @override
  String get customIntervalHelper => 'cth: 2 = setiap 2 hari';

  @override
  String get customIntervalInvalidError => 'Masukkan interval valid (1+)';

  @override
  String get customDayOfMonthLabel => 'Tanggal';

  @override
  String get customDayOfMonthHelper =>
      '1-31 (dilewati jika bulan tidak punya tanggal ini)';

  @override
  String get customDayOfMonthInvalidError => 'Masukkan tanggal valid (1-31)';

  @override
  String get weekdayMonShort => 'Sen';

  @override
  String get weekdayTueShort => 'Sel';

  @override
  String get weekdayWedShort => 'Rab';

  @override
  String get weekdayThuShort => 'Kam';

  @override
  String get weekdayFriShort => 'Jum';

  @override
  String get weekdaySatShort => 'Sab';

  @override
  String get weekdaySunShort => 'Min';

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
  String get profileStreakDaysLabel => 'hari streak';

  @override
  String get profileTasksDoneTodayLabel => 'tugas selesai';

  @override
  String get profileBadgesLabel => 'badge';

  @override
  String get badgeCollectionTitle => 'Koleksi Badge';

  @override
  String badgesUnlockedCount(int unlocked, int total) {
    return '$unlocked dari $total';
  }

  @override
  String errorLoadingBadges(String error) {
    return 'Gagal memuat badge: $error';
  }

  @override
  String get avatarCollectionTitle => 'Kosmetik';

  @override
  String cosmeticsUnlockedCount(int count) {
    return '$count terbuka';
  }

  @override
  String errorLoadingAvatars(String error) {
    return 'Gagal memuat avatar: $error';
  }

  @override
  String get editNameDialogTitle => 'Edit Nama';

  @override
  String get splashTagline => 'Satu langkah kecil setiap hari';

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
  String get celebrationRankTitle => 'Rank Baru!';

  @override
  String get celebrationContinueAction => 'Lanjutkan';

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
  String get notifFocusSessionLabel => 'Sesi fokus';

  @override
  String get notifTaskSubtitle => 'Saat jam task tiba';

  @override
  String get notifHabitSubtitle => 'Saat waktu habit tiba';

  @override
  String get notifStreakWarningSubtitle => 'Kalau belum ada yang selesai';

  @override
  String get notifFreezeSubtitle => 'Saat freeze otomatis dipakai';

  @override
  String get notifFocusSessionSubtitle => 'Saat timer Pomodoro habis';

  @override
  String get permissionBannerMessage =>
      'Notifikasi dimatikan. Aktifkan supaya pengingat task & habit berfungsi.';

  @override
  String get permissionBannerAction => 'Aktifkan';

  @override
  String get notifStatusLabel => 'Status notifikasi';

  @override
  String get notifStatusEnabled => 'Aktif';

  @override
  String get notifStatusDisabled => 'Mati';

  @override
  String get dbResetMessage =>
      'Data lokal sempat rusak, jadi Tazk amankan dengan mulai dari awal.';

  @override
  String get widgetStreakActiveLabel => 'Streak aktif';

  @override
  String get widgetStreakDaysSuffix => 'hari';

  @override
  String get widgetTasksEmpty => 'Belum ada tugas';

  @override
  String get widgetHabitsEmpty => 'Belum ada habit';

  @override
  String get streakDaySingular => 'hari';

  @override
  String get exactAlarmBannerMessage =>
      'Izin alarm presisi dimatikan. Pengingat bisa telat hingga 15 menit.';

  @override
  String get exactAlarmBannerAction => 'Aktifkan';

  @override
  String get exactAlarmSettingsTitle => 'Alarm presisi';

  @override
  String get exactAlarmActive => 'Aktif';

  @override
  String get exactAlarmInactive => 'Mati — pengingat bisa telat';

  @override
  String get aboutScreenTitle => 'Tentang Tazk';

  @override
  String aboutVersionLabel(String version) {
    return 'Versi $version';
  }

  @override
  String get aboutDescription =>
      'Task, habit, dan fokus dalam satu tempat. Semua data tersimpan di HP-mu.';

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

  @override
  String get stateEmptyTasksTitle => 'Belum ada tugas hari ini';

  @override
  String get stateEmptyTasksSubtitle =>
      'Santai dulu, atau tambah satu tugas kecil untuk mulai.';

  @override
  String get stateEmptyTasksAction => 'Tambah tugas';

  @override
  String get stateLoadingLabel => 'Memuat data';

  @override
  String get stateErrorTitle => 'Gagal memuat data';

  @override
  String get stateErrorMessage =>
      'Coba lagi sebentar. Data lokalmu tetap aman.';

  @override
  String get stateRetryAction => 'Coba lagi';

  @override
  String get navStats => 'Statistik';

  @override
  String get statsPeriodWeek => 'Minggu';

  @override
  String get statsPeriodMonth => 'Bulan';

  @override
  String get statsPeriodYear => 'Tahun';

  @override
  String get statsTasksDone => 'task selesai';

  @override
  String get statsFocusTime => 'waktu fokus';

  @override
  String statsDurationHoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String statsDurationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get statsValueDash => '–';

  @override
  String get statsXpWeek => 'XP mingguan';

  @override
  String get statsXpMonth => 'XP bulanan';

  @override
  String get statsXpYear => 'XP tahunan';

  @override
  String get statsHabitConsistency => 'Konsistensi habit';

  @override
  String statsDaysCount(int days) {
    return '$days hari';
  }

  @override
  String get statsLegendRare => 'jarang';

  @override
  String get statsLegendFrequent => 'rutin';

  @override
  String get statsVsLastWeek => 'vs minggu lalu';

  @override
  String get statsVsLastMonth => 'vs bulan lalu';

  @override
  String get statsVsLastYear => 'vs tahun lalu';

  @override
  String get statsEmptyWeek => 'Belum ada data minggu ini';

  @override
  String get statsEmptyMonth => 'Belum ada data bulan ini';

  @override
  String get statsEmptyYear => 'Belum ada data tahun ini';

  @override
  String get statsEmptyHint =>
      'Selesaikan tugas atau jalankan sesi fokus, lalu kembali ke sini.';

  @override
  String get statsFocusEmpty => 'Belum ada sesi fokus';

  @override
  String get statsXpEmpty => 'Belum ada XP';

  @override
  String get statsHeatmapEmpty => 'Belum ada catatan habit';

  @override
  String get statsInsightTitle => 'Insight';

  @override
  String statsInsightProductive(String day) {
    return 'Kamu paling produktif hari $day.';
  }

  @override
  String statsInsightConsistentHabit(String habit) {
    return '$habit paling konsisten belakangan ini.';
  }

  @override
  String get statsInsightEmpty =>
      'Insight muncul setelah kamu menyelesaikan beberapa tugas dan habit.';

  @override
  String get statsNoComparison => 'belum ada pembanding';

  @override
  String get dayMonday => 'Senin';

  @override
  String get dayTuesday => 'Selasa';

  @override
  String get dayWednesday => 'Rabu';

  @override
  String get dayThursday => 'Kamis';

  @override
  String get dayFriday => 'Jumat';

  @override
  String get daySaturday => 'Sabtu';

  @override
  String get daySunday => 'Minggu';

  @override
  String habitsSummaryHeadline(int done, int total) {
    return '$done dari $total habit hari ini';
  }

  @override
  String get habitsSummaryStart => 'Mulai satu habit untuk menjaga ritme';

  @override
  String get habitsSummaryAllDone => 'Semua habit hari ini selesai';

  @override
  String get habitsSummaryOnTrack => 'Jaga ritme, kamu sedang on-track';

  @override
  String get aboutPrivacyTitle => 'Kebijakan privasi';

  @override
  String get aboutPrivacyBody =>
      'Tazk bekerja sepenuhnya di HP-mu. Tidak ada akun, tidak ada server kami, dan tidak ada data yang dikirim ke siapa pun. Aplikasi tidak meminta izin kamera, mikrofon, lokasi, atau penyimpanan. Semua catatan tugas, habit, dan sesi fokus tersimpan di database lokal perangkatmu. Cadangan hanya dibuat bila kamu sendiri mengaktifkan backup ke Google Drive milikmu, dan file itu tetap di Drive-mu, bukan di tempat kami. Menghapus aplikasi menghapus seluruh data lokal.';

  @override
  String get aboutLicensesTitle => 'Lisensi open source';

  @override
  String get aboutFooter =>
      'Dibuat dengan Flutter. Gratis, tanpa iklan, tanpa akun.';

  @override
  String get pomodoroStatusIdle => 'Siap fokus';

  @override
  String get pomodoroStatusRunning => 'Fokus berjalan';

  @override
  String get pomodoroStatusPaused => 'Dijeda';

  @override
  String get pomodoroDurationHint => 'Ketuk angka waktu untuk mengubah durasi';

  @override
  String get customDurationTitle => 'Atur durasi';

  @override
  String get customDurationFieldLabel => 'Menit';

  @override
  String get customDurationHint => '1 sampai 180 menit';

  @override
  String get customDurationInvalid => 'Masukkan 1 sampai 180 menit';

  @override
  String get presetEditTitle => 'Ubah chip durasi';

  @override
  String get presetEditHint => 'Tekan lama chip untuk mengubah nilainya';

  @override
  String get fieldCategoryOptionalLabel => 'Kategori (opsional)';

  @override
  String get categoryNoneLabel => 'Tanpa kategori';

  @override
  String get settingsCategories => 'Kategori';

  @override
  String get manageCategoriesLabel => 'Kelola kategori';

  @override
  String get categoriesScreenTitle => 'Kelola kategori';

  @override
  String get addCategoryTitle => 'Kategori baru';

  @override
  String get editCategoryTitle => 'Ubah kategori';

  @override
  String get categoryNameLabel => 'Nama kategori';

  @override
  String get categoryNameHint => 'mis. Kerja, Belanja';

  @override
  String get categoryColorLabel => 'Warna';

  @override
  String get saveCategoryLabel => 'Simpan kategori';

  @override
  String get deleteCategoryTitle => 'Hapus kategori?';

  @override
  String get deleteCategoryBody =>
      'Tugas dan habit di kategori ini tetap ada — hanya kategorinya yang dilepas.';

  @override
  String get deleteCategoryConfirm => 'Hapus';

  @override
  String get categoryEmptyTitle => 'Belum ada kategori';

  @override
  String get categoryEmptyBody =>
      'Buat kategori untuk mengelompokkan tugas dan habit.';

  @override
  String get categoryEmptyAction => 'Buat kategori';

  @override
  String get categoryNameDuplicateError => 'Nama kategori itu sudah dipakai';

  @override
  String get categoryNameRequiredError => 'Nama kategori tidak boleh kosong';

  @override
  String get categorySaveFailedMessage =>
      'Kategori belum tersimpan. Coba lagi.';

  @override
  String get categoryColorSage => 'Sage';

  @override
  String get categoryColorHoney => 'Madu';

  @override
  String get categoryColorRose => 'Ros';

  @override
  String get categoryColorSky => 'Langit';

  @override
  String get categoryColorPlum => 'Plum';

  @override
  String get categoryColorSand => 'Pasir';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupLabel => 'Cadangkan & pulihkan';

  @override
  String get settingsBackupSubtitle => 'Ekspor atau impor file JSON';

  @override
  String get backupScreenTitle => 'Cadangkan & pulihkan';

  @override
  String get backupLocalNote =>
      'File tetap di perangkatmu. Tanpa akun, tanpa server.';

  @override
  String get backupExportAction => 'Ekspor data';

  @override
  String get backupImportAction => 'Pulihkan data';

  @override
  String get backupDriveDeferred => 'Backup Google Drive belum tersedia.';

  @override
  String get backupExportDone => 'File backup dibagikan.';

  @override
  String get backupImportDone => 'Data berhasil dipulihkan.';

  @override
  String get backupImportInvalid => 'File backup tidak valid atau rusak.';

  @override
  String get backupConfirmTitle => 'Timpa data lokal?';

  @override
  String get backupConfirmBody =>
      'Data lokal saat ini akan diganti dengan isi backup. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get backupConfirmAction => 'Ya, timpa';

  @override
  String get searchScreenTitle => 'Pencarian';

  @override
  String get searchFieldHint => 'Cari tugas dan habit';

  @override
  String get searchPromptBody =>
      'Mencocokkan judul, lokasi, dan nama kategori saat kamu mengetik.';

  @override
  String get searchFilterAll => 'Semua';

  @override
  String get searchFilterHabits => 'Habit';

  @override
  String get searchFilterCompleted => 'Selesai';

  @override
  String get searchNoResultsTitle => 'Tidak ada hasil';

  @override
  String searchNoResultsBody(String query) {
    return 'Tidak ada yang cocok dengan \"$query\". Coba kata lain atau ganti filter.';
  }

  @override
  String get searchClearTooltip => 'Hapus pencarian';

  @override
  String get searchTypeTask => 'Task';

  @override
  String get searchTypeHabit => 'Habit';

  @override
  String get searchCompletedLabel => 'selesai';

  @override
  String get batteryTitle => 'Izinkan Tazk tetap berjalan';

  @override
  String get batteryBody =>
      'Android menunda pekerjaan app yang lama tidak dibuka, sehingga centang di widget bisa tertahan. Beri pengecualian optimasi baterai agar widget dan pengingat tetap tepat waktu.';

  @override
  String get batteryAllow => 'Izinkan';

  @override
  String get batteryLater => 'Nanti saja';
}
