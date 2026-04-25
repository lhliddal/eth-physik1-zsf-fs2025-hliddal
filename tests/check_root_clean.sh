#!/usr/bin/env bash
# Verhindert, dass Fremd-Dateien im Projekt-Root landen.
# Whitelist pflegen, wenn neue Root-Level-Dateien legitim sind.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

allowed_files=(
  "main.tex"
  "main.pdf"
  "main.synctex.gz"
  "physik1_fs2025_hliddal.pdf"
  "physik1_fs2025_hliddal.synctex.gz"
  "preamble.tex"
  "Makefile"
  ".gitignore"
  ".latexindent.yaml"
  ".pre-commit-config.yaml"
  ".cursorrules"
  "MODULAR_SYSTEM.md"
  "README.md"
)

allowed_dirs=(
  "chapters"
  "styles"
  "tests"
  "scripts"
  "graphics"
  "build"
  "_scratch"
  ".git"
  ".github"
  ".vscode"
  ".cursor"
)

is_in() {
  local needle="$1"; shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

violations=0

shopt -s dotglob nullglob
for entry in "$ROOT_DIR"/*; do
  name="$(basename "$entry")"
  if [[ -d "$entry" ]]; then
    if ! is_in "$name" "${allowed_dirs[@]}"; then
      echo "[ROOT CLEAN] Unerwarteter Ordner im Root: $name/"
      violations=1
    fi
  else
    if ! is_in "$name" "${allowed_files[@]}"; then
      echo "[ROOT CLEAN] Unerwartete Datei im Root: $name"
      violations=1
    fi
  fi
done
shopt -u dotglob nullglob

if [[ $violations -ne 0 ]]; then
  echo ""
  echo "Root darf nur Whitelist-Einträge enthalten. Neue Dateien bitte in"
  echo "  chapters/ | styles/ | tests/ | scripts/ | graphics/ | _scratch/"
  echo "ablegen. Whitelist bei Bedarf in tests/check_root_clean.sh erweitern."
  exit 1
fi

echo "Root clean check passed."
