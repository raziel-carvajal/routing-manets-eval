#!/bin/bash -
#===============================================================================
#
#          FILE: make_sent-messages_dataset.sh
#
#         USAGE: ./make_sent-messages_dataset.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (rcg), raziel.carvajal-gomez@uclouvain.be
#  ORGANIZATION: UCLouvain
#       CREATED: 06/29/2020 10:17:12 PM
#      REVISION:  ---
#===============================================================================
eos="End of ${0}"

( [ ! -d bin ] || [ ${#} -ne 1 ] ) && echo -e "ERROR. Run ${0} from root directory of RoVy \
  repository as follows: source bin/${0} <ini-file> \n${eos}" && exit 1

[ ! -f "${1}" ] && echo -e "ERROR. Configuration file do not exist. \n${eos}" && exit 1

datasetLoc=`dirname ${1}`"/results"
iniFid=`basename ${1} | awk -F '.ini' '{print $1}'`
outputLoc=`dirname ${1}`"/${iniFid}"
netDir=`dirname ${1} | sed -e 's/configs/networks/g'`
allRoutes="${netDir}/chosenRoutes.data"

sendInterval=`grep "sendInterval" ${1} | awk '{print $3}' | awk -F 's' '{print $1}'`
iterations=`grep "repeat" ${1} | awk '{print $3}'`

[ ! -d ${outputLoc} ] && mkdir ${outputLoc}
lineNo=2 ; configNo=1 ; lines=`wc -l ${allRoutes} | awk '{print $1}'`

while [ ${lineNo} -ne ${lines} ]; do
  route=`sed -n ${lineNo}p ${allRoutes}`
  src=`echo ${route} | awk '{print $2}'` ; dst=`echo ${route} | awk '{print $3}'`
  hops=`echo ${route} | awk '{print $4}' | awk -F '=' '{print $2}'`
  cf=`grep "\\[Config" ${1} | sed -n ${configNo}p | awk '{print $2}' | awk -F "]" '{print $1}'`

  Rscript src/datasets/make_dataset.R ${datasetLoc} ${cf} ${src} ${dst} ${sendInterval} \
    ${hops} ${outputLoc} ${iterations} --with-sent-messages
  echo "DONE" && exit 1
  let lineNo=lineNo+1
  let configNo=configNo+1
done
# NOTE do not let blank lines in the following R program
Rscript -e "\
  source( 'src/datasets/utils.R' ) ; \
  allFiles <- list.files('${outputLoc}') ; \
  ds <- allFiles[ grep('sentmessagesno', allFiles) ] ; \
  df <- lapply( ds, function(f) { \
    read.table( paste('${outputLoc}', f, sep='/'), header=TRUE ) ; \
  }) ; \
  storeDataset( do.call('rbind', df), '${outputLoc}', 'sentmessagesno' ) ;"
