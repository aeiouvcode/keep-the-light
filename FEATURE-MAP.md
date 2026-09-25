# KEEP THE LIGHT - web surface standards (fleet checklist)

Applied to https://aeiouvcode.github.io/keep-the-light/ - status as of cycle 93 (2026-09-25).

| Standard | Where | Status |
|---|---|---|
| Favicon | index.html -> index.icon.png, apple-touch-icon | OK (pre-existing) |
| Real page title | index.html `<title>KEEP THE LIGHT</title>` | OK (pre-existing) |
| Meta description + theme-color | index.html head | FIXED in c93 (was missing) |
| Decent 404 | 404.html (new in c93, branded card, link back) | FIXED in c93 |
| No placeholder text | loader + status overlay reviewed; no lorem/default copy | OK |
| Honest empty/success/error states | loading: splash + themed progress bar; success: overlay removes into the title screen; error: friendly on-brand notice (c93) | FIXED in c93 |
| No raw stack traces | displayFailureNotice now maps engine/loader errors to plain-language messages; raw detail stays in console.error only | FIXED in c93 |

Verification habit: every cycle that touches index.html re-checks this table; every export is
followed by apply_loader.py (which owns ALL index.html customizations, idempotently).
