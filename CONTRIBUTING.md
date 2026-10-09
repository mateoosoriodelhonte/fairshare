# Contributing

Thanks for your interest. FairShare is small and opinionated; the notes below keep it that way.

## Setup

```bash
flutter --version            # 3.47 stable or newer
flutter pub get
./tool/codegen.sh            # regenerates Drift code and formats it
flutter test                 # unit + widget tests, no device needed
flutter run -d macos         # requires Xcode with the licence accepted
```

## Rules of the road

* **No floating point for money.** Use `Money`, `ConversionRate` and the allocation helpers. If you need to round, do it in `allocation.dart` and test it.
* **Every balance change must stay conserved.** The property tests in `test/domain` will catch it if not; add a case when you add a feature.
* **Keep layers honest.** `lib/core` and `lib/domain` must not import Flutter. UI code must not touch Drift directly; go through repositories.
* **Tests drive the real app.** Widget tests pump `FairShareApp` against an in-memory database (`test/support/app_harness.dart`). Avoid `pumpAndSettle`; use the harness helpers.
* **Lints are strict** (`flutter analyze --fatal-infos`) and formatting is enforced at 120 columns (`dart format`).
* **Privacy is a feature.** No network calls, no analytics, no background writes outside the app's own database.

## Workflow

1. Open an issue describing the change.
2. Branch from `main`, implement with tests, keep commits focused.
3. Open a pull request that references the issue. CI runs analysis, tests, the macOS build and the desktop integration tests.
4. Squash or merge once green.

## Releases

Tagging `vX.Y.Z` runs the release workflow, which builds the macOS app, zips it and publishes a GitHub release with generated notes.
