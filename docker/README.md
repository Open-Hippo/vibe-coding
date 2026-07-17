# Preloaded environments

Two ready-to-go setups with the AI coding toolchain baked in — node/npm, python + **uv**,
**Claude Code**, **opencode**, and **Playwright + Chromium** — so you don't install anything by
hand. Pick the one that matches how you want to work:

| | **Devcontainer** | **Standalone box** |
|---|---|---|
| Where | [`.devcontainer/`](../.devcontainer/) | [`docker/`](.) (this folder) |
| Best for | interactive dev inside **VS Code** | **remote / overnight** agent runs over SSH |
| Extras | + Supabase CLI, Stripe CLI, headroom, docker-in-docker | just the coding toolchain (no dind) |
| Started by | "Reopen in Container" | `docker compose up -d` + `screen` |

Both run agents against your own Claude/opencode auth (or free
[OpenHippo](https://openhippo.io) models — see the [root README](../README.md)).

---

## Option A — Devcontainer (VS Code)

The full sandbox. Opens the repo inside a container with the whole toolchain plus a local
Supabase stack (docker-in-docker), so `supabase start`, Stripe test mode, etc. all work.

**Setup**

1. Install [VS Code](https://code.visualstudio.com/) + the
   [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
   and have Docker Desktop running.
2. Copy the env template so container creation doesn't fail on a missing file:
   ```sh
   cp .devcontainer/sandbox.env.example .devcontainer/sandbox.env
   # fill in Stripe TEST creds if you need them (Supabase is local — no remote creds)
   ```
3. Open the repo in VS Code → **"Reopen in Container"** (command palette:
   *Dev Containers: Reopen in Container*).

The devcontainer **builds locally** from [`.devcontainer/Dockerfile`](../.devcontainer/Dockerfile)
and runs [`.devcontainer/setup.sh`](../.devcontainer/setup.sh) to install the toolchain
(idempotent — rebuilds are cheap). It's configured with `shutdownAction: none`, so unattended
`screen`/`claude` sessions keep running when the VS Code window closes. Then open a terminal and
run `claude` or `opencode`.

> The prebuilt GHCR image below (`…/box`) is **only** for the standalone setup — the
> devcontainer intentionally stays a local build.

---

## Option B — Standalone box (remote / overnight)

A small, self-contained image for **remote and overnight agent runs** — Ubuntu 24.04 with the
coding toolchain and **`screen`** for detachable sessions. Deliberately simple: **no
docker-in-docker**, no supabase/stripe. Published to
`ghcr.io/open-hippo/vibe-coding/box` by [`box-image.yml`](../.github/workflows/box-image.yml).

### Quick start

```sh
# start the box (detached, stays up)
docker compose -f docker/docker-compose.yml up -d

# get a shell
docker compose -f docker/docker-compose.yml exec box zsh
```

Inside, drive an agent in a detachable session:

```sh
screen -S work            # start a named session
claude                    # …Claude Code, or:
opencode run "refactor the auth module and run the tests"   # …an overnight run
# Ctrl-a d                # detach — the run keeps going after you disconnect
```

Reattach later (even after your SSH session dropped — the container keeps running):

```sh
docker compose -f docker/docker-compose.yml exec box screen -r work
screen -ls                # list your sessions
```

### Overnight runs

Because the container stays alive (`sleep infinity`) and the agent runs inside `screen`, the
run survives `docker exec` disconnects and host SSH drops. `restart: unless-stopped` brings the
box back after a host reboot. For a fully unattended run you can log the output to a file:

```sh
screen -S nightly -L -Logfile ~/nightly.log -dm \
  opencode run "work through the TODO list and open a PR"
# check on it in the morning:
docker compose -f docker/docker-compose.yml exec box screen -r nightly
```

### Credentials

Home is a named volume (`box-home`), so `~/.claude`, `~/.config/opencode` and their auth
persist across restarts — log in once with `claude` / `opencode auth login`. Or pass keys via
the environment (an `.env` file next to the compose file is picked up automatically):

```sh
# docker/.env
ANTHROPIC_API_KEY=sk-ant-…
OPENAI_API_KEY=sk-…
```

### Plain `docker run` (no compose)

```sh
docker run -d --name box --restart unless-stopped \
  -v box-home:/home/dev \
  ghcr.io/open-hippo/vibe-coding/box:latest

docker exec -it box zsh
```

### Files

- [`Dockerfile`](Dockerfile) — the image recipe
- [`entrypoint.sh`](entrypoint.sh) — runtime startup (banner, then hands off to CMD)
- [`screenrc`](screenrc) — screen config tuned for long sessions (big scrollback, status line)
- [`docker-compose.yml`](docker-compose.yml) — long-running box, one command

---

## What's inside

| Tool | Devcontainer | Standalone box |
|---|:---:|:---:|
| `claude` (Claude Code) | ✅ | ✅ |
| `opencode` | ✅ | ✅ |
| `node` / `npm` / `npx` (Node 22) | ✅ | ✅ |
| `python3` / `uv` | ✅ | ✅ |
| `npx playwright` + Chromium | ✅ | ✅ |
| `screen` | ✅ | ✅ |
| Supabase CLI, Stripe CLI, psql | ✅ | — |
| headroom | ✅ | — |
| docker-in-docker (`supabase start`) | ✅ | — |
