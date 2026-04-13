## [1.12.3](https://github.com/PepeuFBV/good-trip/compare/v1.12.2...v1.12.3) (2026-04-13)


### Bug Fixes

* portable semver comparison without sort -V ([d04b9a3](https://github.com/PepeuFBV/good-trip/commit/d04b9a363e953c68293dd52697c65e31183af71d))
* replace bash 4+ constructs for macOS bash 3.2 compatibility ([461ba54](https://github.com/PepeuFBV/good-trip/commit/461ba54569f6b9b16afba9441a1a27ffa50738f0))

## [1.12.2](https://github.com/PepeuFBV/good-trip/compare/v1.12.1...v1.12.2) (2026-04-12)


### Bug Fixes

* enable docker-in-docker in devcontainer ([ebb13f2](https://github.com/PepeuFBV/good-trip/commit/ebb13f2d3bc32510a23389de3e0ecc3c8187c21b))
* exclude changelog.md from prettier ([7c66e8b](https://github.com/PepeuFBV/good-trip/commit/7c66e8b137ed29d8a690e3b7d63b4ae3b63e05f3))

## [1.12.1](https://github.com/PepeuFBV/good-trip/compare/v1.12.0...v1.12.1) (2026-04-12)


### Bug Fixes

* format changelog.md for prettier ([e6787dd](https://github.com/PepeuFBV/good-trip/commit/e6787dddc581b1626e475f9947fe25789e9dc252))
* satisfy shellcheck warnings ([53c941a](https://github.com/PepeuFBV/good-trip/commit/53c941ab9078d6de746d60881126d3a2bd43a7fb))

# [1.12.0](https://github.com/PepeuFBV/good-trip/compare/v1.11.1...v1.12.0) (2026-04-12)

### Bug Fixes

- auto-install missing zip dependency for sdkman ([246544a](https://github.com/PepeuFBV/good-trip/commit/246544a2dc01ffc3443d7f31e89a4982cd9a57e5))
- format files for prettier ([cac033d](https://github.com/PepeuFBV/good-trip/commit/cac033d4e55a89fed821e3cc7a119604e27a9da1))
- skip docker engine install when running inside a container ([f3e2552](https://github.com/PepeuFBV/good-trip/commit/f3e25528f6ed3d7420a1d292d8d2d8856fb71d0d))
- stabilize devcontainer git config ([fe6f733](https://github.com/PepeuFBV/good-trip/commit/fe6f733b55d709fa8e65fd224b0455a51b69db8b))
- suppress interactive prompts and source path in atuin installer ([f45b03b](https://github.com/PepeuFBV/good-trip/commit/f45b03bd1a8af065e8fa8263bec2ddec826c16c9))
- update devcontainer configuration to include .codex directory mount ([9f1da51](https://github.com/PepeuFBV/good-trip/commit/9f1da51fbfc7f600308a1ac20516117d79f88ba4))
- use sudo fallback for cli install and export good_trip_dir ([77345cc](https://github.com/PepeuFBV/good-trip/commit/77345cc33898b7eaf988368dfb8f65f64157e642))

### Features

- add devcontainer configuration ([9c8c3be](https://github.com/PepeuFBV/good-trip/commit/9c8c3beecc0f3a5ba00280121f6e7791cf2ae4e0))
- import host zsh and p10k config in devcontainer ([27f5c35](https://github.com/PepeuFBV/good-trip/commit/27f5c35f533d4d7cf3b6e921d73e3b3f67da4edc))

## [1.11.1](https://github.com/PepeuFBV/good-trip/compare/v1.11.0...v1.11.1) (2026-03-13)

### Bug Fixes

- handle non-TTY input for non-interactive installations in install.sh ([7507a42](https://github.com/PepeuFBV/good-trip/commit/7507a42e2300f90624d6b552ce4c416837c24ee8))

# [1.11.0](https://github.com/PepeuFBV/good-trip/compare/v1.10.0...v1.11.0) (2026-03-13)

### Bug Fixes

- correct command syntax in docker compose for cli checks ([0a7733b](https://github.com/PepeuFBV/good-trip/commit/0a7733b4616ffb6b016cd34c133ab0c5fc73db71))
- correct command syntax in docker compose for cli checks ([a1d500f](https://github.com/PepeuFBV/good-trip/commit/a1d500f97b7f601476e717c36d64ea7968d40916))
- shadow variable fix for `run_in_docker.sh` ([69fc8aa](https://github.com/PepeuFBV/good-trip/commit/69fc8aa48bbb41072df7830ff89eaf02afc2c574))
- sucessfull messsage printed for an outcome in `install-python.sh` ([5f5c057](https://github.com/PepeuFBV/good-trip/commit/5f5c0574bdb72ad8caa21c3d1c0986e322e8dfef))

### Features

- add docker-based installation and testing workflow ([ccb2fcf](https://github.com/PepeuFBV/good-trip/commit/ccb2fcf3e92b6bf2f2aeb1745bec0bbc8c0ba17c))
- add environment variable for node.js version enforcement in ci ([b4c3c90](https://github.com/PepeuFBV/good-trip/commit/b4c3c90b0511db2d2e0ef201db8c21a5bb2c127c))
- add environment variables and workflow triggers for installation ci ([69b7a8a](https://github.com/PepeuFBV/good-trip/commit/69b7a8a46ef9bcb204ae8f80351fbfcd7aec7427))
- enhance docker installation script and update readme for clarity ([eb12d65](https://github.com/PepeuFBV/good-trip/commit/eb12d656f24efa2c47a6d2c813390aec29971e69))
- remove push and pull_request triggers from installation workflow ([36b3061](https://github.com/PepeuFBV/good-trip/commit/36b3061e69f03b56cb5036a40cedf15f61e779ed))
- update checkout step in installation workflow to include token and fetch options ([cdad3af](https://github.com/PepeuFBV/good-trip/commit/cdad3af4894da38c9d3665e6e3bbfe3bac9c0db1))

# [1.10.0](https://github.com/PepeuFBV/good-trip/compare/v1.9.0...v1.10.0) (2026-03-02)

### Features

- **bootstrap:** add configurable default versions for nvm, sdkman, and python ([1f17b6f](https://github.com/PepeuFBV/good-trip/commit/1f17b6f8a047567262a00cc7ef3b90bfef0c8b4c)), closes [#3](https://github.com/PepeuFBV/good-trip/issues/3)

# [1.9.0](https://github.com/PepeuFBV/good-trip/compare/v1.8.0...v1.9.0) (2026-03-02)

### Features

- **cli:** add p10k config import subcommand ([cd2ffa0](https://github.com/PepeuFBV/good-trip/commit/cd2ffa0b62de6ff4402cf55d9c3d6356ce3317d6)), closes [#2](https://github.com/PepeuFBV/good-trip/issues/2)

# [1.8.0](https://github.com/PepeuFBV/good-trip/compare/v1.7.0...v1.8.0) (2026-03-02)

### Features

- **bootstrap:** set zsh as default shell if already installed ([5ad9beb](https://github.com/PepeuFBV/good-trip/commit/5ad9beb0d64dfadc7f6643e9d8f5db2c9ee95ef7)), closes [#1](https://github.com/PepeuFBV/good-trip/issues/1)

# [1.7.0](https://github.com/PepeuFBV/good-trip/compare/v1.6.2../v1.7.0) (2026-03-02)

### Features

- **git:** add interactive git identity configuration and update related scripts ([6b42f20](https://github.com/PepeuFBV/good-trip/commit/6b42f20a8765f482a8460098a62011ef0a020711))

## [1.6.2](https://github.com/PepeuFBV/good-trip/compare/v1.6.1...v1.6.2) (2026-02-24)

### Bug Fixes

- **install:** move 'already installed' check to a new section ([9bdd869](https://github.com/PepeuFBV/good-trip/commit/9bdd869aedb3ffc326935dbb5a217405fd3164ef))

## [1.6.1](https://github.com/PepeuFBV/good-trip/compare/v1.6.0../v1.6.1) (2026-02-24)

### Bug Fixes

- **update:** handle detached HEAD state during updates ([9c1ec2d](https://github.com/PepeuFBV/good-trip/commit/9c1ec2d04d601d8fc38fcba2d94ee4628194945a))

# [1.6.0](https://github.com/PepeuFBV/good-trip/compare/v1.5.0../v1.6.0) (2026-02-24)

### Features

- **uninstall:** add uninstall command with interactive and non-interactive options ([7dd56c9](https://github.com/PepeuFBV/good-trip/commit/7dd56c93a0ed0185e6ace97aecde3f138b11f3ef))

# [1.5.0](https://github.com/PepeuFBV/good-trip/compare/v1.4.2../v1.5.0) (2026-02-24)

### Features

- **update:** add version management commands for listing, installing, and locking versions ([1dea0b3](https://github.com/PepeuFBV/good-trip/commit/1dea0b3b5689f7a1458cab64946ec8d5ec942692))

## [1.4.2](https://github.com/PepeuFBV/good-trip/compare/v1.4.1../v1.4.2) (2026-02-24)

### Bug Fixes

- **update:** enhance version comparison by normalizing version strings ([fea86f7](https://github.com/PepeuFBV/good-trip/commit/fea86f76711cf53b5c7a6919609e58c532c9841d))

## [1.4.1](https://github.com/PepeuFBV/good-trip/compare/v1.4.0...v1.4.1) (2026-02-24)

### Bug Fixes

- **update:** ensure update check timestamp is recorded on exit ([45ccbea](https://github.com/PepeuFBV/good-trip/commit/45ccbea67d27067527ea4a9371ee7a098f3587ce))

# [1.4.0](https://github.com/PepeuFBV/good-trip/compare/v1.3.2...v1.4.0) (2026-02-24)

### Features

- **ssh:** add SSH key management commands and scripts ([6ba5758](https://github.com/PepeuFBV/good-trip/commit/6ba575868e5a68efe415f3488faab1f708a87feb))

## [1.3.2](https://github.com/PepeuFBV/good-trip/compare/v1.3.1../v1.3.2) (2026-02-24)

### Bug Fixes

- **release:** update release process to correctly tag and track minor version series ([c34152d](https://github.com/PepeuFBV/good-trip/commit/c34152da2efb733b31401990e3a5da922056c042))

## [1.3.1](https://github.com/PepeuFBV/good-trip/compare/v1.3.0...v1.3.1) (2026-02-24)

### Bug Fixes

- **release:** correct package name for conventional changelog in release workflow ([8da3ef4](https://github.com/PepeuFBV/good-trip/commit/8da3ef46cc717abb84113db9626bb66e7a288085))
- **release:** update package.json using GitHub Contents API to avoid git pushes ([3680001](https://github.com/PepeuFBV/good-trip/commit/36800017e12f661d7315114f1e7fbe7525c0dab1))

# [1.3.0](https://github.com/PepeuFBV/good-trip/compare/v1.2.0...v1.3.0) (2026-02-23)

### Features

- add configuration files for Husky and Prettier ([50ef548](https://github.com/PepeuFBV/good-trip/commit/50ef5483f0b8bc9909d16dfba80acca11b1e9a50))

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
