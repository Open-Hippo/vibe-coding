# Coding box

A small, self-contained image for **remote and overnight AI agent runs**. Ubuntu 24.04 with
node/npm, python + **uv**, **Claude Code**, **opencode**, **Playwright + Chromium**, and
**`screen`**. Everything is installed at build time — bring the container up, `exec` in, start
a `screen` session, run an agent, detach, and reattach whenever you like.

Deliberately simple: **no docker-in-docker**, no supabase/stripe — just the coding toolchain.

Published to `ghcr.io/open-hippo/vibe-coding/box` by
[`.github/workflows/box-image.yml`](../.github/workflows/box-image.yml).

## Quick start

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

## Overnight runs

Because the container stays alive (`sleep infinity`) and the agent runs inside `screen`, the
run survives `docker exec` disconnects and host SSH drops. `restart: unless-stopped` brings the
box back after a host reboot. For a fully unattended run you can log the output to a file:

```sh
screen -S nightly -L -Logfile ~/nightly.log -dm \
  opencode run "work through the TODO list and open a PR"
# check on it in the morning:
docker compose -f docker/docker-compose.yml exec box screen -r nightly
```

## Credentials

Home is a named volume (`box-home`), so `~/.claude`, `~/.config/opencode` and their auth
persist across restarts — log in once with `claude` / `opencode auth login`. Or pass keys via
the environment (an `.env` file next to the compose file is picked up automatically):

```sh
# docker/.env
ANTHROPIC_API_KEY=sk-ant-…
OPENAI_API_KEY=sk-…
```

## Plain `docker run` (no compose)

```sh
docker run -d --name box --restart unless-stopped \
  -v box-home:/home/dev \
  ghcr.io/open-hippo/vibe-coding/box:latest

docker exec -it box zsh
```

## What's inside

| Tool | Use |
|---|---|
| `claude` | Claude Code CLI |
| `opencode` | opencode agent CLI (overnight runs) |
| `node` / `npm` / `npx` | Node 22 |
| `python3` / `uv` | Python + fast package/dep manager (`uv run`) |
| `npx playwright` | Playwright + headless Chromium (browser automation) |
| `screen` | detach/reattach long-running sessions |

## Files

- [`Dockerfile`](Dockerfile) — the image recipe
- [`entrypoint.sh`](entrypoint.sh) — runtime startup (banner, then hands off to CMD)
- [`screenrc`](screenrc) — screen config tuned for long sessions (big scrollback, status line)
- [`docker-compose.yml`](docker-compose.yml) — long-running box, one command
