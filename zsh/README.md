# ZSH Configuration File

This directory contains configuration files and scripts for setting up and customizing the Z shell (ZSH) environment. The files included here are intended to enhance the user experience by providing useful aliases, functions, and themes.

## Features

This ZSH configuration is designed to be modular, fast, and developer-friendly. Key features included in this repository:

-   Powerlevel10k instant prompt: fast, attractive prompt powered by `powerlevel10k` with instant prompt support for snappy startup.

-   Oh My Zsh integration: configuration boots Oh My Zsh and makes it easy to manage themes and plugins.

-   Carefully selected plugins: `git`, `z` (jump around directories), `sudo`, `history`, `command-not-found`, `docker`, `docker-compose`, `npm`, `node`, `zsh-autosuggestions`, and `zsh-syntax-highlighting` to improve shell productivity.

-   History configuration: larger history size and shared/incremental history settings (`HISTSIZE`, `SAVEHIST`, `INC_APPEND_HISTORY`, `SHARE_HISTORY`) to preserve and sync commands across sessions.

-   Environment defaults: sets common environment variables such as `EDITOR=nano` and `ZSH` path for Oh My Zsh.

-   Aliases and shared snippets: loads user aliases from `~/.shell/aliases/*.aliases` for easy customization and separation of concerns.

-   SDKMAN support: initializes SDKMAN (if installed) to manage Java/SDK versions easily.

-   Powerlevel10k config loader: automatically sources `~/.p10k.zsh` if present so prompt customizations are applied.

## Installation / Usage

1. Install a ZSH runtime if you don't have it (`zsh`).

2. Install `oh-my-zsh` and `powerlevel10k` according to their official instructions (git clone the repos).

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
