#!/bin/sh

VERSIONS_FILE=Dockerfile.versions

echo "TODAY=`date -I`" > ${VERSIONS_FILE}
echo 'THINGS=stuff' >> ${VERSIONS_FILE}
echo 'FIELDS="values work too!"' >> ${VERSIONS_FILE}
echo 'FROM_IMAGE_SHA=ubuntu:latest' >> ${VERSIONS_FILE}
echo 'TERRAFORM_IMAGE_SHA=hashicorp/terraform:light' >> ${VERSIONS_FILE}

