#!/bin/bash -
#===============================================================================
#
#          FILE: make_route_maintenance_dataset.sh
#
#         USAGE: ./make_route_maintenance_dataset.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (rcg), raziel.carvajal-gomez@uclouvain.be
#  ORGANIZATION: UCLouvain
#       CREATED: 05/06/2020 03:59:54 PM
#      REVISION:  ---
#===============================================================================
eos="End of ${0}"

( [ ! -d bin ] || [ ${#} != 1 ] )&& echo -e "ERROR. Run ${0} from root directory of RoVy \
  repository as follows: source bin/${0} <ini-file> \n${eos}" && exit 1

[ ! -f ${1} ] && echo -e "ERROR. Configuration file do not exist. \n${eos}" && exit 1

iniF=`basename ${1} | awk -F ".ini" '{print $1}'`
echo ${iniF} | grep "route_maintenance" &> /dev/null
[ ${?} -ne 0 ] && echo -e "ERROR. The provided configuration file must evaluate the route \
  maintenance phase. \n${eos}" && exit 1

logsDir=`dirname ${1}`"/results"
datasetLoc=`dirname ${1}`"/${iniF}"
rm -fr ${datasetLoc} ; mkdir ${datasetLoc}

for logF in `ls ${logsDir}/*.stdout | grep "route_maintenance"` ; do
  lossRate=`grep "loss rate" ${logF} | awk '{print $NF}'`
  dsId=`basename ${logF} | awk -F ".stdout" '{print $1}'`
  dstF="${datasetLoc}/${dsId}"
  echo "ping_latency_loss_rate_${lossRate}" > ${dstF}
  grep " time=" ${logF} | awk -F "time=" '{print $2}' | awk '{print $1}' >> ${dstF}
done

Rscript -e " \
  source('src/datasets/utils.R'); \
  df <- lapply(list.files('${datasetLoc}'), function(f) { \
    hopsNo <- unlist(strsplit(f, '_'))[7]; \
    nDf <- read.table(paste('${datasetLoc}', f, sep='/'), header=TRUE); \
    data.frame( data=nDf[, 1], group=rep(hopsNo, length(nDf[,1])) ); \
  }); \
  storeDataset(do.call('rbind', df), '${datasetLoc}', 'all_latencies');"
