# Token-efficiency evidence

Peter uses two upstream components to reduce output volume:

- Honey constrains builders and auditors to the minimum code and prose needed.
- ESON encodes structured agent returns with record keys declared once.

The evidence supports lower output tokens and fewer lines of generated code.
It does **not** establish a measured end-to-end cost saving for Peter: the
public Peter run has no equivalent no-Honey/no-ESON control arm.

## ESON format benchmark

Recomputed on 2026-08-12 from
[`Green-PT/honey-eson@d6809a1`](https://github.com/Green-PT/honey-eson/tree/d6809a131067e84faad6cc1ff47026664dcca988).
All five documents round-tripped losslessly before token measurement; the JS
and Python suites also passed (29 tests total).

| Format | o200k tokens | vs compact JSON | Claude tokenizer estimate | vs compact JSON |
|--------|-------------:|----------------:|--------------------------:|----------------:|
| Compact JSON | 4,395 | baseline | 4,536 | baseline |
| Pretty JSON | 6,816 | +55% | 6,702 | +48% |
| Columnar JSON | 3,440 | -22% | 3,451 | -24% |
| ESON | 3,151 | -28% | 3,361 | -26% |

The corpus contains a small review, large review, scalar envelope, nested
context, and tool results. ESON was 30% smaller than compact JSON on the large
review and 28% smaller on tool results, but **8% larger** on the scalar
envelope.

The ESON primer measured 125 o200k tokens, versus 50 for columnar JSON. Its
extra 75 tokens break even after about two average record-heavy messages when
the primer is cached; without prompt caching, the benchmark says it never
breaks even. This is why Peter reserves ESON for repeated agent handoffs and
keeps `graph.jsonl` as JSONL.

Reproduce:

```bash
git clone https://github.com/Green-PT/honey-eson.git
cd honey-eson
git checkout d6809a131067e84faad6cc1ff47026664dcca988
npm ci --ignore-scripts
npm test
npm run bench:formats
npm run bench:primer
```

The o200k count uses `gpt-tokenizer@3.4.0`. The Claude column uses
`@anthropic-ai/tokenizer@0.0.4`, which is a legacy estimate rather than an
exact count for current Claude models.

## Honey paired benchmark

Recomputed from the committed records in
[`Green-PT/honey-for-devs@b39339e`](https://github.com/Green-PT/honey-for-devs/tree/b39339e32e63721835756188d7ba08947ac7f709/bench).
Each result is the paired per-task median over 23 author-written tasks and three
runs. Continuous endpoints use a two-sided Wilcoxon signed-rank test; judge
scores use an exact sign test.

| Model | Output delta | LOC delta | Total-cost delta | Tests, baseline → Honey | Judge W/L/T |
|-------|-------------:|----------:|-----------------:|------------------------:|------------:|
| Claude Opus 4.8 | -29%, `p=.020` | -43%, `p<.001` | -21%, `p=.104` (not significant) | 97% → 100% | 8/11/2, `p=.648` (tie) |
| GPT-5.5 | -20%, `p=.004` | -18%, `p<.001` | +14%, `p=.820` (not significant) | 100% → 99% | 6/8/7, `p=.791` (tie) |

The significant result is less output and less code on both model families.
Quality was a judge tie, not a gain. Total cost was inconclusive and moved in
opposite directions: Claude reused the skill prompt through caching, while the
GPT run reported no cache reads and paid 573% more fresh/cache-creation input
(`p<.001`). Therefore Peter claims output reduction, not a proven dollar saving.

Reproduce without API spend from the committed result records:

```bash
git clone https://github.com/Green-PT/honey-for-devs.git
cd honey-for-devs
git checkout b39339e32e63721835756188d7ba08947ac7f709
cd bench
node src/report.js --stamp full-opus48
node src/report.js --stamp full-gpt55
```

## Limits

- The Honey tasks were written by Honey's author and are not an independent
  external suite; 23 tasks are enough to observe an effect, not a leaderboard.
- Judge scores are noisy. Objective tests are the stronger correctness signal.
- ESON's format benchmark measures serialization, not model quality. Its
  separate upstream comprehension suite is not reproduced here.
- Neither benchmark recreates Peter's full graph, retries, audits, or context
  history. Those can dominate the final bill.
- No saving is claimed for auth, money, migrations, deletes, or other
  irreversible payloads; Peter keeps those explicit rather than compact.
