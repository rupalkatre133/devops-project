FROM node:18

WORKDIR /app

# Copy only package.json
COPY package.json ./

RUN npm install

# Copy the rest of the source code
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
