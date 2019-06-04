import inet.physicallayer.idealradio.IdealRadioMedium;
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.common.lifecycle.LifecycleController;
import nodes_positions.base.Host;

network NETWORK_NAME
{
submodules:
  lifecycleController: LifecycleController;
  radioMedium: IdealRadioMedium;
  configurator: IPv4NetworkConfigurator;

// list of nodes
NODES_LIST
}
