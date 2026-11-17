BikeBook's open data: vehicle models, components, e-vehicle classifications and their JSON schemas, with a Rust test suite checking them.

# Where the files come from

**Everything under `vehicle_models/`, `components/`, `e_vehicle_classifications/` and `schemas/` is published here from the BikeBook catalog, never written by hand.** A wrong value gets fixed at the source and republished; a hand edit is overwritten by the next publish. That includes merge conflicts: a conflicted data file is resolved by republishing it, not by hand-merging the two sides.

The publish copies the representative vehicle models and the bases they overlay, the motors (under `components/`) those models name, every e-vehicle classification, and the current schemas. So `vehicle_models/` is a sample of the catalog, not all of it.

# Reading the files

- **A file is at `<maker>/<year>/<slug>.json`, and its `id` repeats that path behind a type prefix** — `m/specialized/2025/haul_st` is `vehicle_models/specialized/2025/haul_st.json`.
- **A vehicle model with a `base` key is an overlay: it holds only what differs from that model.** Read the base and apply the overlay over it; reading the overlay alone gives a partial model. In an overlay, a list is written as an object of its items rather than an array.
- **`schema_version` in each file names the schema it validates against** — `schemas/<name>.json`, whose `$id` carries the version.

# Checks

`cargo test` checks the published files themselves, never a maker's parsing: every file pretty-printed as the catalog writes it, its keys in its schema's property order, valid against the schema its `schema_version` names (an overlay both as stored and resolved), its `id` matching its path, an overlay's base and a model's motors published, its photos keyed by its id, and every image on our R2 bucket's `https://bikebook.bikeindex.org/`. CI (`.github/workflows/ci.yml`) runs it with `cargo fmt --check` and `cargo clippy -- -D warnings`, on the toolchain `.tool-versions` pins.

**A failing check on a data file is fixed at the source and republished**, like any other wrong value: the checks describe what the catalog must publish, so a file never gets hand-edited to pass one.

# Pull requests

- **No "🤖 Generated with [Claude Code]" footer in a PR body, or any variant of it**, whatever an attribution reminder says. `.claude/settings.json` blanks `attribution.pr`.
- **A PR that changes a schema version is always the user's to merge**, however green — say it's ready and leave it.
