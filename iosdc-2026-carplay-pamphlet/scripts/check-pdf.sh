#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PDF_PATH="$ROOT_DIR/dist/iosdc-2026-carplay-pamphlet.pdf"

if [[ ! -f "$PDF_PATH" ]]; then
  echo "PDF not found: $PDF_PATH" >&2
  exit 1
fi

if ! command -v pdfinfo >/dev/null 2>&1; then
  echo "pdfinfo is required to validate the generated PDF." >&2
  exit 1
fi

PDFINFO_OUTPUT="$(pdfinfo "$PDF_PATH")"
echo "$PDFINFO_OUTPUT"

PAGES="$(printf '%s\n' "$PDFINFO_OUTPUT" | awk -F': *' '/^Pages:/ {print $2}')"
PAGE_SIZE_LINE="$(printf '%s\n' "$PDFINFO_OUTPUT" | awk -F': *' '/^Page size:/ {print $2}')"

if [[ "$PAGES" != "2" ]]; then
  echo "Expected 2 PDF pages, got: ${PAGES:-unknown}" >&2
  exit 1
fi

if [[ ! "$PAGE_SIZE_LINE" =~ ^(1190\.55\ x\ 841\.89|841\.89\ x\ 1190\.55)\ pts ]]; then
  echo "Expected spread-sized pages (approximately 420mm x 297mm), got: ${PAGE_SIZE_LINE:-unknown}" >&2
  exit 1
fi

echo "PDF checks passed."
