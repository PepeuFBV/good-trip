# ZSH Configuration File

This directory contains configuration files and scripts for setting up and customizing the Z shell (ZSH) environment. The files included here are intended to enhance the user experience by providing useful aliases, functions, and themes.

## Features

This ZSH configuration is designed to be modular, fast, and developer-friendly. Key features included in this repository:

-   Powerlevel10k instant prompt: fast, attractive prompt powered by `powerlevel10k` with instant prompt support for snappy startup.

-   Oh My Zsh integration: configuration boots Oh My Zsh and makes it easy to manage themes and plugins.

-   Plugins: `git`, `z` (jump around directories), `sudo`, `history`, `command-not-found`, `docker`, `docker-compose`, `npm`, `node`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `atuin` to improve shell productivity.

-   History configuration: larger history size and shared/incremental history settings (`HISTSIZE`, `SAVEHIST`, `INC_APPEND_HISTORY`, `SHARE_HISTORY`) to preserve and sync commands across sessions.

-   Environment defaults: sets common environment variables such as `EDITOR=nano` and `ZSH` path for Oh My Zsh.

-   Aliases and shared snippets: loads user aliases from `~/.shell/aliases/*.aliases` for easy customization and separation of concerns.

-   SDKMAN support: initializes SDKMAN (if installed) to manage Java/SDK versions easily.

-   Powerlevel10k config loader: automatically sources `~/.p10k.zsh` if present so prompt customizations are applied.

-   Atuin shell history integration: integrates Atuin for enhanced shell history management.

-   Auto-show directory contents on `cd`: lists files automatically when changing directories.

-   NVM support: automatically loads Node versions specified in `.nvmrc` files when changing directories.

## Installation / Usage

1. Install a ZSH runtime if you don't have it (`zsh`).

2. Install `oh-my-zsh`, `powerlevel10k` and `atuin` according to their official instructions (git clone the repos).

3. Clone or symlink this `zsh` folder into your home configuration, for example:

```sh
# from your dotfiles repo root
ln -s "$PWD/zsh/.zshrc" "$HOME/.zshrc"
```

4. Install any plugins that require separate installation (`zsh-autosuggestions`, `zsh-syntax-highlighting`) via your plugin manager or by cloning into `~/.oh-my-zsh/custom/plugins`.

5. (Optional) Create `~/.p10k.zsh` by running `p10k configure` to customize the prompt.

6. (Optional) Install SDKMAN if you need SDK management: https://sdkman.io/install

7. Reload your shell or open a new terminal: `exec zsh`.

## Tips

-   Recommended fonts: use a Nerd Font / Powerline-patched font for Powerlevel10k icons and glyphs to render correctly.
-   Customize aliases: add your personal aliases into `~/.shell/aliases/*.aliases` — files are loaded automatically if readable.
-   Keep `~/.p10k.zsh` in your home directory if you want to store prompt preferences separately from this repo.

## NVM support (auto-loading `.nvmrc`)

This ZSH configuration includes support for Node Version Manager (nvm) and will automatically load the Node version specified in a project's `.nvmrc` when you change into that directory.

-   It sets `NVM_DIR` and sources `nvm.sh` and the `bash_completion` script if available.
-   A `load-nvmrc` function is defined that looks for an `.nvmrc` (via `nvm_find_nvmrc`). If it finds one, it will:
    -   read the version from the file,
    -   install the version with `nvm install` if it's not present,
    -   switch to the version with `nvm use` (silently).
-   The function is registered with `add-zsh-hook chpwd` so it runs automatically on `cd` and it's invoked once at shell startup.

Usage:

-   Create a `.nvmrc` at the repository root containing a node version string, for example:

```
14
# or a specific version
v14.20.1
# or an alias like
lts/*
```

-   When you `cd` into the project directory the shell will automatically switch to the node version specified in `.nvmrc`. If the version isn't installed, it will be installed automatically.

Disable or override:

-   To disable automatic switching, remove or comment out the `add-zsh-hook chpwd load-nvmrc` line in your `~/.zshrc`.
-   You can still manually switch versions with `nvm use <version>` or trigger the loader manually with `load-nvmrc`.
