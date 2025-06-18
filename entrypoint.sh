#!/bin/bash
set -e

OUTPUT_DIR=${OUTPUT_DIR:-/output}
CODE_DIR=${GITHUB_WORKSPACE:-/workspace}
CONTAINER_NAME=${CONTAINER_NAME:-}
TARGET_ENDPOINT=${TARGET_ENDPOINT:-}

mkdir -p "$OUTPUT_DIR"

echo "[+] Running SAST (Static Analysis)..."
bash /suite/sast/run_sast.sh "$CODE_DIR" "$OUTPUT_DIR"

if [ -n "$CONTAINER_NAME" ]; then
    echo "[+] Running container image scan on $CONTAINER_NAME..."
    trivy image --format json -o "$OUTPUT_DIR/container_report.json" "$CONTAINER_NAME" || true
else
    echo "[!] Skipping container image scan; CONTAINER_NAME not set."
fi

if [ -n "$TARGET_ENDPOINT" ]; then
    echo "[+] Running DAST (Dynamic/Endpoint Scan) on $TARGET_ENDPOINT..."
    bash /suite/dast/run_dast.sh "$TARGET_ENDPOINT" "$OUTPUT_DIR"
else
    echo "[!] Skipping DAST; TARGET_ENDPOINT not set."
fi

echo "[✓] All security scans complete. Reports in $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"

