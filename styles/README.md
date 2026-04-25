# Style Modules (ZSF_Physik_V3)

Dieses Verzeichnis enthält das modulare Style-System, das von `preamble.tex` geladen wird.

- `00_packages.tex`: Paket-Imports und Paket-Level-Setup (siunitx, tcolorbox, geometry, …)
- `10_math.tex`: Math-Operatoren und Vektor-Macros (Physik-spezifisch)
- `20_tables.tex`: Reserviert für Tabellen-Helfer
- `30_layout_spacing.tex`: Layout-Grundlagen, 4-Level-Spacing-Scale und Physik-spezifische Skips
- `40_colors_structure.tex`: Named Theme-Palettes (Elektro/Magneto/Maxwell/Optik), Index-Palette (12 Kapitel), Kapitel-Start-Orchestrierung
- `50_typography_semantics.tex`: Schriftmakros für Balken und Box-Titel
- `55_readability.tex`: Intelligente Zeilenumbruch-Steuerung (Flattersatz + TeX-Penalties) für Fliesstext in schmalen Spalten
- `60_boxes.tex`: tcolorbox-Stile, chapterbar, subsectionbar, defbox, tablebox, figbox, formulabox, warnbox, runintext
- `70_document_settings.tex`: hyperref-Farben

Chapter-Dateien bleiben inhaltsfokussiert; Layout und Styling laufen über diese Module.

## Readability-System (55_readability.tex)

Der Fliesstext (`runintext`, `defbox`, `warnbox`) ist standardmässig im **Flattersatz** (ragged-right) gesetzt, damit LaTeX in den schmalen 4-Spalten-Zeilen lieber früh umbricht als Wörter hart zu trennen oder Leerraum aufzublähen.

**Globaler Schalter:**

```latex
\ZSFReadableBodyOff   % zurück zu Blocksatz (überall)
\ZSFReadableBodyOn    % wieder an (Standard)
```

**Lokale Anwendung:**

```latex
\begin{ZSFReadable}
  ... Text im Flattersatz ...
\end{ZSFReadable}
```

**Semantische Feinsteuerung (selten nötig):**

- `\ZSFbreak` — weicher bevorzugter Umbruch an dieser Stelle
- `\ZSFnobreak` — gebundenes Leerzeichen (kein Umbruch): `5\ZSFnobreak kg`
- `\ZSFallowbreak` — erlaubt Umbruch, wo sonst keiner erlaubt wäre
