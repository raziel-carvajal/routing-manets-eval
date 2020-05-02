require(omnetpp)

getNodeId <- function(s) {
  n <- strsplit(
    # strsplit returns a list
    strsplit(toString(s), '\\[')[[1]][2], '\\]'
  )[[1]][1]
  as.numeric(n)
}

# scalars
#   - rcvdPkFromLl:count
getScalarDataset <- function(omnetDS, scalar) {
  scalar <- paste('name("', scalar, '")', sep='')
  omnetDS <- paste(omnetDS, '.sca', sep = '')
  ds <- loadDataset(omnetDS, add(select=scalar))
  # nodes will be a vector of integers (nodes IDs)
  nodes <- sapply(ds$scalars$module, getNodeId, USE.NAMES=F)
  data.frame(
    nodeId = nodes,
    value = ds$scalars$value)
}

getVectorDataset <- function(omnetDS, vector) {
  vector <- paste('name("', vector, '")', sep='')
  omnetDS <- paste(omnetDS, '.vec', sep='')
  ds <- loadVectors(loadDataset(omnetDS, add(select=vector)), NULL)
  temp <- data.frame(
    dsKey = ds$vectors$resultkey,
    nodeId = sapply(ds$vectors$module, getNodeId, USE.NAMES=F)
  )
  nodeIds <- sapply(ds$vectordata$resultkey, function(key) {
    temp[ temp$dsKey == key, ]$nodeId
  })
  data.frame(
    nodeId = nodeIds,
    timestamp = ds$vectordata$x,
    value = ds$vectordata$y
  )
}

getSrcDstPairs <- function(ds, hopsBtwPairs, pairsNo, netId) {
  # get sample of interest
  dsSample <- ds[ ds$topologyID == netId, ]
  dsSample <- dsSample[ dsSample$hopsNo == hopsBtwPairs, ]
  dsSample <- dsSample[ order(dsSample$src), ]
  # for every pair (a, b) take rid of permutation (b, a)
  idsAdd <- unique(dsSample$src + dsSample$dst)
  temp <- rep(FALSE, length(idsAdd))
  names(temp) <- idsAdd
  print(temp)
  indx <- sapply(1:length(dsSample$src), function(i) {
    key <- toString(dsSample[i, ]$src + dsSample[i, ]$dst)
    r <- ifelse(temp[key], NA, i)
    temp[key] <- TRUE
    r
  })
  # get the requested number of pairs
  indx <- head(indx[ !is.na(indx) ], n=pairsNo)
  dsSample <- dsSample[ indx, ]
  data.frame(
    src = dsSample$src,
    dst = dsSample$dst,
    hopsNo = paste('hops', dsSample$hopsNo, sep='='),
    path = dsSample$path
  )
}
