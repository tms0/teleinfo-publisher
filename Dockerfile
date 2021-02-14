FROM nodered/node-red:1.2.9-12

# Installation du nécessaire pour utiliser le port série et les ports GPIO

USER root

RUN apk add --no-cache py-pip python-dev \
  && pip install RPi.GPIO \
  && addgroup --system --gid 997 gpio \
  && adduser node-red gpio \
  && adduser node-red dialout

USER node-red

COPY package.json /data/package.json

RUN cd /data && npm install

COPY data /data
