# Use Node.js 18 base image
FROM node:18

# Set working directory inside container
WORKDIR /app

# Copy only package files first (for better caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose application port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
