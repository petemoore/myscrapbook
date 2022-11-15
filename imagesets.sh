#!/usr/bin/env bash

set -eu
set -o pipefail

function repo {
  NAME="${1}"
  rm -rf "${NAME}"
  mkdir "${NAME}"
  cd "${NAME}"
  mozilla-history
  cd WorkerPools
  set +e
  cat *⁄* | jq -r '.config.launchConfigs[].storageProfile.imageReference.id' 2>/dev/null | grep -v null | sort -u > azure.images
  cat *⁄* | jq -r '.config.launchConfigs[].disks[].initializeParams.sourceImage' 2>/dev/null | grep -v null | sort -u > gcp.images
  cat *⁄* | jq -r '(.config.launchConfigs[] | select(.launchConfig.InstanceType != null)).region' 2>/dev/null | sort -u > aws.regions
  set -e
  cat aws.regions | while read region; do
    cat *⁄* | jq -r "((.config.launchConfigs[] | select(.launchConfig.InstanceType != null)) | select (.region == \"${region}\")).launchConfig.ImageId" 2>/dev/null | sort -u > aws.${region}.images
  done
  workerpools="$(echo *⁄*)"
  images="$(cat azure.images gcp.images aws.*.images | sort -u)"
  for wp in ${workerpools}; do
    for image in ${images}; do
      grep -q -F "\"${image}\"" "${wp}" && echo "${image}" >> "${wp}.images"
    done
  done
  shasum -a 256 *⁄*.images | sort | while read sum wp_images; do
    echo "${wp_images/.images}" >> "imageset_${sum}.txt"
  done
  (
    for file in imageset_*.txt; do
      echo "Machine images:"
      first="$(head -1 "${file}")"
      cat "${first}.images" | sed 's/^/  /'
      echo "Used by:"
      cat "${file}" | sed 's/^/  /'
      echo
    done
  ) > ../Image\ Sets.txt
  cd ../..
}


# Start with community

export TASKCLUSTER_CLIENT_ID='static/taskcluster/root'
export TASKCLUSTER_ACCESS_TOKEN="$(pass ls community-tc/root | head -1)"
export TASKCLUSTER_ROOT_URL='https://community-tc.services.mozilla.com'
unset TASKCLUSTER_CERTIFICATE

repo community

# Now do firefox-ci

unset TASKCLUSTER_CERTIFICATE
eval $(gpg -d ~/firefox-ci-tc.env.gpg)

repo firefox-ci
