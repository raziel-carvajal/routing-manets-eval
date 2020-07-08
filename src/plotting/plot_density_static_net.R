library(argparse)

source("common_funcs.R")

parseArgs <- function() {
  p <- ArgumentParser(
    description='Plot distribution of density, for a static network, as a set of CDFs'
  )
  # mandatory arguments
  p$add_argument('dataset', type='character')

  p$parse_args()
}
args <- parseArgs()

info <- data.frame(
  title="Nodes density",
  xlabel="# of neighboring peers",
  ylabel="CDF in % (nodes)"
)

ds <- read.csv(args$dataset, header=TRUE)
ds$density <- as.factor(ds$density)

plotCDFset(data.frame(data=ds$data, Scenario=ds$density), info)
