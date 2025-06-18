#!/bin/bash
set -e

CODE_DIR="$1"
OUTPUT_DIR="$2"

if [ -z "$CODE_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 CODE_DIR OUTPUT_DIR"
    exit 1
fi

echo "[SAST] Running Trivy filesystem scan..."
trivy fs --scanners vuln,secret,config --format json -o "$OUTPUT_DIR/trivy_code_report.json" "$CODE_DIR" || true

echo "[SAST] Running Semgrep..."
semgrep --config=auto --json --output "$OUTPUT_DIR/semgrep_report.json" "$CODE_DIR" || true

# Optionally add more tools here

echo "[SAST] Static analysis complete."

