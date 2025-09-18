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

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential npm libpq-dev libvips pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install
RUN rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
RUN bundle exec bootsnap precompile --gemfile

# The following steps are no longer needed with importmap
# COPY package.json package-lock.json ./

# Copy application code
COPY . .

ENV HUSKY=0
RUN npm install

#
# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/
#
# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
#
#
# Final stage for app image
FROM base
# Install packages needed for deployment
RUN apt-get update && apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_22.19.0 | bash - && \
    apt-get install -y nodejs

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips chromium && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
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
