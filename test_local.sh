#!/bin/bash
set -e

# 1. Pull and start a test target container (httpd as example)
TARGET_IMAGE="httpd:2.4-alpine"
CONTAINER_NAME="test-httpd"
HOST_PORT=8888

echo "[*] Pulling test image: $TARGET_IMAGE"
docker pull $TARGET_IMAGE

echo "[*] Starting test container..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true
docker run -d --name $CONTAINER_NAME -p $HOST_PORT:80 $TARGET_IMAGE

# 2. Clone the httpd source for SAST (we use a simple git checkout)
CODE_DIR="test_code"
rm -rf $CODE_DIR
git clone https://github.com/apache/httpd.git $CODE_DIR || mkdir $CODE_DIR

# 3. Create output dir
OUTPUT_DIR=$(pwd)/test_output
mkdir -p $OUTPUT_DIR

# 4. Run your security suite
echo "[*] Running dasmlab_security_suite on $CONTAINER_NAME and endpoint http://localhost:$HOST_PORT"
docker run --rm \
  -v "$CODE_DIR":/workspace:ro \
  -v "$OUTPUT_DIR":/output \
  --network host \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e GITHUB_WORKSPACE=/workspace \
  -e CONTAINER_NAME=$CONTAINER_NAME \
  -e TARGET_ENDPOINT="http://localhost:$HOST_PORT" \
  dasmlab-security-suite:latest

echo "[*] Done. Reports are in $OUTPUT_DIR"

# 5. Stop and remove test container
docker rm -f $CONTAINER_NAME

