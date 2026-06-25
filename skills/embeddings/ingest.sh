#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$1" in
  vault)
    node "$SCRIPT_DIR/ingest-vault.js" "${@:2}"
    ;;
  music)
    source ~/.anotht-agent/.env 2>/dev/null
    node "$SCRIPT_DIR/ingest-music.js"
    ;;
  project)
    if [ -z "$2" ]; then
      echo "Usage: ./ingest.sh project <path>"
      exit 1
    fi
    node "$SCRIPT_DIR/ingest-project.js" "$2"
    ;;
  *)
    echo "Usage: ./ingest.sh <vault|music|project> [args]"
    echo ""
    echo "  vault           Embed vault notes (add --smart to use existing Smart Connections)"
    echo "  music           Embed last.fm listening history"
    echo "  project <path>  Embed a work project"
    ;;
esac
