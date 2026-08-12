# Work graph — `runs/<epic-id>/graph.jsonl`

The per-epic work graph: what needs doing right now, dependency-ordered,
append-only, committed. The org graph (stable roles) lives in
`~/.claude/agents/`; terminology and the patterns adopted here are documented
in `graph-engineering.md`. This file is the runtime contract.

## Records

One JSON object per line. Append-only — a status change is a new record for the
same `id`. Nobody edits or deletes a line; history is the audit trail.

**The fold merges per id, field by field**: records for an id apply in file
order — a later field overwrites, an absent field inherits, an explicit `null`
clears. A status-only append (`{"id":"T1","type":"task","status":"in_progress"}`)
is legal and cannot lose the `criteria[]` that §B7 adjudicates the diff against.
(Latest-record-wins is retired: every live run shed fields under it.)

A `closed` record is appended **after** its commit exists, and therefore rides in
a later commit — it cannot be inside the commit whose sha it carries, and `sha`
is a real sha from `git log`, never a placeholder. Closing a task onto a
`closed` epic is illegal — append the epic reopen first (see Epic close).

```jsonl
{"id":"E-ratelimit","type":"epic","title":"Rate limiting","status":"open"}
{"id":"T1","type":"task","deps":[],"zone":"backend","prio":1,"status":"open","criteria":["429 after N reqs in window"]}
{"id":"T1","type":"task","status":"in_progress"}
{"id":"T1","type":"task","status":"closed","sha":"a1b2c3d"}
{"id":"T3","type":"task","deps":[],"zone":"backend","prio":3,"status":"open","discovered-from":"T1","evidence":["pool exhausted at 120 conns during T1 e2e"],"criteria":["conn pool does not leak under load"]}
```

Fields:

| Field | Req | Meaning |
|---|---|---|
| `id` | yes | short, unique in the epic (`T1`…); epic ids `E-<slug>` |
| `type` | yes | `epic` \| `task` \| `note` |
| `parent` | no | the epic id — redundant in a per-epic file; omit |
| `deps` | tasks | ids that must be `closed` before this is ready |
| `zone` | tasks | `backend` (anything that doesn't render — API, CLI, library, pipeline, infra) \| `frontend` (anything that renders) \| `both`. Always a dispatchable builder route, never `epic` — work the parent performs itself (close sweep, live smoke) is Phase C, not a task. Path globs per zone are in `spec.md`; when they overlap, `both` means one builder owns the whole task |
| `prio` | no | 1 high … 3 low; default 2 (discovered tasks: default 3) |
| `status` | yes | `open` \| `in_progress` \| `blocked` \| `closed` |
| `criteria` | tasks | acceptance criteria — pass/fail bars, written at filing, before any code |
| `sha` | on close | the task's single commit sha — real and existing, never `"pending"` |
| `discovered-from` | discovered | the task or sweep whose run surfaced this |
| `evidence` | no | discovered tasks: the observation that motivated filing, verbatim — never mixed into `criteria` |
| `audits` | epic close | both scope keys; each is a verdict object, `"not_applicable: <reason>"`, or `"not_run: <reason>"` |
| `note` | no | one line of context; `fix:` hypotheses live here, never in `criteria`. On `blocked`, prefixed: `gates: <clauses>` \| `needs-input: <question>` |

`criteria` are checkable against a diff — bars, not findings. A pasted finding
("X is broken because Y; fix: Z") is unadjudicable: the observation goes in
`evidence`, the fix idea in `note`. A task whose criteria can't fail isn't
ready to file.

`type: note` records carry run evidence that is neither epic nor task — flake
forensics, capacity headroom, a stop-condition diagnosis. Never dispatched,
never in `deps`; still `open` at close → listed in the report.

## Ready

Fold the file: merge per id, latest field wins. A task is **ready** iff
`status == "open"` and every id in `deps` folds to `closed`. `blocked` is never
ready — loopback counts reset each session, so re-dispatching would retry the
same wall unbounded. Only an `open` record the operator asked for re-enters it —
appended by them, or by the parent on their answer to a `needs-input:` question;
the drain and the resume check never do on their own. **The drain is scoped**: it dispatches planned tasks, plus discovered tasks only when they
block an epic acceptance criterion. A discovery that blocks none is backlog —
ready but never drained, open through close, listed in the report. Dispatch
order: lowest `prio`, then file order. One task in flight at a time — `ready`
feeds a sequential loop, not a fan-out; parallelism lives inside a task (two
builders, one contract).

## Mutation — bounded, logged

The work graph is dynamic; the org graph is not. The parent may, as evidence
arrives:

| Evidence | Move |
|---|---|
| Scope expands | append a new task (`discovered-from` set); if it needs a 5th *specialty*, stop — re-score the §0 gate |
| Tasks converge / one becomes moot | append `closed` with `note` `"merged into <id>"` or `"moot: <why>"` — never delete the line |
| Task fails its gates twice | append `blocked`, `note` `gates: <clauses>`; stop condition |
| A decision needs the operator | append `blocked`, `note` `needs-input: <question>`; stop condition |
| A dispatch is rejected or interrupted by the operator | append `blocked`, `note` `needs-input: dispatch rejected — <agent> for <id>`; stop condition, never retried |
| The operator answers a `needs-input:` question | append the answer as a `note`, then `open` — the answer *is* the reopen |
| Priority shifts | append the task with a new `prio` |

Every mutation is one appended line — this file *is* the log of structural
change, which is why nothing is ever edited out of it. Never rewrite roles,
tools, or models mid-run — org-graph changes are a redeploy.

## Discovered work

Builders return `discovered[]` — one line per adjacent defect or opportunity
they did **not** touch; auditor findings on pre-existing, unchanged code land
here too. The parent files each as a task record in the same iteration it was
reported: `discovered-from`, the observation in `evidence`, `criteria` written
as pass/fail bars, default `prio: 3`. Filed, never worked in the iteration
that found it. Most discoveries are backlog (see Ready): they don't block an
epic criterion, don't enter the drain, and reasonably outlive the epic
unworked — the report lists what's left open.

## Epic close — and after

The epic `closed` record carries `commits[]`, `open[]` (every task not folding
`closed` — backlog and `blocked` alike), and
`audits` (§C2's sweep results — `not_run: <reason>` keeps the epic out of Done;
`not_applicable: <reason>` does not). A close record silent on audits is not a
close. A closed epic is not a
tombstone: to work its backlog later, append an epic `open` record (reopen)
first, then task records as usual, then re-close with updated
`commits[]`/`open[]`/`audits`.

## Zone memory

`zones/backend.md`, `zones/frontend.md` — appended by their builder;
`zones/security.md`, `zones/ui.md` — appended by the parent from auditor
`zone_facts`. Durable domain facts only, never run-specific state; parent
prunes past ~a page, moving cut lines to `zones/<name>.archive.md` rather than
deleting them. Cross-epic — this is what makes run 300's auditor worth more
than run 1's. Details: `references/state.md`.
