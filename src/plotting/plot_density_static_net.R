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
  title="Nodes degree in dense and sparse scenarios",
  xlabel="Nodes degree",
  ylabel="CDF of nodes degree (%)"
)

ds <- read.csv(args$dataset, header=TRUE)
ds$density <- as.factor(ds$density)

plotCDFset(ds, info)
