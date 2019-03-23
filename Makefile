# When editing, use "set noexpandtab"
# run with : make all
# extras : make ebrdproxy login - to enable ebrdproxy, and also login if remote

# Makefile to control the build of the Dockerfile$

NAME   := jonstones/jump-server
SHA    := $$(git rev-parse --short HEAD)
CURRENT := ${NAME}:current

DOCKER_USER=${CI_REGISTRY_USER:-DEFAULT_USER}
DOCKER_PASS=${CI_REGISTRY_PASSWORD:-DEFAULT_PASS}
DOCKER_REG=${CI_REGISTRY:-DEFAULT_REG}

# Dont run if no params
show_info:
	echo Please run with upgrade, Dockerfile, 

## Upgrade Versions
upgrade:
	sh scripts/Dockerfile.upgrade.sh
    
## Build docker file from template
Dockerfile: Dockerfile.versions Dockerfile.template
	sh scripts/Dockerfile.generate.sh
	# TODO: exit with no error if no change
	
build:
	docker build --pull -t "${NAME}:${SHA}" .
	docker push "${NAME}:${SHA}"
	docker tag "${NAME}:${SHA}" "${CI_COMMIT_REF_SLUG}"
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
	
