library(argparse)

source("common_funcs.R")

parseArgs <- function() {
  p <- ArgumentParser(
    description='Plot several metrics to evaluate the performance of routing algorithms.'
  )
  # mandatory arguments
  p$add_argument('dataset', type='character')
  p$add_argument('protocol', type='character')
  # options
  p$add_argument('--with-arp-latency', dest='wal', action='store_true')
  p$add_argument('--with-msg-latency', dest='wmela', action='store_true')
  p$add_argument('--with-msg-loss', dest='wmelo', action='store_true')

  p$parse_args()
}
args <- parseArgs()

ds <- read.table(args$dataset, header=TRUE)

if (args$wal) {
  names(ds) <- c('data', 'group')
  ds <- ds[ order(ds$group) ,]
  ds$group <- as.factor(ds$group)
  # arp <- mas-trece
  ds$data <- ds$data + 13

  info <- data.frame(
    title=paste("ARP latency in", args$protocol),
    xlabel="Hops # between source and destination",
    ylabel="Latency (ms)",
    ylim=60
  )

  plotDistribGroups(ds, info, withBoxplot=TRUE, withDensity=FALSE)
}

if (args$wmela) {
  names(ds) <- c('data', 'group')
  ds <- ds[ order(ds$group) ,]
  ds$group <- as.factor(ds$group)
  # Mretardo <- por-10
  ds$data <- ds$data * 10

  info <- data.frame(
    title=paste("Message latency in", args$protocol),
    xlabel="Hops # between source and destination",
    ylabel="Latency (ms)",
    ylim=3000
  )
  plotDistribGroups(ds, info, withBoxplot=TRUE, withDensity=FALSE)
}

if (args$wmelo) {
  names(ds) <- c('sent', 'received', 'hops')

  ds <- ds[ order(ds$hops), ]
  ds <- lapply(unique( c(ds$hops) ), function(h){
    temp <- ds[ ds$hops == h, ]
    data.frame(
      data = sum(temp$received) / sum(temp$sent) * 100,
      group = as.factor( c(h) )
    )
  })
  ds <- do.call("rbind", ds)

  info <- data.frame(
    title=paste("Throughput in", args$protocol),
    xlabel="Hops # between source and destination",
    ylabel="Message delivery fraction (%)",
    ylim=100
  )
  plotColumns(ds, info, withDensity=FALSE)
}
