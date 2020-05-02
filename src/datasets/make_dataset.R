require(argparse)

source('src/datasets/utils.R')

parseArgs <- function() {
  p <- ArgumentParser(
    description='Gets several dataset with the performance of routing protocols for MANETs.'
  )
  # mandatory arguments
  p$add_argument('dataset_location', type='character')
  p$add_argument('dataset_id', type='character')
  p$add_argument('routes_file', type='character')
  p$add_argument('hopsno', type='character')
  p$add_argument('send_interval', type='integer')
  # options
  p$add_argument('--with-succ-routereq-latency', dest='wsrrl', action='store_true')
  p$add_argument('--with-pk-err-rate', dest='wper', action='store_true')
  p$add_argument('--with-hops-num', dest='whn', action='store_true')
  #p$add_argument('--simulation-time', dest='simTime', type='double')
  # parser$add_argument('--results-dir', dest='resultsDir', type='character')
  # parser$add_argument('--transmission-range', dest='tx', type='integer')
	# parser$add_argument('--with-plotting', dest='wplot', action='store_true')
	# parser$add_argument('--with-metrics-over-time', dest='wmot', action='store_true')
  # # list of broadcast metrics
  # parser$add_argument('--with-energy-consumption', dest='wpc', action='store_true')
  # parser$add_argument('--with-coverage', dest='wco', action='store_true')
  # parser$add_argument('--with-packet-err', dest='wpe', action='store_true')
  # parser$add_argument('--with-sent-msgs', dest='wsm', action='store_true')
  # parser$add_argument('--with-recv-msgs', dest='wrm', action='store_true')
	# parser$add_argument('--with-fwd-type', dest='wft', action='store_true')
	# parser$add_argument('--with-saved-rebroadcasts', dest='wsre', action='store_true')
	# parser$add_argument('--with-observables', dest='wobs', action='store_true')
  # parser$add_argument('--with-dataset-id', dest='wdsid', type='integer', default=0)
  p$parse_args()
}
args <- parseArgs()
routes <- read.table(args$routes_file)
names(routes) <- c('src', 'dst')

# only takes first execution as there are several configuration per INI file
dsf <- paste(
  args$dataset_location, '/', args$dataset_id, '_with_', args$hopsno, '_hops', '-#0', sep=''
)
if(args$wsrrl){
  sentMsgs <- getVectorDataset(dsf, 'packetSent:vector(packetBytes)')
  routeReqRecv <- getVectorDataset(dsf, 'arpRequestSent:vector(packetBytes)')
  routeReqAnsw <- getVectorDataset(dsf, 'arpReplySent:vector(packetBytes)')
  print(sentMsgs)
  print(routeReqRecv[ order(routeReqRecv$timestamp), ])
  print(routeReqAnsw[ order(routeReqAnsw$timestamp), ])
  # stop()
  succRrLatencies <- sapply(1:length(routes$src), function(r_i) {
    src <- routes$src[r_i] ; dst <- routes$dst[r_i]
    t <- r_i * args$send_interval
    sample <- sentMsgs[ sentMsgs$nodeId == src & sentMsgs$timestamp >= t, ]
    rrTa <- head(sample[ order(sample$timestamp), ], n=1)
    rrDstReply <- routeReqRecv[
      routeReqRecv$timestamp >= t &
      routeReqRecv$timestamp < (t + args$send_interval) & routeReqRecv$nodeId == dst ,
    ]
    rrTb <- head(rrDstReply[ order(rrDstReply$timestamp), ], n=1)
    rrSrcRecv <- routeReqAnsw[
      routeReqAnsw$timestamp >= t &
      routeReqAnsw$timestamp < (t + args$send_interval) & routeReqAnsw$nodeId == src,
    ]
    rrTc <- head(rrSrcRecv[ order(rrSrcRecv$timestamp), ], n=1)
    print("AAAA")
    print(rrTa)
    print("BBBB")
    print(rrTb)
    print("CCCC")
    print(rrTc)
    ifelse(
      length(rrTa$nodeId) == 1 & length(rrTb$nodeId) == 1 & length(rrTc$nodeId) == 1,
      rrTc$timestamp - rrTa$timestamp,
      NA
    )
  })
  print(succRrLatencies)
}
