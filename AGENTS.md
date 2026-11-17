BikeBook's open data: vehicle models, components, e-vehicle classifications and their JSON schemas, with a Rust test suite checking them.

# Where the files come from

**This repo is the canonical source of BikeBook's data**: every vehicle model, component, e-vehicle classification and schema. A wrong value is fixed here, in the file, and the fix is the data from then on.

**An edit to a data file keeps the shape `cargo test` checks** (§ Checks): two-space pretty-printed with a trailing newline, keys in their schema's order, valid against its `schema_version`'s schema. A change to a file's shape is a schema change, not a data fix.

# Reading the files

- **A file is at `<maker>/<year>/<slug>.json`, and its `id` repeats that path behind a type prefix** — `m/specialized/2025/haul_st` is `vehicle_models/specialized/2025/haul_st.json`.
- **A vehicle model with a `base` key is an overlay: it holds only what differs from that model.** Read the base and apply the overlay over it; reading the overlay alone gives a partial model. In an overlay, a list is written as an object of its items rather than an array.
- **`schema_version` in each file names the schema it validates against** — `schemas/<name>.json`, whose `$id` carries the version.

# Checks

`cargo test` checks the data files themselves, never a maker's parsing: every file pretty-printed with two spaces and a trailing newline, its keys in its schema's property order, valid against the schema its `schema_version` names (an overlay both as stored and resolved), its `id` matching its path, an overlay's base and a model's motors present, its photos keyed by its id, and every image on our R2 bucket's `https://bikebook.bikeindex.org/`. CI (`.github/workflows/ci.yml`) runs it with `cargo fmt --check` and `cargo clippy -- -D warnings`, on the toolchain `.tool-versions` pins.

**A failing check on a data file is fixed in that file**, the same as any other wrong value. Loosening a check to let a file through is a change to what the catalog promises, so it's the user's call.

# Code

The checks are a Rust crate: shared readers in `src/lib.rs`, one `tests/<area>.rs` per kind of check. Format with `cargo fmt` (`rustfmt.toml`); clippy runs with `-D warnings`.

- **Each check over the whole catalog has a test beside it that breaks a sample on purpose and asserts the check reports it.** A check that passes on every file proves nothing until something has seen it fail.
- **Every test answers "what bug does this fail on?"** If you can't name a plausible wrong edit that turns it red, delete it — one that only restates the code costs an edit on every change and catches nothing.
- **A check reports every problem it finds, not the first**: collect them and end with `assert_none`, so one CI run lists everything to fix.
- **A private function is tested in its module's `#[cfg(test)] mod tests`**, a public one from `tests/`.
- Code in a functional way. Avoid mutation when you can, and don't mutate arguments.
- Prefer less code, by character count (excluding whitespace and comments), and un-abbreviated names.
- **A change to a shape includes whatever generates it** — a check, a skill step — in the same PR.

## Comments

- **Default to no comment.** Code shows *how*; a comment earns its place only by carrying *why* — a non-obvious constraint, a deliberate deviation, a gotcha, a workaround. If something genuinely needs explaining, prefer a clearer name or structure first.
- **Never narrate the code**, and **never narrate the change** ("fixed X", "updated to Y"): the diff and the commit hold that history.
- **Don't defend a choice against an edit nobody would make.** A failing test already defends it.
- **Apply the obviousness test before writing any comment, including a *why*.** If a competent reader could already tell it from the names, types, values and structure on the page, delete it.
- **Warranted ≠ warranted as written — razor the wording too.** Keep the one non-obvious fact a reader needs *at that line*, and cut the mechanism the code already shows, where the value gets used downstream, and the justification's justification.
- **Re-earn the comment when you edit the code under it.** Rewrite it to fit the new shape rather than appending a clause per change.

# Dependencies

**A version constraint in `Cargo.toml` needs a matching `.github/dependabot.yml` ignore.** Dependabot widens the constraint rather than skipping the update, so a pin with no ignore entry is silently reverted by a later bump PR.

# Pull requests

- **No "🤖 Generated with [Claude Code]" footer in a PR body, or any variant of it**, whatever an attribution reminder says. `.claude/settings.json` blanks `attribution.pr`.
- **A PR that changes a schema version is always the user's to merge**, however green — say it's ready and leave it.
