#!/usr/bin/env sh

VERSIONFILE="Dockerfile.versions"
TEMPLATE="Dockerfile.template"
DESTINATION="Dockerfile"

save_changes() {
   git add ${DESTINATION}
   git commit -m "Updated Dockerfile"
   git push
}

TEMPFILE=$(mktemp /tmp/Dockerfile_generate.XXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
cp "${TEMPLATE}" "${TEMPFILE}"

HEADER='##### DONT NOT EDIT ME. THIS FILE IS GENERATED. EDIT Dockerfile.Template #####'
sed -i -e "s|%HEADER%|${HEADER}|g" "${TEMPFILE}"

while read line; do
    setting="$( echo "$line" | cut -d '=' -f 1 )"
    value="$( echo "$line" | cut -d '=' -f 2- )"

    sed -i -e "s|%${setting}%|${value}|g" "${TEMPFILE}"

done < "${VERSIONFILE}"

diff -q "${TEMPFILE}" "${DESTINATION}" > /dev/null
if [ "$?" -ne 0 ]; then
  echo Dockerfile has changed, comitting...
  mv "${TEMPFILE}" "${DESTINATION}"
  save_changes
else
   echo Dockerfile - No Change!
fi

