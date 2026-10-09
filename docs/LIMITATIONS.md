# Limitations and supported platforms

This document is deliberately blunt. If something is not listed as verified, assume it is not.

## Platforms

| Platform | Status |
| --- | --- |
| macOS 13+ (Apple silicon and Intel) | Built and run in CI on GitHub's macOS runner; integration tests execute on the desktop target there. The release artifact is an **unsigned, ad-hoc-signed app bundle**: macOS will warn on first launch (right-click → Open, or remove the quarantine attribute). |
| iOS | Platform folder is generated and the code contains nothing macOS-specific, but **no iOS build or device test has been performed**. |
| Android | Same as iOS: untested. |
| Windows, Linux, web | Not configured. The database layer (Drift with native SQLite) would need the web setup, and the UI has not been exercised there. |

## Functional limits

* **One payer per expense.** Bills paid by several people must be recorded as several expenses.
* **Exchange rates are entered by hand** per expense and per settlement. FairShare never fetches rates; there is no "rate history" beyond what each record stores.
* **Debt simplification is a suggestion, not a proof.** The plan settles everyone with at most *k − 1* transfers, which is often but not always the fewest possible. Balances themselves are exact regardless of the plan.
* **No multi-device sync, accounts or sharing.** Data lives in one SQLite file per device. Collaboration is by exporting and importing JSON.
* **No undo.** Deleting a group, expense or settlement asks for confirmation and then deletes.
* **No receipts, attachments, comments or reminders.**
* **English only**, with number formatting that uses `.` as the decimal separator and `,` for grouping in the UI. Input accepts either separator.
* **Dates are calendar days** in the device's local time zone; there is no time-of-day on expenses.
* **Recurring templates generate on launch** (or on demand). If the app is not opened for months, every missed occurrence is generated then, capped at 120 per template.
* **Amounts above about 9.2 quintillion minor units** are outside the 64-bit range. This is not a practical concern.

## Data and privacy

* The database is stored in the platform's application support directory inside the app sandbox. Nothing is uploaded, synced or logged remotely. There is no analytics or crash reporting.
* Exports are written only where the user chooses in the save panel.
* The demo group is purely synthetic and is created only on request.

## Engineering notes

* Drift generated code is committed and verified by CI.
* The test suite avoids `pumpAndSettle` because a focused text field never settles; see `test/support/app_harness.dart`.
* On the development machine used for V1 the Xcode licence was not accepted, so local macOS builds were not possible; builds and integration tests ran on CI. This is recorded honestly in the release notes.
