# Build the flutter app
FROM dart:stable AS ui_build

# Install Flutter dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    xz-utils \
    libglu1-mesa

# Clone Flutter (stable channel)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor
RUN flutter channel stable
RUN flutter upgrade

# Copy Flutter project
WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build for web
RUN flutter build web --release

# Build the server
FROM golang:1.24-alpine AS server_build

WORKDIR /

# Copy the source code
COPY main.go go.mod /

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build

# Use server to serve the flutter app
FROM alpine:latest
RUN apk add curl
WORKDIR /
COPY --from=ui_build /app/build/web /static
COPY --from=server_build /ui-server .
EXPOSE 3000
CMD ["./ui-server"]