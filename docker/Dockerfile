# ================================
# Build Arguments
# ================================
# Go version from .go-version (single source of truth)
# MUST be passed via --build-arg GO_VERSION=$(cat .go-version)
# Docker cannot read files before FROM, so the build process must pass this.
ARG GO_VERSION=1.23

# ================================
# Stage 1: Builder
# ================================
FROM golang:${GO_VERSION}-bookworm AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/rhiza-go ./cmd/rhiza-go

# ================================
# Stage 2: Runtime
# ================================
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/rhiza-go /app/rhiza-go

# Use non-root user
USER nonroot:nonroot

# Run the application
ENTRYPOINT ["/app/rhiza-go"]
