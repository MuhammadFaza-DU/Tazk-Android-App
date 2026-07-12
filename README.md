# Tazk

Tazk is a warm, offline-first Android productivity app built with Flutter. It combines tasks, habits, calendar planning, Pomodoro focus sessions, reminders, home screen widgets, and lightweight progress rewards into one calm daily workspace.

The app is designed for short everyday check-ins: see what matters today, complete tasks and habits, keep focus sessions moving, and track progress without needing an account or internet connection.

## Download

You can download the latest Android APK from Google Drive:

[Download Tazk APK](https://drive.google.com/drive/folders/1kWlE8sQmOfmOdy_aZhlCZd4OsfzlliJP?usp=sharing)

After downloading the APK on Android, open the file and allow installation from your browser or file manager if prompted.

## Highlights

- Task management with priority, due date, time, location, subtasks, duplication, and completion tracking.
- Habit tracking with daily, weekly, monthly, and custom schedules.
- Pomodoro focus sessions, including habit-linked sessions that complete the habit for the day.
- Calendar view for tasks and habits.
- Offline local database, so core usage does not require an account or internet connection.
- Home screen widgets for tasks, habits, streaks, and a calendar + task + habit overview.
- Local reminders for tasks, habits, streak warnings, and focus sessions.
- Lightweight gamification with XP, levels, streaks, freezes, badges, and cosmetic unlocks.
- Indonesian and English localization.

## Privacy

Tazk is built around local-first usage:

- No account login is required.
- App data is stored locally on the device.
- The app does not request camera, microphone, location, or storage permissions.
- Notification and reboot permissions are used for reminders and scheduled notifications.

## Tech Stack

- Flutter
- Riverpod
- Drift + SQLite
- Flutter Local Notifications
- Home Widget
- Table Calendar
- Video Player

## Android APK Notes

The shared APK is a signed release build for Android:

- Package name: `com.tazk.tazk`
- Minimum Android SDK: `29`
- Current version: `1.0.0`

If you previously installed a debug build of Tazk, uninstall it before installing the release APK because debug and release builds use different signing certificates.

## Development

Prerequisites:

- Flutter SDK
- Android Studio or Android SDK command-line tools
- JDK 17

Install dependencies:

```bash
flutter pub get
```

Run static analysis:

```bash
dart analyze
```

Run tests:

```bash
flutter test
```

Build a debug APK:

```bash
flutter build apk --debug
```

Build a release APK:

```bash
flutter build apk --release
```

Release signing uses local files under `android/key.properties` and `android/*.jks`. These files are intentionally ignored by Git and must never be committed.

## Project Status

Tazk is actively being developed as an Android-first productivity app.

## License

No open-source license has been selected yet. The source code is public for viewing, but reuse, redistribution, or modification is not granted until a license is added.
