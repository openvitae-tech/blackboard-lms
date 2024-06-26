# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-bookworm as base

# Rails app lives here
WORKDIR /deploy

# Set environment
ENV RAILS_ENV="docker" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_MASTER_KEY="dee4823f10cb1f3cc02c610f33eab947"


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

COPY package.json package-lock.json ./
RUN npm install
# Copy application code
COPY . .
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
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips  && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

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
#
# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]