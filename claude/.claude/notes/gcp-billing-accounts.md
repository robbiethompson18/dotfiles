# Google Cloud billing accounts (Usebits)

Added 2026-09-01 after a $1,000 Gemini API charge landed on Robbie's Ramp card instead of startup
credits.

Both accounts are named "My Billing Account" in every picker, which is how the mixup happened.

| Account ID | Status | Admins | Use it? |
| --- | --- | --- | --- |
| `0166EE-D31BEC-7F463A` | shared Usebits account (Klaus Production, klaus-workspace-temp, gen-lang-client-0179543262, Klaus Analytics) | robbie, bailey | **Yes.** Link every project here. This is where Google for Startups credits go, if/when they're applied. |
| `01490A-258074-26F800` | Robbie-only, backed by Ramp Visa ····7377 | robbie | **No.** Bad account. Created ~2026-05-12 when the AI Studio key "robbie local for data gen expensive" was minted and "set up billing" picked a fresh account. Zero projects linked as of 2026-09-01. Should be closed (console only, needs passkey). |

## What happened

- Project "Klaus Analytics" (`gen-lang-client-0527164345`) hosts the Gemini API keys for silkworm
  data generation (SSM `/silkworm/GEMINI_API_KEY`) and sapient (`sapient-*` keys). It was on the
  Ramp account from May to 2026-09-01.
- Google threshold-billed the card as usage accrued: $100, $200, $500 (May), $778 (Jun 1), $1,000
  (Sep 1, ~95k GenerateContent calls in one day from the data-gen key).
- 2026-09-01: relinked Klaus Analytics to `0166EE` via
  `gcloud billing projects link gen-lang-client-0527164345 --billing-account=0166EE-D31BEC-7F463A`.

## Gotchas

- Creating a Gemini key in AI Studio auto-creates a `gen-lang-client-*` project. Before enabling
  billing on it, link it to `0166EE` explicitly or the picker may create yet another account.
- Cloud Billing API is disabled on most projects; run `gcloud billing ...` with
  `CLOUDSDK_BILLING_QUOTA_PROJECT=dev-envs-483613` (billing API enabled there 2026-09-01).
- No evidence in robbie@usebits mail that GFS credits were ever actually granted, only SDR pitches
  (Jaivin Patel, May 2026). Check console → Billing → `0166EE` → Credits before assuming coverage.
