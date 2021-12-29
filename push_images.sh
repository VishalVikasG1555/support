#!/bin/bash
# Script to unpack and push Passport application Docker images to the target registry
# Prerequisite:

#   1) Run on Linux bash shell, with Docker engine running and current user having permission to run docker
#   2) Already logged in to the target registry so 'docker push' can work
#   3) Have the archive file (nap-images-{BuildTag}.tar.gz) and manifest file (image-manifest-{BuildTag}.txt) in current folder
# To run the script:
#   ./push_images.sh {BuildTag} {TargetRegistryUrl}
#   {BuildTag} : Mandatory. the tag of the current build. e.g. 03.16.00-01
#   {TargetRegistryUrl} : The registry url of the target registry. e.g. myregistry.example.com:5000/nexus/repository/aptra-passport If 'target_registry' variable is set in this script, this parameter can be ignored. It always overrides the configured value if provided.
# Logs are output to file image_push.log

GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ "$(systemctl is-active docker)" != "active" ]; 
then 
	echo -e "${RED}Docker Engine is Dead :) ${NC}"
	echo -e "Please restart docker engine with this command ${RED}'service docker restart'${NC} and re-run this script" 
	exit 1;
fi


target_registry=

error_count=0
if [ -z $1 ] ; then
  echo -e "${RED}Please specify build tag as parameter (e.g. 3.16.0-01 )${NC}"
  exit 1
fi

if [ -n "$2" ]; then
  target_registry="$2"

else
  if [ -z "$target_registry" ]; then
    echo -e " ${RED} Please specify target registry URL prefix as the 2nd parameter if not specified in the script. ${GREEN}(e.g. myregistry.example.com:5000/nexus/repository/aptra-passport )${NC}"
    exit 1
  fi
fi

function toggleSpinner {
  if [ -z "$spinner" ]; then
    chars="/-\|"
    while :; do
      for (( i=0; i<${#chars}; i++ )); do
        sleep 1
        echo -en "${chars:$i:1}$1" "\r"
      done
    done&
    spinner=$!
    trap "kill $spinner 2> /dev/null" EXIT
  else
    kill $spinner
    wait $spinner 2>/dev/null
    spinner=
  fi
}

image_manifest=image-manifest-$1.txt
image_dir=NAP-$1

ls ${image_dir}.tar.gz > /dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "Archive files ${image_dir}.tar.gz don't exist."
  exit 1
fi

if [ ! -f $image_manifest ]; then
  echo "$image_manifest doesn't exist."
  exit 1
fi


echo `date` >> image_push.log
echo -e " ${GREEN} Loading $image to docker engine from ${image_dir}.tar.gz ${NC}"

docker load -i ${image_dir}.tar.gz
registryPrefix=
while read -r image
do
  if [ "original_registry_prefix" = "${image%%=*}" ]; then
    registryPrefix=${image##*=}
    continue;
  fi
  if [ -z "$registryPrefix" ]; then
    echo "Error: ${RED}original_registry_prefix setting is missing in the first line of the manifest.${NC}"
    exit 1
  fi
  
  imagename=${image##${registryPrefix}/}
  filename=${image##*/}
  docker tag $image ${target_registry}/${imagename}
  docker push ${target_registry}/${imagename}
  if [ "$?" = "0" ]; then
    echo "SUCCESS - ${target_registry}/${imagename}" >> image_push.log
    docker rmi $image
    docker rmi ${target_registry}/${imagename}
  else
    error_count=$(expr $error_count + 1)
    echo "FAIL - ${target_registry}/${imagename}" >> image_push.log
  fi
done < $image_manifest

echo "Docker images pushed to ${target_registry} with $error_count error(s)."
