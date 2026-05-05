---
name: reverse-proxy-guidelines
description: >-
  Guides sub-path deployment of a web app (frontend + backend API) behind a reverse proxy
  (Caddy, Nginx, Traefik). Use when serving an app under a prefix like /my-app instead of
  the root /. Covers ROOT_PATH for FastAPI/Express, base path for Vite/CRA/Next, proxy
  strip-prefix config, and common gotchas.
---

# Reverse Proxy — Sub-path Deployment Guidelines

Use this when an app needs to be served under a **sub-path** (e.g. `/my-app`) rather than the root (`/`). Common in labs where multiple apps share one domain.

---

## How it works

```
Browser → https://host/my-app/...
         ↓ reverse proxy strips /my-app
Backend ← /...   (never sees the prefix)
```

Two things must know about the prefix:

| Layer | Why it needs the prefix |
|---|---|
| **Frontend build** | Asset URLs (`/my-app/assets/...`), router base, `<link href=...>` |
| **Backend** | OpenAPI/Swagger docs URL, redirect responses, `Request.base_url` |

The proxy itself just strips the prefix and forwards — no app code involved there.

---

## Config variables

Keep both driven from a single env var (e.g. `ROOT_PATH`) so one `.env` change covers both:

```bash
# .env
ROOT_PATH=/my-app
```

**Backend (FastAPI):**
```python
# config.py
ROOT_PATH = os.environ.get("ROOT_PATH", "")

# main.py
app = FastAPI(root_path=ROOT_PATH)
```

**Frontend (Vite):**
```js
// vite.config.js
base: process.env.VITE_BASE_PATH ?? '/'
```

```makefile
# Makefile — pass ROOT_PATH into the frontend build
build-frontend:
    VITE_BASE_PATH=${ROOT_PATH:-/} npm run build
```

Other frameworks:
- **Create React App**: `homepage` in `package.json` or `PUBLIC_URL` env var
- **Next.js**: `basePath` in `next.config.js`
- **Express**: mount router at the sub-path or use `app.set('trust proxy', 1)`

---

## Proxy config

### Caddy

```caddy
your.server {
    handle /my-app/* {
        uri strip_prefix /my-app
        reverse_proxy localhost:8000
    }
}
```

### Nginx

```nginx
location /my-app/ {
    proxy_pass http://localhost:8000/;   # trailing slash strips the prefix
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote-addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Traefik (Docker label)

```yaml
labels:
  - "traefik.http.routers.myapp.rule=PathPrefix(`/my-app`)"
  - "traefik.http.middlewares.myapp-strip.stripprefix.prefixes=/my-app"
  - "traefik.http.routers.myapp.middlewares=myapp-strip"
```

---

## Implementation checklist

- [ ] Single source of truth — one env var (`ROOT_PATH`) drives both backend and frontend build.
- [ ] Backend `root_path` set — FastAPI/Express knows its external prefix (fixes docs + redirects).
- [ ] Frontend built with correct base path — asset URLs and router base include the prefix.
- [ ] Proxy strips the prefix before forwarding — backend receives requests at `/`, not `/my-app/`.
- [ ] `make prod-up` (or equivalent) passes the env var into the frontend build step.
- [ ] Dev mode still works at `/` — `ROOT_PATH` defaults to empty/`/` when not set.
- [ ] API clients / scripts that call the backend directly (bypassing the proxy) use the bare backend URL — they don't need the prefix.

---

## Anti-patterns

- **Hardcoding the sub-path in app code** — it will break when the path changes; always use an env var.
- **Forgetting to rebuild the frontend** after changing `ROOT_PATH` — the base path is baked in at build time, not runtime.
- **Proxy forwarding without stripping the prefix** — backend receives `/my-app/api/...` and 404s on every route.
- **Setting `ROOT_PATH` in dev** — unless your local setup also has a reverse proxy, leave it empty; the dev server runs at root.
- **Separate env vars for backend and frontend** — keep them in sync via one variable; drift causes subtle 404s on assets or API calls.

---

*Skill scope: sub-path reverse proxy deployment. For SSL termination, load balancing, or multi-service routing, compose separately.*
