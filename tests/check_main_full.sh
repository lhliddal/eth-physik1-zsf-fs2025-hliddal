#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAIN_TEX="${ROOT_DIR}/main.tex"

required_chapters=(
  "chapters/ch00_zeichen"
  "chapters/ch00_wichtige"
  "chapters/ch01_feld"
  "chapters/ch02_potenzial"
  "chapters/ch03_kapazitaet"
  "chapters/ch04_gleichstrom"
  "chapters/ch05_magnetfeld"
  "chapters/ch06_induktion"
  "chapters/ch07_wechselstrom"
  "chapters/ch08_maxwell"
  "chapters/ch09_wellenoptik"
  "chapters/ch10_geometrisch"
  "chapters/ch11_quanten"
)

if [ ! -f "${MAIN_TEX}" ]; then
  echo "Error: main.tex not found at ${MAIN_TEX}"
  exit 1
fi

status=0

for chapter in "${required_chapters[@]}"; do
  if ! awk -v c="${chapter}" 'BEGIN { ok=0 } $0 ~ "^[[:space:]]*\\\\input\\{" c "\\}" { ok=1 } END { exit ok ? 0 : 1 }' "${MAIN_TEX}"; then
    echo "[FULL BUILD CHECK] Missing active input: \\input{${chapter}}"
    status=1
  fi
done

if [ "${status}" -ne 0 ]; then
  echo "main.tex is not in full-build mode."
  exit 1
fi

echo "main.tex full-build check passed."
