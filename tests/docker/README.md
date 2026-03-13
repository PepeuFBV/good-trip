# Tests: Docker Environment

This folder contains a Docker-based test environment to run the repository's
`install.sh` inside a Debian-based container.

Usage:

- Build and run with Docker Compose:

```
bash tests/run_in_docker.sh
```

Notes:

- The container runs as a non-root user `tester` who has passwordless sudo.
- The workspace is bind-mounted into the container so changes are visible.
