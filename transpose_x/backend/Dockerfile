# Stage 1: Base image with Node.js and Java 22
FROM node:18-slim

# Install dependencies: curl, unzip, gnupg for key handling
RUN apt-get update && \
    apt-get install -y curl unzip gnupg && \
    # Add Adoptium GPG key
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium-archive-keyring.gpg && \
    # Add Adoptium to sources
    echo "deb [signed-by=/usr/share/keyrings/adoptium-archive-keyring.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" | tee /etc/apt/sources.list.d/adoptium.list && \
    # Install OpenJDK 22 (Temurin)
    apt-get update && \
    apt-get install -y temurin-22-jdk && \
    apt-get clean

# Set working directory
WORKDIR /app

# Copy Node.js dependency files first (leverages Docker caching)
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Copy entire backend app
COPY . .

# Create directory for Audiveris output (needed for Render temp storage)
RUN mkdir -p /tmp/uploads/MusicXml

# Set environment variables
ENV NODE_ENV=production

# Expose the port your server runs on (match index.js)
EXPOSE 10000

# Unzip Audiveris and move it into place
RUN unzip audiveris.zip && \
    mv $(unzip -Z -1 audiveris.zip | head -1 | cut -d/ -f1) audiveris && \
    rm audiveris.zip

# Launch the backend server
CMD ["node", "index.js"]