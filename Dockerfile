# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-bookworm as base

# Rails app lives here
WORKDIR /deploy

ARG RAILS_ENV
ARG PORT=3000
ARG RAILS_MASTER_KEY

# Set environment
ENV RAILS_ENV=${RAILS_ENV}
ENV PORT=${PORT}
ENV BUNDLE_DEPLOYMENT="1"
ENV BUNDLE_PATH="/usr/local/bundle"
ENV BUNDLE_WITHOUT="development:test"
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# ------------------------------
# Node.js stage – official multi-arch image (replaces arm64-specific manual download)
# ------------------------------
FROM node:22-bookworm-slim AS node-fetch

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems (npm removed – Node comes from node-fetch stage)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev libvips pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Copy Node.js from node-fetch into the build stage
COPY --from=node-fetch /usr/local/bin/node /usr/local/bin/node
COPY --from=node-fetch /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install
RUN rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
RUN bundle exec bootsnap precompile --gemfile

# Install Node.js dependencies (copied before app code for better layer caching)
COPY package.json package-lock.json ./
ENV HUSKY=0
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN npm ci

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# -------------------------------------------------------------------
# Final stage for app image
# -------------------------------------------------------------------

FROM base
# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libvips chromium ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Copy Node from node-fetch stage
COPY --from=node-fetch /usr/local/bin/node /usr/local/bin/node
COPY --from=node-fetch /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Set environment variables for Puppeteer/Grover to use system Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
# Run Grover in no-sandbox mode
ENV GROVER_NO_SANDBOX=true

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /deploy /deploy

#
# Run and own only the runtime files as a non-root user for security
## Note:
## Docker allows non root used to bind to port 80 and it works perfectly.
## But tried this in AWS ECS, the application cannot bind to port 80
## as non root user therefore commenting our the user creation.
## Tried a work aroud by using port 3000 but the load balancer health check
## requires port 80 in aws, therefore port 80 seems like a mandatory requirement.
#
# RUN useradd deploy --create-home --shell /bin/bash && \
#     chown -R deploy:deploy db log storage tmp
# USER deploy:deploy

# Entrypoint prepares the database.
ENTRYPOINT ["/deploy/bin/docker-entrypoint"]
# Start the server by default, this can be overwritten at runtime use 3000 in local
EXPOSE ${PORT}
CMD ["sh", "-c", "./bin/rails server -p $PORT"]
