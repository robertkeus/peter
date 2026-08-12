---
name: peter
description: >-
  Build a production-ready feature, app, or multi-task goal from a short
  description. Small changes run one enforced loop: spec and pass/fail bars
  first, implement, machine gates (unit tests, typecheck, lint, build, E2E
  against a real server and database), then read-only OWASP Top 10:2025 and
  WCAG 2.2 AA auditors, looping until green. Bigger goals become an epic: the
  goal is decomposed into a persistent work graph (runs/<epic-id>/graph.jsonl)
  of dependency-ordered tasks, then drained autonomously on a dedicated epic
  branch — one task at a time through the same gates, one commit per task,
  discovered work filed as new tasks for later, until the epic is done or a
  stop condition fires. Use whenever the user asks to build, implement, or ship
  an app, feature, frontend, backend, or full-stack change and wants it
  production-ready, tested, e2e tested, reviewed, secure, accessible, or
  pixel-perfect — even if they never say "loop", "graph", "epic", or "audit".
license: MIT
---

# Build

Short description in, verified code out. The loop is the deliverable, not the
first draft. Nothing ships on "looks done" — it ships on parsed verdicts.

**Never write implementation code before the bars exist.** A build with no
verifier is a draft, and drafts are what this skill exists to prevent.

## Honey — the house style

[Honey](https://github.com/Green-PT/honey-for-devs) is standard in both modes:

- **Lever 1 — minimum code.** The least code that satisfies the spec, stdlib
  before dependency — already every builder's rule; named here as policy.
- **Lever 2 — terse durable prose.** `spec.md` bullets, zone facts, graph
  `note`s, `report.md`: dense, no narration. Every dispatch re-pays for every
  line that survives.
- **Lever 3 — ESON returns.** Every node return is ESON, not JSON, not prose
  (`references/eson.md`). The parent branches on fields (`status=`,
  `verdict=`) and treats declared counts as checksums. The boundary: ESON is
  the message format, never the state format — `graph.jsonl` stays JSONL,
  dispatch prompts stay plain text.

## 0. Gate — loop or epic?

**Resume check, before the gate.** If `<repo-root>/runs/<epic-id>/graph.jsonl`
already exists for the goal in hand, this is a resumed epic, not a new one:
**do not re-plan and do not rewrite `spec.md`.** Fold the graph (merge per id,
latest field wins), switch to `epic/<epic-id>`, assert a clean tree, append an
`open` record for anything left `in_progress` with a note that it was
interrupted, and enter Phase B at step 1. `blocked` tasks stay blocked — name
them in the first message with their `note`s — a `needs-input:` question is
re-asked verbatim; re-opening one is the operator's move, never the resume's.
**An answer to that question is that move**: record it in a `note`, append
`open`, and continue in the same turn — the operator says the word, not a graph
edit. If every planned task already folds `closed` and only backlog remains, resume at Phase C instead — an epic drains
in scope, then closes over its backlog; it does not grind the backlog first.
Planning on top of a live graph duplicates tasks and orphans the commits
already made. The gate below is for new work only.

**Greenfield discovery, also before the gate — both modes.** Fires only when
both hold: the project has no stack to read (no manifest, no source) **and** the
request names none. In an existing repo the stack is a fact on disk — asking is
noise; go straight to the gate. A small greenfield build is still greenfield: it
scores low, stays a loop, and still needs this.

- Propose the boring default in plain words, one message: language, storage,
  how it runs. "Web app, TypeScript everywhere, SQLite so there's nothing to
  install, one command to run — fine?" Defaults-first: never a menu of
  frameworks, never a question that needs technical vocabulary to answer.
- One confirmation, then autonomy as before. This spends one of A1's two
  clarifying questions — greenfield stack choice is the canonical "wrong guess
  wastes the whole build".
- Record the confirmed stack plus a ~5-line architecture sketch (major pieces
  and what talks to what) in `spec.md` in epic mode, inline in loop mode.
  Builders inherit it; no task re-derives it.

Now the gate. Run `decompose` and score its seven signals. Most tasks are a loop.

- **Loop (score 0–4)** — no subagents, no run directory, no branch, no work
  graph. Spec and bars inline, implement inline, run the machine gates (§G),
  then §A audits only if the change touches auth/data (security) or renders UI
  (a11y). Skip everything else below. There is no `spec.md` in loop mode, so:
  gate commands come from what's on disk — the manifest's scripts, the CI
  config, the Makefile — and a gate with no command there is reported `none`,
  never invented; the §G baseline still applies, captured before the first edit;
  and **commit only if the user asked**, branching first if they did and you are
  on the default branch. Loop mode never creates an `epic/` branch. One line at
  each phase entry — `Step 2/4 — implement; next: machine gates` — counting only
  the phases this build gets, naming an auditor while one runs.
- **Epic (score 5–7)** — full-stack or multi-task work, parallel builders,
  read-only auditors, context that won't fit one window. Run Phases A–C.

Say which you picked and why, in one line. Don't build the epic because the
request sounded big. Before entering epic mode, state the estimated task count
and cost — roughly `tasks × (builders + conditional audits)` subagent runs; an
epic at the 15-task ceiling is a large multiple of a single loop build. For a
full-stack epic assume **both** audits on every task: a vertical slice touches
data and renders UI, so §B6's condition only bites for single-zone tasks.

**Probe dispatch once before Phase A.** Spawn one trivial subagent and check it
returns. Epic mode is delegation all the way down, and the "two consecutive
infrastructure/API errors" stop condition only fires after a task is claimed and
its builders are burned. If the probe fails, say so and offer the degraded run —
parent does Phase A and the machine gates inline — instead of discovering it
mid-drain. Audits are never part of a degraded run; see §A.

The probe proves dispatch *works*; it does not buy approval for the ones that
follow. In the same message, say how many dispatches the run will make and that
each may prompt for approval — approving for the session is what keeps the drain
unattended. A run the operator must babysit prompt-by-prompt is not the mode
they were sold.

## Phase A — Plan (parent only, before any code)

### A1. Spec and bars

Write `<repo-root>/runs/<epic-id>/spec.md` — epic-level, shared by every task so
no task re-derives the contract. It must contain, concretely:

- **Acceptance criteria** — numbered, each checkable by a test.
- **API contract** — endpoints, payload shapes, error codes. Written *before*
  frontend and backend split, or they can't run in parallel.
- **Zone map** — the path globs each zone owns, and whether they are **disjoint**.
  Frameworks that co-locate server and client in one file (Next.js server actions
  and route handlers, SvelteKit `+page.server.ts`, Rails, Django) do not have
  disjoint zones. Say so here: it decides whether a task can be dispatched in
  parallel at all (§B4).
- **Visual reference** — the pixel bar. One of: a design file/screenshot the user
  supplied, a URL to match, or a design spec you write and state back for
  confirmation. **"Pixel perfect" with no reference is not a bar** — degrade it
  to "matches the stated design spec" and say so.
- **Stack and commands** — exact test, typecheck, lint, build, and E2E commands,
  plus the **run command, the base URL the app serves on, and the port range
  reserved for the `ui-auditor`** — distinct from the E2E suite's. The auditor
  grades a *running* app; with no way to start one it returns `app unreachable`
  and the UI bar is never applied.
- **E2E environment** — what E2E means for this project type, test database,
  migration and seed strategy, which builder owns `e2e/`, and — only if no form
  of it applies — `no-e2e: <reason>` with every criterion mapped to an
  integration test instead. See `references/e2e-gate.md`.
- **Scope of audits** — which routes/flows the auditors must cover.
- **Gate baseline** — run §G once, before any code, and record where each gate
  starts: `pass`, `fail: <what>`, or `none: <no command in this project>`.
- **`<epic-id>`** — `E-` plus a short slug of the goal. If `runs/<epic-id>/`
  already exists you are resuming, not planning (§0); if it exists and its epic
  record is `closed`, take the next free `-2` suffix and name the prior run here.

**A section that doesn't apply is `n/a: <why>`, never padded.** Half this list
assumes something renders or serves HTTP. A CLI, a library, or a pipeline marks
the visual reference, the run URL, the auditor port range, and the UI audit
scope `n/a` in one line each — and then §B6 never dispatches the `ui-auditor`,
because there is nothing to render. Writing a plausible-sounding visual bar for
a thing with no pixels is how a spec starts lying.

Ambiguity budget: at most 2 clarifying questions, asked together, only when a
wrong guess would waste the whole build. Otherwise pick the obvious default,
state it in `spec.md`, and proceed.

`spec.md` is the parent's to **refine** mid-run. When a gate or an audit surfaces
a contract detail the plan never settled — a validation limit, a new error code, a
clause that turns out to conflict with an audit bar — write it back in the same
iteration with a one-line reason. That keeps the contract and the code in step.
Adding capability nobody asked for is scope creep, not refinement: if the change
would add an acceptance criterion, it needs a task.

### A2. Work graph

Emit `runs/<epic-id>/graph.jsonl`: one epic record plus task records with
`deps`, `zone`, and `criteria[]`. Schema, ready-computation, and mutation rules:
`references/work-graph.md`.

- Every epic acceptance criterion maps to at least one task, or the graph is
  incomplete.
- Tasks are **vertical slices** — a user-visible increment that may touch both
  zones — not horizontal layers ("all backend" then "all frontend"). The outer
  loop is sequential; parallelism lives *inside* a task (§B step 4).
- Each task is completable in one dispatch: one deliverable, criteria checkable
  against a diff. If it isn't, split it.
- A task that **changes a contract other zones already consume** is not
  separable from its consumers. Slice it with the consumers it breaks
  (`zone: both`, one builder), or land the contract change as its own leading
  task — a seam that leaves a later task's tree red at commit time was drawn
  wrong.

### A3. Branch

Create or switch to `epic/<epic-id>` before touching anything. Never commit to
the default branch for the rest of the run. Never merge, never push — the merge
is the user's, proposed as text in `report.md`.

### A4. Bars first, then code

Per task, its acceptance tests are written before its implementation. They
fail; that's correct. A bar that can't fail isn't a bar. Every criterion maps
to at least one E2E test or is marked unit-only in `spec.md` with a reason.
Unmapped criteria fail the gate.

### A5. Commit the plan

Commit `spec.md` + `graph.jsonl` on the epic branch (`<epic-id>: plan`) before
the first dispatch — Phase B step 2 asserts a clean tree, and the plan must be
in the record before code exists. Then print the plan's status table (§S) —
the operator's first sight of the run's shape. E2E flows in a dedicated final
task (owned by the `e2e/` owner), with unit/component bars per earlier task, is
the intended shape.

## Phase B — Dispatch loop

While ready tasks exist and bounds hold:

1. **Pick** the highest-priority ready task (`status: open`, every dep
   `closed`) **in scope**: planned, or discovered-and-blocking an epic
   acceptance criterion. Non-blocking discoveries are backlog — never
   drained; the epic closes over them.
2. **Assert clean working tree.** Dirty → stop and report; never paper over it.
3. **Claim**: append `in_progress` to `graph.jsonl`; print the status table
   (§S), naming who is about to run.
4. **Implement.** Trivial and single-zone → inline. Otherwise delegate, in
   parallel where the task spans zones **and the zone map says the globs are
   disjoint**, contract already fixed in `spec.md`:
   - `backend-builder` — everything that doesn't render: API, schema, auth, CLI,
     library, data pipeline, infra scripts, and their tests
   - `frontend-builder` — everything that renders: UI, components, state,
     styling, and their tests
   Each prompt carries absolute paths, the contract, the task's `criteria[]`,
   and its zone memory (`zones/<zone>.md`) — pruned first if past ~a page,
   cut lines appended to `zones/<zone>.archive.md`, never deleted; every
   dispatch pays the file's length. Nodes inherit nothing.
   **Overlapping zones are single-writer.** When the zone map is not disjoint, a
   `zone: both` task goes to **one** builder owning the whole task. The fence is
   what makes a parallel pair safe, and a shared file has no fence — two builders
   editing one module is the corruption the single-writer rule exists to prevent.
   Pick the builder by the task's centre of gravity and say which in the dispatch.
   **A parallel builder pair is one task, never two.** Two tasks dispatched at
   once share a working tree and therefore a commit, which breaks
   one-commit-per-task. When audit failures split by owner, file them as a single
   `zone: both` task — routing a failure to its owner picks the *builder*, not
   the task.
5. **Machine gates** (§G) — parent runs them. Failure → back to the owning
   builder with the actual error text, not a summary. **Attribute before you
   loop back**: the owner of the failing artifact is not always the task in
   flight. A failure living in files this task cannot write — another zone's
   e2e spec, a stale fixture — is diagnosed with artifacts, then filed or
   routed to its owner (a `note` record with the forensics; amend the owning
   task's record), and burns no loopbacks here. The task in flight may still
   close on its own criteria with the diagnosis in the graph and the suite
   otherwise green. An undiagnosed recurring failure is never "flaky" — it is
   a failing gate.
6. **Conditional audits** (§A) — `security-auditor` only if the task touched
   auth, data, or external input; `ui-auditor` only if it rendered UI.
7. **Adjudicate**: read `git diff` against the task's `criteria[]` — criteria
   written before the code, so this is not post-hoc rationalization.
8. **Close or loop back.** All green and criteria met → one commit with the
   task id in the message → **then** append `closed` carrying that sha — a
   real one from `git log`, never a placeholder — plus `audits` for any
   per-task audit verdicts. The
   close record cannot live inside the commit it names; amending to fold it in
   changes the very sha it just recorded. Let it ride in a
   `graph: close <id> @ <sha>` commit or in the next task's. Print the close
   line (§S). Otherwise loop back
   (max 2 per gate), then it's a stop condition.
9. **File discovered work**: append new task records with `discovered-from`.
   Builders return it in `discovered[]`; the parent files it — **bars, not
   findings**: `criteria[]` pass/fail, the observation in `evidence`, any
   `fix:` idea in `note` (§A: a fix is a hypothesis). Default `prio: 3`.
   **Filed, never worked in the same iteration** — that rule is what stops an
   autonomous run from sprawling.
10. **Zone memory**: builders appended their own durable facts; the parent
    appends auditors' `zone_facts` to `zones/security.md` / `zones/ui.md`.
11. **Route cross-zone contract changes now, not later.** A builder whose change
    alters what another zone depends on — a function signature, a new error code
    or status, a cookie or schema change — reports it, and the parent dispatches
    or files the other side's update in the same iteration. Ownership fences stop
    a builder from repairing what it broke on the other side of the fence, so an
    unrouted contract change is silent breakage, not isolation.

Then loop to 1. Between tasks there is no check-in — the epic waits on no
reply until done, ceiling, or a stop condition. Unattended, not silent: the
status table (§S) prints at every claim, each close emits its one-liner, and
neither ever pauses the run.

## Phase C — Epic close

1. Full test suite once more — a regression here is a stop condition, not a
   footnote.
2. Full audit sweep: `security-auditor` + `ui-auditor` over all changed routes,
   regardless of per-task audits. Both verdicts must be `pass` to close the
   epic, and both land in the epic `closed` record as `audits` — or
   `not_run: <reason>`, which keeps the epic out of Done. A close record
   silent on audits is not a close.
3. Append `closed` for the epic — carrying `commits[]`, `open[]` (the
   backlog), and `audits` — then write `runs/<epic-id>/report.md`, including a
   **Deviations** section: every departure from this protocol with its cause,
   or `none`. A closed epic is reopened by appending an epic `open` record
   before any further task work — never close tasks onto a closed epic.
4. Prune any `zones/*.md` past ~a page — cut lines move to
   `zones/<name>.archive.md`, never deleted.
5. Print the **proposed** merge command, naming `runs/<epic-id>/` and `zones/`
   as part of what it carries across, so keeping or stripping the process
   artifacts is a decision rather than a surprise. Never run it.

## §G. Machine gates — parent runs these, never a node

In order, on every iteration — cheap gates first, stop at the first failure:

1. unit/component tests
2. typecheck
3. lint
4. build
5. **E2E** — the real thing running, in whatever form the project type takes:
   browser, HTTP client, spawned binary, installed package, or the pipeline over
   real fixture data. Real database where one exists, migrated from scratch and
   seeded. Skipped only when `spec.md` declares `no-e2e: <reason>` — reported as
   skipped, never folded into a pass. Per-type definition, bar, and flake policy:
   `references/e2e-gate.md`

A node never reports its own tests as passing. The parent runs the commands and
reads the output.

**Gates are judged against the A1 baseline, not against zero.** A repo that
starts with a red test does not get to fail every task for it — only failures
**new** relative to the baseline belong to the task in flight. A pre-existing
failure is filed as a task and competes on `prio`; it never burns a task's
loopbacks and never blocks a close. A gate with no command in this project is
reported as `none`, not silently skipped and not invented.

**A test that passes only on retry is a failing gate.** Never add retries,
`sleep`, or loosened assertions to reach green — fix the race. Never delete a
failing test to close the loop.

**If the gate tooling itself goes down mid-run** — shell, runner, or spawn
outage — do not keep drafting on top of an ungated tree: finish the task in
flight to implementation-complete, dispatch nothing further until gates run
again, and gate everything before any close. Commits the outage forced into a
batch are a recorded deviation in `report.md`, never silent.

## §A. Audit gates — read-only, structured

Only once machine gates are green. Per task: conditional (§B step 6). At epic
close: both, full scope. In loop mode: only if the change touches their scope.

- `security-auditor` — OWASP Top 10:2025. Bar: `references/security-gate.md`
- `ui-auditor` — WCAG 2.2 level AA + visual fidelity. Bar: `references/ui-gate.md`

Neither has write tools; both return an ESON verdict (`references/eson.md`):
`verdict=` and `score=` scalars plus
`failures[N]{id,cat,severity,clause,evidence,fix,owner}` — `sc` in place of
`cat` for the UI auditor's WCAG criterion. The parent parses `verdict` and
branches on the field, never on prose; checks every `[N]` against the rows
received; and saves the return verbatim as `runs/<epic-id>/security.eson` /
`ui.eson`. Their `Bash` is for read-only commands — the dependency audit,
starting the app — a rule stated in the agent files, not something the tool
list can enforce.

Route each failure to the node that owns the file. Security findings at
`severity: critical|high` block the build regardless of score.

**A fix is not done until its audit re-runs — a stale pass is not a pass.** This
is what the gate is for. A fix is written by the node that was just graded, under
pressure, in exactly the code the auditor flagged; fixes routinely introduce new
defects, sometimes worse than the one repaired. A one-shot audit doesn't merely
miss those — it launders a regression as a fix. Re-run over full scope after
every round. Resume the same auditor where the runtime allows: it keeps its
measurement setup and can compare against its own prior evidence, which is how it
catches regressions in its own findings. Give it the diff and tell it to be
sceptical of the changelog.

**A `fix:` is a hypothesis; `clause:` is the bar.** Route the clause, not the
sentence. An auditor proposing a fix is guessing at a cause from outside the
code, and it can name the wrong measurement — a contrast fix specified as "ring
vs card" gets implemented faithfully and verified against exactly that adjacency
when the one that mattered was ring vs button. Tell the builder which clause it
must satisfy, and have the re-audit **re-derive the measurement from the clause**
rather than re-checking the one its predecessor named.

**Reseed before an audit that follows a destructive probe.** Auditors have no
write tools but they drive a running app, and that mutates the database the E2E
suite and the next audit read. Auditors stop before irreversible actions and
report in `notes` anything they did change; the parent reseeds, and never lets a
later gate run against data an audit disturbed.

**The node that fixes a finding is never the only one testing it.** Its tests
carry the blind spot that produced the defect — a builder that fixes a focus bug
writes tests for the path it was already thinking about. The auditor's re-run is
the independent check; never substitute a builder's own green tests for it.

Auditors are the one role the parent may never fill itself. Machine gates and
even implementation can be inlined when delegation is unavailable; a verdict from
the author of the code is a different, weaker bar. Report it as not run.

## §S. Status table — broadcast, never a question

Autonomous is not silent. The table derives from the folded graph plus the
dispatch in flight — never a new file — and prints at the plan commit (A5),
each claim (naming who is about to run), every stop, and Done. Each close
emits one line instead: `T3 done @ a1b2c3d — 3/5; next: T4`. The shape,
exactly:

```
**E-checkout** on `epic/E-checkout` — 2/5 done · backlog 1

| Task | Status |
|---|---|
| T1 cart API | done a1b2c3d |
| T2 cart UI | done e4f5a6b |
| T3 checkout API | running — backend-builder, then security audit |
| T4 checkout UI | next |
| T5 e2e flows | open — waits on T3, T4 |

Now: T3 checkout API. Next: T4 checkout UI.
```

Statuses, exactly these: `done <sha>` · `running — <agents, or inline>` ·
`next` — the drain's next pick · `open — waits on <deps>` · `blocked — <note>`,
the note keeping its `gates:`/`needs-input:` prefix. Rows are in-scope tasks
in file order; backlog is the header count, never rows; blocked rows always
show. The Now/Next line ends every table. Print and move on — a table never
waits for a reply. Only at a stop does it arrive with the failing clauses or
the open question, followed by the **Next steps** bullets (spec under Stop
conditions) — then halt.

**A stop is announced in the turn it happens**, before anything else and without
being asked. A run that halts and says nothing reads exactly like a run still
working; the operator finds out by asking "how far are we?" — after the run has
been dead for half an hour. Silence is the failure mode this table exists to
prevent.

## Bounds

- One task in flight at a time.
- One commit per task, never batched.
- 15 tasks closed per run — runaway backstop, not a target.
- `max_loopbacks`: 2 per gate. Then stop and report the failing clauses.
- Node types: 4. Parallel instances of one type count once.
- Each delegation carries an explicit stop condition, never "until done".
- Never commit to the default branch — in either mode; never merge; never push.

## Stop conditions — halt, dispatch nothing further, report

- A task fails its gates twice (after the 2 loopbacks). Append `blocked`,
  `note` `gates: <the failing clauses>`; do not force a third pass. Only an
  operator-appended `open` record re-enters it — resume never does.
- Any full-suite regression.
- A decision needs operator input: spec ambiguity, scope change, unsettled
  UX/semantics. Append `blocked` on the task in flight, `note`
  `needs-input: <the question>` — durable, so resume re-surfaces it; no task
  in flight → a `note` record carrying the question.
- Anything requiring a push, a config change, or files outside the project.
- Two consecutive infrastructure/API errors.
- **A dispatch is rejected or interrupted by the operator.** One is enough — a
  denial is a decision, not an error, and re-sending the same prompt re-asks a
  question already answered. Never auto-retry, and never quietly inline the work
  instead. Append `blocked` on the task in flight, `note` `needs-input: dispatch
  rejected — <agent> for <id>; approve and say resume, or say degrade to run it
  inline (no audits, stays out of Done)`, and surface it in that same turn.
- The work needs a 5th specialty — a **tool or model none of the four roles has**
  (mobile simulator, notebook runtime, a different provider). A non-web domain is
  not a 5th specialty: CLIs, libraries, data pipelines, and infra scripts are
  `backend-builder`'s. Re-run the `decompose` gate; never invent a node mid-run.

On any stop, in order: the status table (§S); the exact failing clauses or
the open question — closed, filed, and blocked all read off the table; then
**Next steps** — 2–4 bullets, each one concrete operator action, tailored to
the stop cause, never boilerplate. Always include:

- **How to continue** — re-invoke the skill with the same goal; resume folds
  the graph and picks up here. For a `gates:` block, add the re-entry move:
  say "re-open Tn" (an operator-appended `open` record) and name the failing
  clause to read first. For `needs-input:`, the bullet is the question
  itself, with the options when they are enumerable.
- **One sanity check** worth running before continuing — the suite, the last
  commit's diff, or the app on the epic branch — as a runnable command.
- **Anything only the operator can do** (a push, a config change, a file
  outside the project): the exact command or change. Omit when none.

**A failed gate reported honestly beats a passed gate that was
downgraded to make it pass.** Never relax a bar to close the loop; never mark
`pass` on a verdict the auditor didn't give.

## Done

Ship only when: machine gates green including E2E, epic-close audit verdicts
both `pass`, no unresolved `critical`/`high`. Then report, in this order:

1. What was built, in two sentences.
2. The final status table (§S) — every task's end state.
3. Gate results — unit/typecheck/lint/build, E2E (passed/failed/skipped +
   acceptance-criteria coverage map), security verdict + score, UI verdict + score.
4. What was deliberately not done, every protocol deviation with its cause,
   any quarantined test, and any accepted-risk finding with its reason.
5. The proposed merge command.

**An audit that could not run keeps the build out of Done.** No dispatch
available, app unreachable, no auditor — report `security: not run` or
`ui: not run` with the reason and say plainly that the bar was never applied.
A missing verdict is not a passing one. A degraded run produces a change that
passed its machine gates and nothing more; call it that.

## State

Run directory, `graph.jsonl`, zone memory, and the single-writer table:
`references/state.md` and `references/work-graph.md`.

## Org graph

Stable roles in `~/.claude/agents/` — the work graph in `graph.jsonl` is
per-epic and disposable; this is not (see
`~/.claude/skills/decompose/references/graph-engineering.md`):

```
                    [parent — orchestrator]
             owns: gate runs, graph.jsonl, commits, adjudication
                   /      |        |       \
    backend-builder  frontend-builder  security-auditor(RO)  ui-auditor(RO)
          |               |                |                    |
   non-UI code+tests  UI code+tests   security.eson          ui.eson
          ^               ^                |                    |
          +---------------+----------------+--------------------+
                        failures[], max 2 loopbacks
```

Auditors never fix what they find. Builders never grade their own work. The
parent never delegates gate-running or adjudication.
