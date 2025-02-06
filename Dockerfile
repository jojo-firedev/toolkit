# Use a pre-configured Flutter image for building the web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set the working directory
WORKDIR /app

# Copy the Flutter project files
COPY . .

# Precache Flutter Web SDK
RUN flutter precache --web

# Get Flutter dependencies
RUN flutter pub get

# Build the Flutter web app
RUN flutter build web

# Use Nginx to serve the Flutter web app
FROM nginx:stable-alpine

# Copy built web app from the build stage to the Nginx HTML directory
COPY --from=build /app/build/web/ /usr/share/nginx/html

# Set the owner of the Nginx HTML directory to www-data (not strictly necessary in alpine, added for completeness)
RUN chown -R nginx:nginx /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]