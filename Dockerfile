ARG NODERED_IMAGE_TAG

FROM nodered/node-red:${NODERED_IMAGE_TAG}

# Installation du nécessaire pour utiliser le port série et les ports GPIO

USER root

RUN addgroup --system --gid 997 gpio

RUN apk add --no-cache py-pip python-dev

RUN pip install RPi.GPIO

USER node-red

RUN npm install node-red-node-serialport node-red-node-pi-gpio

ENTRYPOINT ["npm", "start", "--", "--userDir", "/data"]
