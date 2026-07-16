# Slides

Week 1 slides live in `week1-slides.md` — written in **Marp** (Markdown Presentation).

## How to view / export

### Option 1 — VS Code (easiest)
1. Install the **Marp for VS Code** extension.
2. Open `week1-slides.md`.
3. Click the Marp preview icon (top-right of the editor).
4. Export via the command palette: `Marp: Export slide deck...` → PDF / PPTX / HTML.

### Option 2 — CLI
```bash
npm install -g @marp-team/marp-cli

# Preview in browser (auto-reload)
marp --server .

# Export
marp week1-slides.md -o week1-slides.pdf
marp week1-slides.md -o week1-slides.pptx
marp week1-slides.md -o week1-slides.html
```

## Editing tips
- Slides are separated by `---` on its own line.
- `<!-- _class: lead -->` = centered title slide.
- Change the theme by editing the front-matter (`theme: default | gaia | uncover`).
- All styling is in the `style:` block at the top of the file.
