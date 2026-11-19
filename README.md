<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/icon-dark.png">
    <img src="assets/icon-light.png" alt="The HolaClaw mascot" width="128">
  </picture>
</p>

<h1 align="center">HolaClaw for Unraid</h1>

<p align="center">
  <strong>Run HolaClaw on your Unraid server. Your models, your chats, your hardware.</strong>
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#the-template">The template</a> ·
  <a href="https://github.com/ikitana/holaclaw">HolaClaw</a> ·
  <a href="https://holaclaw.ai">holaclaw.ai</a>
</p>

---

[HolaClaw](https://github.com/ikitana/holaclaw) is a small, stable agent
harness. One binary runs an agent that talks on Telegram, Slack, Google Chat,
WhatsApp or your terminal. It uses tools behind a policy gate, remembers, runs
scheduled tasks and drives a browser. It works with OpenRouter, OpenAI, a
ChatGPT subscription, or any other OpenAI-compatible endpoint, such as Ollama.

This repository holds the Unraid templates for it and these instructions. The
templates run the official image, `ghcr.io/ikitana/holaclaw`; nothing here
builds or changes it. There are two; install one of them:

| Template | Image | For |
|---|---|---|
| **HolaClaw** (`holaclaw.xml`) | `latest` | The full agent, with the browser (Chromium). |
| **HolaClaw-Slim** (`holaclaw-slim.xml`) | `slim` | No browser: a smaller image, and Docker's default seccomp profile. |

## Install

### 1. Download the template

In Unraid's terminal (**>_** in the top bar), for **HolaClaw**:

```
curl -fsSL -o /boot/config/plugins/dockerMan/templates-user/my-HolaClaw.xml \
  https://raw.githubusercontent.com/ikitana/holaclaw-unraid/main/holaclaw.xml
```

or for **HolaClaw-Slim**:

```
curl -fsSL -o /boot/config/plugins/dockerMan/templates-user/my-HolaClaw-Slim.xml \
  https://raw.githubusercontent.com/ikitana/holaclaw-unraid/main/holaclaw-slim.xml
```

### 2. Create the container

Go to **Docker → Add Container**, pick the template under **Template**, and
click **Apply**. The defaults work as they are.

### 3. Initialise

Open the container's console (its icon → **Console**) and run `init` with your
provider. It asks for the API key and starts HolaClaw:

```
holaclaw init --provider openrouter --token-file /etc/holaclaw-secrets/token
```

| Provider | `--provider` |
|---|---|
| OpenRouter | `openrouter` |
| OpenAI | `openai` |
| A ChatGPT subscription | `openai-codex`, then `holaclaw login codex` |
| Ollama or another OpenAI-compatible endpoint | `openai-compat --base-url <url> --model <id>` |

For Ollama on the same server, use `--base-url http://host.docker.internal:11434/v1`,
and make Ollama listen beyond loopback (`OLLAMA_HOST=0.0.0.0`).

### 4. Chat

```
holaclaw check
holaclaw chat
```

Next, follow HolaClaw's
[Getting started](https://github.com/ikitana/holaclaw/blob/main/docs/getting-started.md)
to change the model, pair a device or add a chat app.

## The template

Both templates have the same settings, except for the browser.

| Setting | Default | What it is |
|---|---|---|
| **Repository** | `ghcr.io/ikitana/holaclaw:latest` (`:slim`) | The image. Pin a release with `vX.Y.Z` (`vX.Y.Z-slim`). |
| **Control API port** | `8484` | For the apps and scripts. Every client needs a sign-in or the owner's admin token. |
| **Config** | `/mnt/user/appdata/holaclaw/config` | `config.toml`, the agents, `channels.toml`. |
| **Secrets** | `/mnt/user/appdata/holaclaw/secrets` | `auth.toml` (API keys, sign-in tokens) and the admin token. |
| **Data** | `/mnt/user/appdata/holaclaw/data` | The database, the blobs and the daemon's backups. |
| **Public URL** | empty | Optional. The address devices use to reach HolaClaw, such as `http://tower.local:8484`. With it, pairing shows a link and a QR code. |
| **Browser** (advanced, HolaClaw only) | `true` | Lets the agent open web pages in Chromium. |
| **Extra Parameters** (advanced) | `--security-opt seccomp=unconfined` (HolaClaw only) `--add-host host.docker.internal:host-gateway` | See below. |

**The folders.** On every start, the container gives the three folders to
its own users, so keep them for HolaClaw alone, and leave them out of
**Tools → New Permissions**. The secrets folder ends up readable by the
container's user only, so not over SMB. Back up all three: the secrets folder
holds your API keys. Both templates use the same folders, so run one of
them at a time.

**The browser.** Chromium runs inside its own sandbox, which needs user
namespaces that Docker's default seccomp profile blocks: that is what
`--security-opt seccomp=unconfined` is for, in the HolaClaw template only.
HolaClaw never runs Chromium without its sandbox. If you don't need the
browser, install HolaClaw-Slim: it has no Chromium, and the container keeps
Docker's default profile. To move from one to the other, remove the
container (the folders stay) and install the other template.

**`--add-host`** lets the container reach services on the Unraid host, such
as Ollama, at `host.docker.internal`.

**The port.** The Control API speaks plain HTTP. Keep it on your LAN; to
reach it from anywhere else, put a reverse proxy with TLS in front of it.
If no app or script needs it, you can remove the port: the console needs
none.

**Updates.** Unraid's **Check for Updates** pulls a new `latest` or `slim`. The config,
the secrets and the data stay in the three folders.

**The admin token.** Only scripts that call the Control API need it:

```
docker exec HolaClaw cat /etc/holaclaw-secrets/token
```

(or `HolaClaw-Slim`).

## Links

- [HolaClaw](https://github.com/ikitana/holaclaw) and [holaclaw.ai](https://holaclaw.ai)
- [HolaClaw in a container](https://github.com/ikitana/holaclaw/blob/main/docs/deployments/container.md):
  the guide this template follows, with editing the config by hand and backups
- [Getting started](https://github.com/ikitana/holaclaw/blob/main/docs/getting-started.md)
- [The browser](https://github.com/ikitana/holaclaw/blob/main/docs/browser.md)
  and [security](https://github.com/ikitana/holaclaw/blob/main/docs/security.md)
- [Issues with this template](https://github.com/ikitana/holaclaw-unraid/issues);
  issues with HolaClaw itself go to [its tracker](https://github.com/ikitana/holaclaw/issues)

## License

This repository is licensed under the [Apache License 2.0](LICENSE).
HolaClaw is licensed under the
[Apache License 2.0](https://github.com/ikitana/holaclaw/blob/main/LICENSE)
too. The icons in `assets/` come from HolaClaw.
