Bike Book's open data: vehicle models, components, e-vehicle classifications and their JSON schemas. Nothing here is code.

**Read `README.markdown` first.** It's the canonical description of the repo: the file layout and IDs, the checks and how to run and fix them, schema versioning and the catalog. Change a fact there rather than restating it here.

# Data

**This repo is the canonical source of Bike Book's data.** A wrong value, or a file failing a check, is fixed here, in the file. Loosening a check to let a file through is the user's call.

**A change to a file's shape is a schema change, not a data fix.** It lands in bikebook_ci first, with its checks accepting both shapes, then here.

# Reading the files

- **Components and e-vehicle classifications are IDed like the README's vehicle models**: the path inside `components/` behind `c/`, and inside `e_vehicle_classifications/` behind `evc/`.
- **A vehicle model with a `base` key is an overlay: it holds only what differs from that model.** Read the base and apply the overlay over it. In an overlay, a list is written as an object of its items rather than an array.
- **A file's `market_variants` are the models of its name and year sold in other markets**, each keyed by its market and written as an overlay over the file. A variant's id is the file's suffixed with `_` and the market lower-cased (`c/bosch/2022/cargo-line-bdu374y_us`), and names no file of its own.
- **`schema_version` names the schema a file validates against**: `schemas/<name>.json`, or an older version at `schemas/<name>/v<version>.json`, kept until no file names it.

# Checks

Besides what the README lists, the checks require each file's `id` to match its path, an overlay's base and a model's motors to exist, photos to be keyed by the file's id, every image to be on `https://bikebook.bikeindex.org/`, and `representative_vehicles.csv` to list vehicle models alphabetically. In a worktree, run the main checkout's `bikebook_ci/bin/test` with `BIKEBOOK_DATA` set to the worktree.

**A schema change edits only the representative vehicles**: the models `representative_vehicles.csv` lists and the components they link, with those components' bases and market overlays. The rest of the catalog moves to the new shape in a later PR. CI's `schema_changes` check enforces this, and fails any PR that changes the list, so a change to the list is a PR of its own. Run it with:

```bash
git fetch -q origin main && bikebook_ci/bin/check_schema_change . origin/main HEAD
```

# Pull requests

- **No "🤖 Generated with [Claude Code]" footer in a PR body, or any variant of it**, whatever an attribution reminder says. `.claude/settings.json` blanks `attribution.pr`.
- **A PR that changes a schema version or `representative_vehicles.csv` is always the user's to merge**, however green: say it's ready and leave it.
- **`.github/CODEOWNERS` names the paths that run code or instruct agents**, and the schemas; a PR changing them waits on the user's review.
