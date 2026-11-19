---
name: create-issue
description: Draft and open a new GitHub issue for holaclaw-unraid with an issue type and, where it applies, a label, optionally assigned to a milestone, as a sub-issue of an umbrella, or as an umbrella with its sub-issues. Use when asked to file, open, create or write up an issue, bug, task or umbrella.
argument-hint: "[what the issue is about] [type <Task|Bug|Feature>] [label <name>] [milestone <name>] [parent #N]"
allowed-tools: Bash(gh issue create:*), Bash(gh issue edit:*), Bash(gh issue list:*), Bash(gh issue view:*), Bash(gh api repos/*/milestones*), Bash(gh api graphql:*), Bash(gh label list:*), Bash(gh repo view:*)
---

# Create issue

Open a GitHub issue in this repository from what the user asked for: $ARGUMENTS

There are three shapes:

- **Single issue**: one issue, no parent.
- **Sub-issue**: one issue attached to an existing umbrella (`parent #N`, "part of #N", "under #N").
- **Umbrella**: one parent issue plus its sub-issues, new ones, existing ones, or both.

## 1. Gather

- Work out what the issue is about from the request and the conversation. Read `AGENTS.md`, the templates (`holaclaw.xml`, `holaclaw-slim.xml`), the `README.md` or the `docs/` page involved so the issue names real template fields, paths, ports and variables. Don't invent any.
- When the issue is about how the container behaves, check HolaClaw's own container guide (`docs/deployments/container.md` in the HolaClaw repository). If the problem is in HolaClaw or its image rather than in the template or the docs, say so: it belongs in the HolaClaw tracker, not here.
- Check for a duplicate: `gh issue list --state all --search "<key words>" --limit 10`. If one matches, show it and ask before going on.
- For a sub-issue, read the umbrella first (`gh issue view <N>`): its context, its decisions and its existing sub-issues. The new issue must fit them and not repeat them.
- Ask only for what you can't work out yourself. If the problem or the wanted outcome is unclear, ask; don't guess.

## 2. Milestone

A new issue may or may not get a milestone.

- No milestone mentioned: create the issue without one. Don't pick one yourself, and don't copy the umbrella's.
- Milestone named: list the open ones with `gh api 'repos/{owner}/{repo}/milestones?state=open' --jq '.[].title'` and match the name to exactly one title. If none or several match, show the list and ask. Never create a milestone from this skill.
- Umbrella: a named milestone applies to the umbrella and to every new sub-issue, unless the user says otherwise.

## 3. Type and label

Every new issue gets an issue type. Bugs and features also get the label that goes with their type. A task may or may not have a label.

Types are defined for the whole `ikitana` organization. List the ones this repository offers with:

```sh
gh api graphql -f query='{repository(owner:"{owner}",name:"{repo}"){issueTypes(first:20){nodes{name description}}}}' --jq '.data.repository.issueTypes.nodes[] | "\(.name): \(.description)"'
```

Labels are per repository; list them with `gh label list`. Never create a type or a label from this skill. If the user names one that isn't in the list, show the list and ask.

Pick the type from the request, then the label:

| Type | When | Label |
|---|---|---|
| `Task` | Planned work, including an umbrella and its sub-issues | none, unless the user names one |
| `Bug` | Something that exists today behaves wrongly: the template, an install step, a documented command | `bug` |
| `Feature` | A request or idea for new behaviour that isn't planned work yet | `enhancement` |

Don't pick a label for a task yourself: a task gets the labels the user names, plus those it inherits from its umbrella (below), and no others. For a feature that is only documentation, use `documentation` instead of `enhancement`. Add other labels (`good first issue`, `help wanted`, `question`) only if the user asks for them.

Umbrellas keep one type and the same labels across the whole family:

- **New umbrella:** the umbrella and every new sub-issue get the same type and labels: `Task` and no label, unless the user names a label for the family. The one exception is a sub-issue that fixes a bug, which gets `Bug` and `bug`.
- **Sub-issue of an existing umbrella:** read the umbrella's type and labels with `gh issue view <N> --json issueType,labels` and use the same ones, with the same bug exception. An umbrella with labels passes them on; one without passes none. If the umbrella has no type, use `Task`.
- **Adopting existing issues:** list their current type and labels in review. If they differ from the umbrella's, ask whether to align them. Change them only if the user says yes.

The user can override any of this in review.

## 4. Draft

**Title**: short, plain, and states the outcome or the problem, not the work. No `feat:`/`fix:` prefixes. For example:

- `Container loses its config after an image update`
- `Template: offer the slim image without the seccomp flag`
- `README: first init from the Unraid console`

**Body** of a single issue or a sub-issue: these three sections, in this order.

```markdown
## Context

What exists today and why this matters, in a few sentences. Link the HolaClaw
doc involved, the related issues (#N) and PRs.

## Issues

- One bullet per concrete problem: what happens, and what should happen instead.

## Implementation

- The changes, in the order they should land, naming the files and the
  template fields.
- What is out of scope, if it might be assumed.
- Testing: the checks that must pass on an Unraid or Docker host, including
  the ones that must fail cleanly.
```

A bug report also says the Unraid version, the image tag and the steps to reproduce it, with no credentials, tokens or server details.

A sub-issue doesn't restate the umbrella. Its Context says only what this piece needs, and which sibling it depends on if any.

**Body** of an umbrella:

```markdown
Read `AGENTS.md` and <HolaClaw doc> before taking any subtask.

Umbrella for <what>, in a few sentences.

Decisions already taken:
- ...

Subtasks, in dependency order. <Which ones can run in parallel, and after what.>

1. #N <title>
2. #N <title>
```

Draft the umbrella and every new sub-issue before creating anything. In the umbrella's subtask list, write `#TBD` for each sub-issue that doesn't exist yet.

Write in plain words and short sentences, with code identifiers in backticks and no filler. Keep each body as short as the issue allows.

## 5. Review

Show the user every issue that will be created: title, type, labels, milestone (or "none"), parent (or "none") and the full body. For an umbrella, show the umbrella first, then the sub-issues in dependency order, and list any existing issues it will adopt, with their current type and label. Wait for their go-ahead. Apply their edits and show it again if they change anything substantial.

## 6. Create

Write each body to its own file in the scratchpad directory. Add `--type <type>` to every `create` below, the umbrella's included, `--label <label>` (repeated or comma-separated) to any issue that step 3 gave labels, and `--milestone "<exact milestone title>"` to any `create` below when step 2 gave the issue a milestone.

**Single issue:**

```sh
gh issue create --title "<title>" --body-file <scratchpad>/issue.md --type <type> [--label <label>]
```

**Sub-issue:**

```sh
gh issue create --title "<title>" --body-file <scratchpad>/issue.md --type <type> [--label <label>] --parent <N>
```

If the umbrella's body has a numbered subtask list, ask whether to add the new issue to it. If they say yes, update it with `gh issue edit <N> --body-file`, starting from the current body that `gh issue view <N> --json body --jq .body` returns.

**Umbrella:**

1. Create the umbrella with `gh issue create ... --type <type> [--label <label>]` and note its number `<U>`.
2. Create the new sub-issues **in dependency order**, each with its own `--type`, its `--label` if it has one, and `--parent <U>`, so GitHub lists them in that order. Note each number.
3. Adopt the existing issues, if any: `gh issue edit <U> --add-sub-issue <n>,<n>`. An issue that already has another parent can't be adopted; tell the user which ones those are and leave them alone. If the user agreed in review to align the adopted ones, run `gh issue edit <n> --type <type>`, with `--add-label <label>` if the family has one, and `--remove-label <old>` if they agreed to drop it.
4. Replace each `#TBD` in the umbrella's subtask list with its real number and update the umbrella with `gh issue edit <U> --body-file`.
5. Check with `gh issue view <U>` that the sub-issues show up in the expected order, and that the umbrella and each sub-issue carry the agreed type and labels.

If a step fails partway, stop and report what was created (numbers and URLs) and what wasn't. Don't retry blindly, and don't close or delete anything you created.

Reply with each issue's URL, its type, its labels, its milestone and its parent.
