#!/bin/sh

VERSIONS_FILE=Dockerfile.versions
TEMPFILE=$(mktemp /tmp/Dockerfile_upgrade.XXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }

save_changes() {
   git add ${VERSIONS_FILE}
   git commit -m "Updated Versions File"
   git push
}

######################################################

echo "TODAY=`date '+%Y-%m-%d'`" > ${TEMPFILE}
echo 'THINGS=stuff' >> ${TEMPFILE}
echo 'FIELDS="values work too!"' >> ${TEMPFILE}
echo 'FROM_IMAGE_SHA=ubuntu:latest' >> ${TEMPFILE}
echo 'TERRAFORM_IMAGE_SHA=hashicorp/terraform:light' >> ${TEMPFILE}

########################################################

diff -q ${TEMPFILE} ${VERSIONS_FILE} > /dev/null
if [ "$?" -ne 0 ]; then
  echo Versions File has changed.. comitting...
  mv ${TEMPFILE} ${VERSIONS_FILE}
  save_changes
else

fi

# If the tempfile still exists, remove it
[ -e ${TEMPFILE} ] && rm ${TEMPFILE}

