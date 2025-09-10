# Stage 1: Base image with Node.js and Java
FROM node:18-slim

# Install Java, curl, unzip (needed for Audiveris setup)
RUN apt-get update && \
    apt-get install -y default-jdk curl unzip && \
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

# Download and set up Audiveris
RUN curl -fL -o audiveris.zip https://github.com/cchristinezhou/transposeX/releases/download/v5.7.0/audiveris.zip && \
    unzip audiveris.zip && \
    mv $(unzip -Z -1 audiveris.zip | head -1 | cut -d/ -f1) audiveris && \
    rm audiveris.zip

# Start the app
CMD ["node", "index.js"]