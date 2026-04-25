#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PDF_FILE_REL="${PDF_FILE:-main.pdf}"
PDF_FILE="${ROOT_DIR}/${PDF_FILE_REL}"

EXPECTED_AUTHOR="Loris Einar Kristjan Hliddal"
EXPECTED_OWNER_ID="LEKH-ZSF-2026-A1B2"
EXPECTED_RELEASE_ID="R2026.04"

if [[ ! -f "$PDF_FILE" ]]; then
  echo "Identity check failed: PDF not found at $PDF_FILE"
  echo "Run 'make build' first."
  exit 1
fi

if ! command -v pdfinfo >/dev/null 2>&1; then
  echo "Identity check failed: 'pdfinfo' is required but not installed."
  exit 1
fi

pdfinfo_out="$(pdfinfo "$PDF_FILE")"

extract_field() {
  local key="$1"
  awk -F': ' -v k="$key" '$1 == k { sub(/^[[:space:]]+/, "", $2); print $2 }' <<<"$pdfinfo_out"
}

author="$(extract_field "Author")"
title="$(extract_field "Title")"
subject="$(extract_field "Subject")"
keywords="$(extract_field "Keywords")"

status=0

if [[ "$author" != "$EXPECTED_AUTHOR" ]]; then
  echo "Identity check failed: Author mismatch."
  echo "  expected: $EXPECTED_AUTHOR"
  echo "  actual:   ${author:-<empty>}"
  status=1
fi

if [[ "$title" != "ZSF Physik" ]]; then
  echo "Identity check failed: Title mismatch."
  echo "  expected: ZSF Physik"
  echo "  actual:   ${title:-<empty>}"
  status=1
fi

if [[ "$subject" != *"owner=${EXPECTED_OWNER_ID}"* ]] || [[ "$subject" != *"release=${EXPECTED_RELEASE_ID}"* ]]; then
  echo "Identity check failed: Subject missing owner/release markers."
  echo "  actual: ${subject:-<empty>}"
  status=1
fi

if [[ "$keywords" != *"owner-name:${EXPECTED_AUTHOR}"* ]] || [[ "$keywords" != *"owner-id:${EXPECTED_OWNER_ID}"* ]] || [[ "$keywords" != *"release-id:${EXPECTED_RELEASE_ID}"* ]] || [[ "$keywords" != *"build-id:"* ]]; then
  echo "Identity check failed: Keywords missing required identity tags."
  echo "  actual: ${keywords:-<empty>}"
  status=1
fi

if command -v exiftool >/dev/null 2>&1; then
  xmp_author="$(exiftool -s -s -s -Author "$PDF_FILE" 2>/dev/null || true)"
  xmp_subject="$(exiftool -s -s -s -Subject "$PDF_FILE" 2>/dev/null || true)"
  xmp_keywords="$(exiftool -s -s -s -Keywords "$PDF_FILE" 2>/dev/null || true)"

  if [[ -n "$xmp_author" ]] && [[ "$xmp_author" != "$EXPECTED_AUTHOR" ]]; then
    echo "Identity check failed: XMP Author mismatch."
    echo "  expected: $EXPECTED_AUTHOR"
    echo "  actual:   $xmp_author"
    status=1
  fi

  if [[ -n "$xmp_subject" ]] && [[ "$xmp_subject" != *"owner=${EXPECTED_OWNER_ID}"* ]]; then
    echo "Identity check failed: XMP Subject missing owner marker."
    echo "  actual: ${xmp_subject:-<empty>}"
    status=1
  fi

  if [[ -n "$xmp_keywords" ]] && [[ "$xmp_keywords" != *"owner-id:${EXPECTED_OWNER_ID}"* ]]; then
    echo "Identity check failed: XMP Keywords missing owner-id marker."
    echo "  actual: ${xmp_keywords:-<empty>}"
    status=1
  fi
fi

if [[ "$status" -ne 0 ]]; then
  exit 1
fi

echo "PDF identity check passed."
