# Stage 1: Base image with Node.js and Java
FROM node:18-slim

# Install Java, curl, unzip (needed for Audiveris setup)
RUN apt-get update && \
    apt-get install -y curl unzip gnupg && \
    mkdir -p /usr/share/keyrings && \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium-archive-keyring.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && \
    apt-get install -y temurin-21-jdk && \
    apt-get clean

# Set working directory
WORKDIR /app

# Copy Node.js dependency files first (for Docker caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all backend files
COPY . .

# Create required directories (esp. for /tmp usage in Render)
RUN mkdir -p /tmp/uploads/MusicXml

# Set environment variables
ENV NODE_ENV=production

# Expose port for Render (must match your service port)
EXPOSE 10000

RUN unzip audiveris.zip && \
    ls -R && \
    mv $(unzip -Z -1 audiveris.zip | head -1 | cut -d/ -f1) audiveris && \
    rm audiveris.zip

# Start the app
CMD ["node", "index.js"]