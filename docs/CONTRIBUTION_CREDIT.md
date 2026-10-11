# Getting credit for your contributions on GitHub

This page explains how work in this repository shows up on a GitHub profile (the contribution graph and the "Contribution activity" list), how the maintainer's setup is configured, and what a contributor needs to do so their own work is credited.

## How GitHub decides what counts

GitHub counts a commit toward your profile only when **all** of the following are true:

1. **The commit's author email is linked to your account.** GitHub matches the `Author` email of each commit against the emails on your account. Unmatched emails produce commits that show no avatar and count for nobody.
2. **The commit is on the default branch** (`main` here) or on `gh-pages`. Commits that only exist on a feature branch do not count until the pull request is merged.
3. **The repository is not a fork**, or the commit was made in the upstream repository.
4. **The commit is less than a year old** for the graph; older ones still appear in the activity history.

Pull requests and issues count as soon as they are opened, in any repository you can see. Reviews count when submitted.

Only the **author** of a commit is credited, not the committer. GitHub's own merge commits are committed by `web-flow` and authored by whoever pressed merge, so merge commits also count for that person.

## How this repository is set up

The repository-local Git identity uses the account's no-reply address, which GitHub links automatically and which keeps a personal email out of the public history:

```bash
git config user.name "mateoosoriodelhonte"
git config user.email "259801526+mateoosoriodelhonte@users.noreply.github.com"
```

The number is the account id; the address format is `<id>+<username>@users.noreply.github.com`. You can find yours under **Settings → Emails**, where the "Keep my email addresses private" option shows it.

Every change reaches `main` through a pull request merged with a merge commit, so both the branch commits and the merge commits are credited. Verified on 2026-10-11 through the GitHub API: 36 commit contributions, 14 pull requests and 14 issues from this repository appear in the maintainer's contribution collection, and every commit on `main` resolves to the account.

Commits made with an AI coding assistant carry a `Co-Authored-By` trailer. The trailer is informational; GitHub credits the trailer's address only if it belongs to a GitHub account, and it never removes credit from the author.

## Checklist for contributors

Before opening a pull request:

- [ ] Set your email on this clone to one GitHub knows about, or to your no-reply address:
  ```bash
  git config user.email "<id>+<username>@users.noreply.github.com"
  ```
- [ ] If you already committed with another address, fix the last commit before pushing:
  ```bash
  git commit --amend --reset-author --no-edit
  ```
- [ ] Keep the PR's commits authored by you. Rebases and squashes preserve the author; GitHub's "Squash and merge" uses the PR author.
- [ ] Open the PR against `main`. It is credited when merged.

To confirm that GitHub links a pushed commit to you, open it on GitHub: a linked author shows an avatar and username next to the commit title. From the command line:

```bash
gh api repos/mateoosoriodelhonte/fairshare/commits/<sha> --jq '.author.login'
```

A `null` result means the email is not linked.

## Showing the project on your profile

- **Pin the repository**: profile → *Customize your pins*. Pinned repositories appear above the contribution graph.
- **Private activity**: the graph hides private contributions unless **Settings → Public profile → Contribution settings → Private contributions** is enabled. This repository is public, so it is unaffected.
- **Achievements**: merged PRs and closed issues feed GitHub's achievement badges automatically.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Commits show no avatar on GitHub | Author email not linked to an account | Add the email under Settings → Emails (verify it), or amend with a linked address and push again |
| Work is visible in the PR but not on the graph | PR not merged yet, or merged into a non-default branch | Merge into `main` |
| Credit went to someone else | They authored the commit (for example, a maintainer re-created it) | Ask for a cherry-pick with `--author`, or keep your original commit |
| Graph shows fewer commits than `git log` | Several commits on one day are one square, and only the author is counted per commit | Expected behaviour |
