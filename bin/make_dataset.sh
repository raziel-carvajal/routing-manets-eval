#!/bin/bash -
#===============================================================================
#
#          FILE: make_dataset.sh
#
#         USAGE: ./make_dataset.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (rcg), raziel.carvajal-gomez@uclouvain.be
#  ORGANIZATION: UCLouvain
#       CREATED: 04/14/2020 09:53:25 PM
#      REVISION:  ---
#===============================================================================
eos="End of ${0}"

[ ! -d bin ] && echo -e "ERROR. Run ${0} from root directory of RoVy repository as follows: \
  source bin/${0} <ini-file> \n${eos}" && exit 1

[ ! -f ${1} ] && echo -e "ERROR. Configuration file do not exist. \n${eos}" && exit 1

( [ ! -v DATASET_OPTIONS_LIST ] || [ ! -v SEND_INTERVAL ] ) && \
  echo -e "ERROR. Before running ${0} set the variables SEND_INTERVAL and \
    DATASET_OPTIONS_LIST; this latter variable might have as longest value (list of strings \
    separated with spaces) the following string: --with-succ-routereq-latency \
    \
    \n${eos}" &&  exit 1

datasetLoc=`dirname ${1}`"/results"
cnfgId=`basename ${1} | awk -F '.ini' '{print $1}'`
netDir=`dirname ${1} | sed -e 's/configs/networks/g'`
allRoutes="${netDir}/chosenRoutes.data"

for hopStr in `grep "hops=" ${allRoutes} | awk '{print $4}' | uniq` ; do
  hopsNo=`echo ${hopStr} | awk -F '=' '{print $2}'`
  routes=`pwd`"/.routesWith${hopsNo}hops"
  grep "${hopStr}" ${allRoutes} | awk '{print $2, $3}' > ${routes}
  Rscript src/datasets/make_dataset.R ${datasetLoc} ${cnfgId} ${routes} ${hopsNo} \
    ${SEND_INTERVAL} ${DATASET_OPTIONS_LIST}
  exit 1
  rm -f ${routes}
done
