# When editing, use "set noexpandtab"
# vi: set noexpandtab :
 
# Makefile to control the build of the Dockerfile

# NAME	:= jonstones/jump-server
NAME	:= ${CI_PROJECT_PATH}
GITSHA	:= $$(git rev-parse --short HEAD)
STABLE	:= ${NAME}:stable
BRANCH	:= ${CI_COMMIT_REF_SLUG}

# Dont run if no params
show_info:
	echo Please run with upgrade, Dockerfile,
	exit 1

## Upgrade Versions File
upgrade:
	@echo Upgrading Docker Versions File...
	@sh scripts/Dockerfile.upgrade.sh
    
## Build ~ockerfile from template
Dockerfile: Dockerfile.versions Dockerfile.template
	@echo Generating DockerFile from any updated Versions...
	@sh scripts/Dockerfile.generate.sh
	
build:
	docker build --pull -t "${NAME}:${GITSHA}" .
	docker push "${NAME}:${GITSHA}"
	docker tag "${NAME}:${GITSHA}" "${NAME}:${BRANCH}"
	docker push "${NAME}:${BRANCH}"
	
deploy:
	docker pull "${NAME}:${GITSHA}"
	docker tag "${NAME}:${GITSHA}" "${STABLE}"
	docker push "${STABLE}"

# --- Extras ---

login:
	docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY

ebrdproxy:
	@echo EBRD Proxy Set.
	@export http_proxy="http://ldn3log1.ebrd.com:8888"
	@export https_proxy="http://ldn3log1.ebrd.com:8888"
	@export no_proxy="ldn1cvs2.ebrd.com,localhost,docker,docker:2375"

