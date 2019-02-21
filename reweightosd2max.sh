#!/bin/bash

OSD="osd.10"
MAXW="3.63869"

if [ -f reweight2max_gained.tmp ]; then
  echo "all done.. remove reweight2max_gained.tmp file to restart"
  exit
fi

STAUS=$(ceph health|egrep "misplaced|errors")

if [ "${STAUS}" == "" ]; then
  CURW=$(ceph osd tree|grep ${OSD}|awk '{print $3}')
  NEWW=$(echo "${CURW} + 0.2" | bc)
  if (( $(echo "${NEWW} > ${MAXW}" | bc -l) )); then
    ceph osd crush reweight ${OSD} ${MAXW}
    touch reweight2max_gained.tmp
  else
    ceph osd crush reweight ${OSD} ${NEWW}
  fi
fi


