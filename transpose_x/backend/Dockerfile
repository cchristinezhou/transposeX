# Stage 1: Base image with Node.js and Java 24
FROM node:18-slim

# Install dependencies, native libraries, and Java 24
RUN apt-get update && \
    apt-get install -y curl unzip wget gnupg ca-certificates apt-transport-https \
        libleptonica-dev libtesseract-dev tesseract-ocr tesseract-ocr-eng \
        libfreetype6-dev libfontconfig1-dev build-essential pkg-config \
        libjpeg-dev libpng-dev libtiff-dev libgif-dev && \
    mkdir -p /etc/apt/keyrings && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/keyrings/adoptium.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && \
    apt-get install -y temurin-24-jdk && \
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

# Unzip Audiveris and set up library paths
RUN unzip audiveris.zip && \
    ls -R && \
    mv $(unzip -Z -1 audiveris.zip | head -1 | cut -d/ -f1) audiveris && \
    rm audiveris.zip

# Create symlinks for JavaCPP libraries and set up native library paths
RUN find /app/audiveris -name "*.so" -type f | head -10 && \
    find /app/audiveris -name "*leptonica*" -type f && \
    find /app/audiveris -name "*tesseract*" -type f

# Set up environment variables for native libraries and JavaCPP
ENV LD_LIBRARY_PATH=/app/audiveris/lib:/usr/lib/x86_64-linux-gnu:/usr/local/lib:$LD_LIBRARY_PATH
ENV JAVA_LIBRARY_PATH=/app/audiveris/lib:/usr/lib/x86_64-linux-gnu:/usr/local/lib

# Set environment variables
ENV NODE_ENV=production

# Expose port for Render
EXPOSE 10000

# Start the app with additional JVM flags for native access
CMD ["node", "index.js"]