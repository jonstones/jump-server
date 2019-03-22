# run with : make build push
# 

# Makefile to control the build of the Dockerfile

NAME   := acmecorp/foo
TAG    := $$(git log -1 --pretty=%!H(MISSING))
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

build:
  @docker build -t ${IMG} .
  @docker tag ${IMG} ${LATEST}

push:
  @docker push ${NAME}

login:
  @docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
  