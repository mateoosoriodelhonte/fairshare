# Architecture

FairShare is a single Flutter application with a strict layering: pure Dart at the core, Flutter only at the edges. Every layer can be tested without the one above it.

```
┌──────────────────────────────────────────────────────────────┐
│  UI            lib/features/*, lib/ui/*        Flutter, Material 3   │
├──────────────────────────────────────────────────────────────┤
│  State         lib/app/providers.dart          Riverpod streams       │
├──────────────────────────────────────────────────────────────┤
│  Import/export lib/io/*                        JSON codec, CSV, files  │
├──────────────────────────────────────────────────────────────┤
│  Persistence   lib/data/*                      Drift + SQLite          │
├──────────────────────────────────────────────────────────────┤
│  Domain        lib/domain/*                    models, accounting      │
├──────────────────────────────────────────────────────────────┤
│  Core          lib/core/money/*                Money, Currency, rates  │
└──────────────────────────────────────────────────────────────┘
```

## Core: money

`Money` is an integer count of a currency's minor unit (cents, yen, fils) plus a `Currency`. There is no floating point anywhere in the accounting path: parsing goes from text to integers, arithmetic is integer, and formatting goes from integers to text. Mixing currencies in arithmetic throws.

`ConversionRate` is a fixed-point decimal with six fractional digits. Converting an amount uses big-integer arithmetic and rounds exactly once, half-up, so two conversions of the same amount always agree.

`Currencies` is a static, curated list (46 currencies, including 0- and 3-decimal ones). FairShare never downloads currency data or rates.

## Domain: models and accounting

* **Models** (`lib/domain/models`): `Group`, `Member`, `Expense` with materialised `ExpenseShare`s, `Settlement`, `RecurringTemplate`, `AppPreferences`. Shares are stored, not recomputed, so a saved expense never changes meaning if an algorithm is refined.
* **Allocation** (`allocation.dart`): the only place rounding is decided. Equal splits hand leftover units to the first participants; weighted splits use the largest-remainder (Hamilton) method; both are deterministic and conserve the total by construction.
* **`ExpenseSplitter`** turns the editor's inputs (equal, percentage in basis points, shares, exact) into shares with human-readable validation errors.
* **`BalanceCalculator`** produces the exact balance sheet: `balance = paid + settledOut - owed - settledIn`. Foreign-currency expenses are converted once on the total and then re-split in the base currency, so the group's balances always sum to zero. It also computes literal pairwise debts.
* **`DebtSimplifier`** proposes transfers: an exact-match pass, then greedy largest-first matching. It settles everyone with at most *k − 1* transfers (k = members with non-zero balance). It is **not** proven minimal, and the UI says so.
* **`SpendingInsights`** aggregates totals, categories and a six-month series per base currency.

Property tests (`test/domain`) generate random ledgers across split types and currencies and assert that balances always sum to zero, every expense conserves value, pairwise debts reconcile with balances, and simplification zeroes every balance.

## Persistence

Drift tables (`lib/data/db/tables.dart`) store money as integer minor units plus an ISO code and dates as ISO-8601 text. Foreign keys are on: deleting a group cascades; a member with ledger history cannot be deleted. Repositories (`lib/data/repositories`) return domain models, expose reactive streams, and perform multi-row writes in transactions (expense + shares, template + shares, recurring generation).

Generated Drift code is committed; `tool/codegen.sh` regenerates and formats it, and CI fails if it drifts.

## State

Riverpod providers (`lib/app/providers.dart`) wrap repository streams. `groupSnapshotProvider` joins group, members, expenses, settlements and templates into a `GroupSnapshot`, which computes the balance sheet exactly once per change. Screens read snapshots; mutations call repositories directly.

## UI

* `lib/ui/theme`: Material 3 light/dark themes, Inter typography (tabular figures for money), an `FsPalette` extension for balance signs, avatars, categories and chart series, and motion tokens. Page transitions respect reduced motion.
* `lib/ui/shell`: adaptive frame with a sidebar on wide windows and stack navigation on phones.
* `lib/ui/widgets`, `lib/ui/charts`: shared components and custom-painted charts with textual semantics.
* `lib/features/*`: one folder per screen group. The expense editor's state lives in `ExpenseDraft`, a Flutter-free class with its own tests, and its fields are shared with the recurring-template editor.

## Import/export

`GroupJsonCodec` writes a versioned, pretty-printed JSON document and validates it back with element-level error paths and a final conservation check. `GroupImporter` always creates a new group with fresh ids. `CsvExport` writes RFC 4180 reports. All file access goes through `FileGateway`, an interface over open/save panels that tests replace with an in-memory fake.

## Testing strategy

| Layer | Approach |
| --- | --- |
| Core and domain | Unit tests plus seeded property tests (`test/support/property.dart`) |
| Persistence | In-memory SQLite, including cascade and constraint checks |
| Import/export | Round-trips and a rejection matrix with expected paths |
| UI | Widget tests that drive the real app against an in-memory database; layout tests at phone width and large text sizes |
| End to end | Integration tests on the macOS desktop target in CI, which also capture the README screenshots |
