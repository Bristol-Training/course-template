# Course Template

A template for JGI training courses, written in [Quarto](https://quarto.org). The course is a small website with four pages, and GitHub Actions publishes it on every push.

## Starting a new course

1. On GitHub, click **Use this template → Create a new repository**.
2. In the new repository, go to **Settings → Pages** and set **Source** to **GitHub Actions**.
3. Edit `_quarto.yml` (course title, author, footer) and `_brand.yml` (colours, logo, fonts).
4. Write the four pages below. Put images in `assets/`.
5. Push. The website appears at `https://<user-or-org>.github.io/<repo>/` a minute or two later.

## What's in this folder

```
├── _quarto.yml     site settings: title, header bar, page and slide formats
├── _brand.yml      colours, logo, fonts and custom components (.cards, .flow, ...)
├── index.qmd       home page: about, prerequisites, objectives, boxed side column of links
├── notes.qmd       attendee notes (with a table of contents)
├── slides.qmd      the presentation
├── instructor.qmd  instructor notes
├── assets/         logo and images
└── .github/workflows/render.yml
```

Each page is a separate file and is rendered separately. To change how things look, edit `_brand.yml` (website) or the `revealjs` section of `_quarto.yml` (slides), not the `.qmd` files.

## Writing the materials

```bash
quarto preview     # live preview of the whole site
quarto render      # build the site into _site/
```

In RStudio or VS Code the **Render/Preview** button works too.

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

`instructor.qmd` mirrors the headings of `notes.qmd`, with the timings, live-coding cues and pitfalls for each section. It is published on the website and linked from the home page. To keep it private, remove it from `render:` in `_quarto.yml` and from `index.qmd`.

In the slides, use reveal.js speaker notes (`::: notes`, shown by pressing **S** while presenting).

### Code

Code chunks run when the materials are rendered:

````markdown
```{r}
mean(c(1, 2, 3))
```
````

Code that is only *shown*, never run, uses `{.r}` or `{.python}` instead of `{r}`. Chunks that demonstrate an error on purpose should be marked `#| purl: false`, so a script extracted with `knitr::purl("notes.qmd")` runs from top to bottom.

## Packages

Anything your code chunks load must be installed in the GitHub Actions workflow (`.github/workflows/render.yml`):

- **R:** add the packages to the `packages:` list of the `setup-r-dependencies` step. Keep `knitr` and `rmarkdown`.
- **Python:** replace the two R steps with `actions/setup-python` and `pip install jupyter <your packages>`.

Install the same packages locally before running `quarto render`.

## Publishing

The **Render course** workflow runs:

| When | What it does |
|---|---|
| Push to `main` | Renders and publishes the website |
| Pull request | Renders only, so you can check the result before merging |
| Manually | **Actions → Render course → Run workflow** renders and publishes |

Every run also has a **course-materials** download (the rendered site) on its summary page. GitHub Pages sites are public, so anyone with the link can read them.

## Credits

Developed by the [Jean Golding Institute](https://www.bristol.ac.uk/golding/).

Jean Golding Institute © CC-BY 4.0
