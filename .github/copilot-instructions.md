# ETH Physik – Formelsammlung (ZSF) · Copilot Instructions

## Projektübersicht

LaTeX-Formelsammlung für ETH Physik (Elektrizitätslehre & Optik), A4 Querformat, 4 Spalten, 8pt.
Das Dokument ist **modular** aufgebaut:
- `main.tex` — Skelett (30 Zeilen): `\documentclass` + `\input{preamble}` + `\input` je Kapitel
- `preamble.tex` — alle Pakete, Farben, Makros, Box-Definitionen, hyperref (~327 Zeilen)
- `chapters/ch00_zeichen.tex` … `chapters/ch11_quanten.tex` — je ein Kapitel als eigene Datei
Arbeitsumgebung: **macOS**, **VS Code** mit **LaTeX Workshop Extension** und **GitHub Copilot Agent**.

**Zweck:** Prüfungsvorbereitung — die Formelsammlung wird direkt in der Physikprüfung verwendet.
**Priorität:** Schnelle Auffindbarkeit und klare Übersicht haben höchste Priorität. Inhalte müssen auf einen Blick lesbar und logisch strukturiert sein.

## Kritische Regeln

- **Formeln niemals ändern, kürzen oder vereinfachen** ohne expliziten Befehl. Alle Formeln bleiben vollständig und wissenschaftlich korrekt.
- Keine neuen Packages oder Makros ohne explizite Anfrage hinzufügen.
- Stil und Struktur (Boxtypen, Farben, Abstände) konsistent mit bestehendem System halten.
- **Good Practice immer einhalten**: sauberer, lesbarer LaTeX-Code; bestehende Makros und Umgebungen konsequent nutzen statt Inline-Workarounds.
- **Modularität ist Pflicht**: Alles, was sinnvoll modular umgesetzt werden kann (Abstände, Farben, Makros, Strukturen), **muss** modular sein — über zentrale Register, Makros oder Stile in `preamble.tex`. Hardcodierte Werte direkt in Box-Definitionen oder Kapiteldateien sind verboten. Ausnahmen nur wenn Modularisierung offensichtlich sinnlos wäre — dann zuerst fragen, nicht selbst entscheiden. Explizit anders geforderte Lösungen sind natürlich erlaubt.
- **Modular denken**: Erweiterungen (neue Kapitel, Abschnitte, Boxen) so umsetzen, dass sie sich nahtlos ins bestehende System einfügen — neue Kapitel via `\StartChapter`, neue Abschnitte via `\SubsectionBar`, Inhalte in den passenden Box-Typen.
- **`multicols`-Spaltenumbrüche**: In `multicols` löst `\penalty-10000` einen **Seitenumbruch** aus (nicht nur Spaltenumbruch!) und erzeugt leere Seiten. Kapitelumbrüche immer via `\columnbreak`. `\StartChapter` und `\StartFrontChapter` nutzen dafür den Counter `zsfFirstChap` als Flag (= 1 beim ersten Kapitel → kein Break; danach `\columnbreak`).

## Modulare Philosophie — konkrete Regeln

Das Dokument folgt dem Prinzip **Single Source of Truth**: Jeder Wert existiert genau an einem Ort und wird überall referenziert — nie dupliziert.

### Was wo hingehört

| Kategorie | Ort | Mittel |
|---|---|---|
| Abstände (vor/nach Boxen, Padding, Layout) | `preamble.tex` — Block `% SPACING` | `\newlength` + `\setlength` |
| Schriftarten (Box-Typen, Titel, Notizen) | `preamble.tex` — Block `% FONTS` | `\newcommand{\ZSFfont...}` |
| Farben (Paletten, Boxhintergründe) | `preamble.tex` — Block `% COLORS` | `\definecolor` / `\colorlet` |
| Makros & Umgebungen | `preamble.tex` | `\newcommand` / `\newenvironment` |
| Inhalte | `chapters/chXX_*.tex` | Nur Box-Umgebungen, keine Stil-Befehle |

### Verboten in Kapitel-Dateien

Folgende Befehle haben in `chapters/*.tex` nichts zu suchen — sie gehören in `preamble.tex`:
- Abstände: `\vspace`, `\hspace`, `\medskip`, `\bigskip`, `\smallskip`
- Schrift direkt: `\scriptsize`, `\small`, `\large`, `\sffamily`, `\bfseries`, `\itshape`, `\textit`, `\textbf`, `\textsf`
- Layout-Hacks: `\noindent` (ausser innerhalb definierter Umgebungen), `\penalty`, `\columnbreak`

### Verboten in Box-Definitionen (`preamble.tex`)

- Hardcodierte `pt`/`em`/`mm`-Werte für Abstände → immer `\ZSFskip...` / `\ZSFpad...` Register
- Direkte Schriftbefehle → immer `\ZSFfont...` Makros
- Direkte Farb-Tints wie `ETHRot!15` → immer benannte `\colorlet`

### Neue Elemente hinzufügen

- **Neuer globaler Abstand** → Register in `% SPACING`, dann in Box-Definition referenzieren
- **Neue Schrift** → Makro in `% FONTS`, dann referenzieren
- **Neue Farbe** → `\definecolor`/`\colorlet` in `% COLORS`, dann referenzieren
- **Neues Kapitel** → via `\StartChapter` in neuer Datei `chapters/chXX_*.tex` mit `% !TEX root = ../main.tex` als erste Zeile, `\input` in `main.tex` ergänzen

## Build & Pfad-Eigenheiten

Der Workspace liegt auf dem **Desktop** (nicht iCloud). Der Pfad kann Umlaute/Leerzeichen enthalten:
- LaTeX Workshop verwendet `%DOCFILE%.tex` (relativer Pfad), **nicht** `%DOC%` oder `%TEX%`.
- `autoBuild.cleanAndRetry` ist deaktiviert — würde mit absolutem Pfad abstürzen.
- Kein Polling — nativer macOS FSEvents-Watcher ist ausreichend.
- Build-Output: `build/` (Aux- und PDF-Dateien).

**Agent-Build-Pflicht:** Agent-Tool-Edits schreiben direkt ins Filesystem, ohne VS Code Editor-Save-Event → LaTeX Workshop Auto-Build wird **nicht** getriggert. Nach jedem Edit immer manuell bauen:
```
latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf -outdir=build -auxdir=build main.tex
```

## Benutzer-Kurzbezeichnungen für Balken/Titel

Der Nutzer verwendet folgende Kurzformen — immer korrekt zuordnen:

| Kurzform | Auch genannt | LaTeX | Beschreibung |
|---|---|---|---|
| **tit1** | Titel1 | `\StartChapter{...}` → `chapterbar` | Hauptkapitel-Balken (volle Kapitelfarbe) |
| **tit2** | Titel2 | `\SubsectionBar{...}` → `subsectionbar` | Unterkapitel-Balken (75% Kapitelfarbe) |
| **tit3** | Titel3 | `\begin{defbox}[...]` → `zsftitlebox` | Definitionsbox mit farbigem Titelstreifen |

## Dokumentstruktur

| Makro | Verwendung |
|---|---|
| `\StartFrontChapter{Titel}` | Kapitel ohne Nummerierung (z.B. Zeichen & Einheiten) |
| `\StartChapter{Titel}` | Kapitel mit auto-Nummerierung + Farbpalette |
| `\SubsectionBar[label]{Titel}` | Nummerierter Abschnitt mit farbigem Balken |
| `\SubsectionBar*[label]{Titel}` | Unnummerierter Abschnitt |

## Kapitelstruktur (Kap. 0–11)

| Kap. | Titel |
|---|---|
| 0 | Zeichen & Einheiten (SI) + Wichtige Formeln |
| 1 | Elektrisches Feld |
| 2 | Elektrisches Potenzial und Energie |
| 3 | Kapazität und Dielektrika |
| 4 | Gleichstromkreise |
| 5 | Magnetfeld |
| 6 | Elektromagnetische Induktion |
| 7 | Wechselstromkreise |
| 8 | Maxwell-Gleichungen & EM-Wellen |
| 9 | Wellenoptik |
| 10 | Geometrische Optik |
| 11 | Einführung in die Quantenphysik |

## Box-Typen

| Umgebung | Verwendung |
|---|---|
| `formulabox` | Farbig hinterlegte Formel-Box (Hauptinhalt) |
| `defbox[Titel]` | Definition mit farbigem Titelbalken |
| `warnbox[Titel]` | Rot hinterlegter Hinweis (ETH-Rot) |
| `tablebox[Titel]` | Tabellenbox mit farbigem Titel |
| `figbox[Titel]` | Grafikbox mit farbigem Titel |
| `runintext` | Fließtext zwischen Boxen (kein Einzug) |
| `longformula` | Mehrzeilige Formel (`aligned`) |

## Hilfs-Makros

| Makro | Verwendung |
|---|---|
| `\formulanote{...}` | Kursive Erklärung unter Formel in `formulabox` |
| `\formulanoteabove{...}` | Wie `\formulanote`, aber oberhalb |
| `\PlaceholderGraphic{Beschreibung}` | Platzhalter für noch fehlende Grafiken |
| `\vect{x}` | Vektor-Notation (`\vec{x}`) |
| `\sgn` | Signum-Operator |

## Farbpaletten-System

Kapitelfarben werden automatisch per `\SetChapterPaletteByNumber` gesetzt (Rainbow: Grün → Orange → Rot → Blau → Lila). Manuell überschreibbar mit `\SetChapterPalette{elektro|magneto|maxwell|optik}`.

## Abstands-System

Alle Abstände zentral in `preamble.tex` im Block `% SPACING — zentrale Stellschrauben` als `\newlength`-Register definiert. **Nie** hardcodierte `pt`-Werte in Box-Definitionen schreiben — immer Register verwenden.

| Register | Bedeutung | Standardwert |
|---|---|---|
| `\ZSFcolumnsep` | Abstand zwischen Spalten | 4pt |
| `\ZSFmulticolsep` | Vertikaler Rand multicols | 5pt |
| `\ZSFemergencystretch` | Notfall-Streckung Zeilenumbruch | 2em |
| `\ZSFskipChapterBefore` | Abstand VOR Kapitelbalken | 2pt |
| `\ZSFskipChapterAfter` | Abstand NACH Kapitelbalken | 4pt |
| `\ZSFskipSectionBefore` | Abstand VOR Abschnittsbalken | 14pt |
| `\ZSFskipSectionAfter` | Abstand NACH Abschnittsbalken | 3pt |
| `\ZSFskipBoxBefore` | Abstand VOR formulabox/defbox/warnbox/etc. | 2pt |
| `\ZSFskipBoxAfter` | Abstand NACH formulabox/defbox/warnbox/etc. | 2pt |
| `\ZSFbreakThreshold` | Mindesthöhe für `\BreakIfNotEnoughSpace` | 8\baselineskip |
| `\ZSFpadInnerH` | left/right-Padding alle Boxen | 2pt |
| `\ZSFpadInnerV` | top/bottom-Padding formulabox/subsectionbar/def | 2pt |
| `\ZSFpadChapterV` | top/bottom-Padding Kapitelbalken | 3pt |
| `\ZSFpadDefH` | left/right-Padding defbox | 3pt |
| `\ZSFparskipInBox` | `\parskip` innerhalb Boxen | 1pt |
| `\ZSFformulanoteSkip` | `\vspace` in `\formulanote` | 0.5pt |

## Schrift-System

Alle Box-Schriften zentral in `preamble.tex` im Block `% FONTS` als Makros definiert. **Nie** Schriftbefehle direkt in Box-Definitionen schreiben — immer Makros verwenden.

| Makro | Verwendung | Wert |
|---|---|---|
| `\ZSFfontChapter` | Kapitelbalken | `\sffamily\bfseries\small` |
| `\ZSFfontSection` | Abschnittsbalken | `\sffamily\scriptsize` |
| `\ZSFfontBoxTitle` | Titel defbox/tablebox/figbox/warnbox | `\sffamily\scriptsize\bfseries` |
| `\ZSFfontNote` | `\formulanote` / `\formulanoteabove` | `\scriptsize\itshape` |

## siunitx-Konventionen

- Dezimaltrennzeichen: Komma (`output-decimal-marker = {,}`)
- Einheiten: `\si{...}`, Zahlenwert+Einheit: `\SI{...}{...}`
- Einheitenbrüche: `per-mode = symbol`
