#!/bin/bash

set -e  # Exit on any error

# Step 1: Pull the latest changes from the main repo and submodules
echo "Pulling latest changes from the main repository and submodules..."
git pull origin main
git submodule update --init --recursive
git submodule foreach git pull origin main

# Step 2: Update the homepage in package.json
echo "Updating homepage in package.json..."
jq '.homepage = "/reqbin/"' interactsh-web/package.json > tmp.json && mv tmp.json interactsh-web/package.json

echo '# Base build stage
FROM node:16 as builder

WORKDIR /app
COPY package.json yarn.lock ./
COPY . .

RUN yarn install && yarn build

# Serve build with a static file server
FROM node:16 as runner

WORKDIR /app
RUN yarn global add serve

COPY --from=builder /app/build ./build

EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]
'>interactsh-web/Dockerfile

# Step 3: Deploy using docker-compose
echo "Deploying using docker-compose..."
docker-compose up -d --build

echo "Deployment complete."

