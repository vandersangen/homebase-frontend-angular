FROM node:20-alpine as builder

WORKDIR /usr/src/app

RUN npm install -g @angular/cli

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

RUN npm run build -- --output-path=./dist/out --configuration=test

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM nginx:alpine as deployed

# Copy dist output to nginx
COPY --from=builder /usr/src/app/dist/out/ /usr/share/nginx/html

# Copy default nginx configuration
COPY ./docker/config/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
