# When editing, use "set noexpandtab"
# run with : make all
# extras : make ebrdproxy login - to enable ebrdproxy, and also login if remote

# Makefile to control the build of the Dockerfile$

NAME   := acmecorp/foo
TAG    := $$(git log -1 --pretty=%!H(MISSING))
IMG    := ${NAME}:${TAG}
CURRENT := ${NAME}:current

#all: upgrade Dockerfile build push
all: Dockerfile

## Upgrade Versions
upgrade:
	# fetch all the versions into a version file

## Build docker file from template
Dockerfile: Dockerfile.versions Dockerfile.template
	sh Dockerfile.generate.sh
	# TODO: exit with no error if no change
	# TODO: combine version file & template into a dockerfile, and commit.. if changed.

build:
	docker build -t ${IMG} .
	docker tag ${IMG} ${CURRENT}

push:
	docker push ${NAME}

# --- Extras ---

login:
	docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}

ebrdproxy:
	@echo EBRD Proxy Set.
	@export http_proxy="http://ldn3log1.ebrd.com:8888"
	@export https_proxy="http://ldn3log1.ebrd.com:8888"
	@export no_proxy="ldn1cvs2.ebrd.com,localhost,docker,docker:2375"


--
update-prod:
  stage: build
  script:
    - export TODAY=`date -I`
    - docker build --pull -t "$CI_REGISTRY_IMAGE:${TODAY}" .
    - docker push "$CI_REGISTRY_IMAGE:${TODAY}"
    - docker tag "${CI_REGISTRY_IMAGE}:${TODAY}" "${CI_REGISTRY_IMAGE}"
    - docker push "${CI_REGISTRY_IMAGE}"
  only:
    - master

test-build:
  stage: build
  script:
    - docker build --pull -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG" .
    - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG"
  except:
    - master

