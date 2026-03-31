# Contributing to BlackboardLMS

This guide covers how to contribute to this monorepo, which includes **BlackboardLMS**, **NeoComponent**, and the **Content Studio** engine. It also explains how to work with the AI-assisted development setup using Claude Code and Antigravity.

---

## Repository Structure

```
blackboard-lms/
├── app/                        # BlackboardLMS application
├── engines/
│   ├── neo_component/          # UI component library (Rails engine)
│   └── content_studio/         # Content Studio engine (portable, data-agnostic)
├── CLAUDE.md                   # AI agent constitution — read before every session
└── CONTRIBUTING.md             # This file
```

---

## Prerequisites

- Ruby (see `.ruby-version`)
- PostgreSQL
- Node.js + Yarn
- [Antigravity](https://antigravity.google/) — agent-first IDE for AI-assisted development
- Claude Code CLI — `npm install -g @anthropic-ai/claude-code`

---

## Getting Started

```bash
git clone https://github.com/openvitae-tech/blackboard-lms.git
cd blackboard-lms
bundle install
yarn install
bin/rails db:setup
```

---

## AI-Assisted Development Workflow

This project uses AI agents (Claude Code and Antigravity) as primary development tools. Here is how the workflow operates:

### Roles

| Role | Responsibility |
|------|---------------|
| **Developer** | Creates GitHub issues, reviews PRs, approves plans, merges code |
| **Manager Agent** (Antigravity) | Reads issues, decomposes tasks, spawns worker agents, opens PRs |
| **Worker Agents** | Execute specific sub-tasks (UI updates, feature dev, spec writing) |
| **Claude Code** | Used for direct, in-session coding tasks and codebase queries |

### Agent-Driven Workflow (Antigravity)

This is the primary workflow for Content Studio and NeoComponent work.

```
Developer                          Antigravity Agents
─────────────────────────────────────────────────────────────────
1. Create GitHub issue
   - Use the correct issue template
   - Include Figma URL if UI work is involved
   - Be specific and atomic — one screen or feature per issue

2. Open Antigravity, run:
   /feature <issue-number>
                                   3. @manager reads the issue in full
                                      - Fetches Figma URL via Figma MCP
                                      - Posts an Implementation Plan
                                        as a comment on the issue
                                      - Waits for approval

4. Review the plan, comment
   approval or feedback
                                   5. If UI changes needed:
                                      @ui-librarian runs ui-audit skill
                                      - Audits Figma vs ui_manifest.md
                                      - Posts gap analysis on the issue
                                      - Waits for approval

6. Review gap analysis, approve
   or request changes
                                   7. @ui-librarian extends NeoComponent
                                      helpers as approved
                                      - Updates ui_manifest.md
                                      - Runs NeoComponent specs

                                   8. @feature-dev implements the feature
                                      - Creates task/<feature-name> branch
                                      - Builds controllers, views, specs
                                      - All data via ApiClient

                                   9. @qa-agent runs full suite
                                      - bundle exec rspec
                                      - bundle exec rubocop
                                      - Reports failures back to agents

                                  10. @manager opens PR
                                      - From task/<feature-name>
                                      - Into feature/content-studio-v1
                                      - Includes visual diffs for UI changes

11. Review PR
    - Check code diff
    - Check visual diffs
    - Comment feedback if needed
                                  12. Agents pick up PR comments,
                                      fix and push to the same branch

13. Approve and merge into
    feature/content-studio-v1
```

---

### Manual Workflow (Developer / Claude Code)

For direct coding tasks without full agent orchestration.

```
1. Pick up a GitHub issue
2. Create a branch:
   git checkout -b task/<short-description>

3. If UI work — read ui_manifest.md first:
   engines/neo_component/ui_manifest.md

4. Build in this order:
   a. ApiClient method(s) if new data is needed
   b. Controller action(s)
   c. Route(s)
   d. View(s) using NeoComponent helpers only
   e. View spec(s)
   f. System spec(s)

5. Verify:
   bundle exec rspec engines/content_studio
   bundle exec rubocop

6. Open PR from task/<name> into feature/content-studio-v1
   - Fill in the PR template
   - Include screenshots for any UI changes
```

### Setting Up Antigravity

1. Download and install Antigravity from [https://antigravity.google/](https://antigravity.google/).
2. Open this repository in Antigravity.
3. Antigravity will automatically read `CLAUDE.md` at session start to align with project standards.
4. Connect your GitHub account so the Manager Agent can read issues and open PRs.

### Setting Up Claude Code

```bash
npm install -g @anthropic-ai/claude-code
cd blackboard-lms
claude
```

Claude Code reads `CLAUDE.md` at session start. Always ensure it is up to date before starting a session.

---

## Content Studio Rules

Content Studio is a portable Rails engine. These rules are enforced by CI and must never be violated:

- **No direct ActiveRecord access to BlackboardLMS models.** All data must flow through `ContentStudio::ApiClient`.
- **All views must use NeoComponent helpers.** Do not write raw HTML for UI elements that have a component.
- **Prop Bloat Policy:** If a component needs new functionality, extend the existing NeoComponent helper with optional arguments (keeping defaults). Do not create new components.
- **Mandatory specs:** Every feature requires RSpec View and System specs before a PR can be opened.

A RuboCop cop enforces the no-direct-model-access rule. Violations will fail CI.

---

## NeoComponent — UI Manifest

A `ui_manifest.md` file at `engines/neo_component/ui_manifest.md` catalogs all available helpers and their arguments. This file is the primary reference for AI agents when building views.

It is **auto-generated** via a pre-commit hook. Never edit it manually. To regenerate manually:

```bash
bin/rails neo_component:generate_manifest
```

---

## Branching Strategy

- `main` — production-stable, protected
- `feature/content-studio-v1` — integration branch for all Content Studio work
- Task branches — opened by agents, named `task/<description>`, PRed into the integration branch

Merge `main` into your feature branch when a blocking upstream change lands. Avoid daily merges as they create unnecessary noise.

---

## Running Tests

```bash
bundle exec rspec                  # Full suite
bundle exec rspec engines/content_studio  # Content Studio only
bundle exec rubocop                # Lint + custom cops
```

---

## PR Guidelines

- PRs from agents include Visual Diffs — review them alongside the code diff.
- Do not merge a PR without passing specs and RuboCop.
- Tag PRs that touch NeoComponent helpers with the `neo-component` label — these trigger visual regression checks.
