# Docker project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Image discipline
- Multi-stage builds; final stage minimal (distroless/alpine/slim). Pin base images by digest.
- Run as a non-root USER. No secrets in layers or ENV; use build secrets / runtime injection.
- A .dockerignore that excludes .git, node_modules, build artifacts. Order layers for cache reuse (deps before source).
- One process per container; add a HEALTHCHECK. Least surprise: explicit WORKDIR, EXPOSE, ENTRYPOINT.

## Checks
- `hadolint` clean. Scan images (trivy/grype) for known CVEs before publishing.

## Commands
- Lint: hadolint Dockerfile   ·   Build: docker build -t app .   ·   Scan: trivy image app
