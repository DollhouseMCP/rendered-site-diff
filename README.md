# VisiDelta

A visual old-vs-new diff tool for static websites.

It builds two versions of a site (`base` and `current`), then serves a browser UI for page-by-page rendered comparison with:

- Split and single-pane viewing
- Sidebar navigation across changed pages
- Add / delete / moved highlighting toggles
- Fuzzy moved-line detection to reduce false positives

## Why this exists

Git diffs are great for source-level review, but website changes often need rendered review. This tool gives you a fast workflow for that.

## Requirements

- `git`
- `docker` (default build path)
- `python3` (for local preview server)

## Quick start

Run from any repository you want to review (Jekyll default):

```bash
/path/to/visidelta/scripts/visidelta.sh origin/main /tmp/site-diff serve .
```

Open:

- `http://127.0.0.1:4310`

## GitHub Action quick start

Use VisiDelta directly in workflows:

```yaml
- uses: DollhouseMCP/visidelta@main
  with:
    base_ref: origin/main
    out_dir: /tmp/visidelta
    mode: build
```

For non-Jekyll projects, pass custom build commands:

```yaml
- uses: DollhouseMCP/visidelta@main
  with:
    base_ref: origin/main
    out_dir: /tmp/visidelta
    mode: build
    build_old_cmd: npm ci && npm run build && cp -R dist/. "$DEST_DIR"
    build_new_cmd: npm ci && npm run build && cp -R dist/. "$DEST_DIR"
```

## One-command local launcher

Install the launcher once:

```bash
./scripts/install-local-launcher.sh
```

Then run from any repo:

```bash
visidelta
```

Or target a specific repo path:

```bash
visidelta /path/to/repo
```

## Usage

```bash
visidelta.sh [BASE_REF] [OUT_DIR] [MODE] [TARGET_REPO]
```

- `BASE_REF`: Git ref to compare against (default `origin/main`)
- `OUT_DIR`: output directory for generated diff site (default `/tmp/visidelta`)
- `MODE`: `build` or `serve` (default `build`)
- `TARGET_REPO`: repo path to diff (default `.`)

## Action inputs

- `base_ref`: compare base ref (default `origin/main`)
- `out_dir`: output directory (default `/tmp/visidelta`)
- `mode`: `build` or `serve` (default `build`)
- `target_repo`: target repository path (default `.`)
- `build_old_cmd`: optional custom base build command
- `build_new_cmd`: optional custom current build command
- `extra_exclude_globs`: extra file globs to exclude from route list
- `port`: serve port when `mode=serve` (default `4310`)

## Custom build commands

For non-Jekyll sites, pass build commands with env vars:

```bash
BUILD_OLD_CMD='npm ci && npm run build && cp -R dist/. "$DEST_DIR"' \
BUILD_NEW_CMD='npm ci && npm run build && cp -R dist/. "$DEST_DIR"' \
./scripts/visidelta.sh origin/main /tmp/site-diff serve /path/to/repo
```

Available env vars inside build commands:

- `SRC_DIR`
- `DEST_DIR`
- `BASEURL` (`/old` or `/new`)

## Notes

- Changed pages are inferred from changed `*.md` files by default.
- Excludes include `README.md`, `LICENSE`, `docs/*`, `scripts/*`, `.github/*`.
- Add extra excludes with `EXTRA_EXCLUDE_GLOBS`.

## CI

- `shellcheck` runs against all shipped shell scripts.
- A smoke test creates a temporary git fixture repo and validates generated output.

## GitHub Pages

Yes, but with one constraint: VisiDelta itself is a build-time tool, so GitHub Pages can host generated output for a specific run, not run comparisons dynamically in-browser.

Typical setup:

1. Run VisiDelta in CI for a target repo/branch pair.
2. Publish the generated `/tmp/visidelta` output as a Pages artifact.
3. Browse static compare output on Pages.

An example workflow is included at [`docs/examples/pages-preview.yml`](docs/examples/pages-preview.yml).

## License

AGPL-3.0-or-later.
