# Codex Guidance

The root `AGENTS.md` is a public, reusable set of repository instructions for
Codex. It is licensed with the rest of the kit under `0BSD` so operators can
inspect, copy, and adapt it.

## How it is loaded

Codex discovers instruction files from its global configuration and then from
the repository root toward the current working directory. More specific files
later in that chain take precedence. Keep nested overrides rare and place them
only where a narrower rule genuinely applies.

The official OpenAI guide explains discovery, precedence, fallback filenames,
size limits, and verification:
<https://developers.openai.com/codex/guides/agents-md>.

## General safety constraints

Rules about untrusted executables, exact device targeting, synthetic data,
secret avoidance, destructive-action checks, and explicit external mutations
are broadly reusable safety constraints.

## Project choices

The five-gate workflow, no-network initial lane, API 34 reference AVD, GitHub
upstream adapter, GitLab target adapter, evidence-retention policy, and exact
report format are this project's choices. Adaptations should document changed
assumptions instead of silently weakening a gate.

The repository also treats chats as disposable work sessions. Codex follows
`docs/session-continuity.md`, records resumable state in `docs/next-session.md`,
and keeps long or risk-bearing work aligned with explicit gate boundaries.

## Verify the active instructions

From the repository root, ask Codex:

```text
Summarize the instruction sources you loaded, their precedence, the current
handoff, the approval boundaries in this repository, and the commands you must
run before acting. Do not mutate files or external state.
```

Restart the session after changing an instruction file. Do not publish global
account instructions, chat transcripts, hidden prompts, workstation paths, or
claims about model internals as part of a project handoff.

## Reusable answers

For newcomer questions, follow [Start here](start-here.md#questions-and-improvements):
put reusable explanations in the existing public guide and answer briefly with
a link to its relevant section. Use direct help when privacy, urgent recovery or
a case-specific environment requires it. Do not publish updates without the
operator's authority, promise a support service or add speculative FAQs.
