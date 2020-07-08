#!/bin/bash -
#===============================================================================
#
#          FILE: deploy-one-worker-per-config.sh
#
#         USAGE: source bin/deploy-one-worker-per-config.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (rcg), raziel.carvajal-gomez@uclouvain.be
#  ORGANIZATION: UCLouvain
#       CREATED: 05/15/2020 04:51:11 PM
#      REVISION:  ---
#===============================================================================
script="deploy-one-worker-per-config.sh"
eos="End of ${script}"

( [ ! -d bin ] || [ ${#} -ne 1 ] ) && echo -e "ERROR. Run ${script} from root directory of \
  RoVy repository as follows: source bin/${script} <ini-file> \n${eos}" && exit 1

# check that the INI file exist
[ ! -f "${1}" ] && echo -e "Error. The provided INI file doesn't exist.\n${eos}" && exit 1

iniFullP=`dirname ${1}`"/"`basename ${1}`
iniF=`echo ${iniFullP} | awk -F 'configs' '{print $2}'`
[ ${?} -ne 0 ] && echo -e "Error. The provided INI file should be located at the directory \
  './configs'. \n${eos}" && exit 1

iniF="configs/${iniF}"
cd containerization
for config in `grep "^\\[Config" ${iniFullP} | awk '{print $2}'` ; do
  config=`echo ${config} | awk -F "]" '{print $1}'`
  echo "Running configuration ${config} ..."
  docker-compose run -d --name "worker_${config}" \
    --entrypoint "./bin/run-config-in-worker.sh ${iniF} ${config}" worker
  echo "END of ${config}"
done
