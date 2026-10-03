FROM node:20-alpine
ARG XRAY_VERSION=latest
WORKDIR /app
RUN apk add --no-cache ca-certificates curl unzip nginx
COPY package*.json ./
RUN npm install --omit=dev
COPY server.js ./
COPY public ./public
RUN mkdir -p /app/data /run/nginx
RUN if [ "$XRAY_VERSION" = "latest" ]; then \
      curl -fsSL -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip; \
    else \
      curl -fsSL -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip; \
    fi && unzip -o /tmp/xray.zip xray -d /usr/local/bin && chmod +x /usr/local/bin/xray && rm /tmp/xray.zip
ENV NODE_ENV=production
ENV PORT=1323
ENV GATEWAY_PORT=1400
ENV XRAY_DEFAULT_PORT=15001
ENV XRAY_INTERNAL_BASE=20000
ENV XRAY_BIN=/usr/local/bin/xray
ENV NGINX_BIN=/usr/sbin/nginx
ENV XRAY_AUTOSTART=true
EXPOSE 1323 1400
CMD ["node","server.js"]
