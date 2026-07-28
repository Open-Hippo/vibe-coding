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

The agent asks before it edits or runs anything. Both tools have a switch to stop asking — read
[§5](#5-sandboxing--put-the-agent-in-a-box) before you reach for it.

That's it — you're vibe coding. 🎧

---

## 5. Sandboxing — put the agent in a box

> **Windows readers:** if you plan to follow this chapter, do it *before* steps 2–3. Run
> `wsl --install`, reboot, and install + clone everything **inside** the Ubuntu shell rather
> than in `C:\Users\…`. Otherwise you'll redo it.

### Why we do this

A coding agent is not just a chat window. It reads files, runs shell commands, installs
packages and fetches web pages — with *your* user account, on *your* machine. And it reads that
content with no reliable way to tell **data** from **instructions**. Text on a web page, in a
GitHub issue, in a dependency's README or in a scraped search result can simply *tell the agent
what to do next*. That's **indirect prompt injection**, and it is not theoretical:

- 📄 **Paper —** [*Exploiting Web Search Tools of AI Agents for Data Exfiltration*](https://arxiv.org/abs/2510.09093)
  (Rall, Bauer, Mittal, **Fraunholz** — arXiv:2510.09093, Oct 2025). We tested agents that use
  web search and RAG against indirect prompt injection across model sizes and vendors. The
  finding: **well-known attack patterns still succeed**, and data walks out.
- 🎥 **Talk —** [*How to Hack an Agent — or Not*](https://www.youtube.com/watch?v=pTSKL6e66mE)
  (Thomas Fraunholz, [hessian.AI](https://hessian.ai) AI Academy, Darmstadt) — live demos of
  jailbreaks and injections, then the defenses: LLM judges, task-drift detection, prompt shields.

The uncomfortable conclusion from both: **the defenses help, but they don't hold.** So don't
make the model's good judgement your only control. Give it a box it can't step out of.

That matters most the moment you stop reading every permission prompt — auto-accept,
`claude --dangerously-skip-permissions`, `opencode run "…"` overnight. On a bare laptop the
blast radius of one bad instruction is your `~/.ssh` keys, `~/.aws/credentials`, `.env` files,
browser cookies, your git remotes — everything *you* can reach.

### First principles

The idea is simple: **give the agent its own room, and don't keep anything valuable in it.**
Three questions, in the order they matter:

| Boundary | The question | Answer |
| --- | --- | --- |
| **Filesystem** | What can it read & write? | a container with only the project inside |
| **Credentials** | Which secrets can it reach? | a throwaway token — no SSH keys, no cloud logins |
| **Kernel / host** | What if it breaks out? | a VM, which has its own operating system |

Two things worth knowing:

1. **A prompt is not a boundary.** Permission prompts only work while a human actually reads
   them, and nobody reads the hundredth one. That's why "skip permissions" flags belong *inside*
   a container or a VM — never on your own machine.
2. **A sandbox doesn't change what gets sent to the model.** Your prompts and every file the
   agent reads still go to your provider (Anthropic, OpenHippo, …), box or no box. Isolation
   limits *the agent*, not *the API call*.

Pick the rung that matches what you're doing:

| Rung | Protects | Good for |
| --- | --- | --- |
| Permission prompts | one command at a time | everyday work you watch |
| **Devcontainer / Docker** | the whole agent and everything it starts | **the default — start here** |
| **VM** | a whole operating system | untrusted code, Windows hosts |

_Claude Code also has a **built-in sandbox** (`/sandbox`) and an experimental
[sandbox runtime](https://code.claude.com/docs/en/sandbox-environments) that wrap the agent
without Docker. As of July 2026 the built-in one only covers shell commands, and the runtime is
still a beta research preview — worth watching, not worth relying on yet. Stick with a container
or a VM below._

### Option A — Devcontainer (Linux, macOS, WSL2)

A [devcontainer](https://containers.dev) is a Docker container described by a
`.devcontainer/devcontainer.json` in the repo. Your editor starts it, mounts the project inside,
and gives you a shell in there. The agent runs *in the container*: it sees the project and the
toolchain, and none of your host home directory.

**This repo already ships one.** You need
[Docker](https://docs.docker.com/get-started/get-docker/),
[VS Code](https://code.visualstudio.com/) and the
[Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
On Windows, install [WSL](https://learn.microsoft.com/windows/wsl/install) first
(`wsl --install`), enable Docker Desktop's
[WSL2 backend](https://docs.docker.com/desktop/features/wsl/), and keep the repo in the **Linux**
filesystem (`~/code/…`, not `/mnt/c/…`) — `/mnt/c` bind mounts are slow and blur the boundary
you're drawing.

```sh
code .   # then: command palette → "Dev Containers: Reopen in Container"
```

> ⏳ **The first start takes a while.** It pulls the base image and runs
> [`.devcontainer/setup.sh`](.devcontainer/setup.sh) (Node 22, `claude`, `opencode`, `uv`,
> Playwright + Chromium) — several GB and 10–20 minutes on a good connection. Start it on a
> decent link and let it finish. Every start after that is fast.

**Your host config does not come along.** The container has its own home, so the
`~/.claude/settings.json` from step 2 isn't there — and that's the point. Set a token *in the
container terminal* instead:

```sh
export ANTHROPIC_BASE_URL=https://api.openhippo.io
export ANTHROPIC_AUTH_TOKEN=<YOUR-HIPPO-API-TOKEN>
export ANTHROPIC_MODEL=hippo-coding
claude
# opencode: export OPENAI_API_KEY=<YOUR-HIPPO-API-TOKEN> && opencode
```

Standalone "box" image for remote/overnight runs: [`docker/README.md`](docker/README.md).

**Three habits that do most of the work:**

- **Only the project goes in.** Don't mount `~/.ssh`, `~/.aws`, or your host home directory.
- **Use a throwaway token.** The free OpenHippo one is perfect — if it leaks, you make a new one.
- **Keep asking.** Leave the permission prompts on until you trust what the agent is doing:
  [Claude Code](https://code.claude.com/docs/en/permissions) ·
  [opencode](https://opencode.ai/docs/permissions/).

> ⚠️ One caveat about *this* repo's devcontainer: it turns on `docker-in-docker` (so
> `supabase start` works), which makes the container **privileged** — convenient, but it can
> reach the host, so it isn't a real security boundary. If that matters to you, drop that feature
> from [`devcontainer.json`](.devcontainer/devcontainer.json), use the plain box in
> [`docker/`](docker/), or go with a VM (Option B).

_(Licensing, because it catches people out: **Docker Desktop needs a paid licence** for companies
over 250 employees or $10M revenue. On Linux — or with Podman / Rancher Desktop — there's no
such condition.)_

**Learn devcontainers properly** — two conference talks by Thomas Fraunholz, from zero to a
reproducible Python environment (package management, GPU passthrough, team setups):

| Talk | Where |
| --- | --- |
| [*Unlock the Power of Dev Containers: Consistent Environments in Seconds!*](https://www.youtube.com/watch?v=zuyvcxNR_RE) | EuroPython 2024, Prague |
| [*Unlock the Power of Dev Containers: Build a Consistent Python Development Environment in Seconds!*](https://www.youtube.com/watch?v=Uhf9JDsKao0) | PyCon DE & PyData Berlin 2024 |

Hands-on material from the talks: [github.com/pd-t/devcontainer-101](https://github.com/pd-t/devcontainer-101).
Vendor tutorials: [VS Code devcontainer tutorial](https://code.visualstudio.com/docs/devcontainers/tutorial) ·
[full docs](https://code.visualstudio.com/docs/devcontainers/containers) ·
[spec & features](https://containers.dev/).

### Option B — Virtual machine (Windows hosts, untrusted code)

A container shares the host kernel. A **VM brings its own** — the strongest separation you can
run locally, and the right call when you're pointing an agent at a repo you don't trust, or when
your host is Windows and you'd rather not have the agent anywhere near it.

> **Naming, so you download the right thing:** **VMware Fusion** is the **macOS** product;
> on **Windows/Linux** hosts the equivalent is **VMware Workstation Pro**. Since Broadcom's
> November 2024 change both are **free** — personal, educational *and* commercial use.

| Option | Host | Notes |
| --- | --- | --- |
| [VMware Workstation Pro](https://knowledge.broadcom.com/external/article/368667/download-and-license-vmware-desktop-hype.html) | Windows, Linux | full-featured, great snapshots; free (Broadcom account needed) |
| [VMware Fusion](https://knowledge.broadcom.com/external/article/368667/download-and-license-vmware-desktop-hype.html) | macOS | the same product for Macs |
| [Hyper-V](https://learn.microsoft.com/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v) | Windows **Pro**/Enterprise | built in; *Quick Create* gives you an Ubuntu VM in a few clicks |
| [VirtualBox](https://www.virtualbox.org/) | all | free and open source, easiest start |
| [Windows Sandbox](https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview) | Windows **Pro**/Enterprise | disposable desktop, **discarded on close** — nice for a throwaway experiment |

**On Windows 11 Home** two of those rows are unavailable (Hyper-V, Windows Sandbox) → use VMware
Workstation Pro. And note VirtualBox gets noticeably slower once WSL2/Docker Desktop has switched
the machine onto the Hyper-V platform.

#### Step by step with VMware

On **Windows** this is **Workstation Pro**; on a **Mac** it's **Fusion**. The windows look
slightly different, the steps are the same. Plan an evening the first time — the downloads alone
are ~7 GB.

1. **Get the installer.** Both live behind a free Broadcom account at
   [support.broadcom.com](https://knowledge.broadcom.com/external/article/368667/download-and-license-vmware-desktop-hype.html)
   → *VMware Cloud Foundation* → *My Downloads* → **VMware Workstation Pro** (or **Fusion**).
   No licence key needed since the November 2024 change. Install it, reboot.
2. **Download [Ubuntu LTS Desktop](https://ubuntu.com/download/desktop)** — one `.iso` file,
   ~6 GB. Put it somewhere you'll find it again.
3. **Create the VM.** *File → New Virtual Machine* → point it at the `.iso` → let it use the
   easy install → give it at least **4 CPUs, 8 GB RAM, 60 GB disk**. Then click through the
   Ubuntu installer inside the VM window like you would on a real machine.
4. **Close the convenient holes.** In the VM's settings, turn **off** shared folders and
   drag-and-drop / clipboard sharing. They're exactly what you're paying a VM to prevent.
   (Fusion: *Settings → Sharing*. Workstation: *VM → Settings → Options*.)
5. **Install what you need, inside the VM:** Docker, VS Code, and the agent — then run Option A's
   devcontainer in there. A container inside a VM costs you nothing extra and stacks the boxes.
6. **Take a snapshot** — *VM → Snapshot → Take Snapshot*, call it `clean`. This is the payoff:
   after a run that went sideways, *Revert to Snapshot* puts you back in seconds instead of
   leaving you guessing what changed.
7. **Keep it lean.** One repo, one throwaway token, no personal SSH keys or cloud logins.

> **Windows only:** if you've enabled WSL2 or Docker Desktop, Windows has already switched on
> Hyper-V. Recent Workstation Pro versions run fine alongside it, but a little slower. If VMs
> refuse to start, that's the first thing to look at.

One thing to be clear about: **WSL2 is not a VM in this sense.** It's a great place to run
Docker, but it can see your Windows files through `/mnt/c`, so it doesn't protect them. Use it
for Option A, and a real VM when you want Option B. WSL2 is just an option for isolation in combination with a devcontainer setup.

### Before you go hands-off

A short checklist for `--dangerously-skip-permissions` / overnight `opencode run`:

- [ ] The agent runs in a container or VM — **not** on your own machine
- [ ] Only the project is in there — no `~/.ssh`, no cloud logins
- [ ] Throwaway token, not your personal key
- [ ] Work happens on a branch, and you read the diff before merging
- [ ] You can get back to a clean state — VM snapshot, or a fresh clone

---

## Going further

- **Prebuilt environments** (nothing to install by hand — devcontainer for VS Code, or a
  standalone Docker box for remote/overnight agent runs): [`docker/README.md`](docker/README.md).
- **Sandboxing, talks & the paper:** see [§5](#5-sandboxing--put-the-agent-in-a-box).
- **Workshop slides:** [`docs/Vibe_Coding_Workshop.pdf`](docs/Vibe_Coding_Workshop.pdf).
- **Turn off Claude Code telemetry** (optional): add `"CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"`
  to the `env` block in `~/.claude/settings.json` — one switch for telemetry, error reports, and
  auto-update checks. _(opencode is open-source and sends no telemetry.)_
- **Docs & help:** [Claude Code](https://code.claude.com/docs) · [opencode](https://opencode.ai/docs).
  Stuck? Run `claude doctor`, or grab a facilitator.
