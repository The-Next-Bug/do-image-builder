# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo manages containerized Hugo blog deployments to DigitalOcean Kubernetes. It builds Docker images for two blog properties and updates Helm chart values to trigger GitOps deployments via ArgoCD.

**Blog sites (git submodules under `images/`):**
- `chrissalch-com/` — chrissalch.com personal site
- `the-next-bug/` — thenextbug.com tech blog

**`helm-charts/`** is a separate git repo (not a submodule; excluded from `.gitignore`) that holds the Kubernetes deployment definitions.

## Common Commands

```bash
# Build and push all images, update helm-charts (full CI pipeline)
make ci

# Update git submodules and push
make ci-update

# Per-image operations (run from images/<name>/)
make build   # build image locally with timestamp tag
make push    # build and push to DO registry
make clean   # remove local image
```

## Architecture

### Build & Deploy Flow

1. Push to `master` → GitHub Actions (`.github/workflows/docker-build-and-push.yaml`)
2. CI authenticates with DigitalOcean registry via `doctl`
3. Root `make ci` iterates each directory under `images/`, running `make ci` (uses `--force-rm --pull` flags)
4. Each image tag is a Unix timestamp: `$(shell date +%s)`
5. Helm chart values are updated with the new image tags, then committed/pushed to the `helm-charts` repo
6. ArgoCD picks up the helm-charts changes and deploys to Kubernetes

### Kubernetes Stack

- **Ingress**: nginx-ingress controller
- **TLS**: cert-manager with Let's Encrypt (ClusterIssuers in `helm-charts/cluster-issuers/`)
- **Deployments**: `helm-charts/site-deploy/` — one Deployment + Service + Ingress per domain
- **Redirects**: A "redirector" nginx pod handles domain redirect rules (e.g., www → apex)
- **GitOps**: `helm-charts/argo-deploy/` defines the ArgoCD root App-of-Apps

### Docker Images

Each image uses a two-stage Dockerfile:
1. **Build stage**: Hugo extended (v0.126.2) compiles the static site
2. **Runtime stage**: nginx serves the compiled output

Hugo theme used by both sites: `hermit-V2`

### Adding a New Blog Post

Blog content lives inside the git submodules (`images/chrissalch-com/` and `images/the-next-bug/`). Add posts as Markdown files under the `content/` directory of the relevant submodule, then run `make ci` (or push to master) to build and deploy.
