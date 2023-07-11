# 11ty-scalingo
sample 11ty/eleventy scalingo app

This repo contains:
- a sample site based on 11ty/eleventy and markdown pages
- use nodejs buildpack
- use nginx buildpack (to expose static content)

- different deployment stack available: docker or scalingo PaaS

3 deployment mode available:
- Native Scalingo deployment: 11ty/eleventy build static pages and nginx expose static content
- A Docker stack for local dev purpose: launch 11ty/eleventy on port 3000 (http://localhost:3000)
- A Scalingo stack for dev purpose: 11ty/eleventy build static site and nginx expose static content on (http://localhost:3000)

Links:
- https://www.11ty.dev/
- https://scalingo.com

## Files:

Minimum files for scalingo
- `src` directory contains the web site (for the demo, a simple markdown file)
- `package.json` : npm build/start command, dependencies, override with scalingo-postbuild target
- `Procfile`: scalingo procfile , start nginx
- `.buildpacks`: scalingo buildpack : nodejs and nginx
- `nginx.conf`: nginx conf used by nginx-buildpack to host static file
- `.slugignore`: cleaning files before packaging

Addons file for local dev purpose
- `Makefile`: quick start commands
- `docker/Dockerfile` and `docker-compose.yml`: local docker stack
- `docker/scalingo.Dockerfile` and `docker-compose-scalingo.yml`: local scalingo docker stack for dev purpose and mimic scalingo steps (build/run)

## Deploy on scalingo

- Create an app in the scalingo dashboard
- Add environment variables: 
```bash
BUILDPACK_URL=https://github.com/Scalingo/multi-buildpack.git
```
- Add remote git repo (or use git scalingo server)
- Commit
- Wait for build
- Then connect to your app and see logs

#### Deploy on scalingo with cli and push archive

```bash
# Set variables
SCALINGO_API_URL=
SCALINGO_TOKEN=
SCALINGO_REGION=
SCALINGO_APP=
```

```bash
# login
scalingo login --api-token $SCALINGO_TOKEN
```

```bash
# set once
scalingo --region ${SCALINGO_REGION} --app  ${SCALINGO_APP} env-set BUILDPACK_URL=https://github.com/Scalingo/multi-buildpack.git
# build tar.gz archive
make buildpack-archive
# deploy
make scalingo-deploy-archive
# scalingo --region ${SCALINGO_REGION} --app  ${SCALINGO_APP} deploy buildapp-main.tar.gz
```

## Build Dev mode : Build/deploy on localhost

Prereq:
- docker installed (for dev mode)

### Build the docker stack

```bash
make build
make up
# curl http://localhost:3000
make down
```

### Build the local docker scalingo stack (dev purpose)

```bash
make scalingo-build
make scalingo-up
# curl http://localhost:3000
make scalingo-down
```
