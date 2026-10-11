# Tech stack

What FairShare is built with, which version each piece is pinned to, why it was chosen, and where it lives in the code. Versions are the resolved ones in `pubspec.lock` at the time of writing; `flutter pub outdated` shows drift from them.

## At a glance

| Layer | Technology | Version | Role |
| --- | --- | --- | --- |
| Language | Dart | 3.13.5 | Everything, with sound null safety and records/patterns |
| Framework | Flutter (stable) | 3.47.7 | UI, rendering, platform shells for macOS, iOS, Android |
| Design | Material 3 + custom theme | Flutter built-in | Components, light/dark colour schemes, motion |
| Typography | Inter (static TTFs, OFL) | 4.1 | Bundled font with tabular figures for money |
| State | Riverpod (`flutter_riverpod`) | 3.4.3 | Providers that wrap repository streams and join them into snapshots |
| Navigation | go_router | 18.0.2 | Declarative routes, shell route for the adaptive sidebar |
| Database | Drift + SQLite (`drift`, `drift_flutter`, `sqlite3`) | 2.35.2 / 0.3.1 / 3.7.0 | Typed schema, reactive queries, transactions; SQLite bundled via Dart native assets |
| Codegen | `drift_dev`, `build_runner` | 2.35.1 / 2.16.2 | Generates the database and companion classes (committed) |
| Files | `file_selector`, `path_provider` | 1.1.0 / 2.1.6 | Native open/save panels; application-support directory for the database |
| Ids | `uuid` | 4.6.0 | Random v4 ids so exports can be merged without coordination |
| Formatting | `intl` | 0.20.3 | Date formatting only; money is formatted by the `Money` class |
| Testing | `flutter_test`, `integration_test` | Flutter built-in | Unit, widget and on-device tests |
| Lint | `flutter_lints` + extra rules | 6.0.0 | `flutter analyze --fatal-infos` in CI |
| CI/CD | GitHub Actions | — | Linux analysis/tests, macOS build and integration tests, tag-triggered release |

## Why these choices

### Dart and Flutter

A single codebase renders identically on desktop and mobile, which matters for an app whose main surface is a macOS window but whose users will want it on a phone. Flutter owns its rendering (Impeller on macOS), so the custom charts and the design system behave the same everywhere. Dart's 64-bit integers and `BigInt` make exact money arithmetic natural; there is no floating point anywhere in the accounting path.

### Material 3 with a custom theme

Material 3 provides accessible, well-tested components (dialogs, menus, segmented buttons, date pickers, text fields). The theme in `lib/ui/theme` replaces its defaults with hand-tuned light and dark colour schemes, hairline borders instead of shadows, Inter, and an `FsPalette` theme extension for semantic colours (balance signs, avatars, categories, chart series). Page transitions on desktop are a custom fade-through that honours reduced-motion settings.

### Riverpod 3

Riverpod gives compile-safe dependency injection and reactive state without a service locator. Repository streams are exposed as `StreamProvider`s; `groupSnapshotProvider` joins five of them into a `GroupSnapshot` that computes the balance sheet once per change. Tests override a single provider (`databaseProvider`) to run the whole app against an in-memory database. Riverpod 3 removed the legacy family notifiers, so the few mutable UI states use plain `Notifier` classes.

### go_router

Routes are declared once in `lib/app/router.dart` with stable paths (`/groups/:groupId/expenses/:expenseId`), which the screens, tests and the screenshot capture all rely on. A `ShellRoute` wraps every page in the adaptive shell so the sidebar persists on wide windows while phones get stack navigation.

### Drift on SQLite

Drift gives a typed schema (`lib/data/db/tables.dart`), compile-time checked queries, reactive `watch()` streams and transactions, on top of SQLite, which is the right store for an offline-first, single-user ledger. Money columns are integer minor units plus an ISO code; dates are ISO-8601 text. Foreign keys are enabled on open so cascades and member-deletion rules are enforced by the database, not only by the app. Since `sqlite3` 3.x the native library is bundled through Dart native assets, which is why `sqlite3_flutter_libs` appears only as an end-of-life placeholder.

Generated code is committed and `tool/codegen.sh` regenerates and formats it; CI fails if it is stale.

### file_selector and path_provider

All file access is user-driven: `file_selector` opens the platform's open and save panels, and the macOS sandbox is granted only `files.user-selected.read-write`. `path_provider` locates the application-support directory for the database. Both are wrapped by `FileGateway` so widget tests use an in-memory fake instead of real dialogs.

### Inter

Bundling a font avoids a runtime download and keeps rendering identical across platforms and in CI screenshots. Inter's tabular figures (`FontFeature.tabularFigures()`) keep money columns aligned. The static weights 400–700 are shipped; see `assets/fonts/LICENSE-Inter.txt`.

### Charts without a charting package

The donut and monthly bar charts in `lib/ui/charts` are custom `CustomPainter`s and plain layout. They are small, animate with `TweenAnimationBuilder`, expose textual `Semantics`, and avoid a dependency that would carry its own theming assumptions.

## What is deliberately absent

| Not used | Reason |
| --- | --- |
| Any HTTP client, sync service, analytics or crash reporting | Offline-first and private by design; there are no network calls in `lib` |
| Firebase, Supabase or another backend | No accounts, no server |
| Code generation for Riverpod (`riverpod_generator`) | Hand-written providers are few and readable |
| `freezed` / `json_serializable` | Domain models are small immutable classes with explicit `copyWith`; JSON mapping is hand-written and validated with element paths |
| A charting library | See above |
| Floating-point money, `double` anywhere in accounting | See `docs/ARCHITECTURE.md` |

## Toolchain and automation

- **Flutter SDK** pinned to 3.47.7 in CI (`subosito/flutter-action`) to match the development machine.
- **CI** (`.github/workflows/ci.yml`): on Linux, `dart format` check, generated-code verification, `flutter analyze --fatal-infos`, `flutter test --coverage`; on macOS, the two integration tests on the desktop target, README screenshot capture, and a release build.
- **Release** (`.github/workflows/release.yml`): on a `v*` tag, verifies the tag against `pubspec.yaml`, builds the macOS app, ad-hoc signs it, zips it with a SHA-256 checksum, and publishes a GitHub release.
- **Lints**: `analysis_options.yaml` enables strict casts, inference and raw types plus a curated rule set; the formatter page width is 120.

## Upgrading

```bash
flutter pub outdated          # see what moved
flutter pub upgrade           # within pubspec constraints
./tool/codegen.sh             # after any drift or drift_dev bump
flutter analyze --fatal-infos && flutter test
```

Bump the pinned `FLUTTER_VERSION` in both workflows when moving the SDK, and re-run the macOS job to refresh the screenshots.
