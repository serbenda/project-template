# Dev container for working with Claude Code away from your Mac: the agent sees only this project, not your
# home folder, SSH keys, keychain or other repos. Pinned: the base image by digest, Gitleaks by release and
# SHA-256, Claude Code by version (a release at least a week old, like Dependabot's cooldown). Not pinned: the
# Ubuntu packages (from the pinned image's release) and Claude Code's npm dependencies, resolved at build time.
# Dependabot (devcontainers and docker ecosystems) proposes updates to the base image.
FROM mcr.microsoft.com/devcontainers/base:2-ubuntu-24.04@sha256:d94c97dd9cacf183d0a6fd12a8e87b526e9e928307674ae9c94139139c0c6eae

ARG GITLEAKS_VERSION=8.30.1
ARG CLAUDE_CODE_VERSION=2.1.319

# python3/jq: the guard hook; shellcheck: the Verify commands; bubblewrap/socat: Claude Code's sandbox on Linux;
# nodejs/npm: Claude Code itself; gh: PRs and issues (as the agent account, with its token).
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 jq shellcheck bubblewrap socat nodejs npm gh \
 && rm -rf /var/lib/apt/lists/*

# Gitleaks, so the pre-commit hook can run (it refuses every commit without it). Checked against the release's
# published checksums for each architecture.
RUN set -eu; \
    case "$(dpkg --print-architecture)" in \
      amd64) asset=linux_x64;   sum=551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb ;; \
      arm64) asset=linux_arm64; sum=e4a487ee7ccd7d3a7f7ec08657610aa3606637dab924210b3aee62570fb4b080 ;; \
      *) echo "unsupported architecture" >&2; exit 1 ;; \
    esac; \
    curl -fsSLo /tmp/gitleaks.tgz "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_${asset}.tar.gz"; \
    echo "${sum}  /tmp/gitleaks.tgz" | sha256sum -c -; \
    tar -xzf /tmp/gitleaks.tgz -C /usr/local/bin gitleaks; \
    rm /tmp/gitleaks.tgz

RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"

# The volume for Claude Code's settings is mounted here; created now so it belongs to vscode, not root.
RUN mkdir -p /home/vscode/.claude && chown vscode:vscode /home/vscode/.claude

USER vscode
