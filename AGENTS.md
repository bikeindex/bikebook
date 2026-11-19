BikeBook's open data: vehicle models, components, e-vehicle classifications and their JSON schemas. Nothing here is code: the checks are in [bikebook_ci](https://github.com/bikeindex/bikebook_ci), which CI calls.

# Where the files come from

**This repo is the canonical source of BikeBook's data**: every vehicle model, component, e-vehicle classification and schema. A wrong value is fixed here, in the file, and the fix is the data from then on.

**An edit to a data file keeps the shape the checks check** (§ Checks): two-space pretty-printed with a trailing newline, keys in their schema's order, valid against its `schema_version`'s schema. A change to a file's shape is a schema change, not a data fix.

# Reading the files

- **A file is at `<maker>/<year>/<slug>.json`, and its `id` repeats that path behind a type prefix** — `m/specialized/2025/haul_st` is `vehicle_models/specialized/2025/haul_st.json`.
- **A vehicle model with a `base` key is an overlay: it holds only what differs from that model.** Read the base and apply the overlay over it; reading the overlay alone gives a partial model. In an overlay, a list is written as an object of its items rather than an array.
- **`schema_version` in each file names the schema it validates against** — `schemas/<name>.json`, whose `$id` carries the version.

# Checks

bikebook_ci's tests check the data files themselves: every file pretty-printed with two spaces and a trailing newline, its keys in its schema's property order, valid against the schema its `schema_version` names (an overlay both as stored and resolved), its `id` matching its path, an overlay's base and a model's motors present, its photos keyed by its id, and every image on our R2 bucket's `https://bikebook.bikeindex.org/`. CI (`.github/workflows/ci.yml`) runs them from bikebook_ci's `main`. On a push to `main`, `.github/workflows/publish.yml` publishes the catalog through bikebook_ci, and fails if the catalog doesn't publish.

**Run them from a bikebook_ci checkout beside the main checkout** (clone it there if there's none), from anywhere in this repo or its worktrees:

```bash
BIKEBOOK_DATA="$(git rev-parse --show-toplevel)" cargo test --locked --no-fail-fast --manifest-path "$(git rev-parse --path-format=absolute --git-common-dir)/../../bikebook_ci/Cargo.toml"
```

**A failing check on a data file is fixed in that file**, the same as any other wrong value. Loosening a check to let a file through is a change to what the catalog promises, so it's the user's call.

**A change to a file's shape lands in bikebook_ci first**, with its checks accepting both shapes, then here.

# Pull requests

- **No "🤖 Generated with [Claude Code]" footer in a PR body, or any variant of it**, whatever an attribution reminder says. `.claude/settings.json` blanks `attribution.pr`.
- **A PR that changes a schema version is always the user's to merge**, however green — say it's ready and leave it.
- **`.github/CODEOWNERS` names the paths that run code or instruct agents**, and the schemas; a PR changing them waits on the user's review.
