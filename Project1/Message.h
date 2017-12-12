#ifndef MESSAGE_H
#define MESSAGE_H

#define TOS_NODE_ID_SERIAL 10032
#define TOS_NODE_ID_0      19
#define TOS_NODE_ID_1      20
#define TOS_NODE_ID_2      21
#define TOS_NODE_ID_NVALID 10031

#define TIMER_PERIOD 100

typedef nx_struct Sensor_Data_Msg {
  nx_uint16_t node_id;
  nx_uint16_t seq_id;
  nx_uint16_t temperature;
  nx_uint16_t humidity;
  nx_uint16_t photo;
} Sensor_Data_Msg;

enum {AM_SENSOR_DATA_MSG = 6};

#endif
