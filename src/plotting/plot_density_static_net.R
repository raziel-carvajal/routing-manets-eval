library(argparse)

source("common_funcs.R")

parseArgs <- function() {
  p <- ArgumentParser(
    description='Plot distribution of density, for a static network, as a set of CDFs'
  )
  # mandatory arguments
  p$add_argument('dataset', type='character')
  p$add_argument('plot_name', type='character')

  p$parse_args()
}
args <- parseArgs()

info <- data.frame(
  title="title",
  xlabel="# of neighbors per node",
  ylabel="CDF in % (nodes)"
)

ds <- read.csv(args$dataset, header=TRUE)
typ<- lapply(names(ds), function(col) {
  rep(col, length(ds[ , col]))
})

df <- data.frame(
  data = unlist(ds, use.names=FALSE),
  Density= unlist(typ, use.names=FALSE)
)

plotCDFset(df, info)
