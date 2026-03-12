# tests

This directory holds the Docker-based integration test harness used to exercise the
`good-trip` installer in a reproducible container environment.

Prerequisites
- Docker with Compose v2 available on PATH (`docker compose` command).
- Sufficient network access to download packages during the installer run.
- Recommended: at least 2 CPU cores and 4GB RAM for the Debian-based test image.

Scripts
- `npm test` — runs the full Docker-based test runner (`bash tests/run_in_docker.sh`).
  - Requires Docker; runs the installer inside a Debian container and then runs an external
    CLI smoke-check in a separate container.
  - Artifacts and combined logs are written to `tests/logs/` (this folder is gitignored).

- `npm run test:ci` — lightweight CI-compatible smoke-check (no Docker).
  - Performs a shell syntax check of `install.sh` and prints the installer's help message.
  - Intended for CI runners that cannot run Docker (fast, low-privilege validation).

How the Docker test works (high level)
1. Build a Debian-based test image that includes the repository workspace.
2. Start the `installer` container (detached), wait for it to finish, and collect logs.
3. Copy internal installer logs and relevant `bin` directories from the installer container
   into `tests/logs/` for inspection.
4. Commit the installer container into an image and run deterministic CLI checks against it.
5. Start a fresh `cli-external` container to validate external CLI invocation.

Logs and debugging
- Combined test logs and per-stage logs live in `tests/logs/` with timestamped filenames.
- If containers are removed by compose lifecycle, the runner keeps the installer container
  alive until it finishes so we can inspect and commit it.

CI notes
- `npm run test:ci` is intended to be safe to run on standard CI runners without Docker.
- If your CI runner supports Docker, prefer `npm test` on a self-hosted runner or configure
  Docker-in-Docker / privileged runners accordingly.

If you want, I can add a GitHub Actions workflow that runs `npm run test:ci` on each PR,
and optionally a separate workflow for running the full Docker test on a self-hosted runner.
