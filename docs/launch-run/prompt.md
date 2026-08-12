# Launch proof prompt

This is the complete prompt passed to `/peter` for the public proof run.

```text
/peter Build and verify a complete reading-list vertical slice in this pinned public fixture.

The contract is complete; do not ask clarification questions.

API and persistence:
- GET /api/books returns 200 JSON `{ "books": Book[] }`.
- POST /api/books accepts JSON `{ "title": string, "author": string }` and returns 201 with the created `Book`.
- A Book has `id`, trimmed `title`, trimmed `author`, and ISO-8601 `createdAt`.
- Reject a missing or non-JSON content type, malformed JSON, unknown fields, empty values, values over 100 characters, and bodies over 16 KiB with a safe 4xx JSON response.
- Persist to the JSON file named by `DATA_FILE`, defaulting to `data/books.json`. Writes must be atomic, concurrent creates must not lose data, and a missing file starts as an empty list.

Rendered UI:
- Replace the fixture-only page with a usable reading list that loads existing books, adds a book, filters the visible list by title or author without another request, preserves data after reload, exposes loading/empty/error/success states, and never injects user values as HTML.
- Use native labels and controls, an announced status region, field-level errors, visible keyboard focus, logical heading order, and 44px controls. It must reflow without horizontal scrolling at 320, 768, and 1280px.
- Confirmed visual reference: warm white `#faf8f3` page, ink `#1f2933`, teal `#006b5f` primary accent, restrained red `#a61b1b` errors, system sans-serif type, large editorial heading, cards with subtle borders and 12px corners, one column below 768px and a form/list split at 768px and above. No animation is required.

Verification and scope:
- Preserve the health endpoint and its test.
- Add unit/integration tests for the API, validation, persistence, atomic/concurrent creates, and safe output.
- Add Playwright E2E coverage for empty state, add, filter, invalid input, persistence after reload, keyboard use, and 320px reflow. Playwright is configured to use installed Chrome.
- Run `npm test`, `npm run typecheck`, `npm run lint`, `npm run build`, and `npm run e2e` at baseline, each iteration, and close.
- Security audit applies because the feature accepts external input and writes data. UI audit applies to `/`; use `PORT=43100 DATA_FILE=/tmp/peter-launch-audit-books.json npm run dev`, base URL `http://127.0.0.1:43100`, and reserve ports 43100-43109 for the UI auditor.
- Treat the visual reference above as approved. Work autonomously until Peter's Done bar is met. Keep every failed gate and audit result in the run evidence.
- Commit one change per graph task, push only the epic branch, and do not merge it.
```
