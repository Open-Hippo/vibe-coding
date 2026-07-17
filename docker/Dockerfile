# AI coding box — a small, self-contained image for remote/overnight agent runs.
#
# Everything is installed at BUILD time so `docker compose up` gives you node, python, uv,
# Claude Code, opencode, Playwright + Chromium and `screen` immediately — no post-create step,
# no network needed at start. Keep a long-running container, `exec` into it, start a `screen`
# session, kick off Claude Code or an overnight opencode run, detach, and reattach later.
#
# Deliberately simple: NO docker-in-docker, NO supabase/stripe. Just the coding toolchain.
#
# Base: Ubuntu 24.04 (Noble). Playwright's apt deps and a modern glibc both come for free.
FROM ubuntu:24.04

# Keep the whole build non-interactive — nothing may stop to ask for confirmation.
ENV DEBIAN_FRONTEND=noninteractive \
    npm_config_yes=true

ARG NODE_MAJOR=22

# --- Base OS packages --------------------------------------------------------------------
# ca-certificates/curl/wget/gnupg: fetch + verify the NodeSource apt repo below.
# git/zsh/sudo/unzip/xz-utils/jq/less/vim/openssh-client: everyday shell tooling.
# screen: detach/reattach long-running agent sessions (the whole point of this image).
# build-essential + python3/pip/venv/pipx: Python toolchain for uv-run targets.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl wget gnupg git sudo zsh unzip xz-utils jq screen less vim \
      openssh-client locales \
      build-essential python3 python3-pip python3-venv pipx \
    && sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# --- Node.js (npm/npx; needed for claude, opencode, playwright) --------------------------
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# --- uv (fast Python package/dep manager; `uv run` for python/pytest) ---------------------
ENV UV_INSTALL_DIR=/usr/local/bin
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# --- Non-root user -----------------------------------------------------------------------
# Ubuntu 24.04 ships a default `ubuntu` user at uid 1000. Drop it and take 1000 for `dev`,
# so bind-mounts from a typical host user line up. Passwordless sudo for runtime apt.
RUN userdel -r ubuntu 2>/dev/null || true \
    && useradd --create-home --uid 1000 --shell /usr/bin/zsh dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

# Everything below runs as the unprivileged user, so npm globals land in $HOME and need no
# root at runtime (Claude Code can self-update, etc.).
USER dev
WORKDIR /home/dev

# User-owned global npm prefix so `npm i -g` needs no sudo. Put its bin + ~/.local/bin (uv-style
# user installs, pipx apps) on PATH for every shell and for `docker exec` directly.
ENV NPM_CONFIG_PREFIX=/home/dev/.npm-global \
    PATH=/home/dev/.npm-global/bin:/home/dev/.local/bin:/usr/local/bin:/usr/bin:/bin

# --- Claude Code CLI + opencode + Playwright (global npm installs) -----------------------
RUN npm install -g @anthropic-ai/claude-code opencode-ai playwright

# --- Playwright + headless Chromium (browser automation / visual checks) -----------------
# install-deps needs root (apt) — dev has passwordless sudo; the browser downloads to ~/.cache.
RUN sudo env "PATH=${PATH}" npx --yes playwright install-deps chromium \
    && npx --yes playwright install chromium

# --- A sensible screen config for long/overnight sessions --------------------------------
# Big scrollback (overnight runs produce a lot of output), a visible status line, and UTF-8.
COPY --chown=dev:dev screenrc /home/dev/.screenrc

# --- Startup script (runtime-only: banner + hand off to CMD) ------------------------------
COPY --chown=dev:dev entrypoint.sh /usr/local/bin/box-entrypoint
RUN sudo chmod 0755 /usr/local/bin/box-entrypoint

# --- Sanity check: every tool resolves and runs in the image's PATH ----------------------
RUN set -e; for t in node npm npx python3 uv claude opencode screen; do \
      command -v "$t" >/dev/null || { echo "MISSING: $t"; exit 1; }; \
    done; echo "box OK"

ENTRYPOINT ["/usr/local/bin/box-entrypoint"]
# Default: keep the container alive so you can `exec` in and start screen sessions.
CMD ["sleep", "infinity"]
