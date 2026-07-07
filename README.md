# Vibe Coding — Workshop Onboarding

Welcome! In this workshop we build real software with AI coding agents. You'll set
up two of them:

- **[Claude Code](https://code.claude.com/docs)** — Anthropic's coding agent (CLI + IDE).
- **[opencode](https://opencode.ai/docs)** — an open-source coding agent.

You can run both against free **[OpenHippo](https://openhippo.io)** models — no
Anthropic subscription required. Setup takes ~10 minutes.

Each tool comes as a **CLI** (runs in your terminal) and an **IDE extension**
(runs inside your editor). Install whichever you prefer — or both.

---

## 1. Install Claude Code

📖 **Install pages — pick your platform:**
[CLI setup](https://code.claude.com/docs/en/setup) ·
[VS Code extension](https://code.claude.com/docs/en/vs-code) ·
[JetBrains plugin](https://code.claude.com/docs/en/jetbrains)

### CLI

| Platform | Command |
| --- | --- |
| macOS | `brew install --cask claude-code` |
| Linux | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Windows (PowerShell) | `irm https://claude.ai/install.ps1 \| iex` |

Verify: `claude --version`

### IDE extension

- **VS Code / Cursor:** open Extensions (`Ctrl/Cmd+Shift+X`), search **"Claude
  Code"**, click **Install**. Then click the **Spark icon** (top-right of the editor).
- **JetBrains (IntelliJ / PyCharm):** install the CLI above first, then
  **Settings → Plugins → Marketplace**, search **"Claude Code"**, **Install**, and
  restart the IDE. Run `claude` in the integrated terminal (or press `Ctrl/Cmd+Esc`).

---

## 2. Install opencode

📖 **Download page — CLI, desktop app, and editor extensions:**
**[opencode.ai/download](https://opencode.ai/download)** ·
[IDE integrations](https://opencode.ai/docs/ide/)

### CLI

| Platform | Command |
| --- | --- |
| macOS | `brew install anomalyco/tap/opencode` |
| Linux | `curl -fsSL https://opencode.ai/install \| bash` |
| Windows (PowerShell) | `scoop install opencode`  _(or `npm i -g opencode-ai`)_ |

### IDE extension

opencode has extensions for **VS Code, Cursor, Zed, Windsurf, and VSCodium** —
install from your editor's marketplace or via
[opencode.ai/download](https://opencode.ai/download). Or just run `opencode` in
your editor's integrated terminal.

---

## 3. Get free OpenHippo models

1. Register for free at **[openhippo.io](https://openhippo.io)**.
2. Copy your **API token**.

OpenHippo speaks the Anthropic API, so both agents work with just a URL, your
token, and a model name.

### Claude Code + OpenHippo

Replace `<YOUR-HIPPO-API-TOKEN>` with your token.

**macOS / Linux:**

```bash
ANTHROPIC_BASE_URL=https://api.openhippo.io \
ANTHROPIC_AUTH_TOKEN=<YOUR-HIPPO-API-TOKEN> \
ANTHROPIC_MODEL=hippo-coding \
ANTHROPIC_SMALL_FAST_MODEL=hippo-chat-large \
claude
```

**Windows (PowerShell):**

```powershell
$env:ANTHROPIC_BASE_URL="https://api.openhippo.io"
$env:ANTHROPIC_AUTH_TOKEN="<YOUR-HIPPO-API-TOKEN>"
$env:ANTHROPIC_MODEL="hippo-coding"
$env:ANTHROPIC_SMALL_FAST_MODEL="hippo-chat-large"
claude
```

To avoid retyping, save it once in `~/.claude/settings.json`
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

Then just run `claude` (the IDE extension reads the same settings).

### opencode + OpenHippo

Save this as `opencode.json` in your project folder:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "openhippo": {
      "npm": "@ai-sdk/anthropic",
      "name": "OpenHippo",
      "options": {
        "baseURL": "https://api.openhippo.io/v1",
        "apiKey": "{env:HIPPO_API_TOKEN}"
      },
      "models": {
        "hippo-coding": { "name": "Hippo Coding" },
        "hippo-chat-large": { "name": "Hippo Chat Large" }
      }
    }
  },
  "model": "openhippo/hippo-coding"
}
```

Then set your token and launch:

```bash
export HIPPO_API_TOKEN=<YOUR-HIPPO-API-TOKEN>   # PowerShell: $env:HIPPO_API_TOKEN="..."
opencode
```

---

## 4. Turn off tracking & telemetry (Claude Code)

Claude Code never trains on your code, but it does send usage telemetry and error
reports by default. To turn that off, add these to the `env` block in
`~/.claude/settings.json` (Windows: `%USERPROFILE%\.claude\settings.json`):

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_TELEMETRY": "1",
    "DISABLE_ERROR_REPORTING": "1"
  }
}
```

`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` is the master switch — it disables
telemetry, error reporting, and auto-update checks in one go.

_(opencode is open-source and sends no telemetry.)_

---

## Try it out

From your project folder, run `claude` (or `opencode`) and ask:

```text
> explain what this project does
> add a hello-world script and run it
```

Useful commands: `/model` (switch model), `/help` (all commands).

---

## Docs & help

- Claude Code: https://code.claude.com/docs
- opencode: https://opencode.ai/docs
- Stuck? Run `claude doctor`, or grab a facilitator. Happy vibe coding! 🎧
