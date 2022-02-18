#include "printf.h"
#include "Timer.h"
#include "KeepYourDistance.h"
#define NUM_OF_MOTES 7

module KeepYourDistanceC @safe() {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
  }
}


implementation {

  message_t packet;

  bool locked;
  uint16_t timestamp = 0;
  
  //array to store the last timestamps received from each other mote
  uint16_t action_timestamps[NUM_OF_MOTES];
  //array to keep the number of consecutive messages received from each other mote
  int num_of_msg[NUM_OF_MOTES];
  
  //arrays are automatically initialized with all the elements as 0
  
  event void Boot.booted() {
    call AMControl.start();
    
    printf("DEBUG: start mote %d.\n", TOS_NODE_ID);
    printfflush();
  }
  
  
  event void AMControl.startDone(error_t err) {
  
    if (err == SUCCESS) {
      //starting the timer every 500 ms
      call MilliTimer.startPeriodic(500);
    }
    
    else {
      call AMControl.start();
    }
    
  }
  
  event void AMControl.stopDone(error_t err) {
  }
  
  event void MilliTimer.fired() {
    printf("DEBUG: mote %d: timer fired.\n", TOS_NODE_ID);
    printfflush();
    
    timestamp++;
    
    if (locked) {
      return;
    }
    
    else {
    
      keep_your_distance_msg_t* kdm = (keep_your_distance_msg_t*)call Packet.getPayload(&packet, sizeof(keep_your_distance_msg_t));
      
      if (kdm == NULL) {
		return;
      }

	  //we fill the values of our message with the value of our timestamp and the value of the mote id
      kdm->timestamp = timestamp;
      kdm->sender_id = TOS_NODE_ID;
      

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(keep_your_distance_msg_t)) == SUCCESS) {
		printf("DEBUG: mote %d: packet sent with timestamp %d.\n", TOS_NODE_ID, timestamp);
		printfflush();
		
		locked = TRUE;
      }
    }
  }
  
  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
   
    if (len != sizeof(keep_your_distance_msg_t))
    	return bufPtr;
    	
    else {
      
      keep_your_distance_msg_t* kdm = (keep_your_distance_msg_t*)payload;
      
      printf("DEBUG: mote %d: packet received from mote %d with timestamp %d.\n", TOS_NODE_ID, kdm->sender_id, kdm->timestamp);
      printfflush();
      
      //evaluating the case of the first message of the 10 consecutives from a certain mote
      if( num_of_msg[kdm->sender_id-1] == 0 || num_of_msg[kdm->sender_id-1] == 10 ){
      	 action_timestamps[kdm->sender_id-1] = kdm->timestamp;
      	 num_of_msg[kdm->sender_id-1] = 1;
      	 
      	 printf("DEBUG: mote %d: num of msg from mote %d = %d (tsp %d). [reset case] \n", TOS_NODE_ID, kdm->sender_id, num_of_msg[kdm->sender_id-1], action_timestamps[kdm->sender_id-1]);
      	 printfflush();
      }
      //evaluating the case of non-consecutive timestamps
      else if (kdm->timestamp != action_timestamps[kdm->sender_id-1] + 1){
      	num_of_msg[kdm->sender_id-1] = 1;
      	action_timestamps[kdm->sender_id-1] = kdm->timestamp;
      	
      	printf("DEBUG: mote %d: num of msg from mote %d = %d (tsp %d). [non-consecutive case] \n", TOS_NODE_ID, kdm->sender_id, num_of_msg[kdm->sender_id-1], action_timestamps[kdm->sender_id-1]);
      	printfflush();
      }
      //standard case: consecutive timestamps
      else {
      	num_of_msg[kdm->sender_id-1] = num_of_msg[kdm->sender_id-1] + 1;
      	action_timestamps[kdm->sender_id-1] = kdm->timestamp;
      	
      	printf("DEBUG: mote %d: num of msg from mote %d = %d (tsp %d). [consecutive case] \n", TOS_NODE_ID, kdm->sender_id, num_of_msg[kdm->sender_id-1], action_timestamps[kdm->sender_id-1]);
      	printfflush();
      }
      
      
      //checking if we received 10 consecutive messages after having incremented the counter
      if( num_of_msg[kdm->sender_id-1] == 10 ){
      	printf("ALERT FROM MOTE %d: I'm close to mote %d!\n", TOS_NODE_ID, kdm->sender_id);
      	printfflush();
      }
      
      
      
      return bufPtr;
    }
  }
  
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }
  

}
