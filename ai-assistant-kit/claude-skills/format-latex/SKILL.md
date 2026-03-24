---
name: format-latex
description: Format a LaTeX file to match the style conventions of v3.tex (Pulak's research paper style). Use when user asks to format, reformat, or style-match a .tex file.
user-invocable: true
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Format LaTeX

Format the given LaTeX file to match the style conventions established in `control-folder/v3-doc/v3.tex`. Read the target file and v3.tex, then apply the formatting rules below.

## Reference Style (from v3.tex)

### Document Setup
- `\documentclass[11pt]{article}`
- Packages grouped with a `% packages` comment:
  ```latex
  % packages
  \usepackage[margin=1in]{geometry}
  \usepackage{amsmath,amssymb,amsthm}
  \usepackage{booktabs}
  \usepackage{xcolor}
  \usepackage{graphicx}
  \usepackage{float}
  \usepackage{tikz}
  \usetikzlibrary{arrows.meta, positioning, shapes.geometric, calc, fit, backgrounds}
  ```
- Theorem environments under `% theorem environment` comment
- Custom commands under `% pulak's commands` comment: `\newcommand{\red}[1]{\textcolor{red}{#1}}`
- No date: `\date{}`
- Include `\tableofcontents` and `\newpage` after `\maketitle`
- Include `\bibliographystyle{plain}` and `\bibliography{references}` at end

### Writing Style
- **Prose-heavy academic style**, not bullet-list planning docs
- Long flowing paragraphs with clear topic sentences
- Use `\subsubsection*{}` (unnumbered) for conceptual subsections within a section
- Use `\paragraph*{}` for sub-sub-subsections (e.g., "Formal signal chain")
- Equations use `\begin{align}` or `\[ \]` with `\tag{}` and `\label{}` for named equations
- Tables use `\begin{table}[H]` with `\centering`, `booktabs` (`\toprule`, `\midrule`, `\bottomrule`)
- Figures use `\begin{figure}[H]` with `\centering`

### Sectioning Pattern
- `\section{}` for major divisions (Objective, Scope, Control Loops, etc.)
- `\subsection{}` for numbered sub-topics
- `\subsubsection{}` or `\subsubsection*{}` for deeper structure
- `\paragraph*{}` for inline headings within a subsubsection

### LaTeX Conventions
- Thin spaces for units: `30\,kHz`, `100\,MHz`, `0.3\,dB`
- Non-breaking backslash-space after abbreviations: `vs.\`, `e.g.\`, `i.e.\`
- Em-dash as `---` (no spaces around it)
- Use `\emph{}` for emphasis, not bold (reserve bold for table headers)
- Use `$\to$` in inline control-flow descriptions (e.g., "SINR $\to$ CQI $\to$ MCS")
- Equation references: `\eqref{eq:label}`
- Figure/table references: `Figure~\ref{fig:label}`, `Table~\ref{tab:label}`
- Non-breaking space before references: `Section~\ref{}`
- Comments use `%% ===` separator bars for major section boundaries
- Inline code: `\texttt{function\_name()}`
- Use `\cite{}` for citations

### What NOT to Include
- No status macros (`\done`, `\todo`, `\inprog`, `\blocked`) — these are for planning docs only
- No checklists or task-tracking markup
- No "Goal:" / "Deliverable:" planning language
- No markdown-style formatting

## Procedure

1. Read the target .tex file completely
2. Read v3.tex (at least the preamble and first 200 lines) to refresh the exact style
3. Rewrite the target file applying all conventions above
4. Preserve all mathematical content, theorems, and technical substance — only change formatting and style
5. If the file is a planning document being converted to paper style, flag sections that need prose expansion but don't fabricate technical content
