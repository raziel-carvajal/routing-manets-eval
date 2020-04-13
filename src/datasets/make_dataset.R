require(argparse)

source('utils.R')

parseArgs <- function() {
  p <- ArgumentParser(
    description='Gets several dataset with the performance of routing protocols
    for MANETs.'
  )
  # metadata of data set
  p$add_argument('dataset', type='character')
  p$add_argument('location', type='character')
  p$add_argument('protocol', type='character')
  # experimental settings
  p$add_argument('--with-mac-traffic', dest='wmt', action='store_true')
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

dsFile <- paste(args$location, args$dataset, sep='/')

if(args$wmt){
  getScalarDataset(dsFile, 'rcvdPkFromLl:count')
}
