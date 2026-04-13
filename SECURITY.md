# Security Policy

## Supported versions

Only the latest release receives security fixes.
Older versions are not maintained.

| Version | Supported |
| ------- | --------- |
| latest  | ✅        |
| older   | ❌        |

## Reporting a vulnerability

**Do not open a public issue for security reports.**

Use [GitHub Security Advisories](https://github.com/PepeuFBV/good-trip/security/advisories/new)
to report privately. You will receive a response within 7 days.

Please include:

- A clear description of the vulnerability
- Steps to reproduce
- Potential impact (e.g., credential exposure, privilege escalation)
- Any suggested fix, if you have one

## Scope

This project is a shell-based dotfiles manager. Security-sensitive areas include:

- **SSH key handling** — `scripts/ssh-keygen.sh`, `scripts/ssh-github.sh`
- **API token handling** — GitHub PAT passed via `--token` or `$GITHUB_TOKEN`
- **Installer curl-pipe pattern** — `install.sh` fetched via `curl | bash`
- **Auto-update mechanism** — `scripts/update.sh` fetches and executes remote code

## Disclosure policy

Once a fix is merged and released, the advisory will be published publicly.
