# Contributing

Peter is pre-release. Bug reports, failed runs, narrow fixes, and reproducible
examples are more useful than new orchestration features.

## Report a run

Include:

- Peter commit, Claude Code version, model, operating system, and target repository commit
- Exact goal and project gate commands
- Completed, blocked, and discovered task counts
- Human interventions, failed gates, and relevant redacted logs
- Expected behavior and what happened instead

Never include credentials, private source, or unredacted model transcripts from
repositories you cannot share.

## Change Peter

1. Keep the skill dependency-free and the graph contract append-only.
2. Update the nearest reference document when changing a gate or state rule.
3. Run `./tests/install.sh` after installer changes.
4. Exercise orchestration changes in a disposable repository and attach the
   resulting graph, commits, and gate results to the pull request.

Small, evidence-backed changes are preferred.
