<p align="center">
  <img src="docs/assets/tazk-banner.png" alt="Tazk: tasks, habits and focus in one calm place" width="820">
</p>

<p align="center">
  <img src="docs/assets/otter-wave.gif" alt="Tazk mascot waving" width="104">
</p>

<p align="center">
  <strong>Tasks, habits, and focus in one calm daily workspace.</strong><br>
  Offline-first Android app. No account, no ads, no cloud.
</p>

<p align="center">
  <a href="https://tazk-manager-mfdu.vercel.app">Website</a> ·
  <a href="https://tazk-manager-mfdu.vercel.app/privasi/">Privacy</a> ·
  <a href="docs/STATUS.md">Status</a> ·
  <a href="DESIGN.md">Design system</a>
</p>

---

## What it does

Tazk covers the short daily check-in: see what matters today, tick it off, keep a habit streak alive, run a focus session, and stop. Everything lives in a local SQLite database on the phone.

- **Tasks** with priority (high 15 / medium 10 / low 5 XP), date, time, location, and subtasks. Subtasks can auto-complete the parent, and reordering is drag-based.
- **Habits** on daily, weekly, monthly, or custom schedules, with per-date logs so the calendar and today view never disagree.
- **Pomodoro** with 15/25/45/60 minute presets, editable durations (1 to 180 minutes), and a session that can be linked to a habit.
- **Calendar** combining tasks and habits, with a per-day detail panel.
- **Statistics** from real data only: completion rate, focus minutes, XP per period, a 13×7 habit heatmap, and an insight line. A metric with no data shows a dash, never a fake zero.
- **Gamification** with XP, levels, streaks, freezes, badges, and cosmetic unlocks.
- **Reminders** for tasks, habits, streak warnings, and finished focus sessions.
- **Home screen widgets** for tasks and habits, tasks only, habits only, streak, and calendar, all following the app theme.
- **Backup** as a JSON file with a SHA-256 checksum, exported and imported manually.
- **Two languages**, Indonesian and English, chosen during onboarding.
- **Manual update check** from Settings. No background polling.

## Install

The app is distributed as a signed APK, not through the Play Store.

```text
Package      com.tazk.tazk
Min SDK      29 (Android 10)
Version      2.0.0
Build        release, split per ABI (arm64-v8a, armeabi-v7a, x86_64)
```

Download from the [website](https://tazk-manager-mfdu.vercel.app). On the phone, open the APK and allow install from the browser or file manager when asked.

If a debug build is already installed, uninstall it first: debug and release use different signing keys, so they cannot replace each other.

## Privacy

Tazk stores everything on the device and asks for as little as possible.

- No account, no sign-in, no analytics, no ads.
- No camera, microphone, location, or storage permission.
- Notifications, exact alarm, and boot permissions exist only so reminders survive a reboot and fire on time.
- The battery optimisation exemption is optional and only affects whether widget taps are deferred.
- **One network request exists**: the manual update check fetches `version.json` from the project's own landing page. It sends nothing about you and runs only when you tap the row.

The full text is on the [privacy page](https://tazk-manager-mfdu.vercel.app/privasi/).

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.44.6 / Dart 3.12.2 |
| State | Riverpod 2.6 |
| Storage | Drift + SQLite, schema v8 with tested migrations |
| Notifications | flutter_local_notifications + timezone, exact alarms |
| Widgets | home_widget + Kotlin RemoteViewsService, custom broadcast receiver for taps |
| Calendar | table_calendar |
| Backup | JSON + canonical SHA-256, `share_plus` and `file_selector` |

## Project layout

```text
lib/
  core/        theme tokens, shared widgets, motion, update service
  data/        Drift database, tables, repositories, models
  features/    home, tasks, habits, calendar, pomodoro, stats, profile, settings
  providers/   Riverpod wiring
  notifications/  scheduling and channels
  background/  midnight day rollover
  widgets/     widget push service
  l10n/        Indonesian and English ARB files
android/app/src/main/
  kotlin/      widget providers, RemoteViews factory, tap receiver
  res/layout/  widget layouts (RemoteViews-safe tags only)
landing/       Astro site: download page, privacy, version.json
docs/          STATUS, LESSONS, plans, artifacts
```

## Development

Prerequisites: Flutter SDK, Android SDK, JDK 17.

```bash
flutter pub get
dart analyze                       # must report 0 issues
flutter test                       # must be all green
flutter build apk --release --split-per-abi
```

Release signing reads `android/key.properties` and `android/*.jks`. Both are git-ignored and must never be committed.

Landing page:

```bash
cd landing
npm install
npm run dev
npm run check:gates   # contrast, overflow, reduced motion, weight
```

### Where the truth lives

| File | Contents |
|---|---|
| [`docs/STATUS.md`](docs/STATUS.md) | Current position, open issues, what is verified and what is not |
| [`docs/LESSONS.md`](docs/LESSONS.md) | Failure ledger: each bug, its evidence, and the rule that prevents it |
| [`DESIGN.md`](DESIGN.md) | Design tokens and component rules (Sage and Sand, Dusk Forest) |
| [`PRD-v2.md`](PRD-v2.md) | Scope and requirements for v2 |

## Verification status

Claims in this README match what has been measured. The current state:

- `dart analyze` reports 0 issues.
- `flutter test` runs 590 tests, all green.
- The v2 build was installed on a Galaxy A52 (Android 14) and the update check, profile, level-up celebration, widgets, and the delete-task XP refund were exercised on the device.
- Known gaps are listed in `docs/STATUS.md` rather than hidden here.

## Credits

Mascot and logo are original artwork for this project. Fonts are Fredoka and Plus Jakarta Sans under the SIL Open Font License.
