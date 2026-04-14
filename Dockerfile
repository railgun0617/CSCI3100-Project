FROM ruby:3.2-slim

# Prevent debconf from asking interactive questions
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install build dependencies + runtime libraries + YAML headers
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsqlite3-dev \
    libsqlite3-0 \
    libyaml-dev \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfiles first for better caching
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Precompile assets (required for production)
RUN SECRET_KEY_BASE=placeholder RAILS_ENV=production bundle exec rails assets:precompile

# Expose port 8080 (Cloud Run default)
EXPOSE 8080

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080"]