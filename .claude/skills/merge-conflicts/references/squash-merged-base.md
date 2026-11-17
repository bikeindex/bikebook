# Squash-merged bases and split-off PRs

This repo squash-merges, so a merged PR lands on `main` as one commit sharing no ancestry with its real commits.

## Base already merged? Merge its final commit *before* `main`

Merging `main` straight into a stacked branch turns every file the base *added* into an **add/add** conflict. Merge the base's tip first:

```bash
gh pr view <base-pr> --json headRefOid --jq .headRefOid  # tip survives branch deletion
git fetch origin <sha>                                   # or refs/pull/<base-pr>/head
git merge --no-edit <sha>                                # finish it (and commit) before the next
git merge --no-edit origin/main
```

Your side is then byte-identical to the squash, so only files this branch changed still conflict. Don't look for `origin/<base>` — it's usually deleted.

**The tip already in your branch** (`git merge-base --is-ancestor <sha> HEAD`) makes that first merge a no-op: merge `origin/main` straight and resolve its conflicts like any other merge's. Never take your side wholesale — it drops whatever `main` changed in those files after the squash. A straight merge does quietly bring back what the base added and your branch later removed, so save `git diff <sha> HEAD` before merging, and after it take back out any line or file that diff removed and the merge restored.

## Part of this branch already shipped as its own PR

Every file both touched conflicts. `main`'s side is the reviewed version of your own change — take it, then check `git diff origin/main` lists only the work that PR left out.

**Unless this branch kept editing those files after the PR's tip** — then `main`'s side is *older*. When `git diff --quiet <that PR's headRefOid> origin/main -- <conflicted files>` passes, `git checkout --ours` those files.

## Extracting a slice of another branch

`git checkout <branch> -- <file>` takes the file whole and silently reverts anything `main` moved since. List the overlap and hand-apply those hunks:

```bash
MB=$(git merge-base origin/main origin/<branch>)
comm -12 <(git diff --name-only $MB origin/main | sort) <(git diff --name-only $MB origin/<branch> | sort)
```

Slices from two branches sharing files: `git diff origin/main...origin/<branch> -- <paths> > x.patch`, then `git apply --3way x.patch` per branch.
