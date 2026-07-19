#!/usr/bin/env bash

set -euo pipefail

if ! command -v gs >/dev/null 2>&1; then
  echo "Ghostscript (gs) is required for npm run press-local." >&2
  echo "Install it with: brew install ghostscript" >&2
  echo "Or use npm run press to run the preflight inside Docker." >&2
  exit 1
fi

vivliostyle build --preflight press-ready-local -o dist/iosdc-2026-carplay-pamphlet-press.pdf
