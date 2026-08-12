# Peter launch run

Status: **complete**. This records the first public, reproducible Peter proof
run. Observed failures and unresolved findings are retained.

## Environment

| Field | Observed value |
|-------|----------------|
| Peter commit | [`6f710ea91f5720b89134efb58880788a97393957`](https://github.com/robertkeus/peter/commit/6f710ea91f5720b89134efb58880788a97393957) |
| Target repository and commit | [`robertkeus/peter-launch-fixture@ed3243ce70340eab73ed20d3956dde7efc14f64b`](https://github.com/robertkeus/peter-launch-fixture/tree/ed3243ce70340eab73ed20d3956dde7efc14f64b) |
| Claude Code version | `2.1.228 (Claude Code)` |
| Models | parent/builders: `claude-sonnet-5`; auditors: `claude-opus-5[1m]` |
| Operating system | macOS 26.5.1 (25F80), arm64 |
| Started / finished | 2026-08-12 13:59:21.957Z / 15:26:57.279Z |

## Goal

The [complete, exact prompt](launch-run/prompt.md) specified the API,
persistence, UI, accessibility, visual reference, audit scope, and gate suite.
It explicitly supplied every product decision and required autonomous operation
without clarification.

Project gate commands:

```text
npm test
npm run typecheck
npm run lint
npm run build
npm run e2e
```

## Results

| Metric | Observed value | Evidence |
|--------|----------------|----------|
| Elapsed time | 1:27:35.322 wall time; 1:26:26.435 API duration | [event transcript](launch-run/transcript.md) |
| Tasks completed / blocked / discovered | 3 / 0 / 4 | [graph](https://github.com/robertkeus/peter-launch-fixture/blob/9d01a0aba390948f9e99beaeeca961b5c0a29f73/runs/reading-list/graph.jsonl) |
| Commits produced | 8 after the pinned baseline | [comparison](https://github.com/robertkeus/peter-launch-fixture/compare/ed3243ce70340eab73ed20d3956dde7efc14f64b...9d01a0aba390948f9e99beaeeca961b5c0a29f73) |
| Gate failures repaired | 4 failing audit verdicts repaired in bounded loopbacks; 1 stale E2E assertion routed to T3 and repaired | [transcript](launch-run/transcript.md) |
| Human interventions | 0 | [transcript](launch-run/transcript.md) |
| Input / output tokens | 924 direct input / 402,985 output; 33,306,153 cache-read and 1,500,635 cache-creation tokens | [usage](launch-run/usage.md) |
| Reported cost | $27.63309410 | [usage](launch-run/usage.md) |
| Final test result | 33/33 unit/integration; typecheck, lint, and build clean; 9/9 E2E | [independent repeat](launch-run/gates.md) |
| Security / UI verdict | pass 8/10 with 3 open findings / pass 9/10 with 1 open finding | [security](https://github.com/robertkeus/peter-launch-fixture/blob/9d01a0aba390948f9e99beaeeca961b5c0a29f73/runs/reading-list/security.eson), [UI](https://github.com/robertkeus/peter-launch-fixture/blob/9d01a0aba390948f9e99beaeeca961b5c0a29f73/runs/reading-list/ui.eson) |

## Artifacts

- [Work graph](https://github.com/robertkeus/peter-launch-fixture/blob/9d01a0aba390948f9e99beaeeca961b5c0a29f73/runs/reading-list/graph.jsonl)
- [Specification](https://github.com/robertkeus/peter-launch-fixture/blob/9d01a0aba390948f9e99beaeeca961b5c0a29f73/runs/reading-list/spec.md)
- [Commit history](https://github.com/robertkeus/peter-launch-fixture/compare/ed3243ce70340eab73ed20d3956dde7efc14f64b...9d01a0aba390948f9e99beaeeca961b5c0a29f73)
- [Gate results](launch-run/gates.md)
- [Initial and final security evidence](https://github.com/robertkeus/peter-launch-fixture/tree/9d01a0aba390948f9e99beaeeca961b5c0a29f73/runs/reading-list)
- [Final UI audit](https://github.com/robertkeus/peter-launch-fixture/blob/9d01a0aba390948f9e99beaeeca961b5c0a29f73/runs/reading-list/ui.eson)
- [Terminal demo](launch-run/peter-launch.gif)
- [Final report](https://github.com/robertkeus/peter-launch-fixture/blob/9d01a0aba390948f9e99beaeeca961b5c0a29f73/runs/reading-list/report.md)

## Failures and limitations

Security initially failed 4/10 with eight findings and failed its re-audit 6/10
with five findings. UI initially failed 6/10 with eight findings and failed its
re-audit 8/10 with two findings. Both used the allowed two repair loopbacks and
then passed; the transcript keeps that progression.

Four findings remain, deliberately visible as graph tasks T4–T7:

- Medium: no per-client rate limiting and an unpaginated full-list response.
- Medium: an oversize streaming request returns 413 but its connection remains open.
- Low: the in-memory cache does not reconcile out-of-band file edits.
- Low: the heading overflows at 320px only when text is also scaled to 200%.

No work was blocked and Peter did not misreport the final gate state. Total cost
was $27.63—higher than a one-shot prompt because this run performed repeated
machine gates plus independent security and UI audits.

## Reproduce

```bash
git clone https://github.com/robertkeus/peter.git
cd peter
git checkout 6f710ea91f5720b89134efb58880788a97393957
./install.sh --dry-run
./install.sh
npx --yes @anthropic-ai/claude-code@2.1.228 --version

cd ..
git clone https://github.com/robertkeus/peter-launch-fixture.git
cd peter-launch-fixture
git checkout ed3243ce70340eab73ed20d3956dde7efc14f64b
npx --yes @anthropic-ai/claude-code@2.1.228
```

At the Claude Code prompt, paste the exact contents of
[`launch-run/prompt.md`](launch-run/prompt.md). The run requires a Claude plan
with Sonnet and Opus access, authenticated network access, Git push access to a
fork or clone you own, Node.js, Chrome, and Playwright's pinned MCP package.
Do not reuse the published branch name unless you first delete or rename it.
