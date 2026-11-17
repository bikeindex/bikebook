---
name: merge-conflicts
description: >-
  How to bring a branch up to date and resolve git merge conflicts the way this
  repo expects — merge (never rebase or force-push), merge a data file key by key,
  understand each side's intent before choosing, ask when a resolution isn't
  clear-cut, keep the merge commit to just the merge, and audit what merged
  cleanly before committing. Trigger whenever
  you're about to run `git merge`/`git pull`, sync a branch with `main`, "update
  from main", pick up commits on the branch's own remote, or resolve conflict
  markers — including "fix the conflicts", "merge main in", or "this branch is
  behind". Strictly about git branch integration.
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

# Merging

1. **Pick the base.** Re-read `git branch --show-current`. Base = the branch the user named, else `gh pr view --json baseRefName`, else `main`. A branch built on an unmerged feature branch with no PR: ask the user. A base whose PR already squash-merged, or part of this branch already shipped as its own PR: read `references/squash-merged-base.md` first.
2. **Merge only when there's a reason**: the PR conflicts with the base (`gh pr view --json mergeable` reads `CONFLICTING`), the branch needs something the base just landed, the user asks, or the branch's own remote has commits another session pushed. Never just because the base moved.
3. **Commit uncommitted work first**, then `git fetch -q origin <ref>` and `git merge --no-edit origin/<ref>`. Never rebase, force-push, `--ff-only` or `git pull`. Report what came in from the merge's output.
4. **Already up to date, or merged cleanly** → audit what merged cleanly (below), and you're done.
5. **Conflicts** → resolve them as below, then `git add` and `git commit --no-edit`.

## Resolve

**A data file — anything under `vehicle_models/`, `components/` or `e_vehicle_classifications/` — merges key by key.** This repo is the data's canonical source (AGENTS.md), so its resolution is the data from then on. Compare the merge base (`git show :1:<path>`) with each side (`:2:` this branch, `:3:` the base) and take each side's changed values: a key only one side changed takes that side's, a key the base added or removed stays added or removed. **A key both sides changed to different values is a question for the user**, naming the file, the key and both values — a wrong value merged silently is wrong data. So is a modify/delete conflict: whether the model still exists is the user's call. Write the result in the file's existing key order, pretty-printed (AGENTS.md).

**A `schemas/` file both sides changed is a schema change from each side**: combine them only when they touch different definitions and their versions agree; otherwise ask.

Everything else (`README.markdown`, `AGENTS.md`, `.claude/`, code, licenses):

- Read both sides' intent before choosing — `git log --oneline --merge -- <file>` shows the commits that touched it on each side. The answer is often a combination. Don't drop the branch's purpose or revert something the base did on purpose.
- **A value both sides changed takes the base's; the branch only adds what the base lacks.** Ask when the two can't both hold and the right one isn't clear — a wrong silent resolution is worse than a question.
- Edit out the unwanted half of each `<<<<<<<` block. `git checkout --ours/--theirs` replaces the whole file and loses the other side's clean hunks (`git checkout -m -- <file>` restores the markers).
- **The merge commit holds only the merge.** Fixes the merge makes due go in commits after it.

After resolving, before committing, run the checks (AGENTS.md § Checks): a merged data file that's misordered, misformatted or off its schema fails it.

## Check what merged cleanly

This repo squash-merges, so a squash-merged base shares no history with its real commits and git can silently keep your side of lines the base deleted. Before committing (or right after a clean merge), look at `git diff origin/<base>...HEAD` for:

- **A file the branch never meant to touch** — a stray from a squash-merged base. Reset it to the base's version.
- **Lines the base deleted that came back.** Take them back out.

**Never reset a file the branch changed to the base's version** just because the base changed it too — that drops the branch's purpose.

Pulling part of another branch in with `git checkout <branch> -- <file>` isn't a merge and overwrites what the base moved since: `references/squash-merged-base.md` covers slicing.
