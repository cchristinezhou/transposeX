# Stage 1: Base image with Node.js and Java
FROM node:18-slim

# Install Java (needed for Audiveris)
RUN apt-get update && \
    apt-get install -y default-jdk unzip && \
    apt-get clean

# Create working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install Node dependencies
RUN npm install

# Copy the rest of the backend code
COPY . .

# Make the uploads dir to avoid fs errors
RUN mkdir -p /tmp/uploads/MusicXml

# Set environment variable (optional)
ENV NODE_ENV=production

# Expose port (important for Render!)
EXPOSE 10000

# Download and set up Audiveris
RUN curl -LO https://github.com/Audiveris/audiveris/releases/download/5.3.2/audiveris-5.3.2.zip && \
    unzip audiveris-5.3.2.zip && \
    mv audiveris-5.3.2 audiveris && \
    rm audiveris-5.3.2.zip

# Start the server
CMD ["node", "index.js"]