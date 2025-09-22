# Stage 1: Base image with Node.js
FROM node:18-slim

# Install basic dependencies required for Audiveris installer
RUN apt-get update && \
    apt-get install -y curl wget ca-certificates && \
    apt-get clean

# Download and install Audiveris Linux installer (comes with JRE included)
RUN wget https://github.com/Audiveris/audiveris/releases/download/5.7.1/Audiveris-5.7.1-linux-x86_64.deb && \
    apt-get install -y ./Audiveris-5.7.1-linux-x86_64.deb && \
    rm Audiveris-5.7.1-linux-x86_64.deb

# Set working directory
WORKDIR /app

# Copy Node.js dependency files
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Copy all backend files
COPY . .

# Create required directories
RUN mkdir -p /tmp/uploads/MusicXml

# Remove the audiveris.zip extraction since we're using the system-installed version
# The audiveris command is now available system-wide

# Set environment variables
ENV NODE_ENV=production

# Expose port for Render
EXPOSE 10000

# Start the app
CMD ["node", "index.js"]