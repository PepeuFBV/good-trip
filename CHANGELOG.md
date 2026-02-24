# [1.6.0](https://github.com/PepeuFBV/good-trip/compare/v1.5.0...v1.6.0) (2026-02-24)


### Features

* **uninstall:** add uninstall command with interactive and non-interactive options ([7dd56c9](https://github.com/PepeuFBV/good-trip/commit/7dd56c93a0ed0185e6ace97aecde3f138b11f3ef))

# [1.5.0](https://github.com/PepeuFBV/good-trip/compare/v1.4.2...v1.5.0) (2026-02-24)


### Features

* **update:** add version management commands for listing, installing, and locking versions ([1dea0b3](https://github.com/PepeuFBV/good-trip/commit/1dea0b3b5689f7a1458cab64946ec8d5ec942692))

## [1.4.2](https://github.com/PepeuFBV/good-trip/compare/v1.4.1...v1.4.2) (2026-02-24)


### Bug Fixes

* **update:** enhance version comparison by normalizing version strings ([fea86f7](https://github.com/PepeuFBV/good-trip/commit/fea86f76711cf53b5c7a6919609e58c532c9841d))

## [1.4.1](https://github.com/PepeuFBV/good-trip/compare/v1.4.0...v1.4.1) (2026-02-24)


### Bug Fixes

* **update:** ensure update check timestamp is recorded on exit ([45ccbea](https://github.com/PepeuFBV/good-trip/commit/45ccbea67d27067527ea4a9371ee7a098f3587ce))

# [1.4.0](https://github.com/PepeuFBV/good-trip/compare/v1.3.2...v1.4.0) (2026-02-24)


### Features

* **ssh:** add SSH key management commands and scripts ([6ba5758](https://github.com/PepeuFBV/good-trip/commit/6ba575868e5a68efe415f3488faab1f708a87feb))

## [1.3.2](https://github.com/PepeuFBV/good-trip/compare/v1.3.1...v1.3.2) (2026-02-24)


### Bug Fixes

* **release:** update release process to correctly tag and track minor version series ([c34152d](https://github.com/PepeuFBV/good-trip/commit/c34152da2efb733b31401990e3a5da922056c042))

## [1.3.1](https://github.com/PepeuFBV/good-trip/compare/v1.3.0...v1.3.1) (2026-02-24)


### Bug Fixes

* **release:** correct package name for conventional changelog in release workflow ([8da3ef4](https://github.com/PepeuFBV/good-trip/commit/8da3ef46cc717abb84113db9626bb66e7a288085))
* **release:** update package.json using GitHub Contents API to avoid git pushes ([3680001](https://github.com/PepeuFBV/good-trip/commit/36800017e12f661d7315114f1e7fbe7525c0dab1))

# [1.3.0](https://github.com/PepeuFBV/good-trip/compare/v1.2.0...v1.3.0) (2026-02-23)


### Features

* add configuration files for Husky and Prettier ([50ef548](https://github.com/PepeuFBV/good-trip/commit/50ef5483f0b8bc9909d16dfba80acca11b1e9a50))

# [1.2.0](https://github.com/PepeuFBV/good-trip/compare/v1.1.0...v1.2.0) (2026-02-20)

### Features

- **bootstrap:** add python, pip, and venv support ([25d13bc](https://github.com/PepeuFBV/good-trip/commit/25d13bc617dcdd374a1b30e37fd2ef9d6d1d0ced))

# [1.1.0](https://github.com/PepeuFBV/good-trip/compare/v1.0.0...v1.1.0) (2026-02-20)

### Features

- **aliases:** switch compose aliases to docker compose plugin syntax ([bb517fe](https://github.com/PepeuFBV/good-trip/commit/bb517fe432b310f4f7635d48567d2d6ffa5fe935))
- **bootstrap:** add docker engine and compose plugin installer ([edc29b5](https://github.com/PepeuFBV/good-trip/commit/edc29b5bbbd35b7a11a6d369c4ad7fecf1892976))
- **install:** add docker installation step ([4dcf2cd](https://github.com/PepeuFBV/good-trip/commit/4dcf2cd5e0e4050b311328f5a896554b00e5a9f4))
- **install:** add interactive component picker to installer ([7ef29b6](https://github.com/PepeuFBV/good-trip/commit/7ef29b6bad982adfa2e69dbd93bb52e0cfe903bf))

# 1.0.0 (2026-02-20)

### Bug Fixes

- correct comment for NVM bash completion loading in .zshrc ([e9d67fe](https://github.com/PepeuFBV/dotfiles/commit/e9d67fe157914248e1f6164cbebc81046b4f214a))

### Features

- add aliases for Docker and Node.js to streamline command-line workflows ([aa00211](https://github.com/PepeuFBV/dotfiles/commit/aa002114fdd1b7ff8377d0ab0b77fd0822fd73d3))
- add auto-show directory contents on `cd` and update README ([3a08586](https://github.com/PepeuFBV/dotfiles/commit/3a08586ef1622f5f6210169fb0979a47c8f285f7))
- add initial Git configuration files with user settings and usage instructions ([4582ff3](https://github.com/PepeuFBV/dotfiles/commit/4582ff3c6ffb947e51cc024536baa63fb955c54d))
- add initial ZSH configuration and README with setup instructions ([95a64e3](https://github.com/PepeuFBV/dotfiles/commit/95a64e30c99f2e696b5129977aecb58b32c46b58))
- add NVM support for automatic Node version loading based on .nvmrc ([446d3ca](https://github.com/PepeuFBV/dotfiles/commit/446d3cafc0b51933f591a8c36342ccbe1ce71c4d))
- **aliases:** migrate and expand alias and git config ([36f0510](https://github.com/PepeuFBV/dotfiles/commit/36f0510bfe0a56a3354224d6e2e9a80dac3c8cb8))
- **bootstrap:** add modular idempotent install scripts ([6349d27](https://github.com/PepeuFBV/dotfiles/commit/6349d27e4db32ae6c31b1c31176700f5c225fc0e))
- **install:** add installer, updater, and good-trip cli ([f6ff9df](https://github.com/PepeuFBV/dotfiles/commit/f6ff9df6d854e033faea14087249dd40d6118904))
- integrate Atuin for enhanced shell history management and update README ([dcff322](https://github.com/PepeuFBV/dotfiles/commit/dcff322a11eb7532267fa259ea861d7b9aa7b3f4))
- update README.md with project description, installation instructions, and contribution guidelines ([d83a683](https://github.com/PepeuFBV/dotfiles/commit/d83a683fabaa30e1f8f464d0e5df60ff86708e97))
- **update:** add symlinks, update, and version check scripts ([9110bde](https://github.com/PepeuFBV/dotfiles/commit/9110bde017f5215651b610b258a9ed387b53bee7))
- **zsh:** add zshrc with good-trip integration and daily update check ([9fbe15d](https://github.com/PepeuFBV/dotfiles/commit/9fbe15d9e9d4b34b8de94940a510c32c7604723a))

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Conventional Commits](https://www.conventionalcommits.org/)
and this project adheres to [Semantic Versioning](https://semver.org/).

> This file is automatically maintained by [semantic-release](https://semantic-release.gitbook.io/).
> Do not edit manually.

## [1.0.0] - 2026-02-20

### 🎉 Initial Release

- Modular dotfiles system refactored as an installable product
- ZSH + Oh My Zsh + Powerlevel10k configuration
- NVM auto-loading from `.nvmrc`
- SDKMAN integration for JVM ecosystem
- Atuin shell history with ZSH binding
- Git configuration with GPG commit signing
- Docker and Node aliases
- One-line installer via `curl | bash`
- Auto-updater with daily version check
- `good-trip` CLI (`update`, `status`, `symlinks`, `version`)
- GitHub Actions CI/CD with semantic-release
