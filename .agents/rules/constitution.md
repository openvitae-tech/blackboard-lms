# Project Constitution

This file is always active. All agents must follow these rules without exception.
The full constitution is in `CLAUDE.md` at the repository root — read it first.

---

## Architecture

This is a monorepo with three projects:

| Project | Path | Purpose |
|---------|------|---------|
| BlackboardLMS | `app/` | Host Rails app |
| NeoComponent | `engines/neo_component/` | UI component library |
| Content Studio | `engines/content_studio/` | Portable content creation engine |

---

## Hard Rules

### Data Isolation (enforced by RuboCop)
Content Studio must never access BlackboardLMS ActiveRecord models directly.
All data flows through `ContentStudio::ApiClient`.

```ruby
# NEVER inside engines/content_studio/
User.find(id)
Course.where(...)

# ALWAYS
ContentStudio::ApiClient.current_user
ContentStudio::ApiClient.list_courses
```

### UI — NeoComponent Only
All views use NeoComponent helpers. No raw HTML for elements that components cover.
Reference `engines/neo_component/ui_manifest.md` for the full catalog.

### Prop Bloat Policy
Extend existing helpers with optional arguments. Do not create new components
when an existing one can be extended.

### Testing
Every PR touching Content Studio must include view specs and system specs.
No PR is valid without passing specs.

---

## Git Rules
- All Content Studio work: branch `feature/content-studio-v1`
- Task branches: `task/<short-description>` → PR into `feature/content-studio-v1`
- Never PR directly into `main` during active Content Studio development
- Always run `bundle exec rspec` and `bundle exec rubocop` before pushing
