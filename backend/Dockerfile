FROM node:latest
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ENV HOST=0.0.0.0 PORT=4000
EXPOSE 4000

CMD ["npm", "run", "server"]