# When editing, use "set noexpandtab", because YAML likes spaces, but Makefiles like tabs! *sigh*
# vi: set noexpandtab :
 
# Makefile to control the build of the Dockerfile

CI_REGISTRY	:= registry.gitlab.com
CI_PROJECT_PATH := js-devops/sysadmin/jump-server
DOCKER_IMAGE	:= ${CI_REGISTRY}/${CI_PROJECT_PATH}
GITSHA	:= $(shell git rev-parse --short HEAD)
STABLE	:= ${DOCKER_IMAGE}:stable

# Dont run if no params
show_info:
	@echo Please run with upgrade, Dockerfile, build, deploy - extras login, ebrdproxy
	@exit 1

## Upgrade Versions File
upgrade:
	@echo Upgrading Docker Versions File...
	@sh scripts/Dockerfile.upgrade.sh
	#@cat Dockerfile.versions
    
## Build Dockerfile from template
# Git does not track timestamps, so we cannot do dependency checking on Dockerfile.versions Dockerfile.template
generate_dockerfile: 
	@echo Generating DockerFile from any updated Versions...
	@sh scripts/Dockerfile.generate.sh

# TODAY is taken from the versions file, so it is locked to the current git commit	
# Fetch label: docker inspect app --format "{{ .Config.Labels }}"
# 'git checkout <commit_sha> && make build' should recreate the old image
build:
	docker build --pull --label "jump_server.git.hash=${GITSHA}" -t "${DOCKER_IMAGE}:${GITSHA}" .
	docker push "${DOCKER_IMAGE}:${GITSHA}"

deploy:
	docker pull "${DOCKER_IMAGE}:${GITSHA}"
	docker tag "${DOCKER_IMAGE}:${GITSHA}" "${DOCKER_IMAGE}:${TODAY}"
	docker push "${DOCKER_IMAGE}:${TODAY}"

stable:
	docker pull "${DOCKER_IMAGE}:${GITSHA}"
	docker tag "${DOCKER_IMAGE}:${GITSHA}" "${STABLE}"
	docker push "${STABLE}"

# --- Extras ---

login:
	docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY

ebrdproxy:
	@echo EBRD Proxy Set.
	@export http_proxy="http://ldn3log1.ebrd.com:8888"
	@export https_proxy="http://ldn3log1.ebrd.com:8888"
	@export no_proxy="ldn1cvs2.ebrd.com,localhost,docker,docker:2375"
