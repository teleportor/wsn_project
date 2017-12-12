#include "Message.h"

configuration Project1AppC {}
implementation {
  components Project1C as App;
  components MainC;
  components new TimerMilliC() as Timer;
  components LedsC;
  components new SensirionSht11C() as SenseTH;
  components new HamamatsuS1087ParC() as SenseP;
  components ActiveMessageC;
  components SerialActiveMessageC;

  App.Boot -> MainC;
  App.Timer -> Timer;
  App.Leds -> LedsC;
  App.TempReader -> SenseTH.Temperature;
  App.HumiReader -> SenseTH.Humidity;
  App.PhotoReader -> SenseP;
  App.Packet -> ActiveMessageC;
  App.RadioSend -> ActiveMessageC.AMSend[AM_SENSOR_DATA_MSG];
  App.SerialSend -> SerialActiveMessageC.AMSend[AM_SENSOR_DATA_MSG];
  App.Receive -> ActiveMessageC.Receive[AM_SENSOR_DATA_MSG];
  App.RadioControl -> ActiveMessageC;
  App.SerialControl -> SerialActiveMessageC;
}
