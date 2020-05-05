#!/bin/bash -
#===============================================================================
#
#          FILE: run_all_configs.sh
#
#         USAGE: ./run_all_configs.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (rcg), raziel.carvajal-gomez@uclouvain.be
#  ORGANIZATION: UCLouvain
#       CREATED: 05/05/2020 09:33:15 PM
#      REVISION:  ---
#===============================================================================
eos="End of ${0}"

[ ! -d bin ] && echo -e "ERROR. Run ${0} from root directory of RoVy repository as follows: \
  source bin/${0} <ini-file> \n${eos}" && exit 1

[ ! -f ${1} ] && echo -e "ERROR. Configuration file do not exist. \n${eos}" && exit 1

for config in `grep "^\\[Config" ${1} | awk '{print $2}'` ; do
  config=`echo ${config} | awk -F "]" '{print $1}'`
  echo "Running configuration ${config} ..."
  source bin/run-config.sh ~/BuiltPrograms/omnetpp-5.6.1 ${1} ${config}
  echo "END of ${config}"
done
