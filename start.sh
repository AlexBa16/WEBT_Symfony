#!/bin/bash

usage() {
    echo "Usage: $0 [options] [services...]"
    echo ""
    echo "Services: app (default: all)"
    echo ""
    echo "Options:"
    echo "  -b, --build     Force rebuild images (needs internet — not during the exam)"
    echo "  -d, --detach    Run in background"
    echo "  -s, --stop      Stop running containers"
    echo "  -r, --restart   Restart containers"
    echo "  -l, --logs      Show logs (combine with service names)"
    echo "  -c, --console   Run a Symfony console command in the container"
    echo "  --status        Show container status"
    echo "  -h, --help      Show this help"
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

ACTION="up"
BUILD=""
DETACH=""
SERVICES=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--build)   BUILD="--build"; shift ;;
        -d|--detach)  DETACH="-d"; shift ;;
        -s|--stop)    ACTION="stop"; shift ;;
        -r|--restart) ACTION="restart"; shift ;;
        -l|--logs)    ACTION="logs"; shift ;;
        -c|--console) ACTION="console"; shift; break ;;
        --status)     ACTION="status"; shift ;;
        -h|--help)    usage; exit 0 ;;
        app)          SERVICES="$SERVICES $1"; shift ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# Rebuilding re-runs apt-get inside the Dockerfile, which needs a working
# internet connection. During the exam there is none, and a half-finished build
# leaves the student without an environment. Plain ./start.sh never builds: the
# image is already there, either built beforehand or loaded from a .tar.
if [ -n "$BUILD" ] && [ "${ALLOW_BUILD:-}" != "1" ]; then
    echo "Refusing to rebuild the image."
    echo ""
    echo "Rebuilding downloads system packages and needs internet. During the exam"
    echo "there is none, and a failed rebuild leaves you without a working setup."
    echo ""
    echo "You almost certainly just want:"
    echo "    ./start.sh"
    echo ""
    echo "If you really do need to rebuild and you have internet:"
    echo "    ALLOW_BUILD=1 ./start.sh -b"
    exit 1
fi

case $ACTION in
    up)      docker compose -f "$COMPOSE_FILE" up $BUILD $DETACH $SERVICES ;;
    stop)    docker compose -f "$COMPOSE_FILE" stop $SERVICES ;;
    restart) docker compose -f "$COMPOSE_FILE" restart $SERVICES ;;
    logs)    docker compose -f "$COMPOSE_FILE" logs -f $SERVICES ;;
    status)  docker compose -f "$COMPOSE_FILE" ps ;;
    console) docker compose -f "$COMPOSE_FILE" exec app php bin/console "$@" ;;
esac
