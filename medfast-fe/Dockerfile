# Build stage
FROM node:20-alpine3.19 AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci && npm cache clean --force

# Copy source code
COPY . .

# Build the app
RUN npm run build


# Production stage
FROM nginx:1.27-alpine3.19

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx config if you have custom configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]