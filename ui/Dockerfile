# Use the Flutter SDK image as base
FROM dart:stable AS build

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

# Use Nginx to serve the web build
FROM nginx:stable-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]