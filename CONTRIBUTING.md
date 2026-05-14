# Contributing to BlackboardLMS

This guide covers how to contribute to this monorepo, which includes **BlackboardLMS**, **NeoComponent**, and the **Content Studio** engine. It also explains how to work with the AI-assisted development setup using Claude Code.

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

This project uses Claude Code as the primary AI development tool. Here is how the workflow operates:

### Roles

| Role | Responsibility |
|------|---------------|
| **Developer** | Creates GitHub issues, reviews output visually, approves plans, merges PRs |
| **@manager** | Reads issues, decomposes tasks, delegates to worker agents, opens PRs |
| **@ui-librarian** | Audits Figma vs ui_manifest, extends NeoComponent helpers |
| **@feature-dev** | Builds Content Studio views, controllers, routes, and specs |
| **@qa-agent** | Runs RSpec and RuboCop, reports failures |

### Agent-Driven Workflow (Claude Code)

This is the primary workflow for Content Studio and NeoComponent work.

```
Developer                          Claude Code Agents
─────────────────────────────────────────────────────────────────
1. Create GitHub issue
   - Use the correct issue template
   - Include Figma URL if UI work is involved
   - Be specific and atomic — one screen or feature per issue

2. Run: /feature <issue-number>
                                   3. @manager reads the issue in full
                                      - Fetches Figma design via Figma MCP
                                      - Presents implementation plan
                                        in the session
                                      - Waits for approval

4. Review and approve the plan
                                   5. If UI changes needed:
                                      @ui-librarian runs ui-audit skill
                                      - Audits Figma vs ui_manifest.md
                                      - Presents gap analysis in session
                                      - Waits for approval

6. Review and approve gap analysis
                                   7. @ui-librarian extends NeoComponent
                                      helpers as approved
                                      - Updates ui_manifest.md
                                      - Runs NeoComponent specs

                                   8. @feature-dev implements the feature
                                      - Creates task/<feature-name> branch
                                      - Builds controllers, views, specs
                                      - All data via ApiClient

9. Boot dummy app, review visually
   Give feedback directly in the
   session — not via PR comments
                                  10. Agent fixes immediately in session
                                      Repeat until output matches Figma

                                  11. @qa-agent runs both suites separately
                                      - bundle exec rspec engines/content_studio/spec/
                                      - bundle exec rspec spec/
                                      - bundle exec rubocop
                                      - Reports failures back to agents

12. Confirm feature is ready
    for final review
                                  13. @manager opens PR
                                      - From task/<feature-name>
                                      - Into feature/content-studio-v1
                                      - Includes screenshots of final output

14. Final code review and merge
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
   bundle exec rspec engines/content_studio/spec/
   bundle exec rubocop

6. Open PR from task/<name> into feature/content-studio-v1
   - Fill in the PR template
   - Include screenshots for any UI changes
```

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

**Engine specs and host app specs must be run in separate processes.** Each suite boots a distinct Rails application — Content Studio specs use `Dummy::Application` (defined in `engines/content_studio/spec/dummy/`), while host app specs use `Blackboard::Application`. Ruby cannot initialize both in the same process; attempting to do so will raise `Application has been already initialized`.

```bash
# Host app specs
bundle exec rspec spec/

# Content Studio engine specs (boots Dummy::Application, not Blackboard)
bundle exec rspec engines/content_studio/spec/

# Lint — covers all files including engines
bundle exec rubocop
```

In CI, run the two suites sequentially as separate steps rather than as a single `bundle exec rspec` invocation.

#### Why this separation exists

`.rspec` uses `--require spec_helper` (lightweight, no Rails boot) instead of `--require rails_helper`. Each spec file carries an explicit `require 'rails_helper'` (host) or `require_relative '../../rails_helper'` (engine), so the correct application is booted for whichever suite is running. Adding `--require rails_helper` back to `.rspec` would cause Blackboard to boot first for every run, breaking engine spec isolation.

---

## PR Guidelines

- PRs from agents include Visual Diffs — review them alongside the code diff.
- Do not merge a PR without passing specs and RuboCop.
- Tag PRs that touch NeoComponent helpers with the `neo-component` label — these trigger visual regression checks.
