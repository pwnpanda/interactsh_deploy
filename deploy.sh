#!/bin/bash

cp /etc/letsencrypt/live/h4x.fun-0001/fullchain.pem certs/
cp /etc/letsencrypt/live/h4x.fun-0001/privkey.pem certs/

docker compose down

docker compose up --build -d

