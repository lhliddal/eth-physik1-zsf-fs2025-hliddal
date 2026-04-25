# Modulares ZSF-Physik-LaTeX-System (Pflichtdokumentation)

Diese Datei ist verbindlich für alle zukünftigen Änderungen an `ZSF_Physik_V3`.

## Ziel

Eine 4-spaltige Physik-Zusammenfassung (Elektromagnetik, Optik, Quanten), die strikt modular organisiert ist und sich auf physikalischen Inhalt fokussiert. Layout, Farben und Boxen werden zentral gesteuert.

## Absolute Wichtigkeit

Das Layout-System ist strikt modular. Diese Modularität ist nicht optional, sondern **Pflicht**:

- Keine lokalen Spacing-Hacks (`\vspace`, `\hspace`, `\newpage`) in Kapiteldateien.
- Keine lokalen Stilabweichungen für Boxen, Titel oder Balken.
- Neue Inhalte müssen die zentralen Makros verwenden.
- Ziel: Kapitel fokussieren sich vollständig auf Physik-Inhalt; Layouting kommt aus `styles/`.

## Projektstruktur

```
ZSF_Physik_V3/
├── main.tex                 Hauptdokument: lädt preamble + Kapitel (multicols)
├── preamble.tex             Nur Loader für styles/*.tex
├── styles/                  Modulares Style-System
│   ├── 00_packages.tex      Pakete (amsmath/amssymb, siunitx detect-all, tcolorbox, …)
│   ├── 10_math.tex          \sgn, \vect
│   ├── 20_tables.tex        Zebra-Streifen (\ZSFzebra) + Header-Row (\ZSFheaderRow)
│   ├── 30_layout_spacing.tex  Layout + 4-Level-Scale (XS/S/M/L) + Skips
│   ├── 40_colors_structure.tex  Palettes, \StartChapter, \StartFrontChapter
│   ├── 50_typography_semantics.tex  Schriftmakros
│   ├── 60_boxes.tex         chapterbar, subsectionbar, defbox, tablebox, figbox,
│                            formulabox (+ \formulasep), warnbox, runintext,
│                            \ZSFItemHeading, PlaceholderGraphic
│   └── 70_document_settings.tex  hyperref
├── chapters/                13 Kapitel (ch00_zeichen, ch00_wichtige, ch01..ch11)
├── graphics/                Physik-Bilder (PNG/JPG)
├── tests/                   check_main_full.sh, check_chapter_rules.sh, run_test.sh
├── scripts/                 Reserviert
├── Makefile                 build, lint, format, check, test, clean
├── .latexindent.yaml        2-space-Indent, trailing-whitespace-Removal
├── .pre-commit-config.yaml  end-of-file, trailing-ws, check-main-full, latexindent, chktex
├── .vscode/                 settings.json + tasks.json
└── .gitignore
```

**WICHTIG:** Bei Layout-Anpassungen nicht die Kapitel oder `preamble.tex` ändern, sondern das passende Modul in `styles/`.

## Verbindliche Nutzungsregeln

### 1. Kapitel-Start
```tex
\StartChapter{Titel}            % nummeriert + Palette per Index
\StartChapter[label]{Titel}     % mit \label
\StartFrontChapter{Titel}       % unnummeriert (Front-Matter)
```

### 2. Subsection-Bar
```tex
\SubsectionBar{Text}            % nummeriert
\SubsectionBar*{Text}           % unnummeriert
\SubsectionBar[label]{Text}     % mit Label
```

### 3. Spacing
Niemals `\vspace{...}` oder `\hspace{...}` in Kapiteln. Stattdessen:
- Box-interne Abstände: `\ZSFspaceXS`, `\ZSFspaceS`, `\ZSFspaceM`, `\ZSFspaceL`
- Alle Box-Before/After-Skips sind zentral in `30_layout_spacing.tex` gesetzt.

### 4. Boxen
- `\begin{defbox}[Titel] … \end{defbox}` — Definitionen
- `\begin{tablebox}[Titel] … \end{tablebox}` — Tabellen
- `\begin{figbox}[Titel] … \end{figbox}` — Abbildungen
- `\begin{formulabox} … \end{formulabox}` — zentrale Formeln
- `\begin{warnbox}[Titel] … \end{warnbox}` — rote Warnung (Physik-spezifisch)
- `\begin{runintext} … \end{runintext}` — Text vor Box

### 5a. Formeln stapeln (Trennstrich)
Mehrere verwandte Formeln in **einer** `formulabox` werden durch `\formulasep`
(dünne graue Trennlinie) visuell gegliedert — so bleibt der Block scanbar,
ohne für jede Formel eine eigene Box zu eröffnen.

```tex
\begin{formulabox}
  \[ F = q\,E \]
  \formulasep
  \[ F = q\,v \times B \]
\end{formulabox}
```

Für gleichwertige Teilabschnitte innerhalb einer Box (z. B. "Fall A" / "Fall B"):
```tex
\ZSFItemHeading{Fall A}
... Inhalt ...
\ZSFItemHeading{Fall B}
... Inhalt ...
```

**Regel:** `\formulasep` nur *innerhalb* einer `formulabox`; `\ZSFItemHeading`
nur *innerhalb* einer Box. Im Fliesstext nicht verwenden — dafür gibt es
`\SubsectionBar*`.

### 5. Formelnoten
```tex
\formulanote{Note unter Formel}
\formulanoteabove{Note über Formel}
```

### 6. Farb-Palettes
- Standard: Kapitel-Index (0..19) → `ChapterColor{n}` via `\SetChapterPaletteByNumber`
- Themen: `\SetChapterPalette{elektro|magneto|maxwell|optik}` für semantische Override
- **Reihenfolge perzeptuell optimiert (CIEDE2000 simulated annealing):** Slots 1..19
  sind so sortiert, dass aufeinanderfolgende Kapitel (Abstand 1 **und** 2) maximal
  unterscheidbar sind. Slot 0 ist reserviert für `\StartFrontChapter` (ETH-Rot).
  Nie Kapitel-Farben in Kapiteldateien hart-coden — ausschliesslich `\chaptercolor`
  / `\chaptercolorlight` referenzieren.

### 6b. Tabellen — semantisches Table-System

**Alle Tabellen** laufen ueber die Wrapper-Environments aus
`styles/20_tables.tex`. `tabular`, `tabularx` sowie saemtliche Farb-Primitive
(`\rowcolor`, `\rowcolors`, `\columncolor`, `\arrayrulecolor`) sind in
Kapiteln **verboten** (Linter-Regel).

**Design-Garantien:**
1. Tabelle fuellt immer exakt `\linewidth` → Zebra kann nicht "zu kurz" sein.
2. Spaltenbreiten werden proportional deklariert (Summe der Faktoren =
   Anzahl X-Spalten, `tabularx`-Konvention) → kein Ueberlauf.
3. Zebra + Header-Styling sind eingebaut.

**Environments:**
```tex
\begin{ZSFtable}[<font>]{<colspec>}       % Zeile 1 = Header, Zebra ab Zeile 2
\begin{ZSFtableFlat}[<font>]{<colspec>}   % kein Header, Zebra ab Zeile 1
\begin{ZSFtablePlain}[<font>]{<colspec>}  % ohne Zebra (Sonderfall)
```

`<font>` ist optional. Semantische Varianten (in `styles/50_typography_semantics.tex`):
- `\ZSFfontTable` — Default (`\normalsize`).
- `\ZSFfontTableDense` — kleiner (`\footnotesize`) fuer lange, dichte Tabellen.

**Spaltentypen (colspec):**
- Gleichverteilt (jede zaehlt als Faktor 1): `L` (links), `C` (zentriert),
  `R` (rechts).
- Proportional mit Faktor `n`: `Y{n}` (links), `Z{n}` (zentriert),
  `Q{n}` (rechts), `F{n}` (zentriert + Math-Mode).

**Konvention (wichtig!):**
Die Summe aller Faktoren in _einer_ Tabelle muss gleich der Anzahl der
X-Spalten sein, damit die Tabelle `\linewidth` voll ausfuellt. `L`/`C`/`R`
zaehlen implizit als `1`.

| Spalten | Summe der Faktoren | Beispiel                     |
| ------- | ------------------ | ---------------------------- |
| 2       | 2                  | `Y{0.6} Y{1.4}`              |
| 3       | 3                  | `Y{0.6} Y{1.5} Y{0.9}`       |
| 4       | 4                  | `Y{1.2} Y{0.8} Y{1.2} Y{0.8}`|

**Beispiele:**
```tex
% Header + 3 Spalten, kleinere Schrift (Summe = 3):
\begin{ZSFtable}[\ZSFfontTableDense]{Y{0.6} Y{1.55} Y{0.85}}
  \ZSFheaderRow \ZSFhead{Symbol} & \ZSFhead{Bedeutung} & \ZSFhead{SI-Einheit} \\
  $e$ & Elementarladung & \si{C} \\
  ...
\end{ZSFtable}

% Ohne Header, 2 Spalten, Default-Schrift (Summe = 2):
\begin{ZSFtableFlat}{Y{0.64} Y{1.36}}
  \textbf{Stromstärke} & $I = \dot{Q}$ \\
  ...
\end{ZSFtableFlat}
```

**Header-Zellen (`\ZSFhead`):**
`\ZSFheaderRow` setzt nur den **Zeilen-Hintergrund**. Jede Zelle wird zusaetzlich
mit `\ZSFhead{<Text>}` umschlossen, das Textfarbe (weiss) und Fettdruck pro
Zelle sicherstellt. Grund: in `tabularx`-X-Spalten propagiert ein globales
`\color` nach `\rowcolor` nicht zuverlaessig ueber `&`-Grenzen — die erste
Zelle verliert die Farbe. Per-Zelle-Wrapper loest das deterministisch.

**Tuning-Makros:**
- `\ZSFheaderRow` — Header-Zeilen-Hintergrund in Kapitelfarbe.
- `\ZSFhead{<Text>}` — Header-Zellen-Inhalt (weiss, fett); pro Zelle verwenden.
- `\SetZSFzebraBG{<farbe>}` — Zebra-BG pro Tabelle override
  (z. B. `black!5` fuer kapitelunabhaengige Tabellen).
- `\ZSFzebraOff` — explizit deaktivieren.

### 7. Keyword-Hervorhebung (Fettdruck)

Für zentrale Fachbegriffe im Fliesstext nutzen wir konsequent das semantische Makro

```tex
\ZSFkeyword{Fachbegriff}
```

definiert in `styles/50_typography_semantics.tex` (rendert als `\textbf{…}`, zentral änderbar).

**Wo einsetzen:**
- `runintext`, `defbox`, `warnbox` und vergleichbare Text-Boxen.
- **Nicht** in Formeln, `\formulanote`, `\SubsectionBar`-Titeln oder `\StartChapter`.

**Was auszeichnen:** echte Fachbegriffe — Gesetze (`Coulomb`, `Gauß-Gesetz`, `Biot-Savart`),
Effekte (`Lenz`, `Compton-Effekt`), Bauteile (`Kondensator`, `Transformator`), zentrale
Größen (`Impedanz`, `Dipolmoment`). **Nicht** auszeichnen: generische Substantive (Kraft,
Energie, Spannung, Ladung, Feld), Verben oder Füllwörter.

**Dichte (Richtwert, damit das Schriftbild ruhig bleibt):**
- Kapitel-Intro: 4–6 Keywords.
- Jeder `runintext`-Block: 1–3 Keywords.
- `defbox`/`warnbox`: 1–2 Keywords.
- Pro Kapitel ca. 8–14 Keywords gesamt (siehe bestehende Kapitel als Kalibrierung).

**Faustregel:** Wenn in einem Satz mehr als zwei Begriffe fett werden, ist es zu viel —
die wichtigsten behalten, den Rest in normale Schrift zurücksetzen.

## Workflow-Tools

```
make build            # latexmk → build/main.pdf
make check-main-full  # validiert alle 13 Kapitel in main.tex
make check-chapters   # Lint: \vspace/\hspace/\rowcolor{s}/\columncolor/\arrayrulecolor
make lint             # chktex
make format           # latexindent
make check            # alle Checks
make clean            # build/ + aux entfernen
```

Pre-commit (einmalig): `pre-commit install`.
