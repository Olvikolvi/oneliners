#!/bin/sh

# This script provisions Boot2Docker with the Convoy volume plugin.
# Copy it to /var/lib/boot2docker/bootlocal.sh and make it executable.
# It will be run at the end of boot initialisation.
# https://github.com/boot2docker/boot2docker/blob/master/doc/FAQ.md

RELEASE=v0.5.0

URL=https://github.com/rancher/convoy/releases/download/${RELEASE}/convoy.tar.gz
WORK_DIR=/var/lib/boot2docker
CONVOY_BASE=/var/lib/docker/convoy
CONVOY_ROOT=$CONVOY_BASE/root
CONVOY_VOLUMES=$CONVOY_BASE/volumes
CONVOY_VOLUME_SIZE=500M
CONVOY_LOG=/var/log/convoy.log
CONVOY_RELEASE=$CONVOY_BASE/release.txt

if [ ! -d ${CONVOY_BASE} ] || ( ! grep -qx ${RELEASE} ${CONVOY_RELEASE} )
then
    rm -rf $WORK_DIR/convoy
    wget -O $WORK_DIR/convoy.tar.gz $URL
    tar -xzf $WORK_DIR/convoy.tar.gz -C $WORK_DIR
    rm -rf $WORK_DIR/convoy.tar.gz

    mkdir -p $CONVOY_ROOT
    mkdir -p $CONVOY_VOLUMES
    echo $RELEASE > $CONVOY_RELEASE
fi

cp $WORK_DIR/convoy/convoy /usr/local/bin/
cp $WORK_DIR/convoy/convoy-pdata_tools /usr/local/bin/

mkdir -p /etc/docker/plugins/
echo "unix:///var/run/convoy/convoy.sock" > /etc/docker/plugins/convoy.spec

nohup convoy daemon \
    --root=$CONVOY_ROOT \
    --log=$CONVOY_LOG \
    --drivers vfs \
    --driver-opts vfs.path=$CONVOY_VOLUMES \
    --driver-opts vfs.defaultvolumesize=$CONVOY_VOLUME_SIZE \
    > /dev/null 2>&1 &

