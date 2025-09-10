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
RUN curl -LO https://github.com/Audiveris/audiveris/releases/download/5.3.2/audiveris-5.3.2.zip && \
    unzip audiveris-5.3.2.zip && \
    mv audiveris-5.3.2 audiveris && \
    rm audiveris-5.3.2.zip

# Start the app
CMD ["node", "index.js"]