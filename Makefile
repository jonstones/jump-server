# When editing, use "set noexpandtab"
# run with : make all
# extras : make ebrdproxy login - to enable ebrdproxy, and also login if remote

# Makefile to control the build of the Dockerfile$

NAME   := acmecorp/foo
TAG    := $$(git log -1 --pretty=%!H(MISSING))
IMG    := ${NAME}:${TAG}
CURRENT := ${NAME}:current

# Dont run if no params
show_info:
	echo Please run with upgrade, Dockerfile, 

## Upgrade Versions
upgrade:
	sh Dockerfile.upgrade.sh
    
## Build docker file from template
Dockerfile: Dockerfile.versions Dockerfile.template
	sh Dockerfile.generate.sh
	# TODO: exit with no error if no change
	
build:
	docker build --pull -t "$CI_REGISTRY_IMAGE:${CI_COMMIT_SHORT_SHA}" .
	docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG"
	
deploy:
	docker build --pull -t "$CI_REGISTRY_IMAGE:${TODAY}" .
	docker push "$CI_REGISTRY_IMAGE:${TODAY}"
	docker tag "${CI_REGISTRY_IMAGE}:${TODAY}" "${CI_REGISTRY_IMAGE}"
	docker push "${CI_REGISTRY_IMAGE}"

# --- Extras ---

login:
	docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY

ebrdproxy:
	@echo EBRD Proxy Set.
	@export http_proxy="http://ldn3log1.ebrd.com:8888"
	@export https_proxy="http://ldn3log1.ebrd.com:8888"
	@export no_proxy="ldn1cvs2.ebrd.com,localhost,docker,docker:2375"
	
