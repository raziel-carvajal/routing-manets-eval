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
    separated with spaces) the following string: --with-route-discovery-latency \
    \n${eos}" &&  exit 1

datasetLoc=`dirname ${1}`"/results"
iniFid=`basename ${1} | awk -F '.ini' '{print $1}'`
outputLoc=`dirname ${1}`"/${iniFid}"
netDir=`dirname ${1} | sed -e 's/configs/networks/g'`
allRoutes="${netDir}/chosenRoutes.data"
rm -fr ${outputLoc} ; mkdir ${outputLoc}

for config in `grep "^\\[Config" ${1} | awk '{print $2}'` ; do
  config=`echo ${config} | awk -F "]" '{print $1}'`
  hopsNo=`echo ${config} | awk -F "_with_" '{print $2}' | awk -F "_" '{print $1}'`

  routes=`pwd`"/.routesWith${hopsNo}hops"
  grep "hops=${hopsNo}" ${allRoutes} | awk '{print $2, $3}' > ${routes}

  Rscript src/datasets/make_dataset.R ${datasetLoc} ${config} ${routes} \
    ${SEND_INTERVAL} ${hopsNo} ${outputLoc} ${DATASET_OPTIONS_LIST}

  rm -f ${routes}
done
