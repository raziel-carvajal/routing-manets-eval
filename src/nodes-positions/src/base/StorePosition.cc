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

#include <StorePosition.h>

Register_Class(StorePosition);

void StorePosition::initialize(int stage) {
  ApplicationBase::initialize(stage);

  if (stage == INITSTAGE_APPLICATION_LAYER) {
    log("initialize in application layer");
    Coord position = mobilityModule->getCurrentPosition();
    emit(abscissa, position.x);
    emit(ordinate, position.y);
    selfEvent->setKind(START);
    scheduleAt(max(par("startTime").doubleValue(), simTime().dbl()), selfEvent);
    log("start event scheduled");
  }
}

void StorePosition::handleMessageWhenUp(cMessage* msg) {
  if (msg == selfEvent) {
    switch (msg->getKind()) {
      case START: {
        log("schedule event to store position");
        selfEvent->setKind(STORE_POSITION);
        scheduleAt(simTime() + par("storePosInterval").doubleValue(), selfEvent);
      }
        break;
      case STORE_POSITION: {
        Coord position = mobilityModule->getCurrentPosition();
        emit(abscissa, position.x);
        emit(ordinate, position.y);
        bool endOfExpe = simTime().dbl() >= par("stopTime").doubleValue()
            || simTime().dbl() + par("storePosInterval").doubleValue() > par("stopTime").doubleValue();
        if (endOfExpe) {
          selfEvent->setKind(STOP);
          scheduleAt(simTime() + 0.0001, selfEvent);
        } else {
          scheduleAt(simTime() + par("storePosInterval").doubleValue(), selfEvent);
        }
      }
        break;
      case STOP: {
        log("End of simulation");
        finish();
      }
        break;
      default:
        throw cRuntimeError("Invalid kind %d in self message", (int) selfEvent->getKind());
    }
  } else {
    throw cRuntimeError("Unrecognized message (%s)%s", msg->getClassName(), msg->getName());
  }
}

void StorePosition::finish() {
  ApplicationBase::finish();
}

bool StorePosition::handleNodeStart(IDoneCallback* doneCallback) {
  nodeId = getParentModule()->getFullName();
  log("handle node start...");
  abscissa = registerSignal("abscissa");
  ordinate = registerSignal("ordinate");
  mobilityModule = check_and_cast<IMobility*>(getContainingNode(this)->getSubmodule("mobility"));
  return true;
}

bool StorePosition::handleNodeShutdown(IDoneCallback* doneCallback) {
  if (selfEvent)
    cancelAndDelete(selfEvent);
  return true;
}

void StorePosition::handleNodeCrash() {
  if (selfEvent)
    cancelAndDelete(selfEvent);
}
