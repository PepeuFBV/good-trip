#!/usr/bin/env bash
set -euo pipefail

# Build and run the installer service and then run external CLI tests
LOG_DIR="tests/logs"
mkdir -p "$LOG_DIR"
TS=$(date -u +%Y%m%dT%H%M%SZ)
# combined log path (used later as COMBINED_LOG)

echo "Building and running docker compose test (installer + cli-external)..."
echo "Building images..."
docker compose build --progress=plain

# Clean previous compose state to avoid name conflicts
echo "Cleaning previous compose state..."
docker compose down --remove-orphans || true
docker rm -f good-trip-cli-external-1 good-trip-installer-1 2>/dev/null || true

# Run installer service in detached mode so the container remains for inspection
echo "Running installer service (detached)..."
INSTALLER_LOG="$LOG_DIR/installer_${TS}.log"

# Start installer detached
docker compose up --no-color --build -d installer

# Find installer container id (compose may not return immediately)
CID_INSTALLER=""
for _ in {1..30}; do
	CID_INSTALLER=$(docker compose ps -q installer || docker ps -a --filter "name=good-trip-installer-1" -q | head -n1 || true)
	if [[ -n "$CID_INSTALLER" ]]; then
		break
	fi
	sleep 1
done
echo "CID_INSTALLER=$CID_INSTALLER"
if [[ -z "$CID_INSTALLER" ]]; then
	echo "ERROR: installer container not found after waiting; dumping compose ps and installer logs" | tee "$INSTALLER_LOG"
	docker compose ps --all || true
	docker compose logs installer --no-color --tail=200 || true
	exit 1
fi

# Wait for the installer container to finish and capture its exit code and logs
if [[ -n "$CID_INSTALLER" ]]; then
	EXIT1=$(docker wait "$CID_INSTALLER" || echo 1)
	docker logs "$CID_INSTALLER" 2>&1 | tee "$INSTALLER_LOG"
else
	echo "No installer container found" | tee "$INSTALLER_LOG"
	EXIT1=1
fi

# Copy installer internal log and possible binary dirs for inspection
if [[ -n "$CID_INSTALLER" ]]; then
	docker cp "$CID_INSTALLER":/home/tester/.local/share/good-trip/install.log "$LOG_DIR/installer_internal_${TS}.log" 2>/dev/null || true
	docker cp "$CID_INSTALLER":/root/.local/bin "$LOG_DIR/installer_root_local_bin_${TS}" 2>/dev/null || true
	docker cp "$CID_INSTALLER":/home/tester/.local/bin "$LOG_DIR/installer_home_local_bin_${TS}" 2>/dev/null || true
	docker cp "$CID_INSTALLER":/root/bin "$LOG_DIR/installer_root_bin_${TS}" 2>/dev/null || true
	docker cp "$CID_INSTALLER":/home/tester/bin "$LOG_DIR/installer_home_bin_${TS}" 2>/dev/null || true
fi

# Commit the installer container and run CLI checks from the committed image (deterministic)
if [[ -n "$CID_INSTALLER" ]]; then
	# Wait up to 30s for the installed CLI to appear in any expected target path inside the installer container.
	targets=("/root/.local/bin/good-trip" "/home/tester/.local/bin/good-trip" "/usr/local/bin/good-trip" "/home/tester/workspace/bin/good-trip")
	found_path=""
	for _ in {1..30}; do
		for t in "${targets[@]}"; do
			# Prefer docker exec if the container is running
			if docker inspect -f '{{.State.Running}}' "$CID_INSTALLER" 2>/dev/null | grep -q true; then
				if docker exec "$CID_INSTALLER" bash -lc "[ -f '$t' ]" >/dev/null 2>&1; then
					found_path="$t"
					break 2
				fi
			else
				# Try copying the file out as a presence check (copy will fail if file missing)
				tmp_check_dir=$(mktemp -d)
				if docker cp "$CID_INSTALLER":"$t" "$tmp_check_dir/" >/dev/null 2>&1; then
					found_path="$t"
					rm -rf "$tmp_check_dir"
					break 2
				fi
				rm -rf "$tmp_check_dir"
			fi
		done
		sleep 1
	done
	if [[ -n "$found_path" ]]; then
		echo "Detected CLI at $found_path inside installer container before commit" | tee -a "$LOG_DIR/installer_internal_${TS}.log"
	else
		echo "WARNING: CLI not found in expected paths inside installer container before commit" | tee -a "$LOG_DIR/installer_internal_${TS}.log"
	fi

	COMMIT_TAG="good-trip-installed:${TS}"
	echo "Committing installer container $CID_INSTALLER to image $COMMIT_TAG"
	docker commit "$CID_INSTALLER" "$COMMIT_TAG" || echo "docker commit failed"
	echo "Running CLI checks from committed image..."
	docker run --rm --env NO_CHSH=1 "$COMMIT_TAG" bash -lc "echo 'ENV PATH='$PATH; echo '---- ls bins ----'; ls -la /root/.local/bin 2>/dev/null || true; ls -la /home/tester/.local/bin 2>/dev/null || true; ls -la /root/bin 2>/dev/null || true; ls -la /home/tester/bin 2>/dev/null || true; echo '---- which good-trip ----'; command -v good-trip || true; echo '---- version/status ----'; ( /root/.local/bin/good-trip --version || /home/tester/.local/bin/good-trip --version || /root/bin/good-trip --version || /home/tester/bin/good-trip --version ) && ( /root/.local/bin/good-trip status || /home/tester/.local/bin/good-trip status || /root/bin/good-trip status || /home/tester/bin/good-trip status )" 2>&1 | tee "$LOG_DIR/installer_committed_cli_check_${TS}.log" || true
fi

# Run cli-external service (fresh container)
echo "Running cli-external service..."
CLI_LOG="$LOG_DIR/cli_external_${TS}.log"
set +e
docker compose up --no-color --abort-on-container-exit --exit-code-from cli-external cli-external 2>&1 | tee "$CLI_LOG"
EXIT2=${PIPESTATUS[0]:-1}
set -e

# Copy cli-external internal log from container if present
CID_CLI=$(docker compose ps -q cli-external || true)
if [[ -n "$CID_CLI" ]]; then
	docker cp "$CID_CLI":/home/tester/.local/share/good-trip/install.log "$LOG_DIR/cli_internal_${TS}.log" 2>/dev/null || true
fi

# Combine logs for convenience
COMBINED_LOG="$LOG_DIR/install_test_${TS}.log"
cat "$INSTALLER_LOG" "$CLI_LOG" > "$COMBINED_LOG" || true

echo "Installer exit: $EXIT1; CLI exit: $EXIT2"
echo "Combined log saved to $COMBINED_LOG"

# Exit non-zero if any stage failed
if [[ "$EXIT1" -ne 0 ]] || [[ "$EXIT2" -ne 0 ]]; then
	exit 1
fi

exit 0
