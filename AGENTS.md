# Working on holaclaw-unraid

This repository packages [HolaClaw](https://github.com/ikitana/holaclaw) for
Unraid: a Community Applications (CA) template and the instructions to install
and run it on an Unraid server. It holds no HolaClaw code and builds no image:
it runs the published image `ghcr.io/ikitana/holaclaw`.

## Scope and layout

- `holaclaw.xml` and `holaclaw-slim.xml`: the Unraid templates
  (`<Container version="2">`) for the `latest` and `slim` images. They map
  the image's ports, volumes and environment variables to Unraid's `Path`,
  `Port` and `Variable` entries, and set `ExtraParams`, `Icon`, `Support`,
  `Overview` (with the first-start steps) and `Requires`. They differ only
  where the browser does: keep the rest identical.
- `assets/`: the icons, from HolaClaw.
- `README.md`: install from CA or by template URL, first `init`, upgrades,
  backups and troubleshooting, written for an Unraid user.
- `docs/`: longer guides, when the README is not enough. They describe the
  template as it is.

The source of truth for the container is HolaClaw itself, not this repository:
the `Dockerfile` and
[docs/deployments/container.md](../holaclaw/docs/deployments/container.md).
Read that guide before changing the template. The template must match it:

- Image and tags: `latest` (with the browser) and `slim` (without it), both
  multi-arch.
- Volumes: `/etc/holaclaw` (config), `/etc/holaclaw-secrets` (`auth.toml`,
  the admin token) and `/var/lib/holaclaw` (database, blobs, backups). The
  entrypoint changes their owner on every start, so a host path mapped to
  them must be one HolaClaw owns alone, never a share with other files.
- Port `8484`, the Control API. It needs the owner's admin token over TCP.
- Environment: `HOLACLAW_LISTEN`, `HOLACLAW_ALLOW_INSECURE_TRANSPORT`,
  `HOLACLAW_BROWSER_ENABLED`.
- `--security-opt seccomp=unconfined` only for the browser image; the `slim`
  image keeps the default seccomp profile. Never `--no-sandbox` or
  `--privileged`.
- Every command runs as `docker exec holaclaw holaclaw <command>`.

When HolaClaw changes any of these, update the template and the README in the
same change.

## Building and testing

- Run everything through the dev shell: `nix develop -c <cmd>` (ignore the
  "Git tree is dirty" warning). It has `xmllint`, the Docker client and `gh`.
- There is nothing to build. Check the templates are well-formed XML:
  `nix develop -c xmllint --noout holaclaw*.xml`.
- Test every template change on a host: the `docker run` that Unraid
  generates from the template must start the container, pass
  `docker exec holaclaw holaclaw check`, and survive a restart and an image
  update with the config, the secrets and the data intact. Test both the
  `latest` and the `slim` variant when the change touches either.
- Try every command in the README as written before you document it.
- **No real credentials in tests, and never read or print `.env`, `auth.toml`
  or the admin token.** Use throwaway keys, or a local OpenAI-compatible
  endpoint.

## Models and data

- No private data goes to any model during development, free models above
  all: only synthetic scenarios and fixtures. Never HolaClaw or customer code,
  real conversations, names, credentials, server details or repository
  contents.
- Prefer free models for checks; report any paid spend.

## Changing the template and docs

- Minimal: no template fields, variables, ports or paths beyond what HolaClaw
  needs to run on Unraid. Every option shown to the user must earn its place;
  keep advanced ones under `Display="advanced"`.
- Secure defaults: publish only what the guide publishes, keep secrets in their
  own path, and say plainly in the template and the README what exposing port
  `8484` beyond the LAN requires (TLS in front of it).
- Match the tone, naming and structure of the HolaClaw docs: short, plain
  sentences that describe current behaviour.
- Delete what a change makes obsolete, and update the docs it makes stale.
  Docs describe current behaviour, never planned work.
- New files or tooling need a reason; prefer what Unraid and Docker already
  provide.
- Do not commit, push or rewrite history unless you are asked to.
- Write commit messages in the [Conventional Commits](https://www.conventionalcommits.org/)
  format (`feat: ...`, `fix(template): ...`).
- Do not add AI attribution anywhere: no `Co-Authored-By: Claude ...` or
  similar trailers on commits, and no "Generated with ..." footers or other
  AI credits in issues, pull requests, comments or reviews.
