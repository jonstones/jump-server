#!/usr/bin/env sh

VERSIONFILE="Dockerfile.versions"
TEMPLATE="Dockerfile.template"
DESTINATION="Dockerfile"

TEMPFILE=$(mktemp /tmp/Dockerfile_generate.XXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
cp "${TEMPLATE}" "${TEMPFILE}"

HEADER='##### DONT NOT EDIT ME. THIS FILE IS GENERATED. EDIT Dockerfile.Template #####'
sed -i -e "s|%HEADER%|${HEADER}|g" "${TEMPFILE}"

while read line; do
    setting="$( echo "$line" | cut -d '=' -f 1 )"
    value="$( echo "$line" | cut -d '=' -f 2- )"

    sed -i -e "s|%${setting}%|${value}|g" "${TEMPFILE}"

done < "${VERSIONFILE}"

mv "${TEMPFILE}" "${DESTINATION}"

