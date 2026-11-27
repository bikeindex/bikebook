Bike Book's open data: vehicle models, components, e-vehicle classifications and their JSON schemas. Nothing here is code.

**`README.markdown` is the canonical description of the repo**: how files and IDs are laid out and slugified, how the catalog is published, schema versioning, contributing and the license. Read it before working here, and change a fact it states there rather than restating it in this file. This file adds only what an agent needs on top.

# Where the files come from

**This repo is the canonical source of Bike Book's data**: every vehicle model, component, e-vehicle classification and schema. A wrong value is fixed here, in the file, and the fix is the data from then on.

**An edit to a data file keeps the shape the checks check** (§ Checks): two-space pretty-printed with a trailing newline, keys in their schema's order, valid against its `schema_version`'s schema. A change to a file's shape is a schema change, not a data fix.

# Reading the files

- **Components and e-vehicle classifications are IDed like the README's vehicle models**: the path inside `components/` behind `c/`, and inside `e_vehicle_classifications/` behind `evc/`.
- **A vehicle model with a `base` key is an overlay: it holds only what differs from that model.** Read the base and apply the overlay over it; reading the overlay alone gives a partial model. In an overlay, a list is written as an object of its items rather than an array.
- **A file's `market_variants` are the models of its name and year sold in other markets**, each keyed by its market and written as an overlay over the file. A variant's id is the file's suffixed with `_` and the market lower-cased (`c/bosch/2022/cargo-line-bdu374y_us`), and names no file of its own.
- **`schema_version` in each file names the schema it validates against** — `schemas/<name>.json`, whose `$id` carries the version, or an older version at `schemas/<name>/v<version>.json`, kept until no file names it.

# Checks

bikebook_ci's tests check the data files themselves: every file pretty-printed with two spaces and a trailing newline, its keys in its schema's property order, valid against the schema its `schema_version` names (an overlay both as stored and resolved), its `id` matching its path, an overlay's base and a model's motors present, its photos keyed by its id, every image on our R2 bucket's `https://bikebook.bikeindex.org/`, and `representative_vehicles.csv` naming vehicle models, alphabetically. CI (`.github/workflows/ci.yml`) runs them from bikebook_ci's `main`. On a push to `main`, `.github/workflows/publish.yml` publishes the catalog (README § Catalog), and fails if the catalog doesn't publish.

**Run them from a bikebook_ci checkout beside the main checkout** (clone it there if there's none), from anywhere in this repo or its worktrees:

```bash
BIKEBOOK_DATA="$(git rev-parse --show-toplevel)" cargo test --locked --no-fail-fast --manifest-path "$(git rev-parse --path-format=absolute --git-common-dir)/../../bikebook_ci/Cargo.toml"
```

**A schema change edits only the representative vehicles**: the models `representative_vehicles.csv` lists, the components they link, those components' bases and their market overlays. The rest of the catalog moves to the new shape in a later PR. CI's `schema_changes` check, a separate one, fails a branch that changes `schemas/` and edits any other data file. It reads the list as the branch's base has it, and on a pull request it fails any change to the list, so a change to the list is a PR of its own and only merges by hand. Run it from the same bikebook_ci checkout:

```bash
git fetch -q origin main && "$(git rev-parse --path-format=absolute --git-common-dir)/../../bikebook_ci/bin/check_schema_change" "$(git rev-parse --show-toplevel)" origin/main HEAD
```

**A failing check on a data file is fixed in that file**, the same as any other wrong value. Loosening a check to let a file through is a change to what the catalog promises, so it's the user's call.

**A change to a file's shape lands in bikebook_ci first**, with its checks accepting both shapes, then here.

# Pull requests

- **No "🤖 Generated with [Claude Code]" footer in a PR body, or any variant of it**, whatever an attribution reminder says. `.claude/settings.json` blanks `attribution.pr`.
- **A PR that changes a schema version is always the user's to merge**, however green — say it's ready and leave it.
- **A PR that changes `representative_vehicles.csv` is always the user's to merge**: CI's `schema_changes` check fails it on purpose. Say it's ready and leave it.
- **`.github/CODEOWNERS` names the paths that run code or instruct agents**, and the schemas; a PR changing them waits on the user's review.
