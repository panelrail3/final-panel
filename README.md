# Railway Xray Panel v6

Operational Railway panel with:
- Login (default admin/admin)
- Config Generator: VLESS, VMess, Trojan, Shadowsocks
- Transports: WebSocket, XHTTP, HTTPUpgrade, gRPC, RAW/TCP, HTTP
- Security: None, TLS, REALITY
- Config Manager, QR, URI, subscriptions, import/export
- Inbound Builder with multiple clients
- Real Xray Core supervisor with config test before start
- Nginx HTTP gateway on port 1400
- Path routing for multiple HTTP-based Xray inbounds on one public port (e.g. 443)
- Railway-provided variables are detected automatically; no mandatory Railway variable values are hard-coded by the user
- Persistent data path: `/app/data` (attach a Railway Volume there)

## Railway variables

No required manual variable is needed for a normal deployment. The application automatically uses Railway-provided variables such as:
- `RAILWAY_PUBLIC_DOMAIN`
- `RAILWAY_TCP_PROXY_DOMAIN`
- `RAILWAY_TCP_PROXY_PORT`
- `RAILWAY_TCP_APPLICATION_PORT`

Optional overrides:

```text
PORT=1323
GATEWAY_PORT=1400
XRAY_AUTOSTART=true
XRAY_INTERNAL_BASE=20000
XRAY_DEFAULT_PORT=15001
PANEL_PASSWORD=   # optional; if you prefer environment bootstrap logic in your own deployment
```

The panel defaults to `admin / admin`. Change it from Settings immediately after first login.

## Railway networking

- Panel HTTP service listens on `1323`.
- Nginx gateway listens on `1400`.
- Create the panel Public Domain targeting `1323`.
- Create/use the HTTP gateway endpoint targeting `1400` when your Railway setup supports a domain target for that port.
- For raw non-HTTP traffic, Railway TCP Proxy is required. Railway documents one TCP Proxy per service instance, so the UI does not falsely claim that arbitrary numbers of independent public raw TCP ports can all be exposed from one Railway service.

## Gateway model

Example:

```text
Public HTTPS :443
      |
      v
Railway edge
      |
      v
Nginx :1400
  |       |       |
 /v1     /v2     /grpc
  |       |       |
Xray    Xray     Xray
:20000  :20001   :20002
```

For gateway-routed transports, Xray listens internally on unique ports. Nginx selects the Xray listener by Path. This permits multiple WebSocket/XHTTP/HTTPUpgrade/gRPC inbounds to share a public HTTP/HTTPS port.

TLS/REALITY on the internal gateway listener is intentionally rejected. For this mode TLS is terminated by the public HTTP edge/Nginx layer. REALITY is not path-routable and must use a dedicated raw listener.

## Recommended ports shown by the UI

`80, 443, 2052, 2053, 2082, 2083, 2095, 2096, 8080-8090, 8443`

These are configuration choices/advertised ports. Railway public exposure still depends on Railway's networking capabilities.

## Volume

Create a Railway Volume and mount it at:

```text
/app/data
```

Do not add Docker `VOLUME`; Railway manages the persistent volume.
