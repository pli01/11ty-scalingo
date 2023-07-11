FROM node:18

WORKDIR /app

COPY package*.json .
COPY ./src ./src
COPY docker/entrypoint.sh /entrypoint.sh

RUN npm ci ; \
    npm run build ; \
    find src _site

EXPOSE 3000

CMD ["/entrypoint.sh"]
