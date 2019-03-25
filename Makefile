# When editing, use "set noexpandtab"


# Makefile to control the build of the Dockerfile

# NAME   := jonstones/jump-server
NAME	:= ${CI_PROJECT_PATH}
GITSHA    := $$(git rev-parse --short HEAD)
CURRENT := ${NAME}:current

DOCKER_USER=${CI_REGISTRY_USER:-DEFAULT_USER}
DOCKER_PASS=${CI_REGISTRY_PASSWORD:-DEFAULT_PASS}
DOCKER_REG=${CI_REGISTRY:-DEFAULT_REG}

GIT_COMMIT_PATH=git@gitlab.com:${CI_PROJECT_PATH}.git
GIT_COMMIT_PEM=

# Dont run if no params
show_info:
	echo Please run with upgrade, Dockerfile,
	exit 1

## Upgrade Versions
upgrade:
	sh scripts/Dockerfile.upgrade.sh
    
## Build docker file from template
Dockerfile: Dockerfile.versions Dockerfile.template
	sh scripts/Dockerfile.generate.sh
	# TODO: exit with no error if no change
	# ToDo. do i bother checking-in the Dockerfile?
	
build:
	docker build --pull -t "${NAME}:${SHA}" .
	docker push "${NAME}:${GITSHA}"
	docker tag "${NAME}:${GITSHA}" "${CI_COMMIT_REF_SLUG}"
	docker push "${NAME}:${CI_COMMIT_REF_SLUG}"
	
deploy:
	docker tag "${NAME}:${SHA}" "${CURRENT}"
	docker push "${CURRENT}"

# --- Extras ---

login:
	docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}" ${DOCKER_REG}

ebrdproxy:
	@echo EBRD Proxy Set.
	@export http_proxy="http://ldn3log1.ebrd.com:8888"
	@export https_proxy="http://ldn3log1.ebrd.com:8888"
	@export no_proxy="ldn1cvs2.ebrd.com,localhost,docker,docker:2375"
	
