#!/usr/bin/env bash
# Render the course materials into build/.
#
#   scripts/render.sh [all|notes|slides|instructor|site]   (default: all)
#   scripts/render.sh preview [notes|slides]                live preview while editing
#
# Outputs:
#   build/notes.html              attendee notes (instructor notes removed)
#   build/slides.html             revealjs slides
#   build/instructor-guide.html   only the instructor notes, under their headings
#   build/site/                   the GitHub Pages website (index.html + slides.html)
set -euo pipefail
cd "$(dirname "$0")/.."

# Use the project's Python virtual environment if there is one (created by `just setup`)
if [[ -d .venv ]]; then
    export PATH="$PWD/.venv/bin:$PATH"
fi

mkdir -p build

# Quarto writes its output next to the .qmd, so render there and move it into build/
render_to() {
    local input=$1 output=$2
    shift 2
    local tmp=".render-$(basename "$output")"
    echo "==> Rendering $output"
    (cd source && quarto render "$input" --output "$tmp" "$@")
    mkdir -p "$(dirname "$output")"
    mv "source/$tmp" "$output"
}

notes() {
    render_to notes.qmd build/notes.html -M mode:attendee
}

slides() {
    render_to slides.qmd build/slides.html
}

instructor() {
    render_to notes.qmd build/instructor-guide.html -M mode:instructor --no-execute
}

site() {
    render_to notes.qmd build/site/index.html -M mode:attendee -M site:true
    [[ -f build/slides.html ]] || slides
    cp build/slides.html build/site/slides.html
    if grep -Eq '^publish-instructor-guide:[[:space:]]*true' source/_quarto.yml; then
        [[ -f build/instructor-guide.html ]] || instructor
        cp build/instructor-guide.html build/site/instructor-guide.html
    else
        rm -f build/site/instructor-guide.html
    fi
    touch build/site/.nojekyll  # serve the files as they are, no Jekyll processing
}

all() {
    notes
    slides
    instructor
    site
}

preview() {
    quarto preview "source/${1:-notes}.qmd"
}

target=${1:-all}
case $target in
    all | notes | slides | instructor | site) "$target" ;;
    preview) preview "${2:-notes}" ;;
    *)
        echo "Unknown target '$target'. Use: all, notes, slides, instructor, site or preview" >&2
        exit 1
        ;;
esac
