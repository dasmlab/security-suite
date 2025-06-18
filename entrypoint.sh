#!/bin/bash
set -e

OUTPUT_DIR=${OUTPUT_DIR:-/output}
CODE_DIR=${GITHUB_WORKSPACE:-/workspace}
CONTAINER_NAME=${CONTAINER_NAME:-}
TARGET_IMAGE=${TARGET_IMAGE:-}
TARGET_ENDPOINT=${TARGET_ENDPOINT:-}

mkdir -p "$OUTPUT_DIR"

# --- SAST (Static Analysis) ---
if [ -d "$CODE_DIR" ] && [ "$(ls -A "$CODE_DIR")" ]; then
    echo "[+] Running SAST (Static Analysis) on $CODE_DIR..."
    bash /suite/sast/run_sast.sh "$CODE_DIR" "$OUTPUT_DIR"
else
    echo "[!] SAST: Source dir $CODE_DIR not present or empty. Skipping SAST scan."
fi

# --- CONTAINER IMAGE SCAN (Trivy) ---
# Use TARGET_IMAGE (eg: httpd:2.4-alpine) instead of container name
if [ -n "$TARGET_IMAGE" ]; then
    echo "[+] Running container image scan on $TARGET_IMAGE..."
    trivy image --format json -o "$OUTPUT_DIR/container_report.json" "$TARGET_IMAGE" || true
elif [ -n "$CONTAINER_NAME" ]; then
    # Optional fallback: scan the running container's filesystem (advanced, usually not needed)
    echo "[!] TARGET_IMAGE not set, attempting Trivy fs scan on running container $CONTAINER_NAME..."
    docker export "$CONTAINER_NAME" | trivy fs - || true
else
    echo "[!] Skipping container image scan; neither TARGET_IMAGE nor CONTAINER_NAME set."
fi

# --- DAST (Endpoint/Active Scan) ---
if [ -n "$TARGET_ENDPOINT" ]; then
    echo "[+] Running DAST (Dynamic/Endpoint Scan) on $TARGET_ENDPOINT..."
    bash /suite/dast/run_dast.sh "$TARGET_ENDPOINT" "$OUTPUT_DIR"
else
    echo "[!] Skipping DAST; TARGET_ENDPOINT not set."
fi

echo "[✓] All security scans complete. Reports in $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"

