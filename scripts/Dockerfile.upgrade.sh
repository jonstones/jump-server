#!/bin/sh

VERSIONS_FILE=Dockerfile.versions
TODAY_FILE=Dockerfile.today
TEMPFILE=$(mktemp /tmp/Dockerfile_upgrade.XXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }

save_changes() {
   git checkout master
   git add ${VERSIONS_FILE} ${TODAY_FILE}
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
   return 0
}

testDockerSock() {
   docker ps > /dev/null
   if [ "$?" -ne 0 ]; then
      echo Error: No Access to docker.sock. exiting...
      exit 2
   fi
   return 0
}


testDockerSock

FROM_IMAGE_SHA=ubuntu@$(getSHA ubuntu:latest)
TERRAFORM_IMG_SHA=hashicorp/terraform@$(getSHA hashicorp/terraform:light)

LSBRelease=$(getLSBRelease ${FROM_IMAGE_SHA})

GOOGLECLI_VERSION=$(curl "https://packages.cloud.google.com/apt/dists/cloud-sdk-${LSBRelease}/main/binary-amd64/Packages" | grep -A 10 -e '^Package: google-cloud-sdk$' | grep 'Version: ' | sort -n | tail -n 1 | cut -d ' ' -f 2 )

KUBECTL_VERSION=$(curl "https://packages.cloud.google.com/apt/dists/cloud-sdk-${LSBRelease}/main/binary-amd64/Packages" | grep -A 10 -e '^Package: kubectl$' | grep 'Version: ' | sort -n | tail -n 1 | cut -d ' ' -f 2 )

AZURECLI_VERSION=$(curl "https://packages.microsoft.com/repos/azure-cli/dists/${LSBRelease}/main/binary-amd64/Packages" | grep -A 10 -e '^Package: azure-cli$' | grep 'Version: ' | sort -n | tail -n 1 | cut -d ' ' -f 2 )

AWSCLI_VERSION=$(getPackageVersionByDockerImage ${FROM_IMAGE_SHA} awscli)

echo "TODAY=`date '+%Y%m%d'`" > ${TODAY_FILE}
echo "FROM_IMAGE_SHA=${FROM_IMAGE_SHA}" >> ${TEMPFILE}
echo "AWSCLI_VERSION=${AWSCLI_VERSION}" >> ${TEMPFILE}
echo "AZURECLI_VERSION=${AZURECLI_VERSION}" >> ${TEMPFILE}
echo "GOOGLECLI_VERSION=${GOOGLECLI_VERSION}" >> ${TEMPFILE}
echo "KUBECTL_VERSION=${KUBECTL_VERSION}" >> ${TEMPFILE}
echo "TERRAFORM_IMAGE_SHA=${TERRAFORM_IMG_SHA}" >> ${TEMPFILE}

########################################################

diff -q ${TEMPFILE} ${VERSIONS_FILE} > /dev/null
if [ "$?" -ne 0 ]; then
  # Show Whats Changed
  echo
  echo Versions File has changed.. committing...
  diff -u ${VERSIONS_FILE} ${TEMPFILE}
  echo
  
  mv ${TEMPFILE} ${VERSIONS_FILE}
  save_changes
else
  echo
  echo Versionsfile - no change!
  cat ${VERSIONS_FILE}
  echo
fi

# If the tempfile still exists, remove it
[ -e ${TEMPFILE} ] && rm ${TEMPFILE}

exit 0
