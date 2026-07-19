#!/usr/bin/env bash

set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required for npm run press." >&2
  echo "Use npm run press-local if Ghostscript is installed locally." >&2
  exit 1
fi

vivliostyle build --preflight press-ready -o dist/iosdc-2026-carplay-pamphlet-press.pdf
