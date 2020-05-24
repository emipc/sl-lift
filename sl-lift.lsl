integer _CHANNEL = 42;
list _FLOORS; 
list _FLOORSNAME;
vector _TARGET;
float _VEL = 1.9;

default {
  state_entry() {
    llOwnerSay("Commands:");
    llOwnerSay("\"add\" \t- Add floor (using channel " + (string)_CHANNEL+")");
    llOwnerSay("\"start\"\t- Start lift");
    llSetStatus(STATUS_PHYSICS,TRUE);
    llSetStatus(STATUS_ROTATE_X|STATUS_ROTATE_Y|STATUS_ROTATE_Z,FALSE);
    state setup;
  }
}

state setup {
  state_entry() {
    llListen(_CHANNEL, "", llGetOwner(), "");
  }

  listen(integer channel, string name, key id, string message) {
    if(message == "add") {
      vector pos = llGetPos();
      pos.z = pos.z;
      _FLOORS = (_FLOORS=[]) + _FLOORS + pos;
      _FLOORSNAME = (_FLOORSNAME=[]) + _FLOORSNAME + ("Floor " + (string)llGetListLength(_FLOORSNAME));
      llOwnerSay("New floor added at " + (string)pos+" position");
    }
    else if (message == "start") {
      if(llGetListLength(_FLOORS)<2)   {
        llOwnerSay("Two floors are needed at least");
      }
      else {
        llOwnerSay("Ok, initializing...");
        state wait;
      }
    }
    else if (message == "reset") {
      _FLOORS = [];
      llOwnerSay("List of floors restarted");
    }
  }
}

state wait {
  state_entry() {
    llListen(_CHANNEL, "", NULL_KEY, ""); 
    llOwnerSay("Waiting...");
  }

  listen(integer channel, string name, key id, string message) {
    integer floorNumber = llSubStringIndex(message, " ");
    string floorNum = llGetSubString(message, floorNumber + 1, -1);
    _TARGET = llList2Vector(_FLOORS, (integer)floorNum);
    llOwnerSay("Going to " + (string)_TARGET);
    state move;
  }

  touch_start(integer num_detected) {
    llSensor("", llDetectedKey(0), AGENT, 2.5, PI);
  }

  sensor(integer total_number) {
    llDialog(llDetectedKey(0), "Where to?", _FLOORSNAME, _CHANNEL);
  }

  no_sensor() {
    llSay(0, "You are not inside the elevator!");   
  }
}

state move {
  state_entry() {
    llSay(41, ""); // call lift door
    llMoveToTarget(_TARGET, _VEL);
    llSetTimerEvent(_VEL * 5);
  }

  timer() {
    llSetTimerEvent(0);
    vector pos = llGetPos();
    pos.z = _TARGET.z;
    llSetStatus(STATUS_PHYSICS,FALSE);
    llSetPos(pos);
    llSetStatus(STATUS_PHYSICS,TRUE);
    llOwnerSay("\nWe've arrived!\n");
    state wait;
  }
}
