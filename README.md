# urlaubsverwaltung-cloudron-app

Cloudron packaging for [Urlaubsverwaltung](https://github.com/urlaubsverwaltung/urlaubsverwaltung).

The application source is built from the slint-ui fork at
[github.com/slint-ui/urlaubsverwaltung](https://github.com/slint-ui/urlaubsverwaltung).
This repository contains only the packaging metadata and the runtime
glue (manifest, Dockerfile, start script, description, changelog).

## Build

```sh
cloudron build
```

To override the upstream ref being built (default is a pinned commit on
slint-ui/main):

```sh
cloudron build --build-arg UV_REF=<commit-sha-or-branch-or-tag>
```

## Layout

- `CloudronManifest.json` — Cloudron app manifest
- `Dockerfile` — fetches Urlaubsverwaltung sources from the slint-ui
  fork at `${UV_REF}`, builds the fat jar, then assembles the runtime
  image on top of `cloudron/base`
- `cloudron/start.sh` — entrypoint wiring Cloudron addon env vars
  (postgres, sendmail, oidc) into Spring Boot properties
- `cloudron/CHANGELOG` — Cloudron app changelog
- `cloudron/DESCRIPTION.md` — Cloudron app store description
