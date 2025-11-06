# Stage 1: Build the application
FROM rust:1.91 AS builder

# Create a new empty shell project
WORKDIR /usr/src/app
RUN USER=root cargo init --bin .

# Copy over your manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# Build only the dependencies to cache them
RUN cargo build --release
RUN rm src/*.rs

# Copy your actual source code
COPY ./src ./src

# Build for release.
RUN rm ./target/release/deps/backend*
RUN cargo build --release

# Stage 2: Create the final, minimal image
FROM debian:buster-slim AS final

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/target/release/backend .

# Set the binary as the entrypoint
CMD ["./backend"]
