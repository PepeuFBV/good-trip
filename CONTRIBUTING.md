# Contributing to good-trip

## Prerequisites

- `bash` (≥ 3.2 for macOS compatibility)
- `shellcheck` — for linting shell scripts
- `docker` — for running the full BATS test suite locally

## Workflow

1. Fork the repository
2. Create a branch from `main`:
   ```sh
   git checkout -b feat/my-feature
   ```
3. Make your changes
4. Verify syntax and linting:
   ```sh
   bash -n install.sh          # syntax check
   shellcheck install.sh        # lint
   ```
5. Run unit tests:
   ```sh
   npm run test:unit            # BATS unit tests (no Docker required)
   npm test                     # full suite inside Docker
   ```
6. Commit following [Conventional Commits](https://www.conventionalcommits.org/):

   | Prefix                           | When to use                        | Version bump |
   | -------------------------------- | ---------------------------------- | ------------ |
   | `feat:`                          | New feature or behaviour           | minor        |
   | `fix:`                           | Bug fix                            | patch        |
   | `docs:`                          | Documentation only                 | —            |
   | `refactor:`                      | Code cleanup, no behaviour change  | —            |
   | `ci:`                            | CI/CD changes                      | —            |
   | `chore:`                         | Maintenance tasks                  | —            |
   | `feat!:` / `BREAKING CHANGE:`    | Breaking change                    | **major**    |

   Commit messages are enforced by commitlint on every PR.

7. Open a Pull Request against `main` — fill in the PR template checklist

## Key conventions

- **Idempotent scripts** — every script must be safe to run more than once
- **macOS compatibility** — avoid bash 4+ constructs; target bash 3.2
- **No external state assumptions** — scripts must work on a clean machine
- **Scope hints** — commitlint accepts optional scopes:
  `zsh`, `git`, `aliases`, `bootstrap`, `install`, `update`, `bin`, `ci`, `docs`, `release`

## Automated release

Merging to `main` triggers semantic-release automatically:
it creates the tag, GitHub release, and updates `CHANGELOG.md` and `version.txt`.
**Do not manually edit these files.**
