#!/usr/bin/python
import argparse
import networkx as nx
import utils_for_traces as utils
from pymobility.models.mobility import random_waypoint
from sys import exit


def getArgs():
  p = argparse.ArgumentParser(
      description='Creates a mobility trace (in Bonmotion format) of an \
      ad-hoc network where nodes move following the random waypoint \
      (mobility) model. Nodes change their position every T seconds, this \
      behavior results in having a new network topology each T seconds. All \
      topologies are connected, i. e. on each topology there exist (at least) \
      a path between any pair of nodes.')
  p.add_argument(
      '--cma-height', dest='area_l', type=int, default=50,
      help='Length of communication area.')
  p.add_argument(
      '--cma-width', dest='area_w', type=int, default=50,
      help='Width of communication area.')
  p.add_argument(
      '--nodes', dest='nodes', type=int, default=80,
      help='Number of nodes in the network.')
  p.add_argument(
      '--transmission-range', dest='tx', type=int, default=10,
      help='node transmission range')
  p.add_argument(
      '--walks', dest='walks', type=int, default=1,
      help='Number of network topologies in this trace.')
  return p.parse_args()


class CommunicationArea(object):
  def __init__(self, length, width, nodes):
    self.length = length
    self.width = width
    self.nodes = nodes
    self.mobModel = random_waypoint(self.nodes, (self.length, self.width))

  def updateNodePositions(self):
    self.positions = next(self.mobModel)


ARGS = getArgs()
HISTORY = { i: [] for i in range(ARGS.nodes) }
NBRS, ROUTING_INFO = {}, {}
CMA = CommunicationArea(ARGS.area_l, ARGS.area_w, ARGS.nodes)
G = nx.Graph()

if __name__ == '__main__':
  traceNo = 0
  while traceNo != ARGS.walks:
    CMA.updateNodePositions()
    # update vertex/edges of graph with the latest set of positions
    utils.updateGraph(G, CMA.positions, ARGS.tx)
    t = 0
    print 'Looking for connected topology No ' + str(traceNo) + '...'
    while not nx.is_connected(G):
      CMA.updateNodePositions()
      utils.updateGraph(G, CMA.positions, ARGS.tx)
      t = t + 1
      print '\ttry #' + str(t) + ' ...'
    print 'Topology #' + str(traceNo) + ' is connected!'
    # update dictionary of neighbors
    NBRS[traceNo] = [len(G.neighbors(n)) for n in range(ARGS.nodes)]
    # plot snapshots of network
    utils.plotSnapshot(G, traceNo, CMA.positions, (ARGS.area_l, ARGS.area_w))
    # update HISTORY of positions
    utils.updateHistory(HISTORY, CMA.positions)
    # add information of routes in G
    ROUTING_INFO[traceNo] = nx.all_pairs_dijkstra_path(G)
    traceNo = traceNo + 1
  # store trace of possition in BonnMotion format
  utils.storeTrace('trace.bm', HISTORY)
  utils.storeRoutingInfo('routingInformation.csv', ROUTING_INFO)
  utils.storeNeigsCardinality('neighborsCardinality.csv', NBRS, ARGS.nodes)
  utils.makeAndStoreInitialPosition('scenario.xml', HISTORY)
