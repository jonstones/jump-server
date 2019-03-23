# run with : make build push
# 

# Makefile to control the build of the Dockerfile

NAME   := acmecorp/foo
TAG    := $$(git log -1 --pretty=%!H(MISSING))
IMG    := ${NAME}:${TAG}
CURRENT := ${NAME}:current

## Phases

#
## Upgrade Versions
upgrade:
  # fetch all the versions into a version file

## Build docker file from template
build_dockerfile_template:
  # combine version file & template into a dockerfile, and commit.. if changed.

build:
  @docker build -t ${IMG} .
  @docker tag ${IMG} ${CURRENT}

push:
  @docker push ${NAME}

login:
  @docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
  