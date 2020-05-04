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
  [ ! -v PING_INTERVAL ] || [ ! -v SENT_PINGS ] ) && echo -e "Error. Before running ${0} set \
  the following variables: NODES, TX, CMA_WIDTH, CMA_HEIGHT, PROTOCOL, HOPS_BTW_PAIRS, \
  ROUTES, PING_INTERVAL and SENT_PINGS \n${eos}" && exit 1

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

#----------------------------------------------------------------------------------------------
# make INI file thought to evaluate the route discovery phase of a routing algo
#----------------------------------------------------------------------------------------------
iniFile="${cnfgsDir}/${scnId}.ini"
cat configs/aodv_idealnet_ackmac.ini >${iniFile}
scenario="*.scenarioManager.script = xmldoc("'"'"${origin}/${netsDir}/scenario.xml"'"'")"
echo ${scenario} >>${iniFile}

sed -i -e "s/NETWORK_NAME/${scnId}_${d}.${scnId}/" ${iniFile}
sed -i -e "s/NODES_NUM/${NODES}/" ${iniFile}
sed -i -e "s/TX_RANGE/${TX}m/" ${iniFile}
sed -i -e "s/AREA_MAX_X/${CMA_WIDTH}m/" ${iniFile}
sed -i -e "s/AREA_MAX_Y/${CMA_HEIGHT}m/" ${iniFile}
sed -i -e "s/PING_COUNT/1/" ${iniFile}
sed -i -e "s/PING_INTERVAL/${PING_INTERVAL}s/" ${iniFile}
sed -i -e "s/START_TIME/${PING_INTERVAL}s/" ${iniFile}

# complete INI with one configuration per distance (hops) between sources and destinations
time=1
routes=".temp"
rm -fr ${routes}
for hops in `echo -e ${HOPS_BTW_PAIRS}` ; do
  dstsList=""
  grep "hops=${hops}" "${netsDir}/chosenRoutes.data" > ${routes}
  src=`awk '{print $2}' ${routes} | uniq`
  # single source node for every destination
  if [ `echo ${src} | wc -w` -eq 1 ] ; then
    for dst in `awk '{print $3}' ${routes}` ; do
      dstsList="${dstsList} host[${dst}]"
      let time=${time}+1
    done
    echo "[Config ${scnId}_with_${hops}_hops]" >> ${iniFile}
    echo "*.host[${src}].app[0].destAddr = \"${dstsList}\"" >> ${iniFile}
  else # several source nodes to destinations
    for s in `echo ${src}` ; do
      dstsList=""
      for dst in `grep " ${s} " ${routes} | awk '{print $3}'` ; do
        dstsList="${dstsList} host[${dst}]"
        let time=${time}+1
      done
      echo "[Config ${scnId}_with_${hops}_hops_${s}]" >> ${iniFile}
      echo "*.host[${s}].app[0].destAddr = \"${dstsList}\"" >> ${iniFile}
    done
  fi
done
rm -fr ${routes}
let time=${time}*${PING_INTERVAL}
sed -i -e "s/STOP_APP_AT/${time}s/" ${iniFile}
mv ${iniFile} "${cnfgsDir}/${scnId}_route_discovery.ini"

#----------------------------------------------------------------------------------------------
# make INI file thought to evaluate the route maintance phase of a routing algo
#----------------------------------------------------------------------------------------------
iniFile="${cnfgsDir}/${scnId}.ini"
cat configs/aodv_idealnet_ackmac.ini >${iniFile}
scenario="*.scenarioManager.script = xmldoc("'"'"${origin}/${netsDir}/scenario.xml"'"'")"
echo ${scenario} >>${iniFile}

sed -i -e "s/NETWORK_NAME/${scnId}_${d}.${scnId}/" ${iniFile}
sed -i -e "s/NODES_NUM/${NODES}/" ${iniFile}
sed -i -e "s/TX_RANGE/${TX}m/" ${iniFile}
sed -i -e "s/AREA_MAX_X/${CMA_WIDTH}m/" ${iniFile}
sed -i -e "s/AREA_MAX_Y/${CMA_HEIGHT}m/" ${iniFile}
sed -i -e "s/PING_COUNT/-1/" ${iniFile}
sed -i -e "s/PING_INTERVAL/${PING_INTERVAL}s/" ${iniFile}
sed -i -e "s/START_TIME/${PING_INTERVAL}s/" ${iniFile}

route=".temp"
rm -fr ${route}
for hops in `echo -e ${HOPS_BTW_PAIRS}` ; do
  grep "hops=${hops}" "${netsDir}/chosenRoutes.data" | head -1 > ${route}
  src=`awk '{print $2}' ${route}`
  dst=`awk '{print $3}' ${route}`
  echo "[Config ${scnId}_with_${hops}_hops]" >> ${iniFile}
  echo "*.host[${src}].app[0].destAddr = \"host[${dst}]\"" >> ${iniFile}
done
rm -fr ${route}
# NOTE the simulation will finish when a fixed number of ping messages is sent
let time=${PING_INTERVAL}*(${SENT_PINGS}+1)
sed -i -e "s/STOP_APP_AT/${time}s/" ${iniFile}
mv ${iniFile} "${cnfgsDir}/${scnId}_route_maintenance.ini"
