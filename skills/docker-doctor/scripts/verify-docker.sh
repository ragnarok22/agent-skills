#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-.}"

if [[ ! -d "$ROOT_DIR" ]]; then
  echo "ERROR|root|$ROOT_DIR|Directory does not exist"
  exit 2
fi

cd "$ROOT_DIR"

if command -v rg >/dev/null 2>&1; then
  SEARCH_TOOL="rg"
else
  SEARCH_TOOL="grep"
fi

critical_count=0
high_count=0
medium_count=0
low_count=0
total_findings=0

emit_check() {
  local check_id="$1"
  local status="$2"
  local details="$3"
  echo "CHECK|$check_id|$status|$details"
}

emit_finding() {
  local severity="$1"
  local category="$2"
  local rule_id="$3"
  local location="$4"
  local issue="$5"
  local fix="$6"

  total_findings=$((total_findings + 1))
  case "$severity" in
    critical) critical_count=$((critical_count + 1)) ;;
    high) high_count=$((high_count + 1)) ;;
    medium) medium_count=$((medium_count + 1)) ;;
    low) low_count=$((low_count + 1)) ;;
    *) ;;
  esac

  echo "FINDING|$severity|$category|$rule_id|$location|$issue|$fix"
}

search_lines() {
  local pattern="$1"
  local file_path="$2"
  if [[ "$SEARCH_TOOL" == "rg" ]]; then
    rg -n --no-heading "$pattern" "$file_path" || true
  else
    grep -nE "$pattern" "$file_path" || true
  fi
}

record_pattern_findings() {
  local severity="$1"
  local category="$2"
  local rule_id="$3"
  local file_path="$4"
  local pattern="$5"
  local issue="$6"
  local fix="$7"

  while IFS=: read -r line _; do
    [[ -z "${line:-}" ]] && continue
    emit_finding "$severity" "$category" "$rule_id" "${file_path}:${line}" "$issue" "$fix"
  done < <(search_lines "$pattern" "$file_path")
}

strip_quotes() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  value="${value#\'}"
  value="${value%\'}"
  echo "$value"
}

dockerfiles=()
while IFS= read -r file_path; do
  [[ -z "$file_path" ]] && continue
  dockerfiles+=("$file_path")
done < <(
  find . -type f \
    \( -name 'Dockerfile' -o -name 'Dockerfile.*' -o -name '*.Dockerfile' \) \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/.venv/*' \
    -not -path '*/vendor/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' | sed 's|^\./||' | sort
)

compose_files=()
while IFS= read -r file_path; do
  [[ -z "$file_path" ]] && continue
  compose_files+=("$file_path")
done < <(
  find . -type f \
    \( -name 'docker-compose.yml' -o -name 'docker-compose.yaml' -o -name 'compose.yml' -o -name 'compose.yaml' \) \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/.venv/*' \
    -not -path '*/vendor/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' | sed 's|^\./||' | sort
)

echo "INFO|root|$(pwd)"
echo "SUMMARY|dockerfiles|${#dockerfiles[@]}"
echo "SUMMARY|compose_files|${#compose_files[@]}"

if [[ ${#dockerfiles[@]} -eq 0 && ${#compose_files[@]} -eq 0 ]]; then
  echo "RESULT|pass|nothing_to_audit"
  exit 0
fi

has_docker_compose=0
if command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    has_docker_compose=1
  fi
fi

if [[ $has_docker_compose -eq 1 ]]; then
  for compose_file in "${compose_files[@]}"; do
    if output="$(docker compose -f "$compose_file" config -q 2>&1)"; then
      emit_check "compose-config" "pass" "$compose_file"
    else
      first_line="$(printf '%s\n' "$output" | head -n 1 | tr -s ' ')"
      emit_check "compose-config" "fail" "${compose_file}: ${first_line:-unknown_error}"
      emit_finding \
        "critical" \
        "correctness" \
        "CHK-COMP-001" \
        "${compose_file}:1" \
        "Compose file fails docker compose config -q." \
        "Fix syntax/schema/env/build references until docker compose config -q succeeds."
    fi
  done
else
  emit_check "compose-config" "skipped" "docker compose CLI unavailable"
fi

has_hadolint=0
if command -v hadolint >/dev/null 2>&1; then
  has_hadolint=1
fi

if [[ $has_hadolint -eq 1 ]]; then
  for dockerfile in "${dockerfiles[@]}"; do
    if lint_output="$(hadolint "$dockerfile" 2>&1)"; then
      emit_check "hadolint" "pass" "$dockerfile"
    else
      first_line="$(printf '%s\n' "$lint_output" | head -n 1 | tr -s ' ')"
      emit_check "hadolint" "fail" "${dockerfile}: ${first_line:-lint_issues}"
      emit_finding \
        "medium" \
        "maintainability" \
        "CHK-DF-001" \
        "${dockerfile}:1" \
        "hadolint reported issues for this Dockerfile." \
        "Run hadolint locally and apply rule-specific fixes."
    fi
  done
else
  emit_check "hadolint" "skipped" "hadolint not installed; heuristic checks only"
fi

for dockerfile in "${dockerfiles[@]}"; do
  record_pattern_findings \
    "medium" \
    "security" \
    "DF-SEC-001" \
    "$dockerfile" \
    "^[[:space:]]*FROM[[:space:]]+[^@[:space:]]+:latest([[:space:]]|$)" \
    "Mutable :latest base image found." \
    "Pin base image with a specific tag or digest."

  user_hits="$(search_lines "^[[:space:]]*USER[[:space:]]+" "$dockerfile")"
  if [[ -z "$user_hits" ]]; then
    emit_finding \
      "high" \
      "security" \
      "DF-SEC-002" \
      "${dockerfile}:1" \
      "No USER instruction found; container may run as root." \
      "Create and switch to a non-root user in the final stage."
  fi

  record_pattern_findings \
    "high" \
    "security" \
    "DF-SEC-003" \
    "$dockerfile" \
    "(curl|wget).*(\\||>)[[:space:]]*(sh|bash)" \
    "Remote content piped directly to shell." \
    "Download artifacts separately and verify checksum/signature before execution."

  while IFS=: read -r line content; do
    [[ -z "${line:-}" ]] && continue
    if [[ "$content" != *"/var/lib/apt/lists"* ]]; then
      emit_finding \
        "medium" \
        "optimization" \
        "DF-OPT-001" \
        "${dockerfile}:${line}" \
        "Apt install without apt-list cleanup in same RUN layer." \
        "Clean apt lists in the same RUN command to reduce image size."
    fi
  done < <(search_lines "^[[:space:]]*RUN[[:space:]].*(apt-get|apt)[[:space:]].*install" "$dockerfile")

  record_pattern_findings \
    "low" \
    "maintainability" \
    "DF-MTN-001" \
    "$dockerfile" \
    "^[[:space:]]*ADD[[:space:]]+" \
    "ADD instruction used." \
    "Prefer COPY unless ADD-specific behavior is required."

  health_hits="$(search_lines "^[[:space:]]*HEALTHCHECK[[:space:]]+" "$dockerfile")"
  if [[ -z "$health_hits" ]]; then
    emit_finding \
      "low" \
      "reliability" \
      "DF-REL-001" \
      "${dockerfile}:1" \
      "No HEALTHCHECK instruction found." \
      "Add a lightweight healthcheck for long-running services."
  fi

  from_count="$(search_lines "^[[:space:]]*FROM[[:space:]]+" "$dockerfile" | wc -l | tr -d ' ')"
  build_hits="$(search_lines "(build-essential|gcc|g\\+\\+|make|go build|cargo build|npm ci|yarn install)" "$dockerfile")"
  if [[ "$from_count" == "1" && -n "$build_hits" ]]; then
    first_build_line="${build_hits%%:*}"
    emit_finding \
      "low" \
      "optimization" \
      "DF-OPT-002" \
      "${dockerfile}:${first_build_line}" \
      "Single-stage Dockerfile appears to include build tooling." \
      "Use multi-stage builds to keep runtime images smaller."
  fi
done

for compose_file in "${compose_files[@]}"; do
  record_pattern_findings \
    "critical" \
    "security" \
    "CP-SEC-001" \
    "$compose_file" \
    "^[[:space:]]*privileged:[[:space:]]*true" \
    "Service runs in privileged mode." \
    "Remove privileged mode and grant only required capabilities."

  record_pattern_findings \
    "critical" \
    "security" \
    "CP-SEC-002" \
    "$compose_file" \
    "/var/run/docker\\.sock" \
    "Docker socket is mounted into a container." \
    "Avoid mounting docker.sock except in tightly controlled admin workflows."

  record_pattern_findings \
    "high" \
    "security" \
    "CP-SEC-003" \
    "$compose_file" \
    "^[[:space:]]*network_mode:[[:space:]]*['\\\"]?host['\\\"]?" \
    "Host network mode is enabled." \
    "Use explicit Compose networks and only publish required ports."

  while IFS=: read -r line content; do
    [[ -z "${line:-}" ]] && continue
    if [[ "$content" == *"127.0.0.1:"* || "$content" == *"localhost:"* ]]; then
      continue
    fi
    emit_finding \
      "medium" \
      "security" \
      "CP-SEC-004" \
      "${compose_file}:${line}" \
      "Host port appears publicly bound on all interfaces." \
      "Bind to 127.0.0.1 when public exposure is not required."
  done < <(search_lines "^[[:space:]]*-[[:space:]]*\"?[0-9]+:[0-9]+" "$compose_file")

  record_pattern_findings \
    "medium" \
    "maintainability" \
    "CP-MTN-001" \
    "$compose_file" \
    "^[[:space:]]*image:[[:space:]].*:latest([[:space:]]|$)" \
    "Mutable :latest image tag found in Compose." \
    "Pin image tags or digests for repeatable deployments."

  while IFS=: read -r line content; do
    [[ -z "${line:-}" ]] && continue
    context_value="$(printf '%s' "$content" | sed -E 's/^[[:space:]]*context:[[:space:]]*//; s/[[:space:]]+#.*$//')"
    context_value="$(strip_quotes "$context_value")"
    [[ -z "$context_value" ]] && continue
    if [[ "$context_value" == *'$'* ]]; then
      emit_check "build-context" "skipped" "${compose_file}:${line} uses env interpolation"
      continue
    fi
    if [[ "$context_value" =~ ^(https?://|git://) ]]; then
      continue
    fi

    compose_dir="$(dirname "$compose_file")"
    candidate_path="$compose_dir/$context_value"
    if [[ "$context_value" == "." ]]; then
      candidate_path="$compose_dir"
    fi

    if [[ ! -e "$candidate_path" ]]; then
      emit_finding \
        "high" \
        "correctness" \
        "CP-COR-001" \
        "${compose_file}:${line}" \
        "Referenced build context path does not exist." \
        "Fix context path or create the expected build directory."
    fi
  done < <(search_lines "^[[:space:]]*context:[[:space:]]+" "$compose_file")

  restart_hits="$(search_lines "^[[:space:]]*restart:[[:space:]]+" "$compose_file")"
  if [[ -z "$restart_hits" ]]; then
    emit_finding \
      "medium" \
      "reliability" \
      "CP-REL-001" \
      "${compose_file}:1" \
      "No restart policy found in Compose file." \
      "Add restart behavior such as unless-stopped where appropriate."
  fi

  compose_health_hits="$(search_lines "^[[:space:]]*healthcheck:[[:space:]]*$" "$compose_file")"
  if [[ -z "$compose_health_hits" ]]; then
    emit_finding \
      "low" \
      "reliability" \
      "CP-REL-002" \
      "${compose_file}:1" \
      "No service healthcheck blocks found." \
      "Add healthcheck definitions for critical services."
  fi

  limit_hits="$(search_lines "mem_limit:|cpus:|resources:" "$compose_file")"
  if [[ -z "$limit_hits" ]]; then
    emit_finding \
      "low" \
      "optimization" \
      "CP-OPT-001" \
      "${compose_file}:1" \
      "No memory/CPU limits found in Compose file." \
      "Set conservative resource limits for predictable container behavior."
  fi
done

echo "SUMMARY|critical|$critical_count"
echo "SUMMARY|high|$high_count"
echo "SUMMARY|medium|$medium_count"
echo "SUMMARY|low|$low_count"
echo "SUMMARY|total_findings|$total_findings"

if [[ $total_findings -eq 0 ]]; then
  echo "RESULT|pass|no_findings"
else
  echo "RESULT|fail|findings_detected"
fi
