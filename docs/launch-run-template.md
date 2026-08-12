# Peter launch run

Status: **not yet run**. Replace every placeholder with observed data; do not
publish this file as evidence while any result field is incomplete.

## Environment

| Field | Observed value |
|-------|----------------|
| Peter commit | `<full SHA>` |
| Target repository and commit | `<public URL and full SHA>` |
| Claude Code version | `<version>` |
| Model | `<model>` |
| Operating system | `<name and version>` |
| Started / finished | `<UTC timestamps>` |

## Goal

Exact prompt:

```text
<goal passed to /peter>
```

Project gate commands:

```text
<unit, typecheck, lint, build, E2E, and audit commands>
```

## Results

| Metric | Observed value | Evidence |
|--------|----------------|----------|
| Elapsed time | `<duration>` | `<transcript timestamps>` |
| Tasks completed / blocked / discovered | `<counts>` | `<graph link>` |
| Commits produced | `<count>` | `<git log link>` |
| Gate failures repaired | `<count>` | `<redacted log links>` |
| Human interventions | `<count and reasons>` | `<transcript links>` |
| Input / output tokens | `<reported values or unavailable>` | `<source>` |
| Reported cost | `<value or unavailable>` | `<source>` |
| Final test result | `<command and result>` | `<CI or log link>` |
| Security / UI verdict | `<result or not run with reason>` | `<artifact links>` |

## Artifacts

- Work graph: `<link to graph.jsonl>`
- Specification: `<link to spec.md>`
- Commit history: `<link to compare or branch>`
- Gate logs: `<links>`
- Audit returns: `<links or prerequisites unavailable>`
- Terminal recording: `<link>`

## Failures and limitations

Record what Peter got wrong, work it could not complete, misleading status,
unexpected cost, and every place a person intervened. Do not remove failed
attempts that materially affect the result.

## Reproduce

Provide the exact checkout, installation, target setup, and `/peter` commands.
State any credential or paid-service requirement without publishing secrets.
