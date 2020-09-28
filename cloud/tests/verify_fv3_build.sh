#!/bin/bash

# default environment variables
COMP=${COMP:-intel}
REPO=${REPO:-dshawul}
VERSION=${VERSION:-latest}
BINARY=${BINARY:-"/opt/NEMSfv3gfs/tests/fv3_1.exe"}

IMAGE_NAME=${REPO}/fv3-intel:$VERSION

echo "Verifying image by looking for  $BINARY in image ${IMAGE_NAME}....."

# first verify image exists
docker inspect --type=image $IMAGE_NAME >& /dev/null
status=$?
if test $status -eq 0; then
    echo $'\t'"found docker image ${IMAGE_NAME}"
else
    echo $'\t'"final docker image ${IMAGE_NAME} does not exist!"
    echo "FAILED"
    false
    exit -9
fi

# now verify binary exists in image
docker run --rm $IMAGE_NAME sh -c "test -f $BINARY" >& /dev/null
status=$?

if test $status -eq 0; then
   echo $'\t'"found binary $BINARY"
   echo "SUCCESS"
else 
   echo $'\t'"Unable to find $BINARY in image ${IMAGE_NAME}!"
   echo "FAILED"
   false
   exit -9
fi

