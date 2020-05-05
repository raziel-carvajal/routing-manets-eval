require(argparse)

source('src/datasets/utils.R')

parseArgs <- function() {
  p <- ArgumentParser(
    description='Gets several dataset with the performance of routing protocols for MANETs.'
  )
  # mandatory arguments
  p$add_argument('dataset_location', type='character')
  p$add_argument('config_id', type='character')
  p$add_argument('routes_file', type='character')
  p$add_argument('send_interval', type='integer')
  p$add_argument('hops_no', type='integer')
  p$add_argument('storage_loc', type='character')
  # options
  p$add_argument('--with-route-discovery-latency', dest='wrdl', action='store_true')
  p$add_argument('--with-pk-err-rate', dest='wper', action='store_true')
  p$add_argument('--with-hops-num', dest='whn', action='store_true')

  p$parse_args()
}
args <- parseArgs()
routes <- read.table(args$routes_file)
names(routes) <- c('src', 'dst')

# only takes first execution as there are several configuration per INI file
dsf <- paste(args$dataset_location, '/', args$config_id, '-#0', sep='')
if(args$wrdl){
  sentMsgs <- getVectorDataset(dsf, 'packetSent:vector(packetBytes)')
  routeReqRecv <- getVectorDataset(dsf, 'arpRequestSent:vector(packetBytes)')

  routeReqAnsw <- getVectorDataset(dsf, 'arpReplySent:vector(packetBytes)')
  succRrLatencies <- sapply(1:length(routes$src), function(r_i) {
    src <- routes$src[r_i]
    dst <- routes$dst[r_i]
    t <- r_i * args$send_interval

    sample <- sentMsgs[ sentMsgs$nodeId == src & sentMsgs$timestamp >= t, ]
    rrTa <- head(sample[ order(sample$timestamp), ], n=1)

    rrDstReply <- routeReqRecv[
      routeReqRecv$timestamp >= t &
      routeReqRecv$timestamp < (t + args$send_interval) & routeReqRecv$nodeId == dst ,
    ]
    rrTb <- head(rrDstReply[ order(rrDstReply$timestamp), ], n=1)

    ifelse(
      length(rrTa$nodeId) == 1 & length(rrTb$nodeId) == 1,
      (rrTb$timestamp - rrTa$timestamp) * 2,
      NA
    )
  })
  # storeDataset <- function(ds, dstPath, fileName)
  # TODO store distributions
  storeDataset(
    data.frame(
      route_discovery_latency=succRrLatencies,
      hops_btw_src_dst=rep(paste("hops", args$hops_no, sep="_"), length(succRrLatencies)) ),
    args$storage_loc, args$config_id
  )
}
