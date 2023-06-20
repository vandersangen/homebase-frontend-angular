FROM node:19-alpine as builder

WORKDIR /usr/src/app

RUN npm install -g @angular/cli

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

CMD build --configuration=test
