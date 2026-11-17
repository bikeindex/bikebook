---
name: remove-archived-worktrees
description: >-
  Removing archived sessions' `.claude/worktrees/` checkouts, which archiving leaves on
  disk. Use when the disk is low or full, or when asked to clean up worktrees or what
  archived sessions left behind.
---

# Removing archived sessions' worktrees

**Who runs this:** from a session with history, one `general-purpose` `Agent` with `model: "haiku"`, since the steps are fixed and `prune_worktrees` holds the checks; relay its report. One session already known to be archived is just step 3's command, run in the session.

1. **List them:** `ls "$(git worktree list --porcelain | sed -n '1s/^worktree //p')/.claude/worktrees" | grep '^bridge-cse_'`. `bridge-cse_<id>` belongs to `session_<id>`.
2. **`get_session` each, all in one turn.** Only a `session_status` of `SESSION_STATUS_ARCHIVED` goes on. Never judge by age, a quiet transcript or no running process: an idle session resumes into its worktree. A lock says nothing either way, since `claude remote-control` holds it past the archive.
3. **Remove them all in one call**: `prune_worktrees session_<id>...`, naming only the archived ids. It carries on past a refusal and works from any checkout.
4. **Report** the space freed (`df -h /System/Volumes/Data` before and after) and each one kept:

   | it refuses because | do |
   |---|---|
   | a process is running in it | a Claude session still exiting: the next sweep gets it |
   | a marker names it as taken over | leave it: the session that took it over removes it |
   | it has uncommitted changes, or commits no branch or remote holds | ask the user, naming the session's title and what's there |

Any other name under `.claude/worktrees/` (`agent-*`, `review-*`, a hand-named one) has no session to ask. List those with their sizes for the user; the session that added one removes it, with `git worktree remove <path>`.

A refusal is the answer: no `--force`, no `git worktree unlock` and no `rm -rf` to get past one.
