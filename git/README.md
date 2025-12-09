````markdown
# Git Configuration

This directory contains a curated `git` configuration intended to be used as a personal global Git config. It centralizes useful defaults (push/pull behavior, rebase and pull settings), commit signing, color and status output, and other niceties to make Git workflows consistent across machines.

## Features

Key configuration choices included in this config:

-   Personal identity: `user.name`, `user.email`, and `user.signingkey` are set so commits are signed and attributed correctly.
-   Commit signing: `commit.gpgsign = true` enforces GPG-signed commits for stronger provenance.
-   Push/pull defaults: `push.default = current` and `pull.default = current` keep pushes and pulls scoped to the current branch to avoid surprises.
-   Rebase workflow: `pull.rebase = true` with `rebase.autoStash = true` to enable a cleaner linear history while stashing local changes automatically.
-   Performance and UX: `core.preloadindex = true` and `core.compression = 1` for snappier operations and smaller pack sizes.
-   Status improvements: `status.branch = true`, `status.showStash = true`, and `status.showUntrackedFiles = all` provide more helpful status output.
-   Color: `color.ui = auto` enables colored output when appropriate.

## Installation / Usage

1. Ensure you have Git installed on your machine.

2. To use this repo's config as your global Git configuration, symlink the file from this repo into your home directory:

```sh
# from repo root
ln -s "$PWD/git/config" "$HOME/.gitconfig"
```

3. If you prefer to copy the config instead of symlinking:

```sh
cp "$PWD/git/config" "$HOME/.gitconfig"
```

4. GPG commit signing:

-   Install GPG (e.g., `gpg` / `gpg2`).
-   Ensure you have a GPG key and that `user.signingkey` matches your key ID.
-   Make sure your GPG agent is configured to allow signing from the terminal or GUI (pinentry). For Git to sign commits with GPG 2.1+ you might need to set `gpg.program` in your `~/.gitconfig` to the right executable, or configure `use-agent` in your GPG config.

Example: set a GPG program and enable signing if needed:

```ini
[gpg]
	program = /usr/bin/gpg

[commit]
	gpgsign = true
```

5. After installing the config, verify settings with:

```sh
git config --list --show-origin
```

## Tips

-   If `commit.gpgsign` blocks automation (CI, bots), consider enabling signing only locally and exclude CI by checking environment variables.
-   Keep your `user.email` and `user.name` accurate per repository or organization requirements.
-   To change the signing key locally for a machine use:

```sh
git config --global user.signingkey <YOUR_KEY_ID>
```

-   If you use multiple machines, symlink the config from a dotfiles manager (this repo) so updates propagate easily.
````
