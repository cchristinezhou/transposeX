# Stage 1: Base image with Node.js and Java
FROM node:18-slim

# Install dependencies and Java 22 from Adoptium (safer than Oracle URL)
RUN apt-get update && \
    apt-get install -y curl unzip wget gnupg ca-certificates && \
    wget https://github.com/adoptium/temurin22-binaries/releases/download/jdk-22.0.1%2B8/OpenJDK22U-jdk_x64_linux_hotspot_22.0.1_8.deb && \
    apt install -y ./OpenJDK22U-jdk_x64_linux_hotspot_22.0.1_8.deb && \
    rm OpenJDK22U-jdk_x64_linux_hotspot_22.0.1_8.deb && \
    java -version && \
    apt-get clean

# Set working directory
WORKDIR /app

# Copy Node.js dependency files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all backend files
COPY . .

# Create required directories
RUN mkdir -p /tmp/uploads/MusicXml

# Unzip Audiveris
RUN unzip audiveris.zip && \
    ls -R && \
    mv $(unzip -Z -1 audiveris.zip | head -1 | cut -d/ -f1) audiveris && \
    rm audiveris.zip

# Set environment variables
ENV NODE_ENV=production

# Expose port for Render
EXPOSE 10000

# Start the app
CMD ["node", "index.js"]