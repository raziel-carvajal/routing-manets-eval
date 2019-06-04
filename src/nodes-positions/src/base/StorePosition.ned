//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package nodes_positions.base;

import inet.applications.contract.IUDPApp;

simple StorePosition like IUDPApp
{
    parameters:
        double storePosInterval @unit(s) = default(0.5s);
        double startTime @unit(s) = default(0s);
        double stopTime @unit(s) = default(300s);

        @signal[abscissa](type=double);
        @statistic[abscissa](source=abscissa; record=vector; interpolationmode=none);
        @signal[ordinate](type=double);
        @statistic[ordinate](source=ordinate; record=vector; interpolationmode=none);

    gates:
        input udpIn @labels(UDPControlInfo/up);
        output udpOut @labels(UDPControlInfo/down);
}
