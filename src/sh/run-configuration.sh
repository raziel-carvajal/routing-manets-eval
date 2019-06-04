#!/bin/bash -
#===============================================================================
#
#          FILE: run-configuration.sh
#
#         USAGE: ./run-configuration.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 06/04/2019 14:18
#      REVISION:  ---
#===============================================================================
[ ${#} != 3 ] && echo "Usage: $0 <inet-path> <project-path> <configuration-ini-file>" && \
	echo "End of ${0}" && exit 1

[ ! -d ${1} ] && echo "Error: dir (${1}) doesn't exist" && echo "End of ${0}" && exit 1
[ ! -d ${2} ] && echo "Error: dir (${2}) doesn't exist" && echo "End of ${0}" && exit 1
[ ! -f ${3} ] && echo "Error: file (${3}) doesn't exist" && echo "End of ${0}" && exit 1

if [ ! -f ${1}/src/libINET.so ]; then
	echo "Error: ${1} doesn't look like an INET directory"
	echo "End of ${0}" ; exit 1
fi
inetPath=${1}

projectName=`basename ${2}`
if [ ! -f ${2}/lib${projectName}.so ]; then
	echo "Error: can't find executable of ${projectName}"
	echo "End of ${0}" ; exit 1
fi
projectPath=${2}

nedPath=${inetPath}/src:${projectPath}/src:../../configs/built
confName=`basename ${3} | awk -F ".ini" '{print $1}'`

opp_run -u Cmdenv -n ${nedPath} -l ${inetPath}/src/INET -l ${projectPath}/${projectName} -c ${confName} -f ${3}
[ ${?} -ne 0 ] && echo "Error. Wrong execution of ${confName}" && echo "End of ${0}" && exit 1

echo -e "Correct execution of ${confName}"
