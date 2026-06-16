#!/bin/bash
DOCKER_DIR="$(dirname "$0")/docker"
source "$DOCKER_DIR/.env"
CONTAINER_NAME="${PROJECT_NAME}-dev"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Starting dev container..."
  docker compose -f "$DOCKER_DIR/docker-compose.yaml" up -d dev
fi

if [ $# -eq 0 ]; then
  docker exec -it "$CONTAINER_NAME" bash
else
  docker exec "$CONTAINER_NAME" bash -c "source install/setup.bash && $*"
fi
