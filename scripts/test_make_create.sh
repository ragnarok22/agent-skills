#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cp "$ROOT_DIR/Makefile" "$TMP_DIR/Makefile"
mkdir -p "$TMP_DIR/skills"
touch "$TMP_DIR/README.md" "$TMP_DIR/AGENTS.md"

stderr_file="$TMP_DIR/stderr.txt"
stdout_file="$TMP_DIR/stdout.txt"

if ! make -C "$TMP_DIR" create sample-skill >"$stdout_file" 2>"$stderr_file"; then
  printf 'make create failed unexpectedly.\n'
  printf 'stdout:\n'
  cat "$stdout_file"
  printf 'stderr:\n'
  cat "$stderr_file"
  exit 1
fi

if [[ -s "$stderr_file" ]]; then
  printf 'make create wrote unexpected stderr.\n'
  cat "$stderr_file"
  exit 1
fi

required_files=(
  "$TMP_DIR/skills/sample-skill/SKILL.md"
  "$TMP_DIR/skills/sample-skill/README.md"
  "$TMP_DIR/skills/sample-skill/agents/openai.yaml"
)

for file in "${required_files[@]}"; do
  if [[ ! -s "$file" ]]; then
    printf 'Expected non-empty scaffold file: %s\n' "$file"
    exit 1
  fi
done

readme_file="$TMP_DIR/skills/sample-skill/README.md"

for expected in '`SKILL.md`' '`agents/openai.yaml`' '`scripts/` (optional)' '`references/` (optional)' '`assets/` (optional)'; do
  if ! grep -Fq -- "$expected" "$readme_file"; then
    printf 'README.md missing expected text: %s\n' "$expected"
    printf 'README.md contents:\n'
    cat "$readme_file"
    exit 1
  fi
done

printf 'make create scaffold test passed.\n'
