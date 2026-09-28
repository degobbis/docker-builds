🇬🇧 English | 🇩🇪 [Deutsch](README_DE.md)

# docker-builds

## 1. Overview

This repository builds and publishes Docker images with a Makefile, Bash scripts, and Dockerfiles. The build process is configured through `.env`, which is created by copying `.env-example`. The scripts in `templates/init`, `templates/build`, and `templates/push` provide the reusable initialization, build, and push logic.

The Makefile exports its variables globally at the top of the file. This makes the configured values available to the subsequent Bash scripts.

## 2. Local usage

### Prerequisites

- Docker with Buildx support
- GNU Make
- Bash >=4.0
- A Docker Hub account if you want to publish images
- A GitHub Container Registry (GHCR) login for multi-platform intermediate images

### Configuration

Create the local environment file from the example:

```bash
cp .env-example .env
```

Then adjust the values in `.env` as required. The example contains placeholders such as:

| Variable | Purpose | Example |
|---|---|---|
| `DOCKER_HUB_REPOSITORY` | Docker Hub username or organization; it corresponds to the GitHub username in the default setup | `"degobbis"` |
| `DOCKER_HUB_REPOSITORY_LOCAL_PREFIX` | Registry prefix for multi-platform intermediate images; GHCR is used instead of a local registry | `"ghcr.io"` |
| `<IMAGE>_VERSION` | Version of an individual image, for example `PHP82_VERSION` | image-specific value |

Historically, the intermediate registry was used because of the multi-architecture push limitation in Docker Hub's Free tier. The configured prefix is now GHCR rather than a local registry.

### Image names and registries

For an image named `php82`, the relevant names are constructed as follows:

```make
IMAGE_BUILD_DOCKERHUB = "$DOCKER_HUB_REPOSITORY/php82"
# Result: degobbis/php82

IMAGE_BUILD = "$DOCKER_HUB_REPOSITORY_LOCAL_PREFIX/$DOCKER_HUB_REPOSITORY/$IMAGE_BUILD_NAME"
# Result: ghcr.io/degobbis/php82
```

`IMAGE_BUILD_DOCKERHUB` is the final Docker Hub target. `IMAGE_BUILD` is the GHCR target used for the multi-platform build and the subsequent GHCR-to-Docker-Hub push.

### Make commands

List the available targets with:

```bash
make help
```

Build an image locally or through the repository's standard target, for example:

```bash
make build-php82
make build-mariadb118
```

A multi-platform build can be requested with:

```bash
make build-php82 multi-platforms=1
```

To push an existing multi-platform image from GHCR to Docker Hub without rebuilding it, use:

```bash
make build-php82 multi-platforms=1 only-push=1
```

The exact image targets depend on the image definitions in the repository.

### Docker login

The local scripts do **not** perform Docker login. Log in locally using Docker's credential store/keychain, for example:

```bash
docker login ghcr.io
docker login
```

Do not put registry passwords into `.env` or into the build scripts. In GitHub Actions, authentication is configured separately as described below.

## 3. GitHub Actions automation

Workflows are located in `.github/workflows/` and are split into a master workflow and reusable subflows.

### Workflow overview

| Workflow | Role |
|---|---|
| `builds.yml` | Master workflow: selects changed images, creates the matrix, calls one build subflow per image, and starts result collection |
| `subflows/detect-changes.yml` | Reusable change detector, called when `changedImages` is empty; compares `.env-example` and detects changed `_VERSION` variables |
| `subflows/build-<IMAGE>.yml` | Reusable per-image build flow |
| `subflows/collect-results.yml` | Collects result artifacts, creates or updates the summary issue, and closes it after a successful run |

### Triggers and manual runs

The master workflow runs on a push to the `2.0.0-dev` branch when `.env-example` changes. The branch is intentionally hardcoded because GitHub Actions does not evaluate variables or expressions in an `on:` trigger.

It can also be started manually from the Actions tab with these inputs:

| Input | Type | Meaning | Default |
|---|---|---|---|
| `changedImages` | string | Optional, space-separated image names, such as `php82 mariadb118`. An empty value enables automatic detection. | empty |
| `onlyPush` | integer/string | `0` builds the image to GHCR; `1` skips rebuilding and pushes the existing GHCR image to Docker Hub. | `0` |

When `changedImages` is empty, `subflows/detect-changes.yml` compares the current and previous `.env-example` versions and extracts changed variables ending in `_VERSION`. The result is converted into a matrix. `builds.yml` then calls the `subflows/build-image.yml` once per image.

### Registry authentication and build modes

The per-image flow logs in to GHCR with `github.actor` and `secrets.GITHUB_TOKEN`. With `onlyPush=1`, it also logs in to Docker Hub with `vars.DOCKER_HUB_REPOSITORY` and `secrets.DOCKER_HUB_TOKEN`.

- With `onlyPush=0`, it runs `make build-<IMAGE> multi-platforms=1` for a multi-platform build and publishes the intermediate image to GHCR, without pushing to Docker Hub.
- With `onlyPush=1`, it runs `make build-<IMAGE> multi-platforms=1 only-push=1` for the existing GHCR-to-Docker-Hub push; no new image build is performed.

### Results, issues, and notifications

Each image flow writes `results/result-<IMAGE>.txt` with `success` or `failure` and uploads it as an artifact. `subflows/collect-results.yml` downloads these artifacts and creates a summary table.

For failed runs, the workflow creates or updates a GitHub issue instead of opening duplicate issues. The label is `Build Images` when `onlyPush=0` and `Push to Docker Hub` when `onlyPush=1`. When all jobs are succeeded, the corresponding open issue is updated with the success summary and automatically closed. For a run that is entirely successful, a new issue is created and closed immediately.

This ensures that a notification is always sent to the email address associated with the user’s GitHub account.

### Retry behavior

The push command to Docker Hub is retried with `nick-invision/retry@v3` when it fails:

```yaml
timeout_minutes: 10
max_attempts: 3
retry_wait_seconds: 30
```

## 4. Fork instructions

Forks receive the workflow files, but repository variables and secrets are **not** copied. To use the automation in a fork, create the following values in the fork's repository settings:

| Name | Type | Required value |
|---|---|---|
| `DOCKER_HUB_REPOSITORY` | Repository variable | Your Docker Hub username or organization |
| `DOCKER_HUB_REPOSITORY_LOCAL_PREFIX` | Repository variable | Registry prefix, normally `ghcr.io` |
| `DOCKER_HUB_TOKEN` | Repository secret | A Docker Hub access token with permission to push images |

Also check the `push` trigger in `.github/workflows/builds.yml`. If the fork uses a different default branch, change `2.0.0-dev` to that branch name. This value must be edited directly because GitHub Actions `on:` triggers do not support variables or expressions.

## 5. Directory structure

```text
.
├── Makefile                         # Global variables and image build targets
├── .env-example                     # Configuration template
├── templates/
│   ├── init                         # Shared initialization logic
│   ├── build                        # Shared image-build logic
│   └── push                         # Shared push logic
└── .github/workflows/
    ├── builds.yml                   # Master workflow
    └── subflows/
        ├── detect-changes.yml       # Change detection
        ├── build-image.yml          # Per-image reusable build flows
        └── collect-results.yml      # Result and issue handling
```
