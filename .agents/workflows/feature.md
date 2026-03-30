---
description: Full pipeline for a Content Studio or NeoComponent feature — from GitHub issue to merged PR.
---

# /feature <issue-number>

Runs the complete feature development pipeline for the given GitHub issue.

## Steps

1. **Read the issue**
   @manager reads issue `#<issue-number>` in full, including the Figma URL and acceptance criteria.

2. **UI Audit** *(skip if no Figma URL or no NeoComponent changes needed)*
   @ui-librarian runs the `ui-audit` skill against the Figma URL.
   Post gap analysis as a comment on the issue and wait for developer approval before proceeding.

3. **Implementation Plan**
   @manager posts a concrete implementation plan as a comment on the issue.
   Wait for developer approval before proceeding.

4. **NeoComponent extensions** *(if needed)*
   @ui-librarian implements the approved helper extensions.
   Runs `bundle exec rspec engines/neo_component` — must pass before proceeding.

5. **Feature implementation**
   @feature-dev runs the `feature-impl` skill to build views, controllers, routes, and specs.

6. **QA review**
   @qa-agent runs the `qa-review` skill.
   If failures are found, delegate fixes back to `@feature-dev` or `@ui-librarian` and re-run.

7. **Open PR**
   @manager opens a PR from `task/<feature-name>` into `feature/content-studio-v1`.
   PR must include screenshots or visual diffs for any UI changes.
