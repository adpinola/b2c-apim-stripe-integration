FROM node:20
WORKDIR /usr/app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 8000
CMD [ "node", "dist/index.js" ]