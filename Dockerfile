# Build stage
FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /app

# Download dependencies
COPY go.mod ./
RUN go mod download

# Copy source code and build
COPY . .
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o main ./cmd/main.go

# Run stage
FROM alpine:3.21

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 8080
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/main .

RUN chmod +x /app/main

CMD ["./main"]
