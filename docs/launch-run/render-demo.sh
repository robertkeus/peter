#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT

frames=(
  '13:59:21|$ /peter build a reading-list vertical slice|Pinned public fixture · Claude Code 2.1.228'
  '14:00:09|✓ baseline gates|test · typecheck · lint · build · e2e'
  '14:02:09|epic/reading-list · 0/3|T1 backend → T2 UI → T3 E2E'
  '14:12:16|security audit · FAIL 4/10|8 findings · 2 bounded repairs'
  '14:36:04|✓ T1 · security PASS 7/10|1e130d6 · 3 findings filed'
  '14:53:58|UI audit · FAIL 6/10|8 findings · 2 bounded repairs'
  '15:17:21|✓ T2 · UI PASS 9/10|24fccae · 1 finding filed'
  '15:22:33|✓ T3 · E2E 9/9|69d0ca7 · all parent gates green'
  '15:26:57|✓ EPIC DONE · 3/3|33/33 tests · 9/9 E2E · 0 interventions'
)

for i in "${!frames[@]}"; do
  IFS='|' read -r stamp title subtitle <<<"${frames[$i]}"
  number="$(printf '%03d' "$i")"
  progress="$((856 * (i + 1) / ${#frames[@]}))"
  sed -e "s|{{STAMP}}|$stamp|g" -e "s|{{TITLE}}|$title|g" -e "s|{{SUBTITLE}}|$subtitle|g" -e "s|{{PROGRESS}}|$progress|g" \
    "$here/terminal-frame.svg" >"$work/$number.svg"
  rsvg-convert -w 960 -h 540 "$work/$number.svg" -o "$work/$number.png"
done

ffmpeg -hide_banner -loglevel error -y -framerate 1 -i "$work/%03d.png" \
  -vf "fps=12,scale=960:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=96[p];[s1][p]paletteuse=dither=bayer" \
  "$here/peter-launch.gif"

echo "$here/peter-launch.gif"
