# Launch checklist

## Required before Hacker News

- [x] Installer detects existing skill and agent filename collisions.
- [x] Forced replacement preserves originals and uninstall restores them.
- [x] Dry-run, uninstall, drift detection, and installer integration tests exist.
- [x] README distinguishes bounded autonomy from unconditional hands-off operation.
- [x] Limitations and contribution instructions are public.
- [ ] Run Peter end-to-end against a small public repository at a pinned commit.
- [ ] Complete `docs/launch-run-template.md` with unedited observed results.
- [ ] Publish the work graph, commits, gate logs, human interventions, and cost data.
- [ ] Record a short terminal demo from the same reproducible run.
- [ ] Replace the illustrative README transcript with the public run.
- [ ] Confirm the documented Claude Code version on a clean account or machine.
- [ ] Create and smoke-test the `v0.1.0` release archive.

## GitHub metadata

Description:

> Persistent work graphs and independently checked quality gates for autonomous Claude Code builds.

Topics:

`claude-code`, `agent-orchestration`, `ai-agents`, `developer-tools`, `open-source`

Before launch, add the description and topics, confirm Issues are enabled, and
leave the website blank unless a useful demo or documentation URL exists.

## Release notes

The `v0.1.0` notes should contain:

- The problem and Peter's graph-and-gates approach
- Supported environment and exact installation command
- Link to the reproducible launch run
- Known limitations and upgrade/uninstall instructions
- SHA-256 checksum for the source archive if distributing one separately

## Launch gate

Do not submit to Hacker News until every required item is complete. Write the HN
title and first comment personally; HN currently asks authors not to publish
LLM-written or LLM-edited text.
