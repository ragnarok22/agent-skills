#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="$ROOT_DIR/skills"

SOURCES=(
  "$HOME/.agents/skills"
  "$HOME/.codex/skills"
)

mkdir -p "$DEST_DIR"

imported=0
updated=0

for source in "${SOURCES[@]}"; do
  if [[ ! -d "$source" ]]; then
    echo "skip missing source: $source"
    continue
  fi

  for skill_dir in "$source"/*; do
    [[ -d "$skill_dir" ]] || continue

    skill_name="$(basename "$skill_dir")"
    target_dir="$DEST_DIR/$skill_name"

    if [[ -d "$target_dir" ]]; then
      mkdir -p "$target_dir"
      cp -R "$skill_dir"/. "$target_dir"/
      updated=$((updated + 1))
      echo "updated: $skill_name"
    else
      cp -R "$skill_dir" "$target_dir"
      imported=$((imported + 1))
      echo "imported: $skill_name"
    fi
  done
done

echo "done: imported=$imported updated=$updated"
