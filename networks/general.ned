package NAMESPACE
import inet.common.scenario.ScenarioManager;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.networklayer.ipv4.RoutingTableRecorder;
import inet.node.inet.ManetRouter;
import inet.physicallayer.unitdisk.UnitDiskRadioMedium;

network NETWORK_NAME {
  parameters:
    int numHosts;

  submodules:
    host[numHosts]: ManetRouter;
    radioMedium: UnitDiskRadioMedium;
    routingTableRecorder: RoutingTableRecorder;

    configurator: Ipv4NetworkConfigurator {
      parameters:
        config = xml(
        "<config><interface hosts='*' address='145.236.x.x' netmask='255.255.0.0'/></config>");
    }
    scenarioManager: ScenarioManager;
    connections allowunconnected:
}
