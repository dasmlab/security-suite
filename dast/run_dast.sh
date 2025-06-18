#!/bin/bash
set -e

ENDPOINT="$1"
OUTPUT_DIR="$2"

if [ -z "$ENDPOINT" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 ENDPOINT OUTPUT_DIR"
    exit 1
fi

echo "[DAST] Running Nikto scan on $ENDPOINT..."
nikto -host "$ENDPOINT" -output "$OUTPUT_DIR/nikto_report.txt" || true

# Optionally add zaproxy, or other DAST tools here

echo "[DAST] Dynamic analysis complete."

