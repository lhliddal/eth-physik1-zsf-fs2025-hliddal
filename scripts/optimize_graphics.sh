#!/usr/bin/env bash
# ============================================================
# optimize_graphics.sh — Verkleinert alle Bilder in graphics/
# auf eine druckoptimale Maximalgrösse für das ZSF-Layout.
#
# Hintergrund:
#   Die ZSF-Spalten sind ca. 4 cm breit. Bei 300 DPI (Druck-
#   qualität) sind das ~470 Pixel. 600 px max. Breite gibt
#   ausreichend Reserve für Retina-Displays und Zoom.
#
# Vorgehen:
#   1. Erstellt ein Backup aller Originale in graphics/_originals/
#   2. Verkleinert jedes Bild auf max. 600 px (längste Seite)
#   3. Behält kleinere Bilder unverändert bei
#   4. Nutzt macOS-eigenes `sips` (kein ImageMagick nötig)
#
# Nutzung:
#   ./scripts/optimize_graphics.sh
# ============================================================

set -euo pipefail

GRAPHICS_DIR="$(cd "$(dirname "$0")/../graphics" && pwd)"
BACKUP_DIR="${GRAPHICS_DIR}/_originals"
MAX_SIZE=600  # Pixel (längste Seite)

echo "=== ZSF Graphics Optimizer ==="
echo "Zielverzeichnis: ${GRAPHICS_DIR}"
echo "Max. Dimension:  ${MAX_SIZE}px"
echo ""

# Backup-Verzeichnis erstellen
if [ ! -d "${BACKUP_DIR}" ]; then
  mkdir -p "${BACKUP_DIR}"
  echo "✓ Backup-Verzeichnis erstellt: _originals/"
fi

# Zähler
optimized=0
skipped=0
total=0

while IFS= read -r -d '' img; do
  total=$((total + 1))

  filename="$(basename "$img")"
  size_before=$(stat -f%z "$img")

  # Dimensionen lesen
  w=$(sips --getProperty pixelWidth "$img" 2>/dev/null | awk '/pixelWidth/{print $2}')
  h=$(sips --getProperty pixelHeight "$img" 2>/dev/null | awk '/pixelHeight/{print $2}')

  # Prüfe ob Verkleinerung nötig
  if [ "$w" -le "$MAX_SIZE" ] && [ "$h" -le "$MAX_SIZE" ]; then
    skipped=$((skipped + 1))
    printf "  ⏭  %-60s %4dx%-4d (bereits klein)\n" "$filename" "$w" "$h"
    continue
  fi

  # Backup (nur wenn noch nicht vorhanden)
  if [ ! -f "${BACKUP_DIR}/${filename}" ]; then
    cp "$img" "${BACKUP_DIR}/${filename}"
  fi

  # Resample auf MAX_SIZE (längste Seite, Aspect Ratio bleibt)
  sips --resampleHeightWidthMax "$MAX_SIZE" "$img" >/dev/null 2>&1

  size_after=$(stat -f%z "$img")
  savings=$(( (size_before - size_after) * 100 / size_before ))

  # Neue Dimensionen
  w_new=$(sips --getProperty pixelWidth "$img" 2>/dev/null | awk '/pixelWidth/{print $2}')
  h_new=$(sips --getProperty pixelHeight "$img" 2>/dev/null | awk '/pixelHeight/{print $2}')

  printf "  ✅ %-60s %4dx%-4d → %4dx%-4d  (%d%% kleiner)\n" \
    "$filename" "$w" "$h" "$w_new" "$h_new" "$savings"

  optimized=$((optimized + 1))
done < <(find "${GRAPHICS_DIR}" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0)

echo ""
echo "=== Fertig ==="
echo "Total: ${total} Bilder | Optimiert: ${optimized} | Übersprungen: ${skipped}"
echo "Originale gesichert in: graphics/_originals/"

# Vorher/Nachher Gesamtgrösse
size_total_after=$(du -sh "${GRAPHICS_DIR}" | awk '{print $1}')
echo "Neue Gesamtgrösse graphics/: ${size_total_after}"
