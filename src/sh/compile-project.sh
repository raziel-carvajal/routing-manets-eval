#!/bin/bash -
#===============================================================================
#
#          FILE: compile-project.sh
#
#         USAGE: ./compile-project.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 06/04/2019 14:03
#      REVISION:  ---
#===============================================================================

if [ ${#} -ne 2 ]; then
  echo "Usage: ${0} <omnet-path> <project-dir>"
  echo "End of ${0}" ; exit 1
fi
if [ ! -d ${1} ]; then
  echo "Error: ${1} is not a directory or it's invalid"
	echo "End of ${0}" ; exit 1
fi
if [ ! -d ${2} ]; then
	echo "Error: ${1} is not a directory or it's invalid"
	echo "End of ${0}" ; exit 1
fi

OMNET_PATH=${1}
PROJECT=${2}
projectName=`basename ${PROJECT}`
INET="${OMNET_PATH}/samples/inet/src"
if [ ! -f "${OMNET_PATH}/configure.user" -o ! -f "${OMNET_PATH}/include/omnetpp.h" ]; then
  echo "Error: ${OMNET_PATH} directory does not look like an OMNeT++ root directory"
  echo "End of ${0}" ; exit 1
fi

cd ${PROJECT}
opp_makemake -f --deep -s -I${INET} -I${PROJECT}/src -o ${projectName}
make
if [ ${?} != 0 ]; then
  echo "Error: during compilation of ${projectName} project"
  echo "End of ${0}" ; exit 1
fi
cd ${here}
