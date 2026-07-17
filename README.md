# Vibe Coding — Workshop

Build real software by *talking* to an AI coding agent. In this workshop you'll get one (or
both) running in ~10 minutes, powered by **free [OpenHippo](https://openhippo.io) models** — no
paid subscription needed.

Two agents, same idea — you type what you want, they edit and run your code:

- **[Claude Code](https://code.claude.com/docs)** — Anthropic's coding agent (CLI + IDE).
- **[opencode](https://opencode.ai/docs)** — an open-source coding agent (CLI + IDE).

> **New here? Do this:** clone this repo, then follow steps 1–4 below with **one** agent.
> ```sh
> git clone https://github.com/open-hippo/vibe-coding && cd vibe-coding
> ```

---

## 1. Get your free key

1. Register at **[openhippo.io](https://openhippo.io)** and copy your **API token**.
2. Keep it handy — both agents just need this token + the OpenHippo URL.

---

## 2. Run Claude Code

**Install the CLI** ([other options](https://code.claude.com/docs/en/setup)):

| Platform | Command |
| --- | --- |
| macOS | `brew install --cask claude-code` |
| Linux | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows (PowerShell) | `irm https://claude.ai/install.ps1 \| iex` |

**Point it at OpenHippo** — paste your token into `~/.claude/settings.json`
(Windows: `%USERPROFILE%\.claude\settings.json`):

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.openhippo.io",
    "ANTHROPIC_AUTH_TOKEN": "<YOUR-HIPPO-API-TOKEN>",
    "ANTHROPIC_MODEL": "hippo-coding",
    "ANTHROPIC_SMALL_FAST_MODEL": "hippo-chat-large"
  }
}
```

**Start it** — from your project folder:

```sh
claude
```

_Prefer your editor? Install the **"Claude Code"** extension (VS Code / Cursor / JetBrains) — it
reads the same settings. See [IDE setup](https://code.claude.com/docs/en/vs-code)._

---

## 3. Run opencode

**Install the CLI** ([other options](https://opencode.ai/download)):

| Platform | Command |
| --- | --- |
| macOS | `brew install anomalyco/tap/opencode` |
| Linux | `curl -fsSL https://opencode.ai/install \| bash` |
| Windows (PowerShell) | `scoop install opencode`  _(or `npm i -g opencode-ai`)_ |

**Point it at OpenHippo** — this repo already ships a ready [`opencode.json`](opencode.json), so
you just set your token and go:

```sh
export OPENAI_API_KEY=<YOUR-HIPPO-API-TOKEN>   # PowerShell: $env:OPENAI_API_KEY="..."
opencode
```

_Run it from the repo folder so opencode picks up that config. opencode also has extensions for
VS Code, Cursor, Zed, and more._

---

## 4. Your first session

Inside `claude` or `opencode`, just ask in plain language:

```text
> explain what this project does
> add a hello-world script and run it
```

Handy while you're in a session: **`/model`** switch model · **`/help`** all commands.

That's it — you're vibe coding. 🎧

---

## Going further

- **Prebuilt environments** (nothing to install by hand — devcontainer for VS Code, or a
  standalone Docker box for remote/overnight agent runs): [`docker/README.md`](docker/README.md).
- **Workshop slides:** [`docs/`](docs/Vibe-Programming-Workshop-Slides.pdf).
- **Turn off Claude Code telemetry** (optional): add `"CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"`
  to the `env` block in `~/.claude/settings.json` — one switch for telemetry, error reports, and
  auto-update checks. _(opencode is open-source and sends no telemetry.)_
- **Docs & help:** [Claude Code](https://code.claude.com/docs) · [opencode](https://opencode.ai/docs).
  Stuck? Run `claude doctor`, or grab a facilitator.
