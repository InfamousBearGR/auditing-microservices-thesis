# --- Stage 1: Build (Go 1.25.6) ---
FROM golang:1.25.6-alpine AS builder

WORKDIR /app

# Install git (required for fetching some Go dependencies)
RUN apk add --no-cache git

# Copy module files and download dependencies
COPY go.mod go.sum* ./
RUN go mod download

# Copy source code and all subdirectories
COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux go build -o history-api main.go

# --- Stage 2: Run (Alpine Linux) ---
FROM alpine:latest

WORKDIR /root/

ENV ENV_FILE=.env.prod

# Copy binary from builder
COPY --from=builder /app/history-api .
# Copy production env file
COPY .env.prod .

EXPOSE 8081

CMD ["./history-api"]
