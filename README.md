# good-trip

[![Release](https://img.shields.io/github/v/release/PepeuFBV/good-trip?style=flat-square&label=version)](https://github.com/PepeuFBV/good-trip/releases/latest)
[![CI](https://img.shields.io/github/actions/workflow/status/PepeuFBV/good-trip/ci.yml?branch=main&style=flat-square&label=CI)](https://github.com/PepeuFBV/good-trip/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-fe5196?style=flat-square)](https://www.conventionalcommits.org/)

> Dotfiles treated as a product — installable, versioned, and auto-updatable.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Auto-update](#auto-update)
- [CLI Reference](#cli-reference)
- [SSH Keys](#ssh-keys)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [Versioning](#versioning)
- [Changelog](#changelog)

---

## Overview

**good-trip** is a modular, production-grade dotfiles system for developers who
want their shell environment to behave like a well-maintained software product:

- One command to install on a fresh machine
- Idempotent — running the installer again never breaks anything
- Version-tracked with [Semantic Versioning](https://semver.org/)
- Self-updating — checks for new releases daily in the background
- Works on **Linux** (Ubuntu, Debian, Arch) and **macOS**

---

## Features

| Component   | Details                                                                                                         |
| ----------- | --------------------------------------------------------------------------------------------------------------- |
| **Shell**   | ZSH with [Oh My Zsh](https://ohmyz.sh/), [Powerlevel10k](https://github.com/romkatv/powerlevel10k)              |
| **Plugins** | `git`, `z`, `sudo`, `docker`, `docker-compose`, `npm`, `node`, `zsh-autosuggestions`, `zsh-syntax-highlighting` |
| **History** | [Atuin](https://atuin.sh/) for searchable, syncable shell history                                               |
| **Node.js** | [NVM](https://github.com/nvm-sh/nvm) with automatic `.nvmrc` switching                                          |
| **JVM**     | [SDKMAN](https://sdkman.io/) for Java/Kotlin/Scala/Groovy SDK management                                        |
| **Git**     | Opinionated config with GPG commit signing, useful aliases                                                      |
| **Aliases** | Docker, Node/NPM/pnpm/Yarn — all in `config/aliases/`                                                           |
| **CI/CD**   | GitHub Actions + semantic-release for fully automated versioning and releases                                   |
| **SSH**     | One-command Ed25519 key generation + GitHub account registration via REST API                                   |

---

## Installation

### One-line installer (fresh machine)

```sh
curl -fsSL https://raw.githubusercontent.com/PepeuFBV/good-trip/main/install.sh | bash
```

The installer will:

1. Detect your OS (Ubuntu / Debian / Arch / macOS)
2. Install ZSH (if missing)
3. Install Oh My Zsh, Powerlevel10k, and ZSH plugins
4. Install NVM, SDKMAN, and Atuin
5. Configure Git with GPG signing support
6. Create managed symlinks (`~/.zshrc`, `~/.gitconfig`, `~/.shell/aliases`)
7. Install the `good-trip` CLI to `~/.local/bin/`

The installer is **idempotent** — safe to run multiple times.

### From a local clone

```sh
git clone https://github.com/PepeuFBV/good-trip.git ~/.good-trip
cd ~/.good-trip
./install.sh
```

### After installation

```sh
exec zsh              # reload shell
p10k configure        # set up your prompt (first run only)
good-trip status      # verify everything is linked
```

---

## Auto-update

good-trip checks for updates once per day in the background when your shell
starts. If an update is available you will see:

```
[good-trip] Update available: 1.0.0 → 1.1.0. Run 'good-trip update' to upgrade.
```

### Manual update

```sh
good-trip update          # interactive — asks before applying
good-trip update --yes    # apply immediately, no prompt
good-trip update --check  # only report latest version, never apply
```

### Disable auto-check

Set the interval to a very large number (in seconds) in your shell:

```sh
# in ~/.zshrc.local or similar
export GOOD_TRIP_UPDATE_INTERVAL=999999999
```

---

## CLI Reference

```
good-trip <command> [options]

Commands:
  update [--yes] [--check] [--silent]   Check and apply updates
  version                               Print installed version
  status                                Show symlink and install status
  symlinks [--dry-run]                  Re-apply all managed symlinks
  ssh-keygen [options]                  Generate an SSH key pair and print public key
  ssh-github [options]                  Register an SSH key with your GitHub account
  help                                  Show help
```

**Examples:**

```sh
good-trip version
good-trip status
good-trip symlinks --dry-run
good-trip update --check
good-trip ssh-keygen --name id_ed25519
good-trip ssh-github --list
```

Short alias `gt` is available after installation:

```sh
gt update
gt status
gt ssh-keygen --name id_ed25519
gt ssh-github
```

---

## SSH Keys

good-trip provides two commands for SSH key management, intended to be run on a
fresh server or any machine where you need quick access setup.

### Generate a key (`ssh-keygen`)

Creates an Ed25519 key pair in `~/.ssh/` and prints the public key so you can
copy it wherever needed.

```sh
# Basic — generate and print public key
good-trip ssh-keygen --name id_ed25519

# With a custom comment (e.g. your email)
good-trip ssh-keygen --name id_ed25519 --comment you@example.com

# Generate AND add to ~/.ssh/authorized_keys (allows incoming SSH with this key)
good-trip ssh-keygen --name id_ed25519 --authorized-keys

# Custom file name
good-trip ssh-keygen --name deploy_key

# Preview what would happen without writing anything
good-trip ssh-keygen --name deploy_key --dry-run
```

| Option | Description |
| --- | --- |
| `--comment <text>` | Key comment (default: `user@hostname`) |
| `--name <filename>` | Filename in `~/.ssh/` (required) |
| `--authorized-keys` | Append public key to `~/.ssh/authorized_keys` |
| `--dry-run` | Print what would happen, write nothing |

### Register key with GitHub (`ssh-github`)

Uses the GitHub REST API to add an SSH public key to your account.
Requires a **Personal Access Token** with the `write:public_key` scope.

```sh
# Add default key (~/.ssh/id_ed25519.pub) — will prompt for token
good-trip ssh-github

# Pass the token inline (or set $GITHUB_TOKEN in your environment)
good-trip ssh-github --token ghp_xxxxxxxxxxxx

# Add a specific public key with a custom title
good-trip ssh-github --key ~/.ssh/deploy_key.pub --title "prod server"

# List SSH keys already on your GitHub account
good-trip ssh-github --list

# Preview the API payload without sending
good-trip ssh-github --dry-run
```

| Option | Description |
| --- | --- |
| `--key <path>` | Path to `.pub` file (default: `~/.ssh/id_ed25519.pub`) |
| `--title <text>` | Key title on GitHub (default: `user@host — date`) |
| `--token <token>` | GitHub PAT, or set `$GITHUB_TOKEN` env var |
| `--list` | List keys currently on your account |
| `--dry-run` | Show API payload without sending |

Create a token at: <https://github.com/settings/tokens/new?scopes=write:public_key>

### Typical server setup workflow

```sh
# 1. On the fresh server — generate key and allow future SSH access
good-trip ssh-keygen --name server_key --comment you@example.com --authorized-keys

# 2. Add the generated key to GitHub so you can clone private repos
good-trip ssh-github --token ghp_xxxxxxxxxxxx --key ~/.ssh/server_key.pub

# 3. Verify
ssh -T git@github.com
```

---

## Configuration

### Git identity

Edit `config/git/config` and fill in your details:

```ini
[user]
    name       = Your Name
    email      = you@example.com
    signingkey = YOUR_GPG_KEY_ID
```

Then re-apply:

```sh
good-trip symlinks
```

### GPG signing

```sh
# Generate a new key (if you don't have one)
gpg --full-generate-key

# List keys to find your ID
gpg --list-secret-keys --keyid-format LONG

# Export public key to add to GitHub
gpg --armor --export YOUR_KEY_ID
```

Paste the output into **GitHub → Settings → SSH and GPG keys**.

### Adding aliases

Drop a new `*.aliases` file into `config/aliases/`:

```sh
echo "alias myalias='echo hello'" > config/aliases/custom.aliases
good-trip symlinks
```

### Adding a new machine

```sh
curl -fsSL https://raw.githubusercontent.com/PepeuFBV/good-trip/main/install.sh | bash
```

### Powerlevel10k prompt

Run `p10k configure` to interactively rebuild your `~/.p10k.zsh`.
To share your prompt config across machines, add `~/.p10k.zsh` to the repo under
`config/p10k/p10k.zsh` and create a symlink for it in `scripts/symlinks.sh`.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Write commits following [Conventional Commits](https://www.conventionalcommits.org/):

   | Prefix                        | When to use                       | Version bump |
   | ----------------------------- | --------------------------------- | ------------ |
   | `feat:`                       | New feature or configuration      | minor        |
   | `fix:`                        | Bug fix                           | patch        |
   | `docs:`                       | Documentation only                | —            |
   | `refactor:`                   | Code cleanup, no behaviour change | —            |
   | `ci:`                         | CI/CD changes                     | —            |
   | `chore:`                      | Maintenance                       | —            |
   | `feat!:` / `BREAKING CHANGE:` | Breaking change                   | **major**    |

4. Push and open a Pull Request (the PR template guides you through the checklist)
5. Merging to `main` automatically creates the tag, release, and updates CHANGELOG.md

---

## Versioning

This project uses **Semantic Versioning** (`MAJOR.MINOR.PATCH`) driven by
[semantic-release](https://semantic-release.gitbook.io/):

- `fix:` commits → patch bump (`1.0.0` → `1.0.1`)
- `feat:` commits → minor bump (`1.0.0` → `1.1.0`)
- `feat!:` or `BREAKING CHANGE:` in footer → major bump (`1.0.0` → `2.0.0`)

The current version is stored in `version.txt` and updated automatically on every release.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full release history.

---

## License

MIT © [PepeuFBV](https://github.com/PepeuFBV)
