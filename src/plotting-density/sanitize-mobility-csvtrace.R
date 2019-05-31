library(argparse)

getArgs <- function() {
  p <- ArgumentParser(description =
		'Supress negative values of nodes positions and turn a CSV dataset into\\n\\
		a BonMotion file trace.\\n\\
		Headers in CSV dataset must be named as follows: id (node ID), x (abscissa), y (ordinate).'
	)
  p$add_argument('dataset', type = 'character', help = 'Location and name of dataset.')
	p$add_argument('--show-cardinality', dest='wcard', action='store_true')
  p$parse_args()
}

turnIntoPositive <- function(v) {
	if (length(v) != length(v[v>0])) {
		v <- v + abs(min(v))
	}
	v
}

turnIntoBonnMotionFormat <- function(ds, ids) {
	# keep same number of samples per node
	minLen <- min(
		sapply(ids, function(iD) {
			length(subset(ds, id == iD)$id)
		})
	)
	l <- lapply(ids, function(iD) {
		head(subset(ds, id == iD), n = minLen)
	})
	subDs <- do.call('rbind', l)
	l <- lapply(1:length(ids), function(i) {
		subsPerId <- subset(subDs, id == ids[i])
		posAtX <- turnIntoPositive(subsPerId$x)
		posAtY <- turnIntoPositive(subsPerId$y)
		merged <- lapply(1:length(subsPerId$id), function(j) {
			# bonn motion format: t_0 x_0 y_0 t_1 x_1 y_1 ...
			c(j - 1, posAtX[j], posAtY[j])
		})
		unlist(merged)
	})
	# one line per node
	do.call('rbind', l)
}

# ___MAIN___
args <- getArgs()
if( !file.exists(args$dataset) ) {
	print('CSV Dataset do not exist.') ; stop()
}
ds <- read.csv(args$dataset)
ids <- unique(ds$id)
if(args$wcard) {
	card<- sapply(1:length(ids), function(i) {
		length(subset(ds, id == ids[i])$id)
	})
	df <- data.frame(id = ids, size = card)
	df <- df[order(df$size), ]
	print('Cardinality of dataset') ; print(df) ; print(df$id)
	stop()
}
ignoredFile <- paste(dirname(args$dataset), 'ignored-values', sep = '/')
if( !file.exists(ignoredFile) ) {
	print('List of ignored samples is empty.') ; stop()
}
ig <- scan(ignoredFile, what = integer())
ids <- ids[ !(ids %in% ig) ]
trace <- turnIntoBonnMotionFormat(ds, ids)
# save table
traceName <- paste(dirname(args$dataset), 'mobility-trace.bm', sep = '/')
write.table(trace, file = traceName, row.names = F, col.names = F)
print('END')
