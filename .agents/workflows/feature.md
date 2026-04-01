---
description: Full pipeline for a Content Studio or NeoComponent feature — from GitHub issue to merged PR.
---

# /feature <issue-number>

Runs the complete feature development pipeline for the given GitHub issue.

## Steps

1. **Read the issue**
   @manager reads issue `#<issue-number>` in full, including the Figma URL and acceptance criteria.
   Present a summary to the developer and wait for confirmation before proceeding.

2. **UI Audit** *(skip if no Figma URL or no NeoComponent changes needed)*
   @ui-librarian runs the `ui-audit` skill against the Figma URL.
   Present the gap analysis to the developer in the session and wait for approval before proceeding.

3. **Implementation Plan**
   @manager presents a concrete implementation plan to the developer in the session.
   Wait for approval before proceeding.

4. **NeoComponent extensions** *(if needed)*
   @ui-librarian implements the approved helper extensions.
   Runs `bundle exec rspec engines/neo_component` — must pass before proceeding.

5. **Feature implementation**
   @feature-dev runs the `feature-impl` skill to build views, controllers, routes, and specs.

6. **Visual review loop** *(for UI changes)*
   Developer boots the dummy app and reviews the rendered output visually.
   Feedback is given directly in the session — not via PR comments.
   @feature-dev applies fixes immediately and the developer re-reviews.
   Repeat until the developer confirms the output matches the Figma design.

7. **QA review**
   @qa-agent runs the `qa-review` skill.
   If failures are found, delegate fixes back to `@feature-dev` or `@ui-librarian` and re-run.

8. **Open PR**
   PR is only opened once the developer explicitly confirms the feature is ready for final review.
   @manager opens a PR from `task/<feature-name>` into `feature/content-studio-v1`.
   PR must include screenshots of the final rendered output.
