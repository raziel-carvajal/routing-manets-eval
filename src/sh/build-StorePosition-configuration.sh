#!/bin/bash -
#===============================================================================
#
#          FILE: build-StorePosition-configuration.sh
#
#         USAGE: ./build-StorePosition-configuration.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 06/04/2019 11:16
#      REVISION:  ---
#===============================================================================
[ ${#} -ne 3 ] && echo "Usage: ${0} <bonnmotion-mobility-trace> <id> <stop-time>" && \
	echo "End of ${0}" && exit 1

[ ! -f ${1} ] && echo "Error: trace file doesn't exist" && echo "End of ${0}" && exit 1

[ ${3} -lt 0 ] && echo "Error: simulation time must be a positive integer bigger than zero" && \
	echo "End of ${0}" && exit 1

trace=`dirname ${1}`"/"`basename ${1}`
id=${2}
stopTime=${3}
let simTime=stopTime+1

n=`wc -l ${trace} | awk '{print $1}'`
let nodes=n-1

cnfName="StorePosition_${nodes}_${id}"
nodesList="" ; nodesIdsList=""
for (( i = 1; i <= ${nodes}; i++ )); do
	nodesList="${nodesList}host${i}: Host;\n"
	nodesIdsList="${nodesIdsList}*.host${i}.mobility.nodeId = ${i}\n"
done

# build NED file
cat ../../configs/network.ned > "${cnfName}.ned"
sed -i -e "s/NETWORK_NAME/${cnfName}/" "${cnfName}.ned"
sed -i -e "s/NODES_LIST/${nodesList}/" "${cnfName}.ned"
mv "${cnfName}.ned" ../../configs/built

# build configuration file for experiment
cat ../../configs/common.ini > "${cnfName}.ini"
sed -i -e "s/MAX_SIMULATION_TIME/${simTime}s/" "${cnfName}.ini"
sed -i -e "s/CONFIG_NAME/${cnfName}/" "${cnfName}.ini"
sed -i -e "s/NETWORK_NAME/${cnfName}/" "${cnfName}.ini"
sed -i -e "s/STOP_TIME/${stopTime}s/" "${cnfName}.ini"
sed -i -e "s/NODES_IDS_LIST/${nodesIdsList}/" "${cnfName}.ini"
echo "*.host*.mobility.traceFile = \"${trace}\"" >> "${cnfName}.ini"
mv "${cnfName}.ini" ../../configs/built
echo "Successful execution of ${0}"
