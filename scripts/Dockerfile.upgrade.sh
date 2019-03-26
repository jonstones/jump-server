#!/bin/sh

VERSIONS_FILE=Dockerfile.versions
TEMPFILE=$(mktemp /tmp/Dockerfile_upgrade.XXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }

save_changes() {
   git checkout master
   git add ${VERSIONS_FILE}
   git commit -m "Updated Versions File"
   git push
}

######################################################

getSHA() {
  local IMG=$1
  local SHA=$(docker pull ${IMG} | grep 'Digest: ' | cut -d ' ' -f 2)
  echo ${SHA}
  return 0
}

FROM_IMAGE_SHA=ubuntu@$(getSHA ubuntu:latest)
TERRAFORM_IMG_SHA=hashicorp/terraform@$(getSHA hashicorp/terraform:light)

echo "export TODAY=`date '+%Y-%m-%d'`" > ${TEMPFILE}
echo "export FROM_IMAGE_SHA=${FROM_IMAGE_SHA}" >> ${TEMPFILE}
echo "export TERRAFORM_IMAGE_SHA=${TERRAFORM_IMG_SHA}" >> ${TEMPFILE}

########################################################

diff -q ${TEMPFILE} ${VERSIONS_FILE} > /dev/null
if [ "$?" -ne 0 ]; then
  echo Versions File has changed.. comitting...
  mv ${TEMPFILE} ${VERSIONS_FILE}
  save_changes
else
  echo Versionsfile - no change!
fi

# If the tempfile still exists, remove it
[ -e ${TEMPFILE} ] && rm ${TEMPFILE}

exit 0

