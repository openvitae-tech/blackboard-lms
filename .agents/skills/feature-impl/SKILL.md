---
name: feature-impl
description: Implement a Content Studio feature — views, controllers, routes, ApiClient methods, and specs — based on an approved implementation plan.
---

# Feature Implementation Skill

## Goal
Build a complete, tested Content Studio feature from an approved plan.

## Instructions

1. Read the GitHub issue and the approved implementation plan in full
2. Read `engines/neo_component/ui_manifest.md` before writing any view
3. Implement in this order:
   a. ApiClient method(s) needed (delegate to BlackboardClient / fixture JSON)
   b. Controller action(s) in `engines/content_studio/app/controllers/content_studio/`
   c. Route(s) in `engines/content_studio/config/routes.rb`
   d. View(s) in `engines/content_studio/app/views/content_studio/` using NeoComponent helpers
   e. View spec(s) in `engines/content_studio/spec/views/`
   f. System spec(s) in `engines/content_studio/spec/system/`
4. Run `bundle exec rspec engines/content_studio` — all specs must pass
5. Run `bundle exec rubocop engines/content_studio` — no offenses
6. Open a PR from `task/<feature-name>` into `feature/content-studio-v1`

## Constraints
- No raw HTML for UI elements covered by NeoComponent
- No direct ActiveRecord model access — always through ApiClient
- No PR without passing specs and clean RuboCop
