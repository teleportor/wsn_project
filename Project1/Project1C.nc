#include "Message.h"

module Project1C {
  uses interface Boot;
  uses interface Timer<TMilli>;
  uses interface Leds;
  uses interface Read<uint16_t> as TempReader;
  uses interface Read<uint16_t> as HumiReader;
  uses interface Read<uint16_t> as PhotoReader;
  uses interface Packet;
  uses interface AMSend as RadioSend;
  uses interface AMSend as SerialSend;
  uses interface Receive;
  uses interface SplitControl as RadioControl;
  uses interface SplitControl as SerialControl;
}

implementation {
  uint16_t next_node_id;
  uint16_t counter;
  Sensor_Data_Msg* payload_get;
  bool reading;
  uint8_t readFlag;

  bool busy;
  bool isForward;
  message_t pkt;

  event void Boot.booted() {
    switch (TOS_NODE_ID) {
    case TOS_NODE_ID_0:
      next_node_id = TOS_NODE_ID_SERIAL;
      break;
    case TOS_NODE_ID_1:
      next_node_id = TOS_NODE_ID_0;
      break;
    case TOS_NODE_ID_2:
      next_node_id = TOS_NODE_ID_1;
      break;
    default:
      next_node_id = TOS_NODE_ID_NVALID;
      break;
    }
    counter = 0;
    reading = FALSE;
    busy = FALSE;
    call RadioControl.start();
    call SerialControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      if (TOS_NODE_ID != TOS_NODE_ID_0) {
        call Timer.startPeriodic(TIMER_PERIOD);
      }
    }
    else {
      call RadioControl.start();
    }
  }
  event void RadioControl.stopDone(error_t err) {}

  event void SerialControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call SerialControl.start();
    }
  }
  event void SerialControl.stopDone(error_t err) {}

  event void Timer.fired() {
    counter++;
    if (reading) {
      call Leds.led2Toggle();
      return;
    }
    payload_get = (Sensor_Data_Msg*)(call Packet.getPayload(&pkt, sizeof(Sensor_Data_Msg)));
    if (payload_get == NULL) {
      call Leds.led2Toggle();
      return;
    }
    payload_get->node_id = TOS_NODE_ID;
    payload_get->seq_id = counter;
    reading = TRUE;
    readFlag = 0;
    call Leds.led0On();
call Leds.led1On();
    call TempReader.read();
    call HumiReader.read();
    call PhotoReader.read();
  }

  event void TempReader.readDone(error_t result, uint16_t val) {
    if (result == SUCCESS && busy == FALSE) {
call Leds.led1Off();
      payload_get->temperature = val;
      readFlag++;
      if (readFlag == 3) {
        if (TOS_NODE_ID == TOS_NODE_ID_0) {
          if (call SerialSend.send(next_node_id, &pkt, sizeof(Sensor_Data_Msg)) == SUCCESS) {
            busy = TRUE;
            isForward = FALSE;
          }
        }
        else {
          if (call RadioSend.send(next_node_id, &pkt, sizeof(Sensor_Data_Msg)) == SUCCESS) {
call Leds.led2On();
            busy = TRUE;
            isForward = FALSE;
          }
        }
      }
    }
    else {
      call Leds.led0Off();
      call Leds.led2Toggle();
    }
  }
  event void HumiReader.readDone(error_t result, uint16_t val) {
    if (result == SUCCESS && busy == FALSE) {
      payload_get->humidity = val;
      readFlag++;
      if (readFlag == 3) {
        if (TOS_NODE_ID == TOS_NODE_ID_0) {
          if (call SerialSend.send(next_node_id, &pkt, sizeof(Sensor_Data_Msg)) == SUCCESS) {
            busy = TRUE;
            isForward = FALSE;
          }
        }
        else {
          if (call RadioSend.send(next_node_id, &pkt, sizeof(Sensor_Data_Msg)) == SUCCESS) {
call Leds.led2On();
            busy = TRUE;
            isForward = FALSE;
          }
        }
      }
    }
    else {
      call Leds.led0Off();
      call Leds.led2Toggle();
    }
  }
  event void PhotoReader.readDone(error_t result, uint16_t val) {
    if (result == SUCCESS && busy == FALSE) {
      payload_get->photo = val;
      readFlag++;
      if (readFlag == 3) {
        if (TOS_NODE_ID == TOS_NODE_ID_0) {
          if (call SerialSend.send(next_node_id, &pkt, sizeof(Sensor_Data_Msg)) == SUCCESS) {
            busy = TRUE;
            isForward = FALSE;
          }
        }
        else {
          if (call RadioSend.send(next_node_id, &pkt, sizeof(Sensor_Data_Msg)) == SUCCESS) {
call Leds.led2On();
            busy = TRUE;
            isForward = FALSE;
          }
        }
      }
    }
    else {
      call Leds.led0Off();
      call Leds.led2Toggle();
    }
  }

  event void RadioSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      if (isForward) {
        call Leds.led1Off();
      }
      else {
call Leds.led2Off();
        reading = FALSE;
        call Leds.led0Off();
      }
    }
  }
  event void SerialSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      if (isForward) {
        call Leds.led1Off();
      }
      else {
        reading = FALSE;
        call Leds.led0Off();
      }
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    Sensor_Data_Msg* rcvPayload;
    Sensor_Data_Msg* sndPayload;

    call Leds.led1On();
    if (len != sizeof(Sensor_Data_Msg)) {
      call Leds.led1Off();
      call Leds.led2Toggle();
      return msg;
    }
    rcvPayload = (Sensor_Data_Msg*)payload;
    sndPayload = (Sensor_Data_Msg*)(call Packet.getPayload(&pkt, sizeof(Sensor_Data_Msg)));
    if (sndPayload == NULL) {
      call Leds.led1Off();
      call Leds.led2Toggle();
      return msg;
    }
    sndPayload->node_id = rcvPayload->node_id;
    sndPayload->seq_id = rcvPayload->seq_id;
    sndPayload->temperature = rcvPayload->temperature;
    sndPayload->humidity = rcvPayload->humidity;
    sndPayload->photo = rcvPayload->photo;
    if (TOS_NODE_ID == TOS_NODE_ID_0) {
      if (call SerialSend.send(next_node_id, &pkt, sizeof(Sensor_Data_Msg)) == SUCCESS) {
        busy = TRUE;
        isForward = TRUE;
      }
    }
    else {
      if (call RadioSend.send(next_node_id, &pkt, sizeof(Sensor_Data_Msg)) == SUCCESS) {
        busy = TRUE;
        isForward = TRUE;
      }
    }
    return msg;
  }
}
