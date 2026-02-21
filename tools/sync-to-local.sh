#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/skills"

TARGETS=(
  "$HOME/.agents/skills"
  "$HOME/.codex/skills"
)

if [[ ! -d "$SRC_DIR" ]]; then
  echo "missing source directory: $SRC_DIR"
  exit 1
fi

synced=0

for target_root in "${TARGETS[@]}"; do
  mkdir -p "$target_root"

  for skill_dir in "$SRC_DIR"/*; do
    [[ -d "$skill_dir" ]] || continue

    skill_name="$(basename "$skill_dir")"
    target_dir="$target_root/$skill_name"

    mkdir -p "$target_dir"
    cp -R "$skill_dir"/. "$target_dir"/
    synced=$((synced + 1))
    echo "synced: $skill_name -> $target_root"
  done
done

echo "done: synced=$synced"
