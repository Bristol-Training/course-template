# Run `just` to list the available commands.
# Each one is a short wrapper around scripts/, which also work without just.

# List the available commands
default:
    @just --list

# Install the R and/or Python packages the course needs
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -f DESCRIPTION ]]; then
        Rscript -e 'if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak", repos = "https://cloud.r-project.org"); pak::local_install_deps()'
    fi
    if [[ -f requirements.txt ]]; then
        [[ -d .venv ]] || python3 -m venv .venv
        .venv/bin/pip install -r requirements.txt
    fi

# Live preview while editing: just preview, or just preview slides
preview target="notes":
    bash scripts/render.sh preview {{target}}

# Render everything into build/ and check it
build: && check
    bash scripts/render.sh all

# Render the attendee notes only
notes:
    bash scripts/render.sh notes

# Render the slides only
slides:
    bash scripts/render.sh slides

# Render the instructor guide only
instructor:
    bash scripts/render.sh instructor

# Render the website only (build/site/)
site:
    bash scripts/render.sh site

# Check the rendered outputs for missing files and leaked instructor notes
check:
    bash scripts/check.sh

# Serve the website locally at http://localhost:8000
serve:
    python3 -m http.server --directory build/site 8000

# Delete all rendered output
clean:
    rm -rf build source/.quarto source/*_files source/.render-*.html
