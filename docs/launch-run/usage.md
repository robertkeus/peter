# Public proof run usage

Claude Code reported the following usage for the run. Cache reads and cache
creation are listed separately from direct input.

| Model | Input | Output | Cache read | Cache creation | Reported cost |
|-------|------:|-------:|-----------:|---------------:|--------------:|
| `claude-sonnet-5` | 658 | 257,749 | 23,468,487 | 659,182 | $13.82294985 |
| `claude-opus-5[1m]` | 266 | 145,236 | 9,837,666 | 841,453 | $13.81014425 |
| **Total** | **924** | **402,985** | **33,306,153** | **1,500,635** | **$27.63309410** |

Elapsed wall time from the first to last streamed timestamp was 1:27:35.322.
Claude Code also reported 5,186,435 ms of API duration and 9 parent turns.
