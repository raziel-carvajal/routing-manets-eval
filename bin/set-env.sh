#!/bin/bash -
#===============================================================================
#
#          FILE: set-env.sh
#
#         USAGE: ./set-env.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 02/05/2020 20:36
#      REVISION:  ---
#===============================================================================
_0="./set-env.sh"
endStr="End of ${_0}"

[ ${#} -ne 1 ] && echo -e "Usage: ${_0} OMNET_PATH \n${endStr}" && exit 1

[ ! -d ${1} ] && echo -e "Error: ${1} isn't a directory.\n${endStr}" && exit 1

# set environment variables for omnet++
cd ${1} && source setenv
[ ${?} -ne 0 ] && exit 1
# set environment variables for inet
cd samples/inet && source setenv
[ ${?} -ne 0 ] && exit 1

echo "Ok, ${_0} ends successfully."
