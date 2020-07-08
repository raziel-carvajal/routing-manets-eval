library(argparse)

source("common_funcs.R")

parseArgs <- function() {
  p <- ArgumentParser(
    description='Plot several metrics to evaluate the performance of routing algorithms.'
  )
  # mandatory arguments
  p$add_argument('high_density_dataset', type='character')
  p$add_argument('low_density_dataset', type='character')
  p$add_argument('protocol', type='character')
  # options
  p$add_argument('--with-arp-latency', dest='wal', action='store_true')
  p$add_argument('--with-route-discovery-latency', dest='wrdl', action='store_true')
  p$add_argument('--with-msg-latency', dest='wmela', action='store_true')
  p$add_argument('--with-msg-loss', dest='wmelo', action='store_true')

  p$parse_args()
}

args <- parseArgs()
sparseDs <- read.table(args$low_density_dataset, header=TRUE)
denseDs  <- read.table(args$high_density_dataset, header=TRUE)
names(sparseDs) <- c('data', 'group') ; names(denseDs) <- c('data', 'group')

df <- data.frame(
  data=c( sparseDs$data, denseDs$data ),
  group=as.factor( c( sparseDs$group, denseDs$group ) ),
  Scenario=c( rep('sparse', length(sparseDs$data)), rep('dense', length(denseDs$data)) )
)
df <- df[ order(df$group) ,]

if (args$wal) {
  info <- data.frame(
    title=paste("Route discovery latency ", args$protocol),
    xlabel="Hops # between source and destination",
    ylabel="Latency (ms)",
    ylim=60
  )
  plotDistribGroups(df, info, withBoxplot=TRUE)
}

if (args$wmela) {
  info <- data.frame(
    title=paste("Message latency ", args$protocol),
    xlabel="Hops # between source and destination",
    ylabel="Latency (ms)",
    ylim=3000
  )
  plotDistribGroups(df, info, withBoxplot=TRUE)
}

if (args$wmelo) {
  sparseDs <- read.table(args$low_density_dataset, header=TRUE)
  denseDs  <- read.table(args$high_density_dataset, header=TRUE)
  names(sparseDs) <- c('sent', 'received', 'hops')
  names(denseDs) <- c('sent', 'received', 'hops')

  sparseDs <- sparseDs[ order(sparseDs$hops), ]
  denseDs <- denseDs[ order(denseDs$hops), ]

  sparse <- lapply(unique( c(sparseDs$hops) ), function(h){
    temp <- sparseDs[ sparseDs$hops == h, ]
    data.frame(
      data = sum(temp$received) / sum(temp$sent) * 100,
      group = as.factor( c(h) ),
      Scenario = as.factor( c("sparse") )
    )
  })
  sparse <- do.call("rbind", sparse)

  dense <- lapply(unique( c(denseDs$hops) ), function(h){
    temp <- denseDs[ denseDs$hops == h, ]
    data.frame(
      data = sum(temp$received) / sum(temp$sent) * 100,
      group = as.factor( c(h) ),
      Scenario = as.factor( c("dense") )
    )
  })
  dense <- do.call("rbind", dense)

  df <- do.call("rbind", list(dense, sparse))

  info <- data.frame(
    title=paste("Throughput ", args$protocol),
    xlabel="Hops # between source and destination",
    ylabel="Message delivery fraction (%)",
    ylim=100
  )
  plotColumns(df, info)
}

if (args$wrdl) {
  # info <- data.frame(
  #   title=paste(
  #     "Route discovery latency in", args$protocol, "(reactive) protocol",
  #     "\n(the number of hops between source and destination varies in the range [4, 10]) "
  #   ),
  #   xlabel="Latency (ms)",
  #   ylabel="CDF of route discovery latency (%)"
  # )
  # plotCDFset(df, info)
  info <- data.frame(
    title=paste(
      "Route discovery latency in", args$protocol, "protocol",
      "\n(the number of hops between source and destination varies in the range [4, 10]) "
    ),
    xlabel="Number of hops",
    ylabel="Latency (ms)"
  )
  plotDistribGroups(df, info)
}
