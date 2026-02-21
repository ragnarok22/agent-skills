# Docker Doctor Check Catalog

Use this catalog when validating script output or running checks manually.

## Check Conventions

- Run commands from the selected audit root.
- Prefer `rg` for static checks. If unavailable, use `grep -nE`.
- Treat all matches as candidates until manually confirmed.
- Default severity points: Critical `12`, High `8`, Medium `5`, Low `2`.

## Tool-Backed Checks

### CHK-COMP-001: Compose parse/config failure

- Category: `correctness`
- Severity: `Critical`
- Command: `docker compose -f <compose-file> config -q`
- Confirm: Command exits non-zero for a Compose file in scope.
- Fix: Resolve schema/typing/env/build references until command passes.

### CHK-DF-001: Dockerfile lint failure (hadolint)

- Category: `maintainability`
- Severity: `Medium`
- Command: `hadolint <dockerfile>`
- Confirm: hadolint reports actionable warnings/errors.
- Fix: Apply rule-specific fixes and re-run lint.

## Dockerfile Rules

### DF-SEC-001: Mutable `:latest` base image

- Category: `security`
- Severity: `Medium`
- Search: `rg -n "^[[:space:]]*FROM[[:space:]]+[^@[:space:]]+:latest([[:space:]]|$)" <dockerfile>`
- Fix: Pin base images by immutable tag or digest.

### DF-SEC-002: Missing non-root user

- Category: `security`
- Severity: `High`
- Search: `rg -n "^[[:space:]]*USER[[:space:]]+" <dockerfile>`
- Confirm: No `USER` exists in final stage.
- Fix: Create and switch to a non-root user.

### DF-SEC-003: Curl/Wget piped directly to shell

- Category: `security`
- Severity: `High`
- Search: `rg -n "(curl|wget).*(\||>)[[:space:]]*(sh|bash)" <dockerfile>`
- Fix: Verify checksums/signatures and avoid direct pipe-to-shell execution.

### DF-OPT-001: Package install without cache cleanup

- Category: `optimization`
- Severity: `Medium`
- Search: `rg -n "^[[:space:]]*RUN[[:space:]].*(apt-get|apt)[[:space:]].*install" <dockerfile>`
- Confirm: Install line does not clear `/var/lib/apt/lists`.
- Fix: Combine install and cleanup in the same `RUN`.

### DF-OPT-002: Missed multi-stage optimization

- Category: `optimization`
- Severity: `Low`
- Confirm: Single-stage Dockerfile includes heavy build tooling.
- Fix: Split build/runtime using multi-stage `FROM`.

### DF-MTN-001: `ADD` used where `COPY` is clearer

- Category: `maintainability`
- Severity: `Low`
- Search: `rg -n "^[[:space:]]*ADD[[:space:]]+" <dockerfile>`
- Fix: Prefer `COPY` unless archive extraction or remote URL behavior is required.

### DF-REL-001: Missing `HEALTHCHECK`

- Category: `reliability`
- Severity: `Low`
- Search: `rg -n "^[[:space:]]*HEALTHCHECK[[:space:]]+" <dockerfile>`
- Confirm: No healthcheck exists for a long-running service image.
- Fix: Add a lightweight container healthcheck.

## Compose Rules

### CP-SEC-001: Privileged container

- Category: `security`
- Severity: `Critical`
- Search: `rg -n "^[[:space:]]*privileged:[[:space:]]*true" <compose-file>`
- Fix: Remove privileged mode; grant least-privilege capabilities only.

### CP-SEC-002: Docker socket mounted

- Category: `security`
- Severity: `Critical`
- Search: `rg -n "/var/run/docker\.sock" <compose-file>`
- Fix: Remove socket mount or isolate to trusted admin-only workflows.

### CP-SEC-003: Host network mode

- Category: `security`
- Severity: `High`
- Search: `rg -n "^[[:space:]]*network_mode:[[:space:]]*['\"]?host['\"]?" <compose-file>`
- Fix: Use explicit bridge networks and published ports.

### CP-SEC-004: Public host port publishing

- Category: `security`
- Severity: `Medium`
- Search: `rg -n "^[[:space:]]*-[[:space:]]*\"?[0-9]+:[0-9]+" <compose-file>`
- Confirm: Port mapping is not constrained to `127.0.0.1`.
- Fix: Bind to loopback when external exposure is not required.

### CP-COR-001: Missing build context path

- Category: `correctness`
- Severity: `High`
- Search: `rg -n "^[[:space:]]*context:[[:space:]]+" <compose-file>`
- Confirm: Local relative context path does not exist.
- Fix: Correct path or create expected build context directory.

### CP-MTN-001: Mutable `:latest` image tags

- Category: `maintainability`
- Severity: `Medium`
- Search: `rg -n "^[[:space:]]*image:[[:space:]].*:latest([[:space:]]|$)" <compose-file>`
- Fix: Pin image tags to tested versions or digests.

### CP-REL-001: Missing restart policy

- Category: `reliability`
- Severity: `Medium`
- Search: `rg -n "^[[:space:]]*restart:[[:space:]]+" <compose-file>`
- Confirm: Service workloads lack restart policy and are expected to self-heal.
- Fix: Add `restart: unless-stopped` or an explicit project policy.

### CP-REL-002: Missing service healthcheck

- Category: `reliability`
- Severity: `Low`
- Search: `rg -n "^[[:space:]]*healthcheck:[[:space:]]*$" <compose-file>`
- Fix: Add `healthcheck` blocks for stateful or critical services.

### CP-OPT-001: Missing container resource limits

- Category: `optimization`
- Severity: `Low`
- Search: `rg -n "mem_limit:|cpus:|resources:" <compose-file>`
- Confirm: Compose stack has no memory/CPU bounds.
- Fix: Add limits appropriate to runtime environment.
