SHELL := /bin/bash
DC_DOCKER_FILE=docker-compose.yml
DC_SCALINGO_FILE=docker-compose-scalingo.yml

# Build simple docker 11ty/eleventy stack
all: up
build: config
	docker-compose -f $(DC_DOCKER_FILE) build --progress plain --no-cache
config:
	docker-compose -f $(DC_DOCKER_FILE) config
up: config
	docker-compose -f $(DC_DOCKER_FILE) up -d
down:
	docker-compose -f $(DC_DOCKER_FILE) down

# Build simple scalingo 11ty/eleventy+nginx stack
scalingo-dev: scalingo-down scalingo-build scalingo-up
scalingo-build: scalingo-config
	docker-compose -f $(DC_SCALINGO_FILE) build --progress plain --no-cache
scalingo-config:
	docker-compose -f $(DC_SCALINGO_FILE) config
scalingo-up: scalingo-config
	docker-compose -f $(DC_SCALINGO_FILE) up -d
scalingo-down:
	docker-compose -f $(DC_SCALINGO_FILE) down

GIT_BRANCH=main
DIST_ARCHIVE := buildapp-$(GIT_BRANCH).tar.gz
SITE_ARCHIVE := site-$(GIT_BRANCH).tar.gz
site-archive:
	docker-compose -f $(DC_DOCKER_FILE) run --rm -T  site /bin/bash -c 'tar zcvf - _site' > $(SITE_ARCHIVE)

# build tar.gz
buildpack-archive:
	( git archive --prefix=main/  --format tar.gz main ) > $(DIST_ARCHIVE)

# Deploy archive on scalingo
scalingo-deploy-archive: buildpack-archive
	if [ -z "${SCALINGO_REGION}" -o -z "${SCALINGO_APP}" ] ;then echo "SCALINGO_REGION or SCALINGO_APP not set" ;  exit 1 ; fi
	scalingo whoami
	scalingo --region ${SCALINGO_REGION} --app ${SCALINGO_APP} deploy $(DIST_ARCHIVE)

# update package-lock.json
update-package-lock:
	docker-compose -f $(DC_DOCKER_FILE) run --entrypoint /bin/bash --rm -it site -c "npm install @11ty/eleventy --save-dev"

# clean all
clean-all: down clean-dir clean-archive
clean-archive:
	rm -rf buildapp-*.tar.gz
clean-dir:
	rm -rf _site
