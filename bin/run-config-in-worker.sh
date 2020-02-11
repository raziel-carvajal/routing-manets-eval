#!/bin/bash -
#===============================================================================
#
#          FILE: run-config-in-worker.sh
#
#         USAGE: ./run-config-in-worker.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 02/11/2020 17:31
#      REVISION:  ---
#===============================================================================
endStr="End of ${0}"
# check that the INI file exist
[ ! -f ${INI_FILE} ] && \
  echo -e "Error: configuration (*.ini) file doesn't exist.\n${endStr}" && exit 1
# check that INI file contains the written configuration
grep ${EXPERIMENT} ${INI_FILE}
[ ${?} -ne 0 ] && \
  echo -e "Error: experiment doesn't exist in ini file.\n${endStr}" && exit 1

opp_run -u Cmdenv -n ${INET_NED_PATH} -l ${INET_ROOT}/src/INET \
  -c ${EXPERIMENT} -f ${INI_FILE}
