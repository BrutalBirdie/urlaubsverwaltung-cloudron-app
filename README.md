# urlaubsverwaltung-cloudron-app

Cloudron packaging for [Urlaubsverwaltung](https://github.com/urlaubsverwaltung/urlaubsverwaltung).

The runtime image pulls the prebuilt fat jar directly from upstream
GitHub releases. This repository contains only the packaging metadata
and the runtime glue (manifest, Dockerfile, start script, description,
changelog).

## Build

```sh
cloudron build
```

To override the upstream version being packaged:

```sh
cloudron build --build-arg URLAUBSVERWALTUNG_VERSION=<version>
```

## Layout

- `CloudronManifest.json` — Cloudron app manifest
- `Dockerfile` — downloads the Urlaubsverwaltung fat jar for
  `${URLAUBSVERWALTUNG_VERSION}` from GitHub releases and assembles the runtime image
  on top of `cloudron/base`
- `start.sh` — entrypoint wiring Cloudron addon env vars
  (postgres, sendmail, oidc) into Spring Boot properties
- `CHANGELOG` — Cloudron app changelog
- `DESCRIPTION.md` — Cloudron app store description
