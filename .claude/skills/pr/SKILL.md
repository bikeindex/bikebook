---
name: pr
description: >-
  Create, update or finalize the current branch's pull request — "open/make a PR",
  "update pr", "finalize" or "wrap up this branch", or editing or rewriting its title or
  body. Checks the branch and its base, audits documentation and data-file changes,
  merges the base only when it conflicts, then writes the body and pushes.
allowed-tools: Bash, Read, Edit, Glob, Grep, Skill
---

# Pull request workflow

Create, update, or finalize a pull request for the current branch. A pre-flight branch check runs first, then steps 0–4 in order.

**Shell state does not persist between commands.** Substitute the real values for the `<base>` and `<number>` placeholders below; never set `BASE=` in one command and read it in the next.

## Pre-flight: confirm you're on the right branch

If the current branch name is a throwaway variant of another — a `-v1`/`-v2` (or similar) suffix on an existing branch — the PR work belongs on the **original** branch. Strip the suffix and check whether that branch exists (`git rev-parse --verify <original>`) and has a PR (`gh pr list --state all --head <original>`). If it does, **ask the user to switch to `<original>`, saying why**. If the histories have diverged, another worktree holds it, or you're unsure, stop and ask before creating or updating a PR from the variant.

**A branch whose name doesn't describe the work gets renamed, not asked about** — but only while nothing has left this machine:

```bash
git ls-remote --heads origin <current-branch>   # empty: no remote branch
git rev-parse --abbrev-ref '@{upstream}'        # fails, or is origin/main
gh pr view --json number                        # "no pull requests found"
```

An upstream of `origin/main` publishes nothing: `git branch --unset-upstream`, then `git branch -m <describes-the-change>`, and say in your reply that you renamed it. If any check comes back non-empty, the name is public: leave it and mention the mismatch.

**Then merge the branch's own remote (per `merge-conflicts`)** if `git log HEAD..origin/<branch>` shows commits another session pushed.

## 0. Audit the branch

Everything here diffs `origin/<base>...HEAD`. Commit what it produces before step 1.

- **Data files (`vehicle_models/`, `components/`, `e_vehicle_classifications/`, `schemas/`) come only from a publish** (AGENTS.md). A hand edit to one is a mistake to undo and fix at the source; say so rather than PR it.
- **Run what CI runs**: `cargo fmt --check`, `cargo clippy --all-targets --locked -- -D warnings` and `cargo test --locked --no-fail-fast`. A failing data check is reported in the body, not patched in the file.
- **A changed `schemas/*.json` whose `$id` version moved makes this a schema-version PR**, which is always the user's to merge.
- **Documentation the branch adds or edits** — `README.markdown`, `AGENTS.md`, anything under `.claude/` — check every claim against the files it describes; nothing runs a doc. Grep for the subject before adding a line: a fact stated twice drifts, and the restatement is the one that goes wrong.

## 1. Settle the base, merge it if it conflicts, gather state

**The base is the open PR this branch builds on, else a branch the user names, else `main`.** Run `gh pr list --state open --json headRefName,number` and `git log --oneline origin/main..HEAD`; a listed head branch whose commits are in that log is the base, and the body says `Builds on #<n>`. When updating an existing PR, leave its base alone unless the user asks.

`git fetch -q origin <base>`, then merge `origin/<base>` through the `merge-conflicts` skill only when the branch conflicts with it — `gh pr view --json mergeable` reads `CONFLICTING`, or with no PR yet `git merge-tree --write-tree origin/<base> HEAD` exits non-zero — or needs something the base just landed. A PR merges cleanly over a moved base.

Then, in parallel: `git status`, `git diff origin/<base>...HEAD --stat`, `git log origin/<base>..HEAD --oneline`, `gh pr view --json number,url,title,state`. `gh pr view` exiting "no pull requests found" means create one. **Only a PR whose `state` is `OPEN` counts as existing** — for a merged or closed one, create a new PR. If the branch has no commits ahead of `origin/<base>`, stop and tell the user.

## 2. Write the body and create or update the PR

Write the body to `tmp/pr_body_<branch>.md` (`/tmp` is gitignored here) — never a fixed name in the system `/tmp`. Match the tone of recent merged PRs (`gh pr list --state merged --limit 5 --json body,title`). Keep the title under ~70 chars.

- **One-line intro plus 2–3 one-line bullets; ≤6 bullets total.** Cut what the diff shows (file lists, mechanics); keep what it adds and the non-obvious decisions.
- **Describe the end state, not the journey.** An update rewrites the body rather than appending a changelog.
- **A PR with work still left opens Ongoing**: a first line `> **Ongoing:** <what's left>` and an `[Ongoing] ` title prefix, both deleted by the update that finishes the work.
- **No "Test plan" section** unless the user asks.
- **Reference other branches by PR number** (`#4`), not branch name.
- **Link the issue when there is one** — `Closes #<n>` on its own line. Don't invent a number.
- **No Claude Code attribution footer**, or any variant of it (AGENTS.md).

**Push with `git push -u origin HEAD`.** A branch cut with `git switch -c <name> origin/main` tracks `origin/main`, and a bare `git push` would push the work straight onto `main` — always name `HEAD`.

- **Open PR found in step 1**: `gh pr edit <number> --title "..." --body-file <file>`. **Read the current body first** — anything a human added that you can't account for gets carried over or asked about. Keep a deliberate custom title.
- Otherwise: `gh pr create --draft --base <base> --title "..." --body-file <file>`. Draft by default; omit `--draft` only when the user asks for a ready PR.

Always `--body-file`, never inline `--body`. **Read the body back** and check a few of its concrete claims against `git diff origin/<base>...HEAD`.

This workflow posts no PR comments. Anything else you have to say goes in the body when a reviewer needs it, and in your reply otherwise.

## 3. Merging

Don't merge unless the user asks. A schema-version PR is always theirs to merge, however ready.

## 4. What this run taught you

Before reporting the PR URL, ask whether this repo's instructions should change: a skill step that misled you, a wall the next run would hit, a convention the branch established (that's `AGENTS.md`). Before editing, check the skill didn't already say it — a rule you skipped needs rewording or moving, not a second rule — and that the guidance fires often enough to pay for itself. Most runs turn up nothing; say so and stop.

Then return the PR URL. When the body still carries an **Ongoing** note, go straight on to the work it names in the same turn.

## Appendix: no `gh`

If a `gh` command comes back "command not found", use the GitHub MCP equivalents — the rest of the workflow is unchanged, including `git push`.

| `gh` | MCP |
| --- | --- |
| `gh pr view --json …,state` | `list_pull_requests`, `state: "open"`, `head: "bikeindex:<branch>"` |
| `gh pr list --state merged` | `list_pull_requests`, `state: "closed"` |
| `gh pr create --draft` | `create_pull_request`, `draft: true`, `head: "<branch>"` |
| `gh pr edit <n> --body-file` | `update_pull_request` |

`head` takes `owner:branch` when listing but a bare branch name when creating, and `list_pull_requests` reports `merged: false` even for merged PRs. `create_pull_request` appends a Claude Code attribution link server-side — read back what you posted and strip it with `update_pull_request`.
