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
temp=`dirname ${1}`"/${2}.stdout"

opp_run -u Cmdenv -n networks/built:${INET_NED_PATH} -l ${INET_ROOT}/src/INET \
  -c ${2} -f ${1} &> ${temp}

mv ${temp} $(dirname ${1})"/results/"
