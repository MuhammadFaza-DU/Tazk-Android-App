---
version: alpha
name: Tazk
description: Design system for Tazk, an offline-first Android productivity app combining tasks, habits, Pomodoro focus, home-screen widgets, and light RPG-style progress.
colors:
  canvas: "#F4F1EA"
  surface: "#FBF9F4"
  surface-alt: "#EDE7DA"
  border: "#E2DACB"
  ink: "#26251F"
  ink-muted: "#6A6659"
  primary: "#4A5A44"
  primary-soft: "#6B7F5E"
  primary-container: "#DDE3D6"
  on-primary: "#FBF9F4"
  on-primary-muted: "#DDE3D6"
  clay: "#C97B5A"
  clay-container: "#F2DCD1"
  honey: "#D69A3C"
  honey-container: "#F6E4C2"
  danger: "#A5432A"
  warning: "#B4791F"
  warning-strong: "#8A5A12"
  success: "#4A5A44"
typography:
  display:
    fontFamily: Fredoka
    fontSize: 30px
    fontWeight: 600
    lineHeight: 1.2
  title:
    fontFamily: Fredoka
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.25
  headline:
    fontFamily: Fredoka
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: 600
    lineHeight: 1.4
  caption:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
rounded:
  sm: 10px
  md: 14px
  lg: 18px
  xl: 24px
  pill: 999px
spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  2xl: 32px
  3xl: 40px
components:
  screen:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  button-primary-quiet:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.primary}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "{spacing.lg}"
  chip-priority:
    backgroundColor: "{colors.honey-container}"
    textColor: "{colors.warning-strong}"
    rounded: "{rounded.pill}"
    padding: "{spacing.xs}"
  chip-high:
    backgroundColor: "{colors.clay-container}"
    textColor: "{colors.danger}"
    rounded: "{rounded.pill}"
    padding: "{spacing.xs}"
  progress-card:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary-muted}"
    rounded: "{rounded.xl}"
    padding: "{spacing.lg}"
  divider:
    backgroundColor: "{colors.border}"
    height: 1px
  input-field:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink-muted}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  tab-bar:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.pill}"
    height: 62px
  progress-track:
    backgroundColor: "{colors.primary-soft}"
    rounded: "{rounded.pill}"
    height: 8px
  segmented-control:
    backgroundColor: "{colors.surface-alt}"
    rounded: "{rounded.pill}"
    padding: "{spacing.xs}"
---

## Overview

Tazk is a daily productivity tool for Gen Z students and young workers, used in short offline sessions on an Android phone. The interface is calm and structured so the next action is obvious; warmth and play come from a single otter mascot and from reward moments, not from decoration on every surface.

## Colors

`canvas` and `surface` carry the page and its cards; `surface-alt` is reserved for secondary fills and inputs. `border` draws every separator so cards never need a shadow to separate themselves.

`primary` is the sage action color. `primary-container` is its tinted background for selected states and quiet buttons. `primary-soft` exists for fills and icons only: it is never a text color on a colored surface.

Two colors carry text on `primary`: `on-primary` for the main label and `on-primary-muted` for a secondary line beneath it. `on-primary` measures 7.03:1 against `primary` and `on-primary-muted` measures 5.65:1, so the muted step is a deliberate hierarchy, not a faded copy.

`honey` marks progress and reward: XP, streaks, and badges. `clay` is the secondary accent and its container backs high-priority signals. `danger` labels destructive actions and `warning` marks attention states.

`warning` is not a text color. It measures 3.27:1 on `canvas`, 3.50:1 on `surface`, and 2.95:1 on `honey-container`, so it clears only the large-text threshold and never the small-text one. Use it for icons, dots, and borders; use `warning-strong` for any warning text at body size.

## Themes

The specification in use has no theme-aware token syntax, so the values above are the light theme. Dark theme ships as "Dusk Forest" and replaces the same semantic tokens:

| Token | Light | Dark |
|---|---|---|
| `canvas` | `#F4F1EA` | `#0F1A14` |
| `surface` | `#FBF9F4` | `#152219` |
| `surface-alt` | `#EDE7DA` | `#1C2C21` |
| `border` | `#E2DACB` | `#23382A` |
| `ink` | `#26251F` | `#E8F0E7` |
| `ink-muted` | `#6A6659` | `#9DAF9F` |
| `primary` | `#4A5A44` | `#8FE0A9` |
| `primary-soft` | `#6B7F5E` | `#5FAE7C` |
| `primary-container` | `#DDE3D6` | `#20362A` |
| `on-primary` | `#FBF9F4` | `#0F1A14` |
| `on-primary-muted` | `#DDE3D6` | `#20362A` |
| `clay` | `#C97B5A` | `#E0A183` |
| `clay-container` | `#F2DCD1` | `#3A2620` |
| `honey` | `#D69A3C` | `#F2C765` |
| `honey-container` | `#F6E4C2` | `#3A3220` |
| `danger` | `#A5432A` | `#F0A48C` |
| `warning` | `#B4791F` | `#EBCB7E` |
| `warning-strong` | `#8A5A12` | `#EBCB7E` |
| `success` | `#4A5A44` | `#8FE0A9` |

Both themes are equally finished. Dark depth comes from `surface` and `surface-alt`, never from shadow.

## Typography

Fredoka carries display, title, and headline roles; its rounded forms supply the playful half of the identity. Plus Jakarta Sans carries body, label, and caption roles, including every number the user reads: XP, timers, dates, and counts.

Never set app text below `caption`. On Android home-screen widgets, where the grid is 4×2 cells, text floors at 8.5px and day-of-week labels at 7.5px; anything smaller belongs to neither surface.

## Layout

Spacing follows the scale above. Related content groups at `sm` or `md`; distinct sections separate at `xl` or `2xl`. A heading takes less space above it than below.

App content sits in a single wrapper whose horizontal padding is applied once, with vertical rhythm from the wrapper's gap rather than spacer elements. Touch targets are at least 48×48 dp.

Home-screen widgets keep a fixed grid height even when they hold one item, and cap loaded items at 20. Scrollable widget lists mark themselves with a half-clipped final row plus a downward-chevron hint; the calendar's dates never scroll with the list.

## Shapes

Radius is a hierarchy tool, not a default. `sm` is for compact cells inside a card, `md` for cards and buttons, `lg` for grouped panels, `xl` for the main progress card and sheets, and `pill` for chips, toggles, and the tab bar.

## Components

`button-primary` uses `primary` with `on-primary` text; that pairing is the only safe text-on-primary combination. `card` separates itself with `border` and the `divider` token, so cards never nest inside cards. `chip-priority` and `chip-high` use `pill` radius with a container/text pair that clears AA at small sizes. `input-field` uses `ink-muted` for placeholder text, which measures 5.09:1 on `surface`.

## Do's and Don'ts

- Do verify every text pairing with a contrast calculation before shipping it. Small text needs 4.5:1 and large text 3:1.
- Do use `on-primary` for the main label on `primary`, and `on-primary-muted` only for a secondary line beneath it.
- Don't use `primary-soft` as a text color on `primary` or any dark surface; it measures 1.70:1 against `primary` and fails both thresholds.
- Don't use `warning` for small text on any surface; use `warning-strong`.
- Don't rely on color alone to mark a completed task or habit; pair it with a shape or icon change.
- Don't place the mascot in the calendar widget, where the cell grid already consumes the available width.
- Don't nest cards.

## Motion

The token schema has no motion category, so these normative values live here.

| Token | Value | Applied to |
|---|---|---|
| `fast` | 150ms | Button press, toggle |
| `base` | 220ms | Screen transition, sheet open |
| `slow` | 320ms | Card expansion |
| `celebration` | 600–900ms | Level up, badge unlock, streak milestone |
| `easeStandard` | `cubic-bezier(0.2, 0, 0, 1)` | Default |
| `easeGentle` | `cubic-bezier(0.4, 0, 0.2, 1)` | Enter and exit |

Entrances use `easeStandard`; `ease-in` never appears in UI motion. Honor `MediaQuery.disableAnimations` by replacing celebration with an instant state change. No ticker runs while the app is idle.

## Mascot

The mascot is a 3D clay-rendered otter with a sprout on its head. `otter-portrait` fills avatars, empty states, and square icons; `otter-waving` appears in onboarding and celebration; `otter-with-sprout` carries the splash. The horizontal wordmark never sits in a square container, where it crops.

The mascot appears in empty states, celebration, onboarding, profile, and in-app banners, and in every home-screen widget except the calendar.

## Navigation

```
Tab bar (5)  →  Home · Tasks · Habits · Kalender · Lainnya
Sheet        →  Statistik · Profil · Pengaturan · Tentang
Pushed       →  Pomodoro (Home CTA) · Task Form · Habit Form · Habit Detail
```

Every screen needs a reachable entry point, and no tab may point at a screen that does not exist. The Home header carries no menu icon: only the greeting, date, and avatar, with the avatar opening Profile.
