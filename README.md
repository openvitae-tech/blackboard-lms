<div align="center">

# Blackboard LMS

**An open-source learning management system built for the hotel and hospitality industry.**

[![Ruby on Rails CI](https://github.com/openvitae-tech/blackboard-lms/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/openvitae-tech/blackboard-lms/actions/workflows/rubyonrails.yml)
![Ruby](https://img.shields.io/badge/ruby-4.0.6-CC342D?logo=ruby&logoColor=white)
![Rails](https://img.shields.io/badge/rails-8.0-D30001?logo=rubyonrails&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgresql-15-4169E1?logo=postgresql&logoColor=white)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[Features](#features) · [Architecture](#architecture) · [Getting Started](#getting-started) · [Testing](#testing) · [Contributing](#contributing)

</div>

---

## Overview

Blackboard LMS helps hospitality organisations train their staff at scale. Administrators build courses, organise learners into teams, track progress and issue certificates, all from one Ruby on Rails application.

## Features

- **Course authoring:** courses, modules and lessons, with video, local content and SCORM package support
- **Assessments:** quizzes, question banks and assessments to measure learner progress
- **Programs:** group courses into structured learning paths
- **Teams and enrollments:** enroll individuals or whole teams and manage access per learning partner
- **Certificates:** customisable certificate templates issued on course completion
- **Reporting:** dashboards and exportable reports (Excel and PDF)
- **Content Studio:** a separate content creation engine, toggled per learning partner
- **AI assistance:** LLM-powered features via [RubyLLM](https://rubyllm.com/)

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Ruby on Rails 8, Ruby 4.0.6 |
| Frontend | Hotwire (Turbo and Stimulus), Tailwind CSS, Flowbite, import maps |
| Database | PostgreSQL 15 |
| Background jobs | Sidekiq with sidekiq-cron, backed by Redis 7 |
| Auth | Devise (authentication), Pundit (authorization) |
| Storage | Active Storage with AWS S3 |
| Media | ImageMagick, FFmpeg |
| Monitoring | Sentry, New Relic |
| Testing | RSpec, FactoryBot, Capybara, Selenium |

## Architecture

This repository is a monorepo containing three projects:

| Project | Path | Purpose |
|---------|------|---------|
| **BlackboardLMS** | [`app/`](app) | Host Rails application: the production LMS |
| **NeoComponent** | [`engines/neo_component/`](engines/neo_component) | UI component library (Rails engine) |
| **Content Studio** | [`engines/content_studio/`](engines/content_studio) | Portable content creation engine (Rails engine) |

```
blackboard-lms/
├── app/                  # Host application (controllers, models, policies, services, queries)
├── config/               # Rails config, routes, tailwind.config.js
├── db/                   # Migrations, schema and seeds
├── engines/
│   ├── neo_component/    # UI components, see ui_manifest.md for the catalogue
│   └── content_studio/   # Content Studio engine with its own dummy app for specs
├── spec/                 # RSpec suite for the host application
└── CLAUDE.md             # Architecture rules and conventions for AI agents
```

Content Studio never touches host models directly. All data goes through `ContentStudio::ApiClient`, which calls the host application's internal API:

```
Content Studio views → ContentStudio::ApiClient → Api::Internal controllers → ActiveRecord models
```

All UI in both the host app and Content Studio is built with **NeoComponent** helpers. Colours are defined only in `config/tailwind.config.js`.

## Getting Started

### Prerequisites

| Dependency | Version |
|------------|---------|
| Ruby | 4.0.6 (see [`.ruby-version`](.ruby-version)) |
| Node.js | 22.x |
| PostgreSQL | 15.x |
| Redis | 7.x |
| ImageMagick | latest |
| FFmpeg | latest |

<details>
<summary><strong>Installing the prerequisites</strong></summary>

#### Ruby

Install Ruby with a version manager such as [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://rvm.io/), then install Bundler:

```bash
gem install bundler
```

#### Node.js

Use [nvm](https://github.com/nvm-sh/nvm) or the [official installer](https://nodejs.org/):

```bash
nvm install 22
nvm use 22
```

#### PostgreSQL and Redis

Install them natively ([PostgreSQL](https://www.postgresql.org/download/), [Postgres.app](https://postgresapp.com/) on macOS, [Redis](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/)) or run them with Docker:

```bash
docker run -d --name postgresql \
  -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=blackboard_development \
  -p 5432:5432 postgres:15.4-bookworm

docker run -d --name redis -p 6379:6379 redis:7.2.6-alpine
```

#### ImageMagick and FFmpeg

```bash
# macOS
brew install imagemagick ffmpeg

# Ubuntu / Debian
sudo apt install imagemagick ffmpeg
```

</details>

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/openvitae-tech/blackboard-lms.git
   cd blackboard-lms
   ```

2. **Install front-end dependencies** (needed for the Tailwind CSS build)

   ```bash
   npm install
   ```

3. **Set up credentials**

   Choose the editor Rails should open, then edit the credentials file. Paste in the contents of `config/credentials.yml.enc.example`, fill in your values, then save and close the file.

   ```bash
   export EDITOR="code --wait"   # or: export EDITOR="vim"
   bin/rails credentials:edit
   ```

4. **Enable git hooks**

   ```bash
   git config core.hooksPath .husky
   ```

5. **Install gems, prepare the database and load seed data**

   ```bash
   bin/setup
   ```

   > [!WARNING]
   > `bin/setup` drops and recreates the development database. Do not run it if you have local data you want to keep.

6. **Start the application**

   ```bash
   bin/dev
   ```

   This starts the Rails server, the Tailwind watcher and Sidekiq (see [`Procfile.dev`](Procfile.dev)). Open <http://localhost:3000> in your browser.

### Running with Docker

```bash
docker compose build
docker compose up
```

Docker Compose runs the app in a dedicated `docker` Rails environment, together with PostgreSQL, Redis and a Sidekiq worker. Generate a master key for that environment and set `RAILS_MASTER_KEY` in `docker-compose.yml` before you start it.

## Testing

Create the test database if `bin/setup` has not already done so:

```bash
bin/rails db:create RAILS_ENV=test
```

Run the suites:

```bash
bundle exec rspec                         # full suite, including engines
bundle exec rspec engines/neo_component   # NeoComponent only
bundle exec rspec engines/content_studio  # Content Studio only
bundle exec rspec -f d --tag focus        # only specs tagged :focus, with descriptions
```

For continuous testing during TDD:

```bash
bundle exec guard
```

### Code Quality

```bash
bundle exec rubocop        # linting, including custom cops
bundle exec brakeman       # static security analysis
bundle exec bundler-audit  # known vulnerabilities in dependencies
```

CI runs RSpec, RuboCop, Brakeman and bundler-audit on every push and pull request to `main`. RSpec and RuboCop must pass before a PR can be merged.

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow, and [CLAUDE.md](CLAUDE.md) for the architecture rules and coding conventions every change must follow.

1. Branch from an up-to-date `main` using the `task/<short-description>` naming convention.
2. Write specs for your change. Content Studio changes need both view and system specs.
3. Make sure `bundle exec rspec` and `bundle exec rubocop` both pass.
4. Open a pull request into `main`. Include visual diffs for any NeoComponent changes.

## License

Blackboard LMS is released under the [MIT License](LICENSE).
Copyright © 2024 Openvitae Technologies Private Limited.
