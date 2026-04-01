# CLAUDE.md — AI Agent Constitution

This file is the source of truth for all AI agents working in this repository. Read it at the start of every session. All rules here are mandatory — they are not suggestions.

---

## Repository Overview

This is a **monorepo** containing three interconnected projects:

| Project | Path | Purpose |
|---------|------|---------|
| **BlackboardLMS** | `app/` | Host Rails application — LMS production app |
| **NeoComponent** | `engines/neo_component/` | UI component library (Rails engine) |
| **Content Studio** | `engines/content_studio/` | Portable content creation engine (Rails engine) |

---

## Architecture Rules

### 1. Content Studio — Data Isolation (HARD RULE)

Content Studio is **strictly forbidden** from directly accessing BlackboardLMS models.

```ruby
# NEVER do this inside engines/content_studio/
User.find(id)
Course.where(...)
Enrollment.create(...)

# ALWAYS do this instead
ContentStudio::ApiClient.find_user(id)
ContentStudio::ApiClient.list_courses(...)
```

This is enforced by a RuboCop custom cop. Violations will fail CI. There are no exceptions.

### 2. Content Studio — Data Flow

```
Content Studio Views
       ↓
ContentStudio::ApiClient  (interface — swap MockClient ↔ real client)
       ↓
BlackboardLMS Internal API  (Api::Internal controllers, session auth + Pundit)
       ↓
ActiveRecord Models
```

During development (Phase 1 & 2), `ContentStudio::MockClient` is used in place of `ApiClient`. The switch to the real client happens in Phase 3.

### 3. UI — NeoComponent Only

All views in Content Studio and BlackboardLMS must use **NeoComponent helpers** for UI elements. Do not write raw HTML for anything a component already covers.

Refer to `engines/neo_component/ui_manifest.md` for the full catalog of available helpers and their arguments.

### 4. Prop Bloat Policy

If a view requires functionality that a NeoComponent helper does not support:

- **Extend** the existing helper with an optional argument (keep the default so existing callers are unaffected).
- **Do not** create a new component.
- **Do not** duplicate the component under a different name.

```ruby
# WRONG — creating a new component
def button_with_spinner(...)

# RIGHT — extending the existing helper with an optional argument
def button_component(
  text: '',
  type: 'solid',
  size: 'md',
  colorscheme: 'primary',
  loading: false,   # <-- new optional arg, defaults to false
  ...
)
```

---

## NeoComponent — Key Helpers

All helpers live in `engines/neo_component/app/helpers/view_component/`. The full auto-generated reference is in `engines/neo_component/ui_manifest.md`.

### `button_component`
```ruby
button_component(
  text: 'Save',
  type: 'solid',          # solid | outline
  size: 'md',             # sm | md | lg
  colorscheme: 'primary', # primary | secondary | danger
  icon_name: nil,
  icon_position: 'left',  # left | right
  tooltip_text: '',
  tooltip_position: 'bottom', # top | left | bottom | right
  disabled: false,
  hide_label_in_mobile: false,
  html_options: {}
)
```

### `button` (simpler variant)
```ruby
button(
  label: 'Save',
  type: 'primary',        # primary | secondary | danger
  size: 'md',
  icon_name: nil,
  icon_position: 'left',
  tooltip_text: '',
  tooltip_position: 'bottom',
  disabled: false,
  html_options: {}
)
```

For the full list of components, see `engines/neo_component/ui_manifest.md`.

---

## Ruby Code Style (RuboCop)

Follow these conventions in all generated code:

- **Single quotes** by default — use double quotes only when interpolating or using special characters (`\n`, `\t` etc.)
- **Empty methods** on one line: `def index; end` — only use this for truly empty methods (no body). Methods with a body, even a single expression, must use the full multi-line form.
- **Argument forwarding** shorthand: use `...` instead of `*args, **kwargs, &block`
- **No doc comments** on classes or modules — `Style/Documentation` is disabled
- **Max method length: 30 lines** — extract private methods if approaching this
- **Max class length: 250 lines** — split into concerns/services if approaching this
- **`frozen_string_literal: true`** magic comment at the top of every Ruby file

---

## BlackboardLMS — Conventions

### Authentication & Authorization
- Authentication: **Devise** (`authenticate_user!` in `ApplicationController`)
- Authorization: **Pundit** (`include Pundit::Authorization`, `before_action :authenticate_user!`)
- Every controller action must have a corresponding Pundit policy. Never skip authorization.
- Admin check: `current_user.is_admin?` | Privileged: `current_user.privileged_user?`

### Controllers
```ruby
class MyController < ApplicationController
  before_action :authenticate_user!
  # Pundit policy expected for every action
end
```

### Models
- All models inherit from `ApplicationRecord`
- Domain logic lives in `app/domain/`, `app/services/`, `app/queries/` — not in models
- Keep models thin

### Testing
- Test framework: **RSpec**
- Specs live in `spec/` mirroring `app/` structure
- Factories: **FactoryBot** (`spec/factories/`)
- Policy specs in `spec/policies/`

---

## Content Studio — Conventions

### Engine Structure
```
engines/content_studio/
├── app/
│   ├── controllers/content_studio/
│   ├── models/content_studio/        # engine-local models only, no BlackboardLMS models
│   ├── views/content_studio/
│   └── helpers/content_studio/
├── lib/
│   └── content_studio/
│       ├── api_client.rb             # interface (delegates to mock or real)
│       ├── mock_client.rb            # Phase 1 & 2 — fake data
│       └── engine.rb
└── spec/
    ├── dummy/                        # lightweight dummy app for isolated testing
    ├── views/
    └── system/
```

### ApiClient Interface
`MockClient` and the real client must implement identical method signatures. Never call `MockClient` directly — always go through `ApiClient`.

```ruby
# lib/content_studio/api_client.rb
module ContentStudio
  class ApiClient
    def self.list_courses = client.list_courses
    def self.find_user(id) = client.find_user(id)

    def self.client
      Rails.env.test? || Feature.disabled?(:content_studio_live_data) ?
        MockClient.new : RealClient.new
    end
  end
end
```

### Feature Flag
Content Studio is mounted behind a feature flag:
```ruby
# config/routes.rb
if Feature.enabled?(:content_studio)
  mount ContentStudio::Engine, at: '/content-studio'
end
```

Never remove the feature flag until the dark launch is complete and verified.

---

## Testing Requirements

Every PR that touches Content Studio **must** include:

1. **View specs** (`spec/views/`) — test rendered HTML for every view
2. **System specs** (`spec/system/`) — test user flows end-to-end against the dummy app

No code proposal is valid without passing specs. The agent must write specs before opening a PR.

```bash
bundle exec rspec engines/content_studio   # run Content Studio specs only
bundle exec rspec                          # full suite
bundle exec rubocop                        # lint + custom cops
```

---

## Development Phases

| Phase | Status | Description |
|-------|--------|-------------|
| **Phase 1** | In progress | Engine scaffold, MockClient, spec/dummy app, ui_manifest |
| **Phase 2** | Pending | Visual audit vs Figma, NeoComponent extensions, visual QA |
| **Phase 3** | Pending | Real ApiClient, Internal API, dark launch |

---

## Git & PR Rules

- All Content Studio work lives on `feature/content-studio-v1`
- Task branches: `task/<short-description>` — PR into `feature/content-studio-v1`
- Never PR directly into `main` during active Content Studio development
- PR descriptions must include Visual Diffs for any NeoComponent changes
- Always run `bundle exec rspec` and `bundle exec rubocop` before pushing. Fix all failures before pushing — do not push a broken build.
- PRs require passing RSpec + RuboCop before merge

---

## What Agents Must Not Do

- Access BlackboardLMS models from within `engines/content_studio/`
- Create new NeoComponent components when extending an existing one is possible
- Write raw HTML for UI elements covered by NeoComponent
- Open a PR without specs
- Modify `CLAUDE.md` without developer approval
