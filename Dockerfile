FROM nodered/node-red:1.0.1-12-arm32v6

RUN npm install node-red-node-serialport

ENTRYPOINT ["npm", "start", "--", "--userDir", "/data"]
