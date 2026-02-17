# Build stage
FROM golang:1.20 AS builder

WORKDIR /build

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build arguments for version information
ARG VERSION=dev
ARG COMMIT_SHA1=unknown
ARG BUILD_DATE=unknown

# Build the binary with static linking and version info
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "-s -w -extldflags '-static' \
    -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.VERSION=${VERSION} \
    -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.COMMIT_SHA1=${COMMIT_SHA1} \
    -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.BUILD_DATE=${BUILD_DATE}" \
    -o /build/openvpn_exporter .

# Final stage - use busybox for minimal image size
FROM busybox:1.36

# Install CA certificates for HTTPS support
RUN apk --no-cache add ca-certificates

WORKDIR /

# Copy binary from builder
COPY --from=builder /build/openvpn_exporter /openvpn_exporter

# Expose metrics port
EXPOSE 9176

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /openvpn_exporter -version || exit 1

# Run as non-root user
USER nobody

ENTRYPOINT ["/openvpn_exporter"]
CMD ["-h"]
