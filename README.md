# Course Template

A template for JGI training courses: course notes and slides written in [Quarto](https://quarto.org), with R or Python code that runs when the materials are rendered. GitHub Actions builds everything and publishes the course website on every push.

## Starting a new course

1. On GitHub, click **Use this template → Create a new repository**.
2. In the new repository, go to **Settings → Pages** and set **Source** to **GitHub Actions**.
3. Edit `source/_quarto.yml`: course title, subtitle and author.
4. List the packages your code uses (see [Packages](#packages)), and delete the file for the language you don't use.
5. Write `source/notes.qmd` and `source/slides.qmd` (put images in `source/assets/`).
6. Push. The website appears at `https://<user-or-org>.github.io/<repo>/` a minute or two later.

## What's in this folder

```
├── source/                 everything you edit
│   ├── _quarto.yml         course settings (title, author, ...)
│   ├── notes.qmd           the course notes
│   ├── slides.qmd          the slides
│   ├── styles.scss         notes styling
│   ├── slides.scss         slide theme
│   ├── assets/             logo and images
│   └── filters/            instructor-notes machinery (no need to edit)
├── DESCRIPTION             R packages the course needs
├── requirements.txt        Python packages the course needs
├── justfile                shortcuts for rendering locally
├── scripts/                the rendering scripts used by just and GitHub Actions
├── .github/workflows/      the GitHub Actions workflow
└── build/                  rendered output (created by `just build`, not committed)
```

Day to day you only touch `source/` and, when you add a package, `DESCRIPTION` or `requirements.txt`.

## What gets built

| File | Who it's for |
|---|---|
| **Website** (`build/site/`) | **Everyone**: the one link to send out. The attendee notes with the slides embedded at the top |
| `notes.html` | Attendees: the full notes without instructor notes, as one file you can email or upload to a VLE |
| `slides.html` | The presenter |
| `instructor-guide.html` | The delivery team: just the instructor notes, under the same numbered headings as the notes |

Every file is self-contained (images and styles embedded), so any of them can be sent on as it is.

**Getting the files:** every GitHub Actions run has a **course-materials** download on its summary page (**Actions** tab → latest *Render course* run → *Artifacts*). Locally, `just build` puts them in `build/`.

The instructor guide is not on the public website unless you set `publish-instructor-guide: true` in `source/_quarto.yml`.

## Writing the materials

Preview while you edit: the page refreshes in your browser every time you save.

```bash
just preview          # notes (with instructor notes shown inline)
just preview slides
```

Without `just`, run `quarto preview source/notes.qmd`. In RStudio or VS Code, the **Render/Preview** button works too.

### Exercises, answers and key points

```markdown
::: {#exercise1 .callout-note icon=false title='Exercise'}
The exercise (one at the end of each section).
:::

::: {#answer1 .callout-caution icon=false title='Answer' collapse="true"}
The answer (collapsed by default).
:::

::: {#keypoints1 .callout-tip icon=false title='Key points'}
Important concepts.
:::
```

### Instructor notes

Put instructor notes right next to the content they are about:

```markdown
::: {.instructor}
**Live code:** ...

**Pitfalls:** ...
:::
```

That's all. They show as red boxes while you preview, are removed from everything attendees see, and are gathered into `instructor-guide.html`. The build fails if one ever leaks into the attendee notes.

In the slides, use reveal.js speaker notes instead (`::: notes`, shown by pressing **S** while presenting).

### The website landing block

The block at the top of `notes.qmd` inside `::: {.content-visible when-meta="site"}` only appears on the website: the embedded slides and the *Course materials* cards. Edit the cards to link to whatever suits your course.

### Title and author

These are set once in `source/_quarto.yml` and shared by the notes and slides. Anything set in a `.qmd` file's own header overrides them (the slides use this to set their own subtitle).

### Code

Code chunks run when the materials are rendered:

````markdown
```{r}
mean(c(1, 2, 3))
```
````

For a Python course, use `{python}` chunks instead. Quarto then runs them with Jupyter. (Mixing R and Python in one document needs `reticulate` added to `DESCRIPTION`.)

Code that is only *shown*, never run, uses `{.r}` or `{.python}` instead of `{r}`.

Chunks that demonstrate an error on purpose should be marked `#| purl: false`, so that a script extracted with `knitr::purl("notes.qmd")` runs from top to bottom.

## Packages

Any package your code chunks load must be listed, so that GitHub Actions (and `just setup`) can install it.

**R:** add it under `Imports:` in `DESCRIPTION`, one per line, each followed by a comma except the last:

```
Imports:
    knitr,
    rmarkdown,
    tidyverse
```

Keep `knitr` and `rmarkdown`: Quarto needs them to run R code.

**Python:** add it to `requirements.txt`, one per line. Keep `jupyter`: Quarto needs it to run Python code.

```
jupyter
pandas
```

GitHub Actions only installs R if `DESCRIPTION` exists, and only installs Python if `requirements.txt` exists. Delete the one you don't need so every build doesn't install a language your course doesn't use.

## Rendering locally

You need [Quarto](https://quarto.org/docs/get-started/), [just](https://just.systems/man/en/packages.html), and R and/or Python. Then:

```bash
just setup     # install the course's R/Python packages (Python goes into .venv/)
just build     # render everything into build/ and check it
just serve     # view the website at http://localhost:8000
```

Run `just` to see every command, e.g. `just notes`, `just slides` or `just instructor` to rebuild a single output, or `just clean` to delete `build/`.

`just setup` puts Python packages in a `.venv/` folder, and the `just` commands use it automatically. If you run `quarto` yourself instead, activate it first (`source .venv/bin/activate`).

`build/` is not committed to git. GitHub Actions builds the published copy.

## Publishing

The **Render course** workflow (`.github/workflows/render.yml`) runs:

| When | What it does |
|---|---|
| Push to `main` | Renders, checks and publishes the website |
| Pull request | Renders and checks only, so you can see the result before merging |
| Manually | **Actions → Render course → Run workflow** renders and publishes |

GitHub Pages sites are public, so anyone with the link can read them.

If a run fails, open it in the **Actions** tab: the *Render* step shows Quarto's error (usually a code chunk that failed or a package missing from `DESCRIPTION`/`requirements.txt`), and the *Check* step says if instructor notes leaked.

## How it works

You don't need this to write a course, but it helps if you're maintaining the template.

- `scripts/render.sh` runs `quarto render` once per output, passing a `mode` setting: `attendee` (notes and website), `instructor` (guide) or nothing (preview, showing everything). It also passes `site` for the website, which shows the landing block. Each file is rendered in `source/` and moved into `build/`.
- `source/filters/instructor.lua` reads `mode` and either shows the `.instructor` blocks as red boxes, removes them, or keeps *only* them and their headings.
- `scripts/check.sh` confirms every output exists and that no instructor notes appear in the attendee files.
- The `justfile` and the GitHub Actions workflow both just call these two scripts.

## Credits

Developed by the [Jean Golding Institute](https://www.bristol.ac.uk/golding/).

Jean Golding Institute © CC-BY 4.0
