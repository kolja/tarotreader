# Stage 1: Build the application
FROM rust:slim-bullseye AS builder

# Install required system dependencies for building
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a new user for building (security best practice)
RUN useradd -m -u 1001 -U -s /bin/sh rust

# Set working directory
WORKDIR /usr/src/app

# Copy manifest files for dependency caching
COPY Cargo.toml Cargo.lock ./

# Create a dummy main.rs to build dependencies
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs

# Build dependencies in release mode (this layer will be cached)
RUN cargo build --release && \
    rm -rf src target/release/deps/backend*

# Copy the actual source code
COPY ./src ./src

# Touch main.rs to ensure it's newer than the cached dependencies
RUN touch src/main.rs

# Build the actual application
RUN cargo build --release

# Stage 2: Create the runtime image
FROM debian:bullseye-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl1.1 \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to run the application
RUN useradd -m -u 1001 -U -s /bin/sh appuser

# Set working directory
WORKDIR /app

# Copy the compiled binary from builder
COPY --from=builder --chown=appuser:appuser /usr/src/app/target/release/backend /app/backend

# Create directory for potential file uploads or logs
RUN mkdir -p /app/data && chown -R appuser:appuser /app/data

# Switch to non-root user
USER appuser

# Expose the port (default Rocket port)
EXPOSE 8000

# Set environment variables for production
ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8000
ENV ROCKET_LOG_LEVEL=normal
ENV RUST_LOG=info

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/bin/sh", "-c", "curl -f http://localhost:8000/health || exit 1"]

# Run the binary
ENTRYPOINT ["/app/backend"]
