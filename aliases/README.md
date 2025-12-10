# Aliases Configuration

This directory contains a set of command aliases intended to streamline and enhance command-line workflows. These aliases cover various tools and utilities, providing shorthand commands for common tasks.

## Features

Two main alias files are included:

-   `docker.aliases`: Contains aliases for Docker commands to simplify container management.
-   `node.aliases`: Contains aliases for Node.js and npm commands to facilitate JavaScript development.

## Installation / Usage

1. Clone this repository to your local machine.

```sh
git clone [repository_url]
```

2. Use the aliases by sourcing the appropriate alias file in your shell configuration (e.g., `.zshrc`, `.bashrc`). It's already set up in this repos `.zshrc`.

```sh
# from repo root
ln -s "$PWD/aliases/docker.aliases" "$HOME/.shell/aliases/docker.aliases"
ln -s "$PWD/aliases/node.aliases" "$HOME/.shell/aliases/node.aliases"
```

> [NOTE]
> If needed create the `~/.shell` and `~/.shell/aliases` directories first.

3. Reload your shell configuration or restart your terminal to apply the changes.

```sh
source ~/.zshrc  # or source ~/.bashrc
```
