# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install required tools
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Node.js and Yarn
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

FROM base AS build

# Install build tools
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy remaining files
COPY . .

# Install JavaScript packages
RUN yarn install

# Add required environment variables for proper compilation
ARG SECRET_KEY_BASE
ARG RAILS_MASTER_KEY
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE \
    RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
    DATABASE_URL=postgresql://doesnt_matter_for_assets \
    RAILS_LOG_TO_STDOUT=true

# Handle configuration key
RUN if [ -f config/credentials.yml.enc ]; then \
    mkdir -p config/credentials && \
    touch config/credentials/production.key && \
    chmod 600 config/credentials/production.key; \
fi

# Add this before the assets:precompile command
RUN bundle exec rails about
RUN node -v && yarn -v
RUN ls -la

# Uncomment this when you're ready to precompile assets
RUN RAILS_ENV=production bundle exec rails assets:precompile --trace

FROM base

# Copy files from build stage
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# User setup
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER 1000:1000

# Set entry point
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80

# Run server (corrected)
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "80"]