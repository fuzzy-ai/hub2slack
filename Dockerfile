FROM mhart/alpine-node:latest

WORKDIR /opt/hub2slack
ADD . .

EXPOSE 80
EXPOSE 443
CMD ["npm", "start"]
