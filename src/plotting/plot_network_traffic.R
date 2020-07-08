library(argparse)

source("common_funcs.R")

parseArgs <- function() {
  p <- ArgumentParser(
    description=''
  )
  # mandatory arguments
  # p$add_argument('--datasets', nargs=3)
  # p$add_argument('--protocols', nargs=3, default=c('AODV', 'DSDV', 'ROVY'))

  p$add_argument('--datasets', nargs=2)
  p$add_argument('--protocols', nargs=2, default=c('AODV', 'ROVY'))

  p$parse_args()
}
args <- parseArgs()

sentMsgs <- lapply(1:length(args$protocols), function(i) {
  ds <- read.table(args$datasets[i], header=TRUE)
  names(ds) <- c('data', 'group')
  ds <- ds[ order(ds$group) ,]
  ds$group <- as.factor(ds$group)
  data.frame(
    data = ds$data,
    group = ds$group,
    protocol = rep(args$protocols[i], length(ds$data))
  )
})
sentMsgs <- do.call('rbind', sentMsgs)

temp <- subset(sentMsgs, group == '8')
sentMsgs <- data.frame(
  data=temp$data,
  protocol=temp$protocol
)

info <- data.frame(
  title="Cost of sending one message \n(distance btw nodes: 10 hops)",
  xlabel="Sent beacons/messages (#)",
  ylabel="CDF in % (nodes)"
)
plotDistribByProtocol(sentMsgs, info)
