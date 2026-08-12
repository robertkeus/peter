<p align="center">
  <img src="assets/peter.png" width="220" alt="Peter, the builder — ink portrait">
</p>

<h1 align="center">Peter</h1>

<p align="center">
  <em>You describe it. He graphs it. He ships it.</em><br>
  <sub>Develop like <a href="#faq">Peter Steinberger</a> — and cut the token bill doing it.</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/Green-PT/peter?style=flat-square&color=111111&label=stars" alt="Stars">
  <img src="https://img.shields.io/badge/runtime-Claude%20Code-111111?style=flat-square" alt="Runtime: Claude Code">
  <img src="https://img.shields.io/badge/license-MIT-111111?style=flat-square" alt="MIT license">
</p>

<p align="center">
  <strong>One goal in &middot; one gated commit per task &middot; zero babysitting</strong><br>
  <sub>Autonomous epic builds for Claude Code — graph engineering with the bars built in.
  Not a framework, not a runtime: a skill, four agent files, and a JSONL contract.
  The parent session is the runtime.</sub>
</p>

---

You know him. You describe a feature at nine; by noon there's a branch with a
commit per task, each one green. He doesn't ask whether you want tests. There
are tests. There's an OWASP pass. The contrast ratios check out.

Peter puts him inside Claude Code.

## Before / after

You ask for a checkout flow. Your agent writes 800 lines, says "All done! 🎉",
and the first click 500s. No tests, no migrations, `main` is broken.

With peter:

```
> /peter checkout flow with Stripe test mode

epic/checkout-flow · 9 tasks · draining unattended

$ git log --oneline epic/checkout-flow
f3a91c2 task-9: e2e — happy path + declined card
8d02b4e task-8: checkout UI against the fixed API contract
…                 every commit: gates green, audits pass
```

## How it works

Every task — loop or epic — goes through the same enforced sequence. No
implementation code before the bars exist:

```
1. Spec + pass/fail bars   → written first, or nothing gets built
2. Implement               → the minimum that meets the bars
3. Machine gates           → unit, typecheck, lint, build, e2e
                             (real server, real database — no mocks)
4. Security audit          → OWASP Top 10:2025, read-only verdict
5. UI audit                → WCAG 2.2 AA + visual fidelity, read-only verdict
6. Loop until green        → then exactly one commit
```

Small changes run that loop once and stop.

Big goals become an **epic**: the goal is decomposed into a persistent work
graph (`runs/<epic-id>/graph.jsonl`, append-only) of dependency-ordered tasks,
then drained on a dedicated `epic/<id>` branch — one task at a time through the
gates above, one commit per task pushed as it lands (a dead machine costs at
most the task in flight), discovered work filed as new tasks instead of
scope-creeping the current one, until the epic closes or a stop condition hands
control back.

Implementation is zone-fenced across two builders: `backend-builder` owns
everything that doesn't render (API, CLI, library, pipeline, infra),
`frontend-builder` owns everything that does. The write fence is what makes a
parallel pair safe — a shared file has no fence, so co-located code goes to one
builder. The two auditors never write; they return verdicts.

## Honey + ESON

Two standards run through every agent in the graph:
[Honey](https://github.com/Green-PT/honey-for-devs) — write the minimum code
that needs to exist, say the minimum about it — and
[ESON](https://github.com/Green-PT/honey-eson), the wire format every subagent
return comes back in.

**Why it cuts tokens.** Output is the bill. Builders write only the code the
spec demands (stdlib before custom, nothing speculative) and skip the
narration; auditors return verdicts, not essays. Fewer tokens per unit of
shipped work — not fewer gates. An epic that runs tests, an OWASP pass and a
WCAG pass still costs more than a one-shot that skips them and ships a 500;
what's gone is the waste, not the rigor.

**Why runs have more context.** Every subagent return lands in the parent's
context window and stays there for the rest of the drain. A narrated diff
burns that window; an ESON manifest is a few lines. Less window spent per task
means more tasks fit before compaction — late tasks in a long epic still see
the spec, the graph, and every verdict that came before.

**Why agent-to-agent is more efficient.** The parent never parses prose — it
branches on fields:

```
!eson/1
status=green
files[2]{path,change}
src/checkout/api.ts	+stripe intent endpoint
src/checkout/api.test.ts	+4 cases
```

That's a whole task return. Cheaper than JSON on the wire — no braces or
quotes per row — and self-checking: `[2]` declares the row count, so a
truncated return is detected and re-requested instead of silently losing
findings. One carve-out is absolute: anything touching auth, money,
migrations, deletes, or data loss keeps its full text. Honey compresses
everything except the things that hurt when compressed.

ESON is the message format only — `graph.jsonl` stays JSONL.

## Install

The most effort peter will ever ask of you:

```bash
git clone https://github.com/Green-PT/peter && cd peter && ./install.sh
```

That's it. `~/.claude` is not version-controlled; this repo is the tracked
copy. `./install.sh pull` copies the other way, `./install.sh check` reports
drift.

## Commands

| Command | What it does |
|---------|--------------|
| `/peter <goal>` | Score the goal. Small → one enforced loop. Big → epic: work graph, dedicated branch, autonomous drain. |

## Layout

```
skills/peter/SKILL.md            the loop + epic orchestration
skills/peter/references/         work-graph, state, eson wire format, e2e/security/ui gate specs
agents/{backend,frontend}-builder.md   zone-fenced implementers
agents/{security,ui}-auditor.md        read-only verdict-only auditors
install.sh                       sync with ~/.claude
```

## FAQ

**Why "peter"?**
Named for [Peter Steinberger](https://x.com/steipete), whose July 2026
question — "Are we still talking loops or did we shift to graphs yet?" —
sparked the graph-engineering framing this repo implements: a stable org graph
of specialist roles, a per-epic work graph of dependency-ordered tasks. No
affiliation or endorsement — just credit for the frame.

**Is it a framework?**
No. A skill, four agent files, and a JSONL contract. Claude Code is the
runtime; delete the files and it's gone.

**What if a task fails its gates?**
The failure is routed to the builder that owns it, with the actual error text.
It loops until green; a task that can't get there is filed as blocked and the
drain moves on. Stop conditions hand control back instead of burning tokens.

**Why are the subagent replies so terse?**
That's the house standard — see [Honey + ESON](#honey--eson).

**Can I use it with [ponytail](https://github.com/DietrichGebert/ponytail)?**
Different layers, same family: ponytail shrinks what one agent writes; peter
decides what gets built, in what order, and what "done" means. Peter's
builders already write minimal code — it's the house standard.

## License

[MIT](LICENSE). Use it, fork it, ship with it.

## Star History

<a href="https://www.star-history.com/green-pt/peter#history">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=Green-PT/peter&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=Green-PT/peter&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=Green-PT/peter&type=Date" />
 </picture>
</a>
