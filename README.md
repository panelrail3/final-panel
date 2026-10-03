# Railway Xray Panel v3

A self-contained Railway panel for generating, storing, importing/exporting and running Xray configurations.

## Features
- VLESS / VMess / Trojan / Shadowsocks
- RAW/TCP, WebSocket, XHTTP, HTTPUpgrade, gRPC, HTTP
- None / TLS / REALITY
- Config Manager: create, edit, delete, copy URI, QR, per-config subscription
- `/sub/all` subscription for all saved configs
- Import/export JSON
- Inbound Builder with multiple clients per inbound
- Port conflict validation before Xray start
- Xray Core inside the same container
- Runtime JSON preview and Start/Stop/Restart
- Optional panel password
- Persistent data under `/app/data`

## Railway deployment

The web panel listens on the Railway-provided `PORT` (default 3000). **For the panel's Railway Public Networking domain, target the panel port 3000 only when `PORT` is not injected/overridden; normally Railway detects `$PORT` automatically.** Do not create the panel domain against an Xray inbound port such as 443.

Railway public HTTP/HTTPS domains are HTTP/HTTPS entry points. For non-HTTP Xray transports (RAW TCP, TCP+TLS, REALITY, etc.), use Railway TCP Proxy and use the proxy's generated external port; Railway does not make the public TCP port equal to your internal Xray port.

For WebSocket/XHTTP behind a Railway HTTP domain, the clean architecture is to terminate Railway HTTPS at the edge and reverse-proxy the WebSocket/HTTP traffic to an internal Xray listener. This release keeps the panel and Xray listener separate and does not pretend that an HTTP domain is a generic TCP forwarder.

### Recommended environment variables
- `PANEL_PASSWORD=change-this` — protect management API
- `XRAY_AUTOSTART=true` — start Xray after the panel starts
- `XRAY_BIN=/usr/local/bin/xray`
- `PUBLIC_BASE_URL=https://your-domain`

### Persistent volume
Create a Railway Volume mounted at `/app/data` so saved configs and runtime data survive redeploys.

### Port model
An Xray `listen + port` is a single socket. The panel rejects duplicate listeners on the same address/port. If you need many users/configs on port 443, create **one inbound on 443 with multiple clients**. If you need different protocols/transports that cannot share one listener, use different ports or a deliberate Xray routing/fallback architecture.

## Security
Never expose the management panel without `PANEL_PASSWORD` on an Internet-facing deployment. The subscription endpoints are intentionally public so client apps can fetch them; do not put sensitive management information in subscription names.


## Port model

- Panel HTTP listens on `0.0.0.0:1323` by default (`PORT=1323`).
- The Xray Core does not have one global port: every inbound owns its own `listen` + `port`.
- The panel accepts any valid TCP port from 1 to 65535 and does not impose a count limit.
- `XRAY_DEFAULT_PORT=1400` is only the default used when an inbound port is omitted; it is not a restriction.
- Multiple clients can share one inbound/port. Two separate listeners cannot bind the same effective `listen:port`. The panel validates this before saving/starting Xray.
- On Railway, exposing a non-HTTP Xray port publicly requires a TCP Proxy for that internal port. Railway generates the external proxy port; it does not make the public port equal to the internal port.


## Railway Volume

This project intentionally does not use Dockerfile `VOLUME`, because Railway does not support the Dockerfile VOLUME instruction during builds. The project expects a Railway Volume mounted at `/app/data`; the included `railway.toml` declares that mount. If your Railway UI does not create the mount automatically, add a Volume manually and set its mount path to `/app/data`.

## Ports

The panel listens on `1323` and the default Xray inbound port is `1400`. Xray can create additional inbound listeners on other valid ports, subject to Railway networking/TCP proxy requirements for public access.
