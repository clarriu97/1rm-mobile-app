---
name: continue
description: >-
  Resume the project roadmap from where it was left. Use when the user asks to
  continue, resume or pick up the work ("sigue", "continúa", "sigue con M4",
  "siguiente issue", "¿por dónde íbamos?", "/continue M4", "/continue #17"),
  at the start of a new session about this project, or before starting any
  milestone or issue.
---

# Continue the roadmap

Pick up the work with no context beyond this repo, then carry it through the
normal workflow. The user wants to say as little as possible: work out the
rest from the sources below and only ask about real decisions.

## 1. Orient (read, don't change anything yet)

1. `docs/ROADMAP.md` is already in context through `CLAUDE.md`: current
   milestone, order of issues, decisions and where things live.
2. Check the live state:
   ```bash
   git status -sb && git fetch -q && git log --oneline -5 origin/main
   gh pr list                                   # anything in flight?
   gh issue list --milestone "<current milestone>" --state open
   gh run list --workflow e2e.yml --branch main --limit 3   # e2e health on main
   ```
   (Unset `GH_TOKEN` before `gh` if it fails with a bad-credentials error.)
3. Choose the target: the issue or milestone the user named, else the next
   open issue in the order the roadmap gives. An open PR or a red E2E run on
   `main` comes first: finish or fix it before starting something new.
4. Read the whole issue (`gh issue view <n> --comments`); its body includes
   follow-ups added later. Read the code it touches and its tests.

## 2. Tell the user, briefly, in Spanish

One short message: which issue, what it will change, anything that needs
their decision. Then continue without waiting unless there is a real decision
or something only they can do (passwords, Apple ID, license acceptance,
connecting the iPhone).

## 3. Do it (AGENTS.md → Workflow and Testing)

- Branch `feat|fix|chore/<issue>-<slug>`; tests first or alongside; skills
  from AGENTS.md → Skills for the area.
- `tool/ci.sh` until green; UI changes checked on the simulator with a
  screenshot, and new states added to the layout matrix / goldens.
- PR with `Closes #n`, summary and verification. No co-author or
  "Generated with" lines.
- On the final pushed head: `tool/ci.sh all` (reports `local-e2e`), wait for
  `analyze`, `test`, `goldens`, squash-merge, then check E2E on `main`.

## 4. Leave the trail

- If the PR finished a milestone, made a decision, or moved something, update
  `docs/ROADMAP.md` in that same PR (status table, "Next step", decisions
  with date and reason).
- Close the milestone on GitHub when its last issue closes.
- End with a short report to the user: what shipped (PR links), what's next.
