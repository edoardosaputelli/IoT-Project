
#ifndef KEEP_YOUR_DISTANCE_H
#define KEEP_YOUR_DISTANCE_H

//struct of the message

//couple timestamp-sender_id is unique in the interaction between the motes
typedef nx_struct keep_your_distance_msg {
  nx_uint16_t timestamp;
  nx_uint16_t sender_id;
} keep_your_distance_msg_t;

enum {
  AM_RADIO_COUNT_MSG = 6, //type of the message = 6
};

#endif
