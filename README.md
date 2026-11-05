# Course Template

A template for JGI training courses, written in [Quarto](https://quarto.org). The course is a small website with four pages. You render it on your own computer into the `docs/` folder, and GitHub Pages publishes that folder.

## Starting a new course

1. On GitHub, click **Use this template → Create a new repository**, then clone it.
2. Edit `_quarto.yml` (course title, author, footer) and `_brand.yml` (colours, logo, fonts).
3. Write the four pages below. Put images in `assets/`.
4. Run `quarto render`, then commit and push, including the `docs/` folder.
5. Set up GitHub Pages once (see [Publishing](#publishing)).
6. Trim this README down to a short description of the course plus the sections from [Building the course locally](#building-the-course-locally) onwards.

## What's in this folder

```
├── _quarto.yml     site settings: title, header bar, page and slide formats
├── _brand.yml      colours, logo and fonts
├── custom.scss     custom styles for the site and slides (.cards, .flow, ...)
├── index.qmd       home page: about, prerequisites, objectives, boxed side column of links
├── notes.qmd       attendee notes (with a table of contents)
├── slides.qmd      the presentation
├── instructor.qmd  instructor notes
├── assets/         logo and images
├── .nojekyll       tells GitHub Pages not to run Jekyll (copied into docs/)
└── docs/           the rendered website (created by quarto render, commit it)
```

Each page is a separate file and is rendered separately. To change how things look, edit `custom.scss` (website and slides styles) or `_brand.yml` (palette), not the `.qmd` files.

## Writing the materials

```bash
quarto preview     # live preview of the whole site
quarto render      # build the site into docs/
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

Code chunks run when the materials are rendered, in R or Python:

````markdown
```{r}
mean(c(1, 2, 3))
```

```{python}
sum([1, 2, 3]) / 3
```
````

Use one language per page. Quarto runs a page with R if it has any `{r}` chunks, otherwise with Python.

Code that is only *shown*, never run, uses `{.r}` or `{.python}` instead of `{r}`. Chunks that demonstrate an error on purpose should be marked `#| purl: false`, so a script extracted with `knitr::purl("notes.qmd")` runs from top to bottom.

## Packages

The site is rendered on your computer, so you need the same setup as the attendees, plus `knitr` and `rmarkdown` for R code or `jupyter` for Python code.

## Publishing

### Set up GitHub Pages (once per course)

1. Render the site and push it, so the `docs/` folder is on GitHub:

   ```bash
   quarto render
   git add docs
   git commit -m "Render site"
   git push
   ```

2. On GitHub, go to **Settings → Pages**.
3. Under **Build and deployment**, set **Source** to **Deploy from a branch**.
4. Set **Branch** to `main` and the folder to `/docs`, then click **Save**.

After a minute or two the website is at `https://<user-or-org>.github.io/<repo>/`. The address is also shown at the top of the Pages settings.

### Updating the website

GitHub only publishes what is in `docs/`, so after changing the materials:

```bash
quarto render
git add -A
git commit -m "Update materials"
git push
```

If you push changes to the `.qmd` files without running `quarto render`, the website keeps showing the old version. Run a full `quarto render` before committing, so every page in `docs/` is up to date.

GitHub Pages sites are public, so anyone with the link can read them.

<!--
  Course builders: keep everything from "Building the course locally" down to
  the end of the file in your course README and replace <user-or-org>/<repo>.
  Delete the template sections above it and write a short description of your
  course instead.
-->

## Building the course locally

You need [Quarto](https://quarto.org/docs/get-started/) and the software from the course's setup instructions, plus `knitr` and `rmarkdown` for R code or `jupyter` for Python code.

Then:

```bash
git clone https://github.com/<user-or-org>/<repo>.git
cd <repo>
quarto preview
```

`quarto preview` opens the course in your browser and reloads it whenever you save a `.qmd` file.

## Contributing

Corrections and suggestions are welcome.

**Spotted a problem?** [Open an issue](https://github.com/<user-or-org>/<repo>/issues) saying which page and section it's in.

**Small fix, like a typo?** Open the `.qmd` file on GitHub, click the pencil icon (**Edit this file**), make the change and click **Propose changes**. GitHub makes a copy of the repository for you and opens a pull request.

**Bigger change?**

1. Fork the repository on GitHub and clone your fork.
2. Create a branch: `git checkout -b my-change`.
3. Edit the `.qmd` files and check the result with `quarto preview`.
4. Commit and push your branch, then open a pull request on GitHub describing what you changed and why.

Only commit the `.qmd` files (and any new images in `assets/`), not the `docs/` folder. The maintainer re-renders the website after merging.

## Credits

Developed by the [Jean Golding Institute](https://www.bristol.ac.uk/golding/).

Jean Golding Institute © CC-BY 4.0
