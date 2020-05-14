#!/bin/bash -
#===============================================================================
#
#          FILE: make_message_delivery_dataset.sh
#
#         USAGE: ./make_message_delivery_dataset.sh
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
logsDir=`dirname ${1}`"/results"
datasetLoc=`dirname ${1}`"/${iniF}"

[ ! -d ${datasetLoc} ] && mkdir ${datasetLoc}

msgLossF="${datasetLoc}/messageloss"
echo "total count" > ${msgLossF}

for logF in `ls ${logsDir}/*.stdout | grep "${iniF}"` ; do
  # add message latency
  dsId=`basename ${logF} | awk -F ".stdout" '{print $1}'`
  hopsNo=`echo ${dsId} | awk -F '_' '{print $7}'`
  dstF="${datasetLoc}/${dsId}_msglatency"
  echo "msg_latency hops_btw_src_dst" > ${dstF}
  grep " time=" ${logF} | awk -F "time=" '{print $2}' | \
    awk -v h=${hopsNo} '{print $1, h}' >> ${dstF}
  # add message loss
  msgNo=`grep "run #" ${logF} | wc -l`
  lost=`wc -l ${dstF} | awk '{print $1}'` ; let lost=lost-1
  echo "${msgNo} ${lost}" >> ${msgLossF}
done

Rscript -e " \
  source('src/datasets/utils.R'); \
  allFiles <- list.files('${datasetLoc}'); \
  msgLatFs <- allFiles[ grep('_msglatency', allFiles) ]; \
  df <- lapply(msgLatFs, function(f) { \
    read.table(paste('${datasetLoc}', f, sep='/'), header=TRUE); \
  }); \
  storeDataset(do.call('rbind', df), '${datasetLoc}', 'msglatency');"
