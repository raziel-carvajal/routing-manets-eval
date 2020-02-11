#!/bin/bash -
#===============================================================================
#
#          FILE: run-config.sh
#
#         USAGE: ./run-config.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 02/05/2020 20:37
#      REVISION:  ---
#===============================================================================
endStr="End of ${0}"
# check correct # of arguments
[ ${#} -ne 3 ] && \
  echo -e "Usage: ${0} INET_PATH INI_FILE CONFIGURATION\n${endStr}"  && exit 1
# check that the INI file exist
[ ! -f ${2} ] && \
  echo -e "Error: configuration (*.ini) file doesn't exist.\n${endStr}" && exit 1
# check that INI file contains the written configuration
grep ${3} ${2}
[ ${?} -ne 0 ] && \
  echo -e "Error: experiment doesn't exist in ini file.\n${endStr}" && exit 1

# set environment for omnet++/inet
myNedFiles=$(cd .. && pwd)
source set-env.sh ${1}
[ ${?} -ne 0 ] && \
  echo -e "Error. Cannot set environment for omnet++/inet.\n${endStr}" && exit 1

opp_run -u Cmdenv -n ${myNedFiles}/networks:${INET_NED_PATH} \
  -l ${INET_ROOT}/src/INET -c ${3} -f ${2}

echo "Ok, ${0} ends successfully."
