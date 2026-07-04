# Rebasing This Fork Onto Upstream

This fork keeps local changes on top of the original COSMIC compositor repo.
The recurring maintenance workflow is:

1. Fetch the original repo.
2. Create a backup branch.
3. Rebase `workspace-overview-changes` onto the latest upstream release or upstream `master`.
4. Resolve conflicts, if any.
5. Run a smoke check.
6. Push the rewritten branch to this fork with `--force-with-lease`.

## Remotes

```sh
origin=https://github.com/crocodile/cosmic-comp.git
upstream=https://github.com/pop-os/cosmic-comp.git
```

`origin` is this fork. `upstream` is the original repo.

## One-Time Setup

Enable Git's recorded conflict-resolution cache:

```sh
git config rerere.enabled true
```

This helps when the same conflict appears again during future rebases.

## Rebase Onto A New Release

Use this when the original repo publishes a new release tag such as
`epoch-1.2.0`.

```sh
git switch workspace-overview-changes
git fetch upstream --tags

git tag --list 'epoch-*' --sort=-version:refname | head -10

git branch backup/workspace-overview-changes-pre-rebase-YYYY-MM-DD
git rebase epoch-X.Y.Z
```

Replace `YYYY-MM-DD` with today's date, and replace `epoch-X.Y.Z` with the
release tag to use.

## Rebase Onto Latest Upstream Master

Use this when you want the newest upstream commits, even if they are newer than
the latest release tag.

```sh
git switch workspace-overview-changes
git fetch upstream --tags

git branch backup/workspace-overview-changes-pre-rebase-YYYY-MM-DD
git rebase upstream/master
```

## If Conflicts Happen

Check which files need attention:

```sh
git status --short
```

After fixing each conflicted file:

```sh
git add <fixed-files>
git rebase --continue
```

To stop and return to the pre-rebase branch state:

```sh
git rebase --abort
```

## Verify

After a successful rebase:

```sh
git rev-list --left-right --count upstream/master...HEAD
git log --oneline --decorate upstream/master..HEAD
cargo check
```

The count should usually look like `0 2`: zero commits behind upstream, with
the local patch stack ahead of upstream.

## Push The Rebased Branch

Because rebase rewrites commit IDs, update the fork with a safe force push:

```sh
git push --force-with-lease origin workspace-overview-changes
```

Use `--force-with-lease`, not plain `--force`, so Git refuses to overwrite
remote work that was added after the last fetch.

## Current Local Patch Stack

At the time this note was added, this fork intentionally carried these commits
on top of upstream:

```text
feat(input): enhanced workspace overview gestures
feat: add build_and_install.sh script to automate release builds and binary deployment
```

