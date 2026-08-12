# Graph engineering in Peter

Peter separates two graphs:

- The stable **org graph** is the parent plus four roles in `agents/`.
- Each epic's append-only **work graph** is `runs/<epic-id>/graph.jsonl`.

The parent alone routes work, runs gates, mutates the graph, commits, and
adjudicates. Builders own disjoint code zones and append durable zone facts.
Auditors are read-only and never verify their own fixes. A failure can loop back
at most twice; graph mutations and cross-zone contract changes are recorded.

Keep those boundaries stable during a run. If the work needs a fifth specialty,
stop and re-score the seven-signal gate in `SKILL.md`; do not invent a role
mid-epic.
