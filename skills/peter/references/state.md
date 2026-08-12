# Build state

Epic mode only. In loop mode there is no run directory, no branch, no work
graph — just the repo.

## Run directory

Both directories sit at the **repo root** — `<repo-root>/runs/` and
`<repo-root>/zones/`:

```
<repo-root>/runs/<epic-id>/
  spec.md            # epic-level bars, API contract, visual reference — parent writes once
  graph.jsonl        # append-only work graph — schema in work-graph.md
  security.eson      # security-auditor's ESON return, saved verbatim (latest; prior in git history)
  ui.eson            # ui-auditor's ESON return, saved verbatim (latest)
  shots/             # ui-auditor screenshots, <route>-<width>.png
  report.md          # final summary — parent only, only after the epic closes
```

`<epic-id>` is `E-` plus a short slug of the goal (`E-ratelimit`). A retry is a
new run that references the old one in `spec.md`, never an overwrite.

The run directory is committed on the epic branch — the plan of record travels
with the code, which is what makes a dead epic resumable and its verdicts
auditable after the fact. It also means the merge carries `runs/` and `zones/`
into the target branch, so `report.md`'s proposed merge names both: keeping or
stripping them is the user's decision, not an accident.

Code goes in the repo, not the run directory. The run directory holds the
*process* — spec, work graph, evidence, verdicts — so a failed epic is
debuggable and **resumable** after the subagent contexts are gone: fold
`graph.jsonl` and the ready tasks are exactly where the run left off.

## Single-writer table

| Path | Writer | Readers |
|---|---|---|
| `spec.md` | parent | all |
| `graph.jsonl` | parent (append-only) | all |
| repo backend paths | backend-builder | all |
| repo frontend paths | frontend-builder | all |
| `e2e/` | the builder named in `spec.md` (UI → frontend, API-only → backend) | all |
| `security.eson` | parent, from security-auditor's return | parent |
| `ui.eson`, `shots/` | parent, from ui-auditor's return | parent |
| `report.md` | parent | — |
| `zones/backend.md`, `zones/frontend.md` | the owning builder | that node, parent |
| `zones/security.md`, `zones/ui.md` | parent, from auditor `zone_facts` | that auditor, parent |
| `zones/*.archive.md` | parent (pruned lines only) | on-demand grep — never dispatched |
| git commits, branches | parent — one commit per task, epic branch only | all |

Two nodes never write one path. Frontend and backend split on directory, fixed
in `spec.md`'s zone map before either starts — that's what makes them safe in
parallel. **When the globs overlap the split doesn't exist**, and a `zone: both`
task goes to one builder owning all of it. Co-located frameworks (Next.js server
actions, SvelteKit `+page.server.ts`, Rails, Django) are the common case: one
file holds both zones, so no fence can separate them.

The fence isolates *writes*, not *consequences*. A change on one side can break a
file on the other — an async'd function whose caller lives in `e2e/`, a new error
code with no client mapping — and the owner of the broken file has no idea it
happened. Whoever makes such a change reports it; the parent routes the other
side's update in the same iteration (§B step 11). Never reach across the fence to
fix it yourself.
`e2e/` crosses both zones, so exactly one builder owns it; the other reads it
and never edits. See `e2e-gate.md`.

Builders never run `git commit` — the parent commits after adjudication, task
id in the message. Auditors have **no write tools**: they return their verdict
as ESON in the final message (`eson.md`) and the parent saves it verbatim —
never hand-transcoded; transcription is where fields drift. Their `Bash` is for
read-only commands — a dependency audit, starting the app — never file writes,
never git mutations. That last part is convention, not an allowlist: `Bash` can
write, so the rule lives in the agent files and holds because they follow it.

## Zone memory

`<repo-root>/zones/` sits beside `runs/`, not inside one — it is cross-epic
state:

- `zones/backend.md`, `zones/frontend.md` — appended by their builder.
- `zones/security.md`, `zones/ui.md` — appended by the parent from the
  auditors' `zone_facts` return field.

Durable domain facts only — the stack's conventions, where auth lives, which
component library, recurring gotchas, the threat model. A few terse lines per
fact; never run-specific state, never a narrative of what a builder just did.
The parent prunes each past ~a page **before it rides in a dispatch prompt**,
not only at epic close — every dispatch pays the file's length.

**Pruning moves, it never deletes.** Cut lines are appended verbatim to
`zones/<name>.archive.md`, which is never read into a prompt and so costs
nothing per dispatch. The cap exists because of dispatch cost, not storage
cost — once a fact is out of the live file it is free to keep forever. The
archive is grepped on demand, and a fact that proves live again is promoted
back into `zones/<name>.md` by hand. Without this, epic 7 pays to rediscover
what epic 3 already learned.

## Handoff

Every prompt carries absolute paths — rooted, resolvable with no cwd. Nodes
inherit nothing: not cwd, not prior conversation, not the epic's history. **A
relative path in a prompt is a broken prompt**, and it fails silently — the node
reads nothing and reasons from the prompt text alone:

> Read `/Users/me/proj/runs/E-ratelimit/spec.md` and
> `/Users/me/proj/zones/backend.md`. Task T2, criteria: ["429 responses carry
> Retry-After and X-RateLimit-* headers"]. Implement §3.2 of the contract. Write
> only under `/Users/me/proj/api/`. E2E may bind ports 4000-4009; 4100-4109 are
> the auditor's. Return the ESON contract from your agent file. Stop when your
> tests for T2 pass; do not touch `/Users/me/proj/web/`, do not commit.

## Failure isolation

A failed node leaves its output absent, not half-written. Auditors return their
verdict in the final message and let the parent write the file — one round
trip, no partial files that a later `pass` check might misread. A task that
stops mid-flight leaves its last `graph.jsonl` record `in_progress`; the resume
check in §0 of `SKILL.md` folds the file, reopens that record, and re-dispatches
it — a run is resumed from the graph, never re-planned on top of itself.
