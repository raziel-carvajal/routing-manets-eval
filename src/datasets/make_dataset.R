require(argparse)

source('src/datasets/utils.R')

parseArgs <- function() {
  p <- ArgumentParser(
    description='Gets several dataset with the performance of routing protocols for MANETs.'
  )
  # mandatory arguments
  p$add_argument('dataset_location', type='character')
  p$add_argument('config_id', type='character')
  p$add_argument('src_id', type='integer')
  p$add_argument('dst_id', type='integer')
  p$add_argument('send_interval', type='integer')
  p$add_argument('hops_no', type='integer')
  p$add_argument('storage_loc', type='character')
  p$add_argument('iterations', type='integer')
  # options
  p$add_argument('--with-arp-latency', dest='warpl', action='store_true')
  p$add_argument('--with-route-discovery-latency', dest='wrdl', action='store_true')
  # options for env variable: R_SCRIPT_OPTIONS
  p$add_argument('--is-aodv-experiment', dest='isaodv', action='store_true')
  p$add_argument('--is-dsdv-experiment', dest='isdsdv', action='store_true')

  p$parse_args()
}
args <- parseArgs()

if(args$warpl){
  arpLatency <- sapply(0:(args$iterations - 1), function(i) {

    dsf <- paste(args$dataset_location, '/', args$config_id, '-#', i, sep='')
    arpRequests <- getVectorDataset(dsf, 'arpRequestSent:vector(packetBytes)')
    arpReplies <- getVectorDataset(dsf, 'arpReplySent:vector(packetBytes)')
    src <- args$src_id
    dst <- args$dst_id

    # in AODV an ARP session starts at the destination node
    if(args$isaodv){
      src <- args$dst_id
      dst <- args$src_id
    }

    arpReplies <- arpReplies[ arpReplies$nodeId == dst, ]
    endResoTime <- head(arpReplies[ order(arpReplies$timestamp), ], n=1)

    arpRequests <- arpRequests[
      arpRequests$nodeId == src & arpRequests$timestamp < endResoTime$timestamp,
    ]
    iniResoTime <- tail(arpRequests[ order(arpRequests$timestamp), ], n=1)

    ifelse(
      length(iniResoTime$nodeId) == 1 & length(endResoTime$nodeId) == 1,
      (endResoTime$timestamp - iniResoTime$timestamp) * 1000, # ARP latency in milliseconds
      NA
    )
  })
  # take rid of min/max
  nas <- arpLatency[ is.na(arpLatency) ]
  arpLatency <- arpLatency[ !is.na(arpLatency) ]
  arpLatency <- arpLatency[ arpLatency != min(arpLatency) & arpLatency != max(arpLatency) ]
  storeDataset(
    data.frame(
      arp_latency=c( arpLatency, rep(NA, length(nas)) ),
      hops_btw_src_dst=rep( args$hops_no, length(arpLatency) + length(nas) )
    ),
    args$storage_loc,
    paste(args$config_id, "_", "arplatency", sep="")
  )
}

if(args$wrdl){
  routeDiscLat <- sapply(0:(args$iterations - 1), function(i) {

    dsf <- paste(args$dataset_location, '/', args$config_id, '-#', i, sep='')

    arpReplies <- getVectorDataset(dsf, 'arpReplySent:vector(packetBytes)')
    # in AODV an ARP session starts at the destination node
    if(args$isaodv){
      arpReplies <- getVectorDataset(dsf, 'arpRequestSent:vector(packetBytes)')
    }

    arpReplies <- arpReplies[ arpReplies$nodeId == args$dst_id, ]
    reachDst <- head(arpReplies[ order(arpReplies$timestamp), ], n=1)

    ifelse(
      length(reachDst$nodeId) == 1,
      (reachDst$timestamp - args$send_interval) * 1000, # ARP latency in milliseconds
      NA
    )
  })
  # take rid of min/max
  nas <- routeDiscLat[ is.na(routeDiscLat) ]
  routeDiscLat <- routeDiscLat[ !is.na(routeDiscLat) ]
  routeDiscLat <- routeDiscLat[
    routeDiscLat != min(routeDiscLat) & routeDiscLat != max(routeDiscLat)
  ]
  storeDataset(
    data.frame(
      route_discovery_latency=c( routeDiscLat, rep(NA, length(nas)) ),
      hops_btw_src_dst=rep( args$hops_no, length(routeDiscLat) + length(nas) )
    ),
    args$storage_loc,
    paste(args$config_id, "_", "routediscoverylatency", sep="")
  )
}
