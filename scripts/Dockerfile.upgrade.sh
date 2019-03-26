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

getPackageVersionByDockerImage() {
   local IMG=$1
   local PKG=$2

   VERSION=$(docker run --rm ${IMG} "/bin/bash" "-c" "apt-get update >/dev/null && apt-cache show ${PKG}" | grep 'Version: ' | cut -d ' ' -f 2 )

   echo ${VERSION}
   return 0
}

getLSBRelease() {
   local IMG=$1

   echo $(docker run --rm ${IMG} "/bin/bash" "-c" "cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d '=' -f 2" )
}

FROM_IMAGE_SHA=ubuntu@$(getSHA ubuntu:latest)
TERRAFORM_IMG_SHA=hashicorp/terraform@$(getSHA hashicorp/terraform:light)

GOOGLECLI_VERSION=$(curl https://packages.cloud.google.com/apt/dists/cloud-sdk-$(getLSBRelease ${FROM_IMAGE_SHA})/main/binary-amd64/Packages 2>/dev/null | head -n 14 | grep 'Version: ' | cut -d ' ' -f 2 )

AZURECLI_VERSION=$(curl https://packages.microsoft.com/repos/azure-cli/dists/$(getLSBRelease ${FROM_IMAGE_SHA})/main/binary-amd64/Packages 2>/dev/null | head -n 14 | grep 'Version: ' | cut -d ' ' -f 2 )

AWSCLI_VERSION=$(getPackageVersionByDockerImage ${FROM_IMAGE_SHA} awscli)

echo "TODAY=`date '+%Y%m%d'`" > ${TEMPFILE}
echo "FROM_IMAGE_SHA=${FROM_IMAGE_SHA}" >> ${TEMPFILE}
echo "AWSCLI_VERSION=${AWSCLI_VERSION}" >> ${TEMPFILE}
echo "AZURECLI_VERSION=${AZURECLI_VERSION}" >> ${TEMPFILE}
echo "GOOGLECLI_VERSION=${GOOGLECLI_VERSION}" >> ${TEMPFILE}
echo "TERRAFORM_IMAGE_SHA=${TERRAFORM_IMG_SHA}" >> ${TEMPFILE}

########################################################

diff -q ${TEMPFILE} ${VERSIONS_FILE} > /dev/null
if [ "$?" -ne 0 ]; then
  echo Versions File has changed.. comitting...
  # SHow Whats Changed
  diff -u ${VERSIONS_FILE} ${TEMPFILE}

  mv ${TEMPFILE} ${VERSIONS_FILE}
  #save_changes
else
  echo Versionsfile - no change!
fi

# If the tempfile still exists, remove it
[ -e ${TEMPFILE} ] && rm ${TEMPFILE}

exit 0

