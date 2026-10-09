# JSON export format (schema version 1)

A FairShare export is a single UTF-8 JSON document describing one group. It is designed to be read by people as well as programs.

```json
{
  "app": "fairshare",
  "schemaVersion": 1,
  "exportedAt": "2026-10-09T18:30:00.000Z",
  "group": {
    "id": "6f2a…", "name": "Casa Verde", "baseCurrency": "EUR", "emoji": "🏠",
    "isDemo": true, "createdAt": "2026-10-09T18:00:00.000", "updatedAt": "2026-10-09T18:30:00.000"
  },
  "members": [
    { "id": "a1…", "name": "Ana", "colorIndex": 0, "createdAt": "2026-10-09T18:00:00.000" }
  ],
  "expenses": [
    {
      "id": "e9…", "description": "Train tickets to Porto",
      "amount": { "minorUnits": 12600, "currency": "GBP" },
      "paidByMemberId": "a1…", "category": "travel", "date": "2026-09-19",
      "splitType": "equal",
      "shares": [
        { "memberId": "a1…", "amountMinor": 6300, "splitValue": null },
        { "memberId": "c3…", "amountMinor": 6300, "splitValue": null }
      ],
      "conversionRate": "1.17",
      "notes": "Booked on a UK site; rate from the card statement.",
      "recurringTemplateId": null,
      "createdAt": "…", "updatedAt": "…"
    }
  ],
  "settlements": [
    {
      "id": "s1…", "fromMemberId": "d4…", "toMemberId": "a1…",
      "amount": { "minorUnits": 3000, "currency": "EUR" }, "conversionRate": null,
      "date": "2026-10-03", "note": "Cash, partial", "createdAt": "…"
    }
  ],
  "recurringTemplates": [
    {
      "id": "r1…", "description": "Rent",
      "amount": { "minorUnits": 160000, "currency": "EUR" },
      "paidByMemberId": "a1…", "category": "housing", "splitType": "equal",
      "shares": [ … ], "conversionRate": null, "notes": null,
      "frequency": "monthly", "interval": 1, "nextDueDate": "2026-11-01",
      "isActive": true, "createdAt": "…", "lastGeneratedAt": null
    }
  ]
}
```

## Conventions

* **Money** is always `{ "minorUnits": <integer>, "currency": <ISO 4217 code> }`. `12600` GBP means £126.00; `500` JPY means ¥500; `1250` KWD means KD1.250.
* **Rates** are decimal strings with up to six fractional digits, meaning "1 unit of the amount's currency = rate units of the group's base currency". A rate is required exactly when the amount's currency differs from `group.baseCurrency`.
* **Dates** (`date`, `nextDueDate`) are `YYYY-MM-DD`. Timestamps (`createdAt`, `updatedAt`, `exportedAt`, `lastGeneratedAt`) are ISO-8601.
* **Shares** must sum exactly to the amount. `splitValue` keeps the editor input: basis points for `percentage` (10 000 = 100 %), a share count for `shares`, minor units for `exact`, and `null` for `equal`.
* **Enumerations**: `category` ∈ food, groceries, drinks, transport, housing, utilities, entertainment, travel, shopping, health, gifts, other; `splitType` ∈ equal, percentage, shares, exact; `frequency` ∈ daily, weekly, monthly, yearly.
* `expenses`, `settlements` and `recurringTemplates` may be omitted; `members` must contain at least one entry with unique ids and names.

## Validation on import

The importer rejects a document with a message and a path such as `expenses[3].shares` when any rule above is violated, when a member reference is unknown, when a calendar date does not exist, or when the ledger does not balance. Nothing is written in that case. A valid document is imported as a **new group with fresh ids**; existing data is never modified. A dangling `recurringTemplateId` is cleared rather than rejected.
