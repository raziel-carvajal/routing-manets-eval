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

#ifndef STOREPOSITION_H_
#define STOREPOSITION_H_

#include <inet/common/INETDefs.h>
#include <inet/common/geometry/common/Coord.h>
#include <inet/common/ModuleAccess.h>
#include <inet/mobility/contract/IMobility.h>
#include <inet/applications/base/ApplicationBase.h>

using namespace std;
using namespace inet;

class StorePosition : public ApplicationBase {
  protected:
    enum Events {
      START, STOP, STORE_POSITION
    };

    simsignal_t abscissa;
    simsignal_t ordinate;

    string nodeId;

    cMessage* selfEvent = new cMessage("selfEvent");

    IMobility* mobilityModule;

  protected:
    virtual int numInitStages() const override {
      return NUM_INIT_STAGES;
    }
    virtual void initialize(int stage) override;
    virtual void handleMessageWhenUp(cMessage *msg) override;
    virtual void finish() override;

    virtual bool handleNodeStart(IDoneCallback *doneCallback) override;
    virtual bool handleNodeShutdown(IDoneCallback *doneCallback) override;
    virtual void handleNodeCrash() override;

  public:
    StorePosition() {
    }
    ~StorePosition() {
    }
    void log(string msg) {
      cout << "[" << nodeId << ", " << simTime() << "] - " << msg << endl;
    }
};

#endif /* STOREPOSITION_H_ */
