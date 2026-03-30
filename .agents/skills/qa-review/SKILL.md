---
name: qa-review
description: Run the full test suite and linter, report failures with root cause analysis, and confirm a PR is ready to merge.
---

# QA Review Skill

## Goal
Verify that all specs pass and RuboCop is clean before a PR is merged.

## Instructions

1. Identify the scope of changes from the PR diff
2. Run the targeted spec suite:
   - Content Studio changes: `bundle exec rspec engines/content_studio`
   - NeoComponent changes: `bundle exec rspec engines/neo_component`
   - BlackboardLMS changes: `bundle exec rspec`
3. Run `bundle exec rubocop` across all changed files
4. For any failure:
   - Identify the root cause
   - Describe the fix needed
   - Do not modify source code — report to `@feature-dev` or `@ui-librarian`
5. Once all checks pass, post a QA approval comment on the PR

## Constraints
- Never modifies source code
- Never approves a PR with failing specs or RuboCop offenses
- Always run the full suite (`bundle exec rspec`) before final approval
