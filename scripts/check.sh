#!/usr/bin/env bash
# Check the rendered outputs in build/: every file exists, and no
# instructor notes have leaked into anything attendees will see.
set -euo pipefail
cd "$(dirname "$0")/.."

status=0
fail() {
    echo "FAIL: $*" >&2
    status=1
}

for f in build/notes.html build/slides.html build/instructor-guide.html \
         build/site/index.html build/site/slides.html; do
    [[ -s $f ]] || fail "$f is missing or empty (run: just build)"
done

# The instructor filter wraps every note in a div with this class
marker='class="instructor-note"'

for f in build/notes.html build/site/index.html; do
    if [[ -f $f ]] && grep -q "$marker" "$f"; then
        fail "$f contains instructor notes"
    fi
done

if [[ -f build/instructor-guide.html ]] && ! grep -q "$marker" build/instructor-guide.html; then
    fail "build/instructor-guide.html has no instructor notes (are they in ::: {.instructor} blocks?)"
fi

if [[ $status -eq 0 ]]; then
    echo "All checks passed."
    ls -lh build/*.html build/site/*.html
fi
exit $status
