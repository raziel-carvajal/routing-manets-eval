#!/bin/bash -
#===============================================================================
#
#          FILE: make_static_routing_scenario.sh
#
#         USAGE: ./make_static_routing_scenario.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (rcg), raziel.carvajal-gomez@uclouvain.be
#  ORGANIZATION: UCLouvain
#       CREATED: 03/25/2020 09:29:40 PM
#      REVISION:  ---
#===============================================================================
eos="End of ${0}"

[ ! -d bin ] && echo -e "Error. Run ${0} from the root directory of this git \
  repository. \n${eos}" && exit 1

( [ ! -v NODES ] || [ ! -v TX ] || [ ! -v CMA_WIDTH ] || [ ! -v CMA_HEIGHT ] || \
  [ ! -v PROTOCOL ] || [ ! -v HOPS_BTW_PAIRS ] || [ ! -v ROUTES ] || \
  [ ! -v PING_INTERVAL ] ) && echo -e "Error. Before running ${0} set the following \
  variables: NODES, TX, CMA_WIDTH, CMA_HEIGHT, PROTOCOL, HOPS_BTW_PAIRS, ROUTES and \
  PING_INTERVAL \n${eos}" && exit 1

d=`date --rfc-3339='ns'`
d1=`echo ${d} | awk '{print $1}' | awk -F '-' '{print $1"_"$2"_"$3}'`
d2=`echo ${d} | awk '{print $2}' | awk -F '.' '{print $2}' | awk -F '+' '{print "_"$1}'`
d=`echo "${d1}${d2}"`
scnId="cnfg_${NODES}_${TX}_${CMA_WIDTH}x${CMA_HEIGHT}_${PROTOCOL}"

netsDir=networks/built/"${scnId}_${d}" ; cnfgsDir=configs/built/"${scnId}_${d}"
mkdir -p ${netsDir}/pdfs ; mkdir -p ${cnfgsDir}

origin=`pwd` ; cd src/mobility_traces
python get_random_waypoint_trace.py --cma-height ${CMA_HEIGHT} --cma-width ${CMA_WIDTH} \
  --nodes ${NODES} --transmission-range ${TX}
mv *.pdf ${origin}/${netsDir}/pdfs ; mv *.bm *.csv *.xml ${origin}/${netsDir}
cd ${origin}

echo -e "count src dst hops route" >> ${netsDir}/chosenRoutes.data
for hops in `echo -e ${HOPS_BTW_PAIRS}` ; do
  Rscript -e "\
  source('src/datasets/utils.R'); \
  ds <- read.csv('${netsDir}/routingInformation.csv'); \
  getSrcDstPairs(ds, ${hops}, ${ROUTES}, 0)" | grep -e "^[1-9]" \
  >> ${netsDir}/chosenRoutes.data
done

# make NED file
nedFile="${netsDir}/${scnId}.ned"
cat networks/aodv_idealnet_ackmac.ned >${nedFile}
sed -i -e "s/NAMESPACE/${scnId}_${d};/" ${nedFile}
sed -i -e "s/NETWORK_NAME/${scnId}/" ${nedFile}

# make INI file
iniFile="${cnfgsDir}/${scnId}.ini"
cat configs/aodv_idealnet_ackmac.ini >${iniFile}
scenario="*.scenarioManager.script = xmldoc("'"'"${origin}/${netsDir}/scenario.xml"'"'")"
echo ${scenario} >>${iniFile}

sed -i -e "s/NETWORK_NAME/${scnId}_${d}.${scnId}/" ${iniFile}
sed -i -e "s/NODES_NUM/${NODES}/" ${iniFile}
sed -i -e "s/TX_RANGE/${TX}m/" ${iniFile}
sed -i -e "s/AREA_MAX_X/${CMA_WIDTH}m/" ${iniFile}
sed -i -e "s/AREA_MAX_Y/${CMA_HEIGHT}m/" ${iniFile}
sed -i -e "s/PING_INTERVAL/${PING_INTERVAL}s/" ${iniFile}

# complete INI file with one configuration per hop number between
routes=".temp"
rm -fr ${routes}
for hops in `echo -e ${HOPS_BTW_PAIRS}` ; do
  echo "[Config ${scnId}_with_${hops}_hops]" >>${iniFile}
  grep "hops=${hops}" "${netsDir}/chosenRoutes.data" > ${routes}
  if [ `awk '{print $2}' ${routes} | uniq | wc -w` -eq 1 ] ; then
    src=`awk '{print $2}' ${routes} | uniq`
    dstsList=""
    time=1
    for dst in `awk '{print $3}' ${routes}` ; do
      dstsList="${dstsList} host[${dst}]"
      let time=${time}+1
    done
    let time=${time}*${PING_INTERVAL}
    echo -e "\
    *.host[${src}].app[0].startTime = ${PING_INTERVAL}s \n \
    *.host[${src}].app[0].destAddr = \"${dstsList}\" \n" >>${iniFile}
  else
    echo "WARNING. Several source nodes in routes with HOPS=${hops}; this configuration will \
      be ignored."
  fi
done
rm -fr ${routes}
sed -i -e "s/STOP_APP_AT/${time}s/" ${iniFile}
