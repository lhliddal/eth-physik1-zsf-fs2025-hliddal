#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHAPTER_DIR="$ROOT_DIR/chapters"

if [[ ! -d "$CHAPTER_DIR" ]]; then
  echo "chapters directory not found: $CHAPTER_DIR"
  exit 1
fi

# Physik-relevante Regeln: nur Spacing- und direkte Tabellen-Farb-Hacks.
# NICHT gebannt: \mathbb, \operatorname, \sum\limits, \lim\limits — Physik-Konventionen.
patterns=(
  '\\vspace\*?\{'
  '\\hspace\*?\{'
  '\\columncolor\{'
  '\\rowcolor\{'
  '\\rowcolors\{'
  '\\arrayrulecolor\{'
  '\\begin\{tabular\}'
  '\\begin\{tabularx\}'
)

messages=(
  'Use central spacing macros (\\ZSFspaceXS/S/M/L) instead of local \\vspace.'
  'Use central spacing macros instead of local \\hspace.'
  'Avoid direct \\columncolor in chapters; use centralized table styling.'
  'Avoid direct \\rowcolor in chapters; use \\ZSFheaderRow (semantic header highlight).'
  'Avoid direct \\rowcolors in chapters; use \\ZSFzebra / \\ZSFzebraStart from styles/20_tables.tex.'
  'Avoid direct \\arrayrulecolor in chapters; central rule styling lives in styles/50_typography_semantics.tex.'
  'Avoid raw tabular in chapters; use ZSFtable / ZSFtableFlat from styles/20_tables.tex.'
  'Avoid raw tabularx in chapters; use ZSFtable / ZSFtableFlat from styles/20_tables.tex.'
)

violations=0

search_matches() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n --pcre2 "$pattern" "$file"
  else
    grep -nE "$pattern" "$file"
  fi
}

while IFS= read -r file; do
  for i in "${!patterns[@]}"; do
    if search_matches "${patterns[$i]}" "$file" >/dev/null; then
      echo "[RULE VIOLATION] $file"
      search_matches "${patterns[$i]}" "$file"
      echo "  -> ${messages[$i]}"
      violations=1
    fi
  done
done < <(find "$CHAPTER_DIR" -name '*.tex' | sort)

if [[ "$violations" -ne 0 ]]; then
  echo "Chapter rule check failed."
  exit 1
fi

echo "Chapter rule check passed."
